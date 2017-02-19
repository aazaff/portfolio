
# Custom functions are camelCase. Arrays, parameters, and arguments are PascalCase
# Dependency functions are not embedded in master functions, and are marked with the flag dependency in the documentation
# []-notation is used wherever possible, and $-notation is avoided.

######################################### Load Required Libraries ###########################################
# Install libraries if necessary and load them into the environment
if (suppressWarnings(require("RCurl"))==FALSE) {
    install.packages("RCurl",repos="http://cran.cnr.berkeley.edu/");
    library("RCurl");
    }

if (suppressWarnings(require("RJSONIO"))==FALSE) {
    install.packages("RJSONIO",repos="http://cran.cnr.berkeley.edu/");
    library("RJSONIO");
    }

if (suppressWarnings(require("stringdist"))==FALSE) {
    install.packages("stringdist",repos="http://cran.cnr.berkeley.edu/");
    library("stringdist");
    }

if (suppressWarnings(require("doParallel"))==FALSE) {
    install.packages("doParallel",repos="http://cran.cnr.berkeley.edu/");
    library("doParallel");
    }


if (suppressWarnings(require("plyr"))==FALSE) {
    install.packages("plyr",repos="http://cran.cnr.berkeley.edu/");
    library("plyr");
    }

# Start a cluster for multicore, 3 by default 
# Can make it higher if passed as a command line argument through terminal - e.g., RScript ePANDDA.R 7
CommandArgument<-commandArgs(TRUE)
if (length(CommandArgument)==0) {
    Cluster<-makeCluster(3)
    } else {
    Cluster<-makeCluster(as.numeric(CommandArgument[1]))
    }

#############################################################################################################
######################################### DATA DOWNLOAD, EPANDDA ############################################
#############################################################################################################
# No functions at this time.

############################################ Download Datasets from API  ####################################
# Increase the timeout option to allow for larger data downloads
options(timeout=300)

# Download references from the Paleobiology Database through the API
GotURL<-RCurl::getURL("https://paleobiodb.org/data1.2/colls/refs.csv?all_records")
PBDBRefs<-read.csv(text=GotURL,header=TRUE)

# Change data types of PBDBRefs to appropriate types
PBDBRefs[,"pbdb_no"]<-as.numeric(as.character(PBDBRefs[,"pbdb_no"]))
PBDBRefs[,"pbdb_author"]<-as.character(PBDBRefs[,"pbdb_author"])
PBDBRefs[,"pbdb_year"]<-as.numeric(as.character(PBDBRefs[,"pbdb_year"]))
PBDBRefs[,"pbdb_title"]<-as.character(PBDBRefs[,"pbdb_title"])
PBDBRefs[,"pbdb_pubtitle"]<-as.character(PBDBRefs[,"pbdb_pubtitle"])

# Remove PBDB Refs with no title
PBDBRefs<-subset(PBDBRefs,nchar(PBDBRefs[,"pbdb_title"])>2)

# Download the bibjson files from the GeoDeepDive API
# Because GDD contains several million documents, and this is only an example, we only download gdd documents
# Where the publication name holds some similarity to the string "Paleontology"
Paleontology<-fromJSON("https://geodeepdive.org/api/articles?pubname_like=Paleontology")
# Where the publication name holds some similarity to the string geology
Geology<-fromJSON("https://geodeepdive.org/api/articles?pubname_like=Geology")

# Move down two dimensions of the JSON/List object so that GDDRefs is actually an iterable object - i.e., each element is an article
Paleontology<-Paleontology[[1]][[2]]
Geology<-Geology[[1]][[2]]
# Combine the two lists
GDDRefs<-append(Paleontology,Geology)

# Extract authors, docid, year, title, journal, and publisher information from the BibJson List into vectors
gdd_id<-parSapply(Cluster,GDDRefs,function(x) x[["_gddid"]])
gdd_author<-parSapply(Cluster,GDDRefs,function(x) paste(unlist(x[["author"]]),collapse=" "))
gdd_year<-parSapply(Cluster,GDDRefs,function(x) x[["year"]])
gdd_title<-parSapply(Cluster,GDDRefs,function(x) x[["title"]])
gdd_pubtitle<-parSapply(Cluster,GDDRefs,function(x) x[["journal"]])
gdd_publisher<-parSapply(Cluster,GDDRefs,function(x) x[["publisher"]])
 
# Create identically formatted data.frames for geodeepdive and pbdb references (overwrite GDDRefs)
GDDRefs<-as.data.frame(cbind(gdd_id,gdd_author,gdd_year,gdd_title,gdd_pubtitle, gdd_publisher),stringsAsFactors=FALSE)
PBDBRefs<-PBDBRefs[,c("reference_no","author1last","pubyr","reftitle","pubtitle")]
colnames(PBDBRefs)<-c("pbdb_no","pbdb_author","pbdb_year","pbdb_title","pbdb_pubtitle")
    
