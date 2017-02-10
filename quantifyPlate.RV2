# Custom functions are camelCase. Arrays, parameters, and arguments are PascalCase
# Dependency functions are not embedded in master functions
# []-notation is used wherever possible, and $-notation is avoided.

######################################### Load Required Libraries ###########################################
# Load Required Libraries
library("RPostgreSQL")

# Establish postgresql connection.
Driver<-dbDriver("PostgreSQL") # Establish database driver
# Your Database
Alice<-dbConnect(Driver, dbname = "dbname", host = "localhost", port = port, user = "username")

#############################################################################################################
######################################### BYID MERGE FUNCTIONS, ALICE #######################################
#############################################################################################################
# A function to merge all plates with the same id number within the same year that are CANONICAL
mergeBYID<-function(Connection=Alice) {
	# Make a vector of canonical plates
	CanonicalPlates<-unique(dbGetQuery(Connection,"SELECT plateid1 FROM EarthByte2013_raw.reconstructed_550"))[,1]
	Progress<-txtProgressBar(min=0,max=550,style=3)
	for (YEAR in 0:550) {
		dbSendQuery(Connection,paste("CREATE TABLE EarthByte2013_byid.byid_",YEAR," (plateid1 numeric, geom geometry)",sep=""))
		Query<-paste("INSERT INTO EarthByte2013_byid.byid_",YEAR," (plateid1,geom) SELECT plateid1 AS plateid1, ST_Union(ST_Buffer(ST_MakeValid(geom),0.001)) FROM EarthByte2013_raw.reconstructed_",YEAR," WHERE plateid1 IN (",paste(CanonicalPlates,collapse=","),") GROUP BY plateid1",sep="")
		dbSendQuery(Connection,Query)
		setTxtProgressBar(Progress,YEAR)
		}
	close(Progress)
	}

# A function to calculate the distance between every pair of plates
plateDistance<-function(Connection=Alice) {
	# Make a progress bar
	Progress<-txtProgressBar(min=0,max=550,style=3)
	for (YEAR in 0:550) {
		Plates<-unique(dbGetQuery(Alice,paste("SELECT plateid1 FROM EarthByte2013_byid.byid_",YEAR,sep=""))[,1])
		PlateCombinations<-t(combn(Plates,2))
		for (ROW in 1:nrow(PlateCombinations)) {
			NonGeometryQuery<-paste("INSERT INTO EarthByte2013_byid.distance_azimuth_matrix (platea, plateb, year, shortest_line) SELECT ",PlateCombinations[ROW,1]," AS platea, ",PlateCombinations[ROW,2]," AS plateb, ",YEAR," AS year, ",sep="")
			FirstGeometry<-paste("SELECT geom FROM EarthByte2013_byid.byid_",YEAR, " WHERE plateid1 = ",PlateCombinations[ROW,1],sep="")
            		SecondGeometry<-paste("SELECT geom FROM EarthByte2013_byid.byid_",YEAR," WHERE plateid1 = ",PlateCombinations[ROW,2],sep="")
			FinalQuery<-paste(NonGeometryQuery,"ST_ShortestLine((",FirstGeometry,"), (",SecondGeometry,")) AS shortest_line",sep="")
			dbSendQuery(Connection,FinalQuery)
			}
		setTxtProgressBar(Progress,YEAR)
		}
	dbSendQuery(Alice,"UPDATE EarthByte2013_byid.distance_azimuth_matrix SET distance = ST_Length_Spheroid(shortest_line, \'SPHEROID[\"GRS_1980\",6378137,298.257222101]\');")
	close(Progress)
	}

########################################### BYID MERGE: SCRIPTS #############################################
# Drop the schemas if they already exist
dbSendQuery(Alice,"DROP SCHEMA IF EXISTS EarthByte2013_byid CASCADE")
# Create the new schemas
dbSendQuery(Alice,"CREATE SCHEMA EarthByte2013_byid")

# Create a blank distance_azimuth_matrix table
dbSendQuery(Alice, "CREATE TABLE EarthByte2013_byid.distance_azimuth_matrix (platea integer, plateb integer, year integer, shortest_line geometry, distance double precision);")

# Populate the EarthByte2013_byid schema with by million-year geometeries
mergeBYID(Alice)

# Create matrix of the shortest distance between all pairwise comparisons of plates for each million year increment
plateDistance(Alice)

