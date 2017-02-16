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
GenusRichnessSQS<-transform(merge(as.data.frame(GenusRichnessSQS),Epochs,by="row.names",all=FALSE),row.names=Row.names,Row.names=NULL)
GenusRichnessSQS<-GenusRichnessSQS[order(GenusRichnessSQS[,"Midpoint"]),]