# Change data types of DDRefs to appropriate types
GDDRefs[,"gdd_id"]<-as.character(GDDRefs[,"gdd_id"])
GDDRefs[,"gdd_author"]<-as.character(GDDRefs[,"gdd_author"])
GDDRefs[,"gdd_year"]<-as.numeric(as.character(GDDRefs[,"gdd_year"]))
GDDRefs[,"gdd_title"]<-as.character(GDDRefs[,"gdd_title"])
GDDRefs[,"gdd_pubtitle"]<-as.character(GDDRefs[,"gdd_pubtitle"])

# Convert the title and pubtitle to all caps, because stringsim, unlike grep, cannot distinguish between cases
PBDBRefs[,"pbdb_title"]<-tolower(PBDBRefs[,"pbdb_title"])
PBDBRefs[,"pbdb_pubtitle"]<-tolower(PBDBRefs[,"pbdb_pubtitle"])
DDRefs[,"gdd_title"]<-tolower(DDRefs[,"gdd_title"])
DDRefs[,"gdd_pubtitle"]<-tolower(DDRefs[,"gdd_pubtitle"])

#############################################################################################################
########################################## MATCH TITLES, EPANDDA ############################################
#############################################################################################################
# Find the best title stringsim for each PBDB ref in GDD
matchTitle<-function(x,y) {
    Similarity<-stringdist::stringsim(x,y)
    MaxTitle<-max(Similarity)
    MaxIndex<-which.max(Similarity)
    return(c(MaxIndex,MaxTitle))
    }

############################################ Initial Title Match Script #####################################    
# Export the functions to the cluster
clusterExport(cl=Cluster,varlist=c("matchTitle","stringsim"))

# Find the best title matches
TitleSimilarity<-parSapply(Cluster,PBDBRefs[,"pbdb_title"],matchTitle,DDRefs[,"gdd_title"])
# Reshape the Title Similarity Output
TitleSimilarity<-as.data.frame(t(unname(TitleSimilarity)))
    
# Bind Title Similarity by pbdb_no
InitialMatches<-cbind(PBDBRefs[,"pbdb_no"],TitleSimilarity)
InitialMatches[,"V1"]<-DDRefs[InitialMatches[,"V1"],"gdd_id"]
colnames(InitialMatches)<-c("pbdb_no","gdd_id","title_sim")

# Merge initial matches, pbdb refs, and gdd refs
InitialMatches<-merge(InitialMatches,DDRefs,by="gdd_id",all.x=TRUE)
InitialMatches<-merge(InitialMatches,PBDBRefs,by="pbdb_no",all.x=TRUE)
    
#############################################################################################################
########################################## MATCH FIELDS, EPANDDA ############################################
#############################################################################################################
# A function for matching additional bibliographic fields between the best and worst match
matchAdditional<-function(InitialMatches) {
    # Whether the publication year is identical
    Year<-InitialMatches["pbdb_year"]==InitialMatches["gdd_year"]
    # The similarity of the journal names
    Journal<-stringsim(InitialMatches["pbdb_pubtitle"],InitialMatches["gdd_pubtitle"])
    # Whether the first author's surname is present in the GDD bibliography
    Author<-grepl(InitialMatches["pbdb_author"],InitialMatches["gdd_author"],perl=TRUE,ignore.case=TRUE)
    # Return output     
    FinalOutput<-setNames(c(InitialMatches["pbdb_no"],InitialMatches["gdd_id"],InitialMatches["title_sim"],Author,Year,Journal),c("pbdb_no","gdd_id","title_sim","author_in","year_match","pubtitle_sim"))
    return(FinalOutput)
    }

######################################### Match Additional Fields Script ####################################  
# export matchAdditional to the cluster
clusterExport(cl=Cluster,varlist=c("matchAdditional"))                           

# Perform the additional matches
MatchReferences<-parApply(Cluster, InitialMatches, 1, matchAdditional)

# Stop the Cluser
stopCluster(Cluster)

# Reformat MatchReferences
MatchReferences<-as.data.frame(t(MatchReferences))
  
    
#############################################################################################################
########################################## MODEL BUILDLING, EPANDDA #########################################
#############################################################################################################
# No functions at this time

############################################# Model Building Script #########################################

# Upload a training set of manually scored correct and false matches
TrainingSet<-read.csv("https://raw.githubusercontent.com/aazaff/portfolio/master/CSV/epandda_training.csv")

# Check the plausible regression models
Model1<-glm(Match~title_sim,family="binomial",data=TrainingSet)
Model2<-glm(Match~title_sim+author_in,family="binomial",data=TrainingSet)
Model3<-glm(Match~title_sim+author_in+year_match,family="binomial",data=TrainingSet)
Model4<-glm(Match~title_sim+author_in+year_match+pubtitle_sim,family="binomial",data=TrainingSet)

# Make predictions from the basic set
Probabilities<-round(predict(Model4,MatchReferences,type="response"),4)
