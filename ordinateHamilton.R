# Custom functions are camelCase. Arrays, parameters, and arguments are PascalCase
# Dependency functions are not embedded in master functions, and are marked with the flag dependency in the documentation
# []-notation is used preferentially, and $-notation is avoided.

######################################### Load Required Libraries ###########################################
# Load or install the velociraptr package; needed to shape the data
if (suppressWarnings(require("velociraptr"))==FALSE) {
    install.packages("velociraptr",repos="http://cran.cnr.berkeley.edu/");
    library("velociraptr");
    }

# Load or install the vegan package; needed for ordination
if (suppressWarnings(require("vegan"))==FALSE) {
    install.packages("vegan",repos="http://cran.cnr.berkeley.edu/");
    library("vegan");
    }

#############################################################################################################
###################################### FOSSIL DATA FUNCTIONS, Hamilton ######################################
#############################################################################################################
# No functions at this time.

############################################## Load Hamilton Datasets  ######################################
# Load primary Hamilton Dataset from GitHub
Hamilton<-read.csv("https://raw.githubusercontent.com/aazaff/portfolio/master/CSV/ZaffosHamiltonData03102014PBM.csv",header=TRUE,row.names=1)
# Convert the abundance data to presence-absence (1-presence, 0-absence)
Hamilton[Hamilton>0]<-1

# Cull the dataset of depauperate samples (<5 taxa) and rare taxa (<5 samples)
HamiltonCull<-velociraptr::cullMatrix(Hamilton,5,5)

# Load in the Locality-to-County hash table
Localities<-read.csv("https://raw.githubusercontent.com/aazaff/portfolio/master/CSV/HamiltonLocalityHash07312015PBM.csv",header=TRUE)

# Merge the rownames with the county codes
CodesMatrix<-cbind(rownames(Hamilton),substring(rownames(Hamilton),3,4))
colnames(CodesMatrix)<-c("Samples","Code")
CodesMatrix<-merge(CodesMatrix,Localities,by="Code",all=TRUE)
CodesMatrix<-subset(CodesMatrix,is.na(CodesMatrix[,"Samples"])!=TRUE) # Remove NA's
rownames(CodesMatrix)<-CodesMatrix[,"Samples"]

# Do the same for the Brett and Baird (1983) sample codes, which use a different labeling system
CodesMatrixBB<-cbind(rownames(Hamilton),substring(rownames(Hamilton),3,6))
colnames(CodesMatrixBB)<-c("Samples","Code")
CodesMatrixBB<-merge(CodesMatrixBB,Localities,by="Code",all=TRUE)
CodesMatrixBB<-subset(CodesMatrixBB,is.na(CodesMatrixBB[,"Samples"])!=TRUE)
rownames(CodesMatrixBB)<-CodesMatrixBB[,"Samples"]
CodesMatrixBB<-na.omit(CodesMatrixBB)

# Merge the two CodeMatrices
CodesMatrix<-subset(CodesMatrix,rownames(CodesMatrix)%in%rownames(CodesMatrixBB)!=TRUE)
CodesMatrix<-rbind(CodesMatrix,CodesMatrixBB)

# Remove the Pennsylvania data that does not belong in this analysis of New York
Pennsylvania<-subset(CodesMatrix,CodesMatrix[,"County"]=="PENNSYLVANIA")
HamiltonCull<-subset(HamiltonCull,rownames(HamiltonCull)%in%rownames(Pennsylvania)!=TRUE)

#############################################################################################################
####################################### ORDINATION FUNCTIONS, Hamilton ######################################
#############################################################################################################
# Rotate ordination so slope of centroids is zero
# This is an affine rotation that matches the x-axis of variation to the inferred geographic axis
# From Holland and Zaffos (2011)
rotateMatrix <- function(CommunityMatrix, Theta) {
	# rotates a 2-dimensional matrix clockwise by theta radians
	RotationElements<-c(cos(Theta), sin(Theta), -sin(Theta), cos(Theta))
	RotationDimensions<-c(2,2)
	RotationMatrix<-array(RotationElements, RotationDimensions)
	RotatedMatrix<-CommunityMatrix %*% RotationMatrix
	return(RotatedMatrix)
	}

