# portfolio
The following is a collection of excerpts from scientific projects, educational resources, or programming scripts developed by Dr. Andrew Zaffos. Many of these examples have been slightly edited from their original versions to protect proprietary information or ongoing research.

## Table of Contents
+ [Quantitative Paleobiology](#quantitative-paleobiology): R, git, web APIs
+ [Paleogeographic Analyses](#paleogeographic-analyses): postGIS, R, postgreSQL, web APIs
+ Machine Learning in GeoDeepDive: R, postgreSQL, Condor (high-throughput computing)
+ Velociraptr Package: R, web APIs
+ Multivariate Fossil Analyses: R

## Quantitative Paleobiology
I taught an upper-level Quantitative Paleobiology course at the University of Wisconsin-Madison during the Spring 2016 semester. The course focused on points of ecological and geological theory, statistical principles, programming in R, web API usage, and used GitHub as the primary course assignment submission, material distribution, and grading platform. This project was funded as part of an NSF research grant to develop educational tools related to the [Paleobiology Database](www.paleobiodb.org) data service ([API](https://paleobiodb.org/data1.2/)). 

#### Excerpt
I have forked one of the lab assignments from the class to this repository. It deals with plotting paleogeographic maps and fossil data in R using the [Macrostrat Database](www.macrostrat.org) API, [Paleobiology Database](www.paleobiodb.org) API, and the [rgdal](https://cran.r-project.org/web/packages/rgdal/rgdal.pdf) geospatial analysis package. A paleogeographic map is a depiction of where the continents were located n-million years ago.

#### Further Information
+ [Course GitHub Repository](https://github.com/paleobiodb/teachPaleobiology#geoscience-541-paleobiology): The courses main page (readme) has links to the syllabus, lectures, lab assignments, reading assignments, writing assignments, GitHub tutorial, and R tutorial.
+ [R Tutorial](https://github.com/aazaff/startLearn.R/blob/master/README.md#an-introduction-to-r): A lengthy R tutorial covering beginner, intermediate, advanced, and expert level topics in R.
+ [GitHub Tutorial](https://github.com/paleobiodb/teachPaleobiology/blob/master/GitTutorial/gitTutorial.md#introduction): A simple GitHub tutorial used to teach students how to create a GitHub account and repository, and how to pull and push to the repo.

## Paleogeographic Analyses
I generally conduct most of my geospatial analyses in [QuantumGIS](www.qgis.org) or [postGIS](http://www.postgis.net/). This is an example of some R scripts I wrote that processes 550 Paleogeographic Maps from the EarthByte paleocoordinate rotation model using the RPostgreSQL package and postGIS. A paleogeographic map is a depiction of where the continents were located n-million years ago.

#### Excerpt
I have forked a modified version of the original R script from our lab group's private repository to here.

#### Further Information
+ [Macrostrat Database Paleogeography](www.macrostrat.org/api/paleogeography) These maps can be accessed using the Macrostrat Database's paleogeography route.
+ [Paleobiology Database Navigator](www.paleobiodb.org/navigator) These maps underlie the paleogeographic maps in the Paleobiology Database's data visualization tool.
