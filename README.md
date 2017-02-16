# Portfolio
The following is a collection of excerpts from scientific projects, educational resources, and programming scripts developed by [Dr. Andrew Zaffos](www.azstrata.org). Some examples have been edited from their original versions to protect proprietary information or ongoing research.

### table of contents
+ [Quantitative Paleobiology](#quantitative-paleobiology): R, git, web APIs
+ [Paleogeographic Analyses](#paleogeographic-analyses): postGIS, R, postgreSQL, web APIs
+ [Text Mining in GeoDeepDive](#text-mining-in-geodeepdive): R, postgreSQL, Condor (high-throughput computing)
+ [Velociraptr Package](#r-package-velociraptr): R, web APIs
+ [Multivariate Fossil Analyses](#multivariate-fossil-analyses): R

## Quantitative Paleobiology
I taught an upper-level Quantitative Paleobiology course at the University of Wisconsin-Madison during the Spring 2016 semester. The course focused on points of ecological and geological theory, statistical principles, programming in R, and web API usage. The class used GitHub as the primary assignment submission, material distribution, and grading platform. This project was funded as part of an NSF research grant to develop educational tools related to the [Paleobiology Database](www.paleobiodb.org) data service ([API](https://paleobiodb.org/data1.2/)). 

### excerpt
I have forked one of the [lab assignments](https://github.com/aazaff/portfolio/blob/master/lab_9v2.md#the-migration-of-paleocontinents) from the class to this repository. It involves plotting paleogeographic maps and fossil data in R using the [Macrostrat Database](www.macrostrat.org) API, [Paleobiology Database](www.paleobiodb.org) API, and the [rgdal](https://cran.r-project.org/web/packages/rgdal/rgdal.pdf) geospatial analysis package. A paleogeographic map is a depiction of where the continents were located n-million years ago.

### example figure
This is one of the maps students create during the lab.

![Paleocontinent Image](/images/Alice.png)
> A graphic of paleocontinent orientations in the Albian (110 mya; green), Masstrichtian (66 mya; blue), and present (red), using [Macrostrat's](www.macrostrat.org) implementation of the [GPlates](www.gplates.org) rotation model in R.

### further information
+ [Course GitHub Repository](https://github.com/paleobiodb/teachPaleobiology#geoscience-541-paleobiology): The courses main page (readme) has links to the syllabus, lectures, lab assignments, reading assignments, writing assignments, GitHub tutorial, and R tutorial.
+ [R Tutorial](https://github.com/aazaff/startLearn.R/blob/master/README.md#an-introduction-to-r): A lengthy R tutorial covering beginner, intermediate, advanced, and expert level topics in R.
+ [GitHub Tutorial](https://github.com/paleobiodb/teachPaleobiology/blob/master/GitTutorial/gitTutorial.md#introduction): A simple GitHub tutorial used to teach students how to create a GitHub account and repository, and how to pull and push to the repo.

## Paleogeographic Analyses
I conduct most of my geospatial analyses in [QuantumGIS](www.qgis.org) or [postGIS](http://www.postgis.net/). This is an example of some R scripts I wrote to clean and analyze paleogeographic maps from the [EarthByte](www.earthbyte.org) paleocoordinate rotation model using the RPostgreSQL package and postGIS. They are a port/refactor of deprecated python/SQL code written by [John Czaplewski](https://github.com/UW-Macrostrat/alice). These maps and data products underlie several of our group's web applications (see below) and are also an important part of our paper currently under review at the Proceedings of the National Academy of Sciences.

### excerpt
I have forked a modified version of the original [R script](https://github.com/aazaff/portfolio/blob/master/quantifyPlate.RV2) from our lab group's private repository to here. This script ingests the original shapefiles and calculates various metrics about the Earth's former paleogeographic state. This includes, for example, the changing distance between pairs of tectonic plates through time. 

**NOTE: This script will not run without the original datafiles.** It is only included as a demonstration of how R can be used to interact with postGIS.

### example figure
This is an example of how the maps and geographic indices created by the above R script can be used for scientific purposes. I take the maps used above to create a novel index of supercontinenent (e.g., Pangea) coalescence-breakup. It is a quantitative expression of how dispersed continental crustal blocks (i.e., tectonic plates) are throughout the history of complex animal life (541-0 mya). An index value of unity indicates no plates are touching; an index value of zero indicates the formation of a perfectly circular supercontinent.

![Perimeter Index](/images/PerimeterIndexExample.png)
> Top - A visualization of how the fragmentation index is calculated. We divide the total perimeter of exposed plate borders by the total perimeter of all borders, then substract the circumference of a circle with area equal to all of the Earth's plates. We only use plates that persist throughout the entirety of the past 541 million years to keep the calculation consistent.

> Bottom - The history of continental fragmentation over the history of complex animal life. It initially rises in response to the breakup of the Proterozoic supercontinent of Rodinia, then falls again as the continents re-aggregate into the supercontinent Pangaea. The index rebounds as Pangaea begins to fracture. A Phanerozoic high is reached when the southern paleocontinent of Gondwana fragments into South America, Africa, Antarctica, Australia, and the subcontinent of India. The index downturns again towards the present-day as India collides with Asia to form the Himalayas and Africa begins to close the Mediterranean. 

### further information
+ [Macrostrat Database Paleogeography](www.macrostrat.org/api/paleogeography) These maps can be accessed using the Macrostrat Database's paleogeography route.
+ [Paleobiology Database Navigator](www.paleobiodb.org/navigator) These maps underlie the paleogeographic maps in the Paleobiology Database's data visualization tool.

## Text Mining in Geodeepdive
Fifty percent of my current appointment is funded by the [GeoDeepDive Database](https://geodeepdive.org/) initiative. GeoDeepDive is a digital library of scientific documents (e.g., articles, books, reports). We take these documents from our publishing partners (e.g., Elsevier, Wiley,Taylor & Francis) and process them into data analyzable products: natural language processing (NLP), optical character recognition (OCR), and sophisticated elasticsearch tuples for various dictionary terms (e.g., documents mentioning certain countries, minerals, or organisms).

### excerpt
I generally take these products and analyze them to produce scientific results, but also use text-mining for infrastructure building purposes. Here is a fairly simple R script written with my intern, [Erika Ito](https://github.com/ItoErika), that attempts to match references in the Paleobiology Database with scientific documents in the GeoDeepDive corpus. We first determine the similarity of title, authorship, year, and publication between candidate references, then build a [multiple linear logistic regression model](http://www.ats.ucla.edu/stat/r/dae/logit.htm) that assigns a probability to the match. 

Our group hopes to eventually create strong cross-referenced links between scientific literature stored in major databases like [iDigBio](https://www.idigbio.org/), [iDigPaleo](https://www.idigpaleo.org/), the [Paleobiology Database](https://www.paleobiodb.org/), the [Macrostrat Database](https://www.macrostrat.org/), [Neotoma](https://www.neotomadb.org/), and the [Ocean Biogeographic Information System]((https://www.iobis.org/)). This way data in one database (e.g., the museum where a fossil specimen is stored) can be reliably linked to information stored in the other database (e.g., where the fossil was collected) from the same scientific reference. 

### further information
+ [DeepDive](http://deepdive.stanford.edu/): Our machine learning partner at stanford for the GeoDeepDive project.

## R Package: velociraptr
I authored the velociraptr package for R, which is publically available on [GitHub](https://github.com/paleobiodb/paleobiodb_utilities/tree/master/velociraptr#velociraptr) and [CRAN](https://cran.r-project.org/web/packages/velociraptr/index.html). It is a package designed to make downloading data from the Macrostrat and Paleobiology Database APIs easier for R users. It also includes functions for quickly reshaping, cleaning, and analyzing paleontological data.

### excerpt
This is an [example](https://github.com/aazaff/portfolio/blob/master/excerptRichness.R) using functions from the velociraptr package to caculate the history of Phanerozoic biodiversity for each of the 21 internationally recognized geolgoic epochs in Earth History. It is an excerpt of code I wrote for a paper currently under review at the Proceedings of the National Academy of Sciences. Most of the functions in this script come from the velociraptr package. I have tagged all instances of those functions with the standard R coding convention `velociraptr::function( )` so that it is clear which functions are relevant to the package demo.

### example figure
This figure depicts the history of marine biodiversity (number of unique marine organisms) throughout the history of complex animal life.

![Richness Plot](/images/richnessplot.png)
> Top - The number of different marine animal types during each million year increment of the past 541 million years. This calculation is based on the oldest and youngest fossil occurrence of each animal type. It assumes that each animal was present in all time periods between its first and last fossil occurrence. 

> Bottom - The number of different marine animals types during each internationally reocgnized geologic epoch of the past 541 million years. This calculation is based on the number of unique marine animal fossils found in each time bin. This method differs from the former in that it does not assume animals were present in time-bins where they are not directly observed in the fossil record. The sample size of each bin is standardized using the Shareholder Quorum Subsampling method to account for the fact that some time intervals are more thoroughly sampled than others.

### further information
+ [Quantitative Paleobiology Course Repository](https://github.com/paleobiodb/teachPaleobiology#geoscience-541-paleobiology): Most of these functions were written for practical scientific research purposes. Some were written for my students to use in lab assignments.
+ [quantiativeFossils](https://github.com/aazaff/quantitativeFossils.R): This is the original development repository for this package.

## Multivariate Fossil Analyses
My specialty in ecology is multivariate anlaysis (e.g., ordination, cluster analysis, principal components analysis). These methods take contingency tables of samples with multiple characteristics (i.e., multiple variables), and group sites based on the similarity of the observed characteristics. They allow you to visualize or quantify the similarity of samples to each other based on multiple variables.

For example, if we have a multivariate dataset where each row is a sample from a different geographic location (a site) and each column represents the abundance of a particular species at that site, then we can visualize how similar different samples are to each other based on their constituent species or how similar different species are to each other based on shared geographic distribution. 

### excerpt
This is an excerpt from my dissertation using [detrended correspondence analysis](https://github.com/paleobiodb/teachPaleobiology/blob/master/LabExercise4.md#lab-exercise-4) (i.e., ordination) to infer the presence of  ecological gradients in the distribution of marine organisms 380 million years ago. This method found that these ancient marine taxa rom the Hamilton Group were geographically distributed based on their water depth and sediment type preferences. 

### example figure
![Hamilton Ordination](/images/hamiltonordination.png)
> Ancient sediments deposited in New York during this time (380 ma) follow an unsual geographic distribution. Sediments deposited in deep water are bracketed to the east and west by sediments from shallower-water. To the west was a carbonate bank (tropical reef like environment) and to the east was a siliciclastic shelf (sandy beach type environment). This west to east separation of samples is visible in the DCA of Hamilton samples (A). Samples from western New York counties (reef; blue) are separated in ordination space from samples from the eastern (sandy; red) part of the state (A,B).

> I apply an affine rotation of the samples, which maximizes the correlation of west to east sample geography and DCA Axis 1 (C). This rotates the location of points so they are aligned with the pattern of geographic distribution. Once this correction is applied, the biological clustering of taxa closely follows older qualitative descriptions of where different characteristic taxa should be distributed in relation to water depth and turbidity. The turbidity axis (reef-sandy; west-east) is expressed along DCA Axis 1. Lower DCA 1 scores are dominated by reef taxa, particularly large corals and brachiopods. Sandy-tolerant faunas dominate higher DCA 1 scores, particularly large clams and snails characteristic of ancient beaches. The water depth gradient is expressed along DCA Axis 2. Shallow-water faunas from reefs and beaches plot towards the top, while deeper-water diminutive brachiopods and pelagic taxa (deep-water swimmers) populate the bottom (C,D). 

### further information
+ [Dissertation](https://etd.ohiolink.edu/!etd.send_file?accession=ucin1415625754&disposition=inline): My 2014 dissertation, which focused heavily on ordination methods.
+ [Holland and Zaffos 2011](https://www.jstor.org/stable/23014756?seq=1#page_scan_tab_contents) A paper I co-wrote using ordination and gaussian logistic regression techniques.
+ [Zaffos and Miller 2015](http://www.bioone.org/doi/abs/10.1017/pab.2014.13) A paper I co-wrote using ordination and gaussian logistic regression techniques.
+ [Brett et al. 2016](https://books.google.com/books?id=emwpDQAAQBAJ&pg=PA297&lpg=PA297&dq=holland+and+zaffos+2011&source=bl&ots=tKBUtc0Fpc&sig=stwzAOfgETFfI7SSDt4HcnLEbZk&hl=en&sa=X&ved=0ahUKEwi_14eF0ZLSAhXoJ5oKHUIHB0AQ6AEIHzAB#v=onepage&q=holland%20and%20zaffos%202011&f=false) A paper I co-wrote using ordination and gaussian logistic regression techniques.