# Rotate Hamilton Data by so that the axis of greatest taxonomic variation is parallel to the east-west 
# geographic location of New York Counties
rotateSamples<-function(SampleScores,CodesMatrix=CodesMatrix) {
	# Merge the Scores and hash table
	SampleCodes<-merge(SampleScores,CodesMatrix,by="row.names")
	
	# Find Centroids of county groupings
	EasternCounties<-subset(SampleCodes,SampleCodes$County=="Madison" | SampleCodes$County=="Onondaga" | SampleCodes$County=="Chenango")
	WesternCounties<-subset(SampleCodes,SampleCodes$County=="Erie" | SampleCodes$County=="Genesee" | SampleCodes$County=="Livingston")
	CentralCounties<-subset(SampleCodes,SampleCodes$County=="Cayuga" | SampleCodes$County=="Seneca")
	DCA1Centroid<-c(mean(EasternCounties$DCA1),mean(WesternCounties$DCA1),mean(CentralCounties$DCA1))
	DCA2Centroid<-c(mean(EasternCounties$DCA2),mean(WesternCounties$DCA2),mean(CentralCounties$DCA2))
	
	# Use the centroids to calculate the slope of the geographic gradient
  	Slope<-sd(DCA2Centroid)/sd(DCA1Centroid)
  	
	# Realign the axis of taxonomic variation with the geographic gradient
	RotatedSamples<-as.data.frame(rotateMatrix(as.matrix(SampleScores[,1:2]),atan(Slope)))
	RotatedSamples<-transform(merge(RotatedSamples,CodesMatrix,by="row.names"),row.names=Row.names,Row.names=NULL)
  	colnames(RotatedSamples)<-c("Axis1","Axis2","Code","Samples","County")
	return(RotatedSamples)
	}

# Find the position of each species along the inferred gradient of the rotated ordination
# Take the average sample score of all samples each species is present in
rotateSpecies<-function(RotatedSampleScores,OriginalData) {
	# Find which samples each taxon is present in according to the original contingency table
	PresentSamples<-apply(OriginalData,2,function(x) names(which(x>0)))
	# Find the average score of all samples each taxon is present in
	Axis1Scores<-sapply(PresentSamples,function(x,y) mean(y[x,"Axis1"]),RotatedSampleScores)
	Axis2Scores<-sapply(PresentSamples,function(x,y) mean(y[x,"Axis2"]),RotatedSampleScores)
	# Bind and save the data
	FinalMatrix<-cbind(Axis1Scores,Axis2Scores)
	return(FinalMatrix)
	}

######################################### Perform Rotated Hamilton  #########################################
# Perform detrended correspondence analysis
HamiltonDCA<-decorana(HamiltonCull)
HamiltonScores<-scores(HamiltonDCA,display="sites")
# Merge the scores with the lookup table
HamiltonUnrotated<-merge(HamiltonScores,CodesMatrix,by="row.names")

# Rotate the scores so that the x-axis is aligned with the geographic axis
RotatedSampleScores<-rotateSamples(HamiltonScores,CodesMatrix)
RotatedSpeciesScores<-rotateSpecies(RotatedSampleScores,HamiltonCull)

############################################## Plotting Script ##############################################
# Make a figure
quartz(width=10,height=5)
layout(matrix(c(1,2), 1, 2, byrow = TRUE))
par(oma=c(1.5,0.5,0.5,0),mar=c(3,3,2,0.5),mgp=c(1.5,0.5,0))

# Visualize the sample scores
# Separate the points out by county so they can be plotted by different colors
Countyless<-subset(HamiltonUnrotated,HamiltonUnrotated$County!="Madison" | HamiltonUnrotated$County!="Onondaga" | HamiltonUnrotated$County!="Chenango" | HamiltonUnrotated$County!="Erie" | HamiltonUnrotated$County!="Genesee" | HamiltonUnrotated$County!="Livingston" | HamiltonUnrotated$County=="Cayuga" | HamiltonUnrotated$County=="Seneca")
EasternCounties<-subset(HamiltonUnrotated,HamiltonUnrotated$County=="Madison" | HamiltonUnrotated$County=="Onondaga" | HamiltonUnrotated$County=="Chenango")
WesternCounties<-subset(HamiltonUnrotated,HamiltonUnrotated$County=="Erie" | HamiltonUnrotated$County=="Genesee" | HamiltonUnrotated$County=="Livingston")
CentralCounties<-subset(HamiltonUnrotated,HamiltonUnrotated$County=="Cayuga" | HamiltonUnrotated$County=="Seneca")
# Make an initial plot
plot(x=HamiltonUnrotated[,"DCA1"],y=HamiltonUnrotated[,"DCA2"],type="n",las=1,xlab="DCA Axis 1",ylab="DCA Axis 2")
points(x=Countyless[,"DCA1"],y=Countyless[,"DCA2"],pch=16,col="grey",cex=1.5) # Add points from misc. counties
points(EasternCounties[,"DCA1"],EasternCounties[,"DCA2"],pch=16,col="#f3676f",cex=1.5) # Add eastern counties
points(WesternCounties[,"DCA1"],WesternCounties[,"DCA2"],pch=16,col="#77cee3",cex=1.5) # Add western counties
points(CentralCounties[,"DCA1"],CentralCounties[,"DCA2"],pch=16,col="#f3a567",cex=1.5) # Add central counties

# Visualize the rotated species scores
# Save a blank space for the counties map - added in later through illustrator
plot(RotatedSpeciesScores[,"Axis1Scores"],RotatedSpeciesScores[,"Axis2Scores"],pch=16,col="grey",las=1,xlab="DCA Axis 1",ylab="DCA Axis 2",cex=1.5)
# text(RotatedSpeciesScores[,"Axis1Scores"],RotatedSpeciesScores[,"Axis2Scores"],rownames(RotatedSpeciesScores))