#############################################################################################################
##################################### BYTOUCHING MERGE FUNCTIONS, ALICE #####################################
#############################################################################################################
# A dependency of mergeBYTOUCHING
touchingMatrix<-function(YearTouching) {
	FinalMatrix<-matrix(0,nrow=length(unique(YearTouching[,"platea"])),ncol=length(unique(unlist(YearTouching))))
	rownames(FinalMatrix)<-unique(YearTouching[,"platea"])
	colnames(FinalMatrix)<-unique(unlist(YearTouching))
	RowMatches<-match(YearTouching[,"platea"],rownames(FinalMatrix))
	ColMatches<-match(YearTouching[,"plateb"],colnames(FinalMatrix))
	MatchesMatrix<-cbind(RowMatches,ColMatches)
	SelfMatches<-match(rownames(FinalMatrix),colnames(FinalMatrix))
	SelfMatches<-cbind(1:length(SelfMatches),SelfMatches)
	FinalMatrix[SelfMatches]<-1
	FinalMatrix[MatchesMatrix]<-1
	return(FinalMatrix)
	}
	
# A function to merge all touching plates within the same year
mergeBYTOUCHING<-function(Connection=Alice,Distance=30000) {
	DistanceMatrix<-dbGetQuery(Connection,"SELECT platea,plateb,year,distance FROM EarthByte2013_byid.distance_azimuth_matrix")
	Progress<-txtProgressBar(min=0,max=550,style=3)
	for (YEAR in 0:550) {
		YearSubset<-subset(DistanceMatrix,DistanceMatrix[,"year"]==YEAR)
		Touching<-subset(YearSubset,YearSubset[,"distance"]<=Distance)[,c("platea","plateb")]
		Isolated<-setdiff(unique(unlist(YearSubset[,c("platea","plateb")])),unique(unlist(Touching)))
		TouchingMatrix<-touchingMatrix(Touching)
		TouchingSums<-apply(TouchingMatrix,2,sum)
		while(any(TouchingSums>1)) {
			TouchingRows<-which(TouchingMatrix[,which.max(TouchingSums)]==1)
			AggregatedGroups<-TouchingMatrix[TouchingRows,]
			RowSums<-apply(AggregatedGroups,2,sum)
			RowSums[RowSums>1]<-1
			TouchingMatrix<-TouchingMatrix[-TouchingRows,]
			TouchingMatrix<-rbind(RowSums,TouchingMatrix)
			TouchingSums<-apply(TouchingMatrix,2,sum)
			}
		dbSendQuery(Connection, paste("CREATE TABLE EarthByte2013_bytouching.bytouching_",YEAR," AS SELECT * FROM EarthByte2013_byid.byid_",YEAR," LIMIT 0;",sep=""))		
		for (ROW in 1:nrow(TouchingMatrix)) {
			PLATES<-paste(names(which(TouchingMatrix[ROW,]>0)),collapse=",")
			dbSendQuery(Connection,paste("INSERT INTO EarthByte2013_bytouching.bytouching_",YEAR," (geom) SELECT ST_Union(geom) FROM EarthByte2013_byid.byid_",YEAR," WHERE plateid1 in (",PLATES,")",sep="")) 
			}
		if (length(Isolated)>0) {
			for (PLATE in Isolated) {
				dbSendQuery(Connection,paste("INSERT INTO EarthByte2013_bytouching.bytouching_",YEAR," (geom) SELECT geom FROM EarthByte2013_byid.byid_",YEAR," WHERE plateid1 = ",PLATE,sep=""))
				}
			}
		setTxtProgressBar(Progress,YEAR)
		}
	close(Progress)
	}

########################################### BYTOUCHING MERGE: SCRIPTS #######################################
# Drop the schemas if they already exist
dbSendQuery(Alice,"DROP SCHEMA IF EXISTS EarthByte2013_bytouching CASCADE")
# Create the new schemas
dbSendQuery(Alice,"CREATE SCHEMA EarthByte2013_bytouching")

# Join all plates 0 km apart
mergeBYTOUCHING(Alice,0)

#############################################################################################################
###################################### FILL BYTOUCHING FUNCTIONS, ALICE #####################################
#############################################################################################################
# Remove the holes in plate joins to create seamless "chunks"
fillBYTOUCHING<-function(Connection=Alice) {
	Progress<-txtProgressBar(min=0,max=550,style=3)
	for (YEAR in 0:550) {
		Query<-paste("CREATE TABLE EarthByte2013_fill.fill_",YEAR," AS WITH dumped AS (SELECT (ST_DumpRings((ST_Dump(geom)).geom)).geom FROM earthbyte2013_bytouching.bytouching_",YEAR,") SELECT ST_union(geom) as geom FROM dumped;",sep="")
		dbSendQuery(Connection,Query)
		setTxtProgressBar(Progress,YEAR)
		}
	close(Progress)
	}

