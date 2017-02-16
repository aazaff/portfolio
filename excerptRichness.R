# Custom functions are camelCase. Arrays, parameters, and arguments are PascalCase
# Dependency functions are not embedded in master functions, and are marked with the flag dependency in the documentation
# []-notation is used wherever possible, and $-notation is avoided.

######################################### Load Required Libraries ###########################################
# Load or install the velociraptr package
if (suppressWarnings(require("velociraptr"))==FALSE) {
    install.packages("velociraptr",repos="http://cran.cnr.berkeley.edu/");
    library("velociraptr");
    }

# Load or install the pbapply package
if (suppressWarnings(require("pbapply"))==FALSE) {
    install.packages("pbapply",repos="http://cran.cnr.berkeley.edu/");
    library("pbapply");
    }

#############################################################################################################
###################################### FOSSIL DATA FUNCTIONS, ALICE #########################################
#############################################################################################################
# No functions at this time

############################################## FOSSILS: Load Data ###########################################
# Download data from the Paleobiology Database data API
options(timeout=300) # increase the timeout limit since it is a large dataset
SkeletalTaxa<-c("Bivalvia","Gastropoda","Anthozoa","Brachiopoda","Trilobita","Bryozoa","Nautiloidea","Ammonoidea","Crinoidea","Blastoidea","Edrioasteroidea")
SkeletalPBDB<-velociraptr::downloadPBDB(SkeletalTaxa,"Cambrian","Pleistocene")

# Clean subgenera and remove unidentified taxa
SkeletalPBDB<-velociraptr::cleanTaxonomy(SkeletalPBDB,Taxonomy="genus")

# Remove unnecessary columns for increased performance
SkeletalPBDB<-SkeletalPBDB[,c("genus","early_interval","late_interval","max_ma","min_ma")]

# Download Epochs timescale from Macrostrat
Epochs<-velociraptr::downloadTime("international%20epochs")

# Cull the data so that only fossil occurrences with ages reliably constrained to a single geologic epoch are counted
SkeletalEpochs<-velociraptr::constrainAges(SkeletalPBDB,Epochs)

#############################################################################################################
############################################ FOSSIL ANALYSIS FUNCTIONS, ALICE ###############################
#############################################################################################################
# Calculate the number of unique genera in each 1 million year increment of the Phanerozoic (0-541 ma)
rangeRichness<-function(Ages,Increments=1) {
	Bins<-seq(1,541,Increments)
	FinalVector<-vector("numeric",length=length(Bins))
	for (i in 1:length(Bins)){
		FinalVector[i]<-length(which(Ages[,"EarlyAge"]>=Bins[i] & Ages[,"LateAge"]<=Bins[i]))
		}
	return(FinalVector)
	}
  
########################################### FOSSILS: Analysis Scripts #######################################
# Find the number of unique genera in each 1 million year increment of the Phanerozoic (0-541 ma)
GenusAges<-velociraptr::ageRanges(SkeletalEpochs,Taxonomy="genus") # Find the oldest and youngest known fossil of each genus
GenusRichness<-rangeRichness(GenusAges) # Assume that each genus is present in every million year increment between its oldest and youngest occurrence

# Calculate the standardized diversity of each Epoch using the Shareholder Quorum Subsamling method
# SQS subsamples the abundance of each temporal interval so that a certain level of "coverage" (75%) is achieved.
GenusAbundances<-by(SkeletalEpochs[,"genus"],SkeletalEpochs[,"early_interval"],table) # Find the abundance of each genus per each geologic epoch
GenusRichnessSQS<-t(setNames(pbsapply(GenusAbundances,velociraptr::subsampleEvenness,0.75),names(GenusAbundances)))

# Bind the SQS output to the timescale data frame so that richness is mapped to a time period.
GenusRichnessSQS<-transform(merge(t(GenusRichnessSQS),Epochs,by="row.names",all=FALSE),row.names=Row.names,Row.names=NULL)
colnames(GenusRichnessSQS)[1]<-"GenusRichnessSQS"
GenusRichnessSQS<-GenusRichnessSQS[order(GenusRichnessSQS[,"Midpoint"]),]

#############################################################################################################
########################################### PLOTTING FUNCTIONS, ALICE #######################################
#############################################################################################################
# For ploting binned richness data along the Phanerozoic time-scale
plotBinned<-function(TimeMoments,Intervals=Epochs,VerticalLabel="index",Single=TRUE) {
	if (Single) {par(oma=c(1.5,0.5,0.5,0),mar=c(3,3,2,0.5),mgp=c(2,0.5,0))}
	String<-deparse(substitute(TimeMoments))
	Title<-gsub('(?<=[a-z])(?=[A-Z])', ' ', String, perl = TRUE)
	Maximum<-max(TimeMoments[,1])
	Minimum<-Maximum-(Maximum-min(TimeMoments[,1]))*1.05
	plot(y=TimeMoments[,1],x=TimeMoments[,"Midpoint"],xlim=c(541,0),ylim=c(Minimum,Maximum*1.05),ylab=VerticalLabel,xlab="millions of years ago",yaxs="i",xaxs="i",lwd=3,type="l",main=Title,cex.axis=1.25)
	points(y=TimeMoments[,1],x=TimeMoments[,"Midpoint"],col=as.character(TimeMoments[,"color"]),pch=16,cex=2)
	for (i in 2:nrow(Intervals)) {
 		rect(Intervals[i,"t_age"],min(TimeMoments[,1]),Intervals[i,"b_age"],Minimum,col=as.character(Intervals[i,"color"]))
 		}
 	}
 	
# For plotting continuous time-series along the Phanerozoic time-scale
plotContinuous<-function(TimeVector,Intervals=Epochs,VerticalLabel="index",Single=TRUE) {
 	if (Single) {par(oma=c(1.5,0.5,0.5,0),mar=c(3,3,2,0.5),mgp=c(2,0.5,0))}
 	String<-deparse(substitute(TimeVector))
	Title<-gsub('(?<=[a-z])(?=[A-Z])', ' ', String, perl = TRUE)
 	Maximum<-max(TimeVector)
	Minimum<-0-(Maximum*0.05)
 	plot(y=TimeVector,x=1:length(TimeVector),type="l",lwd=3,xlim=c(541,0),ylim=c(Minimum,Maximum*1.05),ylab=VerticalLabel,xlab="millions of years ago",yaxs="i",xaxs="i",main=Title,cex.axis=1.25)
 	for (i in 1:nrow(Intervals)) {
		rect(Intervals[i,"t_age"],0,Intervals[i,"b_age"],Minimum,col=as.character(Intervals[i,"color"]))
		}
	}

########################################## PLOTTING: Plotting Scripts #######################################	
# Make a figure
quartz(width=7,height=7)
layout(matrix(c(1,1,2,2), 2, 2, byrow = TRUE))
par(oma=c(1.5,0.5,0.5,0),mar=c(3,3,2,0.5),mgp=c(1.5,0.5,0))
# Plot fragmentation Index Time-Series
plotContinuous(GenusRichness,Epochs,"number of marine animals",Single=FALSE)
# Plot the SQS time-series
plotBinned(GenusRichnessSQS,Epochs,"number of marine animals",Single=FALSE)