########################################### BYTOUCHING MERGE: SCRIPTS #######################################
# Drop the schemas if they already exist
dbSendQuery(Alice,"DROP SCHEMA IF EXISTS EarthByte2013_fill CASCADE")
# Create the new schemas
dbSendQuery(Alice,"CREATE SCHEMA EarthByte2013_fill")

# Join all plates 0 km apart
fillBYTOUCHING(Alice)

#############################################################################################################
##################################### FRAGMENTATION INDEX FUNCTIONS, ALICE ##################################
#############################################################################################################
# Calculate the perimeter index
calcFragmentation<-function(Connection=Alice) {
	FinalMatrix<-matrix(NA,nrow=551,ncol=5)
	rownames(FinalMatrix)<-0:550
	colnames(FinalMatrix)<-c("Year","Exposed_Borders","All_Borders","Area","Index")
	FinalMatrix[,"Year"]<-0:550
	for (YEAR in 0:550) {
		FinalMatrix[as.character(YEAR),"Exposed_Borders"]<-unlist(dbGetQuery(Connection,paste("SELECT (ST_Perimeter(geom::geography)) FROM EarthByte2013_fill.fill_",YEAR,sep="")))
		FinalMatrix[as.character(YEAR),"All_Borders"]<-unlist(dbGetQuery(Connection,paste("SELECT (SUM(ST_Perimeter(geom::geography))) FROM EarthByte2013_byid.byid_",YEAR,sep="")))
		FinalMatrix[as.character(YEAR),"Area"]<-unlist(dbGetQuery(Connection,paste("SELECT (ST_Area(geom::geography)) FROM EarthByte2013_fill.fill_",YEAR,sep="")))
		}
	# Convert the Area into the Constant Correction
	Radii<-sqrt(FinalMatrix[,"Area"]/pi)
	Constant<-Radii*2*pi
	FinalMatrix[,"Index"]<-(FinalMatrix[,"Exposed_Borders"]-Constant)/(FinalMatrix[,"All_Borders"]-Constant)
	return(FinalMatrix)
	}

######################################### FRAGMENATION INDEX: SCRIPTS #######################################
# Calculate the perimeter index
FragmentationIndex<-calcFragmentation(Alice)

# Drop the old table if it exists
dbSendQuery(Alice,"DROP TABLE IF EXISTS earthbyte2013_fill.fragmentation_index")
# Save the result as a table
dbWriteTable(Alice,c("earthbyte2013_fill","fragmentation_index"),value=as.data.frame(FragmentationIndex),row.names=FALSE)

#############################################################################################################
########################################## PLATE VELOCITY FUNCTIONS, ALICE ##################################
#############################################################################################################
# Find the plate movement of each plate
plateVelocity<-function(Connection=Alice) {
  FinalList<-vector("list",length=550)
   for (i in 0:549) {
      Query<-paste("SELECT ",i+1," AS year1,",i," AS year2, a.plateid1, ST_Distance_Spheroid(ST_Centroid(a.geom), ST_Centroid(b.geom), \'SPHEROID[\"WGS 84\",6378137,298.257223563]\') AS distance_m
      FROM earthbyte2013_byid.byid_",i+1," AS a JOIN earthbyte2013_byid.byid_",i," AS b ON a.plateid1 = b.plateid1",sep="")
      FinalList[[i+1]]<-dbGetQuery(Connection,Query)
      }
   return(FinalList)
   }

########################################### PLATE VELOCITY: SCRIPTS #########################################
# Bind the output togeter
PlateVelocity<-do.call(rbind,plateVelocity(Alice))

# Drop the old table if it exists
dbSendQuery(Alice,"DROP TABLE IF EXISTS earthbyte2013_byid.plate_velocity")
# Save the result as a table
dbWriteTable(Alice,c("earthbyte2013_byid","plate_velocity"),value=as.data.frame(PlateVelocity),row.names=FALSE)

#############################################################################################################
######################################### LATITUDE MAX/MIN FUNCTIONS, ALICE #################################
#############################################################################################################
# Find the maximum and minimum latitude for each CANONICAL plate
plateBoundaries<-function(Connection=Alice) {
	FinalList<-vector("list",length=551)
	for (i in 0:550) {
		Query<-paste("SELECT plateid1,ST_ymax(geom),ST_ymin(geom),ST_xmax(geom),ST_xmin(geom) FROM earthbyte2013_byid.byid_",i,";",sep="")
		YearFrame<-dbGetQuery(Connection,Query)
		Year<-rep(i,nrow(YearFrame))
		FinalList[[i+1]]<-cbind(Year,YearFrame)
		}
	return(FinalList)
	}

########################################### PLATE VELOCITY: SCRIPTS #########################################
# Find the maximum and minimum latitude and longitude of each plate
PlateBoundaries<-do.call(rbind,plateBoundaries(Alice))
colnames(PlateBoundaries)<-c("Year","plateid1","max_lat","min_lat","max_lng","min_lng")

# Drop the old table if it exists
dbSendQuery(Alice,"DROP TABLE IF EXISTS earthbyte2013_byid.plate_boundaries")
# Save the result as a table
dbWriteTable(Alice,c("earthbyte2013_byid","plate_boundaries"),value=as.data.frame(PlateBoundaries),row.names=FALSE)

#############################################################################################################
######################################### LENGTH MATRICES FUNCTIONS, ALICE ##################################
#############################################################################################################
# Find the latitudinal length and longitudinal length of crustal blocks
latitudePlates<-function(Connection=Alice) {
	Latitude<-seq(-89.5,89.5,0.5)
	Years<-0:550
	FinalMatrix<-matrix(0,nrow=length(Years),ncol=length(Latitude))
	rownames(FinalMatrix)<-Years
	colnames(FinalMatrix)<-Latitude
	Progress<-txtProgressBar(min=0,max=550,style=3)
	for (Y in Years) {
		for (L in Latitude) {
			WestPoint<-paste("ST_SetSRID(ST_MakePoint(-180,",L,"),0)",sep="")
			EastPoint<-paste("ST_SetSRID(ST_MakePoint(180,",L,"),0)",sep="")
			Horizontal<-paste("ST_MakeLine(",WestPoint,",",EastPoint,")",sep="")
			MapGeom<-paste("SELECT ST_SetSRID(geom,0) FROM earthbyte2013_fill.fill_",Y,sep="")
			Intersection<-paste("ST_Intersection((",Horizontal,"),(",MapGeom,"))",sep="")
			Query<-paste("SELECT ST_Length_Spheroid(",Intersection,",'SPHEROID[\"GRS_1980\",6378137,298.257222101]');",sep="")
			FinalMatrix[as.character(Y),as.character(L)]<-dbGetQuery(Connection,Query)[[1]]
			}
		setTxtProgressBar(Progress,Y)
		}
	close(Progress)
	return(FinalMatrix)
	}

############################################ LENGTH MATRIX: SCRIPTS #########################################		
# Run the latitude Plates analysis.
LatitudeLength<-latitudePlates(Alice)

# Drop the old table if it exists
dbSendQuery(Alice,"DROP TABLE IF EXISTS earthbyte2013_fill.plate_latitude_length")
# Save the result as a datable
dbWriteTable(Alice,c("earthbyte2013_fill","plate_latitude_length"),value=as.data.frame(LatitudeLength),row.names=TRUE)
# Rename the row columns
dbSendQuery(Alice,"ALTER TABLE earthbyte2013_fill.plate_latitude_length RENAME \"row.names\" TO Year")

#############################################################################################################
########################################### PLATE AREA FUNCTIONS, ALICE #####################################
#############################################################################################################
# Find the area of every plate for every year - best applied to byid maps.
areaPlate<-function(Connection=Alice) {
	FinalList<-vector("list",length=551)
	for (Y in 0:550) {
		Query<-paste("SELECT plateid1, ST_Area(geom) FROM earthbyte2013_byid.byid_",Y,";",sep="")
		Areas<-dbGetQuery(Connection,Query)
		Year<-rep(Y,nrow(Areas))
		FinalList[[Y+1]]<-cbind(Year,Areas)
		}
	return(FinalList)
	}

############################################## PLATE AREA: SCRIPTS ##########################################		
# Run the latitude Plates analysis.
PlateArea<-do.call(rbind,areaPlate(Alice))

# Drop the old table if it exists
dbSendQuery(Alice,"DROP TABLE IF EXISTS earthbyte2013_byid.plate_area")
# Save the result as a datable
dbWriteTable(Alice,c("earthbyte2013_byid","plate_area"),value=as.data.frame(PlateArea),row.names=FALSE)
