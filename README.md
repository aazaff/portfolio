# Portfolio
The following is a collection of excerpts from scientific projects, educational resources, and programming scripts developed by [Dr. Andrew Zaffos](http://www.azstrata.org). Some examples have been edited from their original versions to protect proprietary information or ongoing research.

## Table of Contents
###[Quantitative Paleobiology](#quantitative-paleobiology-excerpt): R, git, web APIs
I taught an upper-level Quantitative Paleobiology course at the University of Wisconsin-Madison during the Spring 2016 semester. The course focused on points of ecological and geological theory, statistical principles, programming in R, and web API usage. The class used GitHub as the primary assignment submission, material distribution, and grading platform. This project was funded as part of an NSF research grant to develop educational tools related to the [Paleobiology Database](https://www.paleobiodb.org) data service ([API](https://paleobiodb.org/data1.2/)). 

### [Paleogeographic Analyses](#paleogeographic-analyses-excerpt): PostGIS, R, PostgreSQL, web APIs
I conduct most of my geospatial analyses in [QGIS](https://www.qgis.org) or [PostGIS](http://www.postgis.net/). This is an example of some R scripts I wrote to clean and analyze paleogeographic maps from the [EarthByte](https://www.earthbyte.org) paleocoordinate rotation model using the RPostgreSQL package and PostGIS. They are a port/refactor of deprecated python/SQL code written by [John Czaplewski](https://github.com/UW-Macrostrat/alice). These maps and data products underlie several of our group's web applications and are also an important part of our paper currently under review at the Proceedings of the National Academy of Sciences.

### [Text Mining in GeoDeepDive](#text-mining-in-geodeepdive-demo): R, PostgreSQL, Condor (high-throughput computing)
Fifty percent of my current appointment is funded by the [GeoDeepDive](https://geodeepdive.org/) initiative. GeoDeepDive is a digital library of scientific documents (e.g., articles, books, reports). We take these documents from our publishing partners (e.g., Elsevier, Wiley,Taylor & Francis) and process them into data analyzable products: natural language processing (NLP), optical character recognition (OCR), and sophisticated elasticsearch tuples for various dictionary terms (e.g., documents mentioning certain countries, minerals, or organisms). Many of our applications need to run on the [CHTC](http://chtc.cs.wisc.edu/) high-throughput computing infrastructure because of the size of the GeoDeepDive corpus (>2.5 million documents; 10TB and growing).

### [Velociraptr Package](#r-package-velociraptr-demo): R, web APIs
I authored the velociraptr package for R, which is publically available on [GitHub](https://github.com/paleobiodb/paleobiodb_utilities/tree/master/velociraptr#velociraptr) and [CRAN](https://cran.r-project.org/web/packages/velociraptr/index.html). It is a package designed to make downloading data from the Macrostrat and Paleobiology Database APIs easier for R users. It also includes functions for quickly reshaping, cleaning, and analyzing paleontological data.

### [Multivariate Fossil Analyses](#multivariate-fossil-analyses-demo): R
My specialty in ecology is multivariate anlaysis (e.g., ordination, cluster analysis, principal components analysis). These methods take contingency tables of samples with multiple characteristics (i.e., multiple variables), and group sites based on the similarity of the observed characteristics. They allow you to visualize or quantify the similarity of samples to each other based on multiple variables.

## Quantitative Paleobiology Excerpt
I have forked one of the lab assignments from the class to this repository. It involves plotting paleogeographic maps and fossil data in R using the [Macrostrat Database](https://www.macrostrat.org) API, [Paleobiology Database](https://www.paleobiodb.org) API, and the [rgdal](https://cran.r-project.org/web/packages/rgdal/rgdal.pdf) geospatial analysis package. A paleogeographic map is a depiction of where the continents were located n-million years ago.

**Script**: [labPaleocontinent.md](/labPaleocontinent.md#the-migration-of-paleocontinents)

### example figure
This is one of the maps students create during the lab.

![Paleocontinent Image](/images/Alice.png)
> A graphic of paleocontinent orientations in the Albian (110 mya; green), Masstrichtian (66 mya; blue), and present (red), using Macrostrat's paleogeographic maps from EarthByte.

### further information
+ [Course GitHub Repository](https://github.com/paleobiodb/teachPaleobiology#geoscience-541-paleobiology): The courses main page (readme) has links to the syllabus, lectures, lab assignments, reading assignments, writing assignments, GitHub tutorial, and R tutorial.
+ [R Tutorial](https://github.com/aazaff/startLearn.R/blob/master/README.md#an-introduction-to-r): A lengthy R tutorial covering beginner, intermediate, advanced, and expert level topics in R.
+ [GitHub Tutorial](https://github.com/paleobiodb/teachPaleobiology/blob/master/GitTutorial/gitTutorial.md#introduction): A simple GitHub tutorial used to teach students how to create a GitHub account and repository, and how to pull and push to the repo.

## Paleogeographic Analyses Excerpt
I have forked a modified version of the original [R script](https://github.com/aazaff/portfolio/blob/master/quantifyPlate.R) from our lab group's private repository to here. This script ingests the original shapefiles and calculates various metrics about the Earth's former paleogeographic state. This includes, for example, the changing distance between pairs of tectonic plates through time. 

**Script**: [quantifyPlate.R](/quantifyPlate.R)

**NOTE: This script will not run without the original datafiles.** It is only included as a demonstration of how R can be used to interact with postGIS.

### example figure
This is an example of how the maps and geographic indices created by the above R script can be used for scientific purposes. I take the maps used above to create a novel index of supercontinenent (e.g., Pangea) coalescence-breakup. It is a quantitative expression of how dispersed continental crustal blocks (i.e., tectonic plates) are throughout the history of complex animal life (541-0 mya). An index value of unity indicates no plates are touching; an index value of zero indicates the formation of a perfectly circular supercontinent.

![Perimeter Index](/images/PerimeterIndexExample.png)
> Top - A visualization of how the fragmentation index is calculated. We divide the total perimeter of exposed plate borders by the total perimeter of all borders, then substract the circumference of a circle with area equal to all of the Earth's plates. We only use plates that persist throughout the entirety of the past 541 million years to keep the calculation consistent.

> Bottom - The history of continental fragmentation over the history of complex animal life. It initially rises in response to the breakup of the Proterozoic supercontinent of Rodinia, then falls again as the continents re-aggregate into the supercontinent Pangaea. The index rebounds as Pangaea begins to fracture. A Phanerozoic high is reached when the southern paleocontinent of Gondwana fragments into South America, Africa, Antarctica, Australia, and the subcontinent of India. The index downturns again towards the present-day as India collides with Asia to form the Himalayas and Africa begins to close the Mediterranean. 

### further information
+ [Macrostrat Database Paleogeography](https://www.macrostrat.org/api/paleogeography) These maps can be accessed using the Macrostrat Database's paleogeography route.
+ [Paleobiology Database Navigator](https://www.paleobiodb.org/navigator) These maps underlie the paleogeographic maps in the Paleobiology Database's data visualization tool.

## Text Mining in GeoDeepDive Demo
I generally take these products and analyze them to produce scientific results, but also use text-mining for infrastructure building purposes. Here is a fairly simple R script written with my intern, [Erika Ito](https://github.com/ItoErika), that attempts to match references in the Paleobiology Database with scientific documents in the GeoDeepDive corpus. We first determine the similarity of title, authorship, year, and publication between candidate references, then build a [multiple linear logistic regression model](http://www.ats.ucla.edu/stat/r/dae/logit.htm) that assigns a probability to the match. 

Our group hopes to eventually create strong cross-referenced links between scientific literature stored in major databases like [iDigBio](https://www.idigbio.org/), [iDigPaleo](https://www.idigpaleo.org/), the [Paleobiology Database](https://www.paleobiodb.org/), the [Macrostrat Database](https://www.macrostrat.org/), [Neotoma](https://www.neotomadb.org/), and the [Ocean Biogeographic Information System](https://www.iobis.org/). This way data in one database (e.g., the museum where a fossil specimen is stored) can be reliably linked to information stored in the other database (e.g., where the fossil was collected) from the same scientific reference. 

**Script**: [epandda.R](\epandda.R)

### further information
+ [DeepDive](http://deepdive.stanford.edu/): Our machine learning partner at stanford for the GeoDeepDive project.
+ [ePANDDA](https://steppe.org/epandda/): A brief description of the ePANDDA working group, which is an affiliate of this project.

## R Package: velociraptr Demo
This is an example script using functions from the velociraptr package to caculate the history of Phanerozoic biodiversity for each of the 34 internationally recognized geolgoic epochs in Earth History. It is an excerpt of code I wrote for a paper currently under review at the Proceedings of the National Academy of Sciences. Most of the functions in this script come from the velociraptr package. I have tagged all instances of those functions with the standard R coding convention `velociraptr::function( )` so that it is clear which functions are relevant to the package demo.

**Script**: [excerptRichness.R](\excerptRichness.R)

### example figure
This figure depicts the history of marine biodiversity (number of unique marine organisms) throughout the history of complex animal life.

![Richness Plot](/images/richnessplot.png)
> Top - The number of different marine animal types during each million year increment of the past 541 million years. This calculation is based on the oldest and youngest fossil occurrence of each animal type. It assumes that each animal was present in all time periods between its first and last fossil occurrence. 

> Bottom - The number of different marine animals types during each internationally reocgnized geologic epoch of the past 541 million years. This calculation is based on the number of unique marine animal fossils found in each time bin. This method differs from the former in that it does not assume animals were present in time-bins where they are not directly observed in the fossil record. The sample size of each bin is standardized using the Shareholder Quorum Subsampling method to account for the fact that some time intervals are more thoroughly sampled than others.

### further information
+ [Quantitative Paleobiology Course Repository](https://github.com/paleobiodb/teachPaleobiology#geoscience-541-paleobiology): Most of these functions were written for practical scientific research purposes. Some were written for my students to use in lab assignments.
+ [quantiativeFossils](https://github.com/aazaff/quantitativeFossils.R): This is the original development repository for this package.

## Multivariate Fossil Analyses Demo
In this example, we start with a multivariate dataset where each row is a sample from a different geographic location (a site) and each column represents the abundance of a particular species at that site. We use [detrended correspondence analysis](https://github.com/paleobiodb/teachPaleobiology/blob/master/LabExercise4.md#lab-exercise-4) to measure how similar different samples are to each other based on their constituent species or how similar different species are to each other based on shared geographic distribution. This is an excerpt from my dissertation using detrended correspondence analysis to quantify the presence of ecological gradients in the distribution of marine organisms 380 million years ago. This analysis found that ancient marine animals from New York were geographically and environmentally distributed based on their water depth and sediment type preferences. 

**Script**: [ordinateHamilton.R](\ordinateHamilton.R)

### example figure
Ancient fossil-bearing marine sediments deposited in New York ~380 million years ago follow an unsual geographic distribution. Sediments near the Finger Lakes region of central New York were deposited in very deep water, and are bracketed to the east and west by sediments from shallower-water environments. There was a tropical reef like environment to the west (near modern day Buffalo), and a sandy beach environment to the east (past Syracuse). This figures illustrates how DCA can be used to understand the distribution of different species in this complex geographic and environmental context.

![Hamilton Ordination](/images/hamiltonordination.png)
> Top Left - This is an unrotated ordination of New York fossils from ~380 million years ago. Each point represents a different sample of fossils taken from various points in New York. The closer points are together, the more species they have in common. Conversely, samples that are far apart in the plot share few or no species. However, because there are >100 species and >400 samples, we cannot know what is causing these species to be distributed differently without more contextual information.

> Top Right - This is a map of New York State Counties. Western counties with reef-like sediments are colored blue. Central counties with deep water and mixed-sediment type conditions are colored orange. Eastern counties with sandy beach-like sediments are colored red. If we go back and color the first figure (Top Left) using this schema, we see that the bottom-left of the plot is dominated by samples from the western, reef environment and top-left samples are dominated by the eastern, beach environment. 

> Bottom Left - This is a variation of the first figure illustrating the relative similarity of different New York fossil species. Each point represents a species. The closer points are to each other then the more sites they co-habitate. In addition, I applied an affine rotation to the points, so the x-axis runs parallel to the west-east (blue-red) gradient that ran diagonally across the original ordination (Top Left)

> Bottom Right - Once this rotation is applied, the visual clustering of taxa closely follows older qualitative descriptions of species' water depth and turbidity preferences. The turbidity axis (reef-sandy; west-east) is expressed along DCA Axis 1. Lower DCA 1 scores are dominated by tropical reef taxa, particularly large corals and brachiopods. Sandy-tolerant faunas dominate higher DCA 1 scores, particularly large clams and snails characteristic of ancient beaches. The water depth gradient is expressed along DCA Axis 2. Shallow-water faunas from reefs and beaches plot toward the top, while deeper-water diminutive brachiopods and pelagic taxa (deep-water swimmers; purple) populate the bottom. Now that we have quantitatively expressed the environmental and geographic relationships of these different organisms, we can use this information to test further hypotheses about extinction or migration patterns. 

### further information
+ [Dissertation](https://etd.ohiolink.edu/!etd.send_file?accession=ucin1415625754&disposition=inline): My 2014 dissertation, which focused heavily on ordination methods.
+ [Holland and Zaffos 2011](https://www.jstor.org/stable/23014756?seq=1#page_scan_tab_contents) A paper I co-wrote using ordination and gaussian logistic regression techniques.
+ [Zaffos and Miller 2015](http://www.bioone.org/doi/abs/10.1017/pab.2014.13) A paper I co-wrote using ordination and gaussian logistic regression techniques.
+ [Brett et al. 2016](https://books.google.com/books?id=emwpDQAAQBAJ&pg=PA297&lpg=PA297&dq=holland+and+zaffos+2011&source=bl&ots=tKBUtc0Fpc&sig=stwzAOfgETFfI7SSDt4HcnLEbZk&hl=en&sa=X&ved=0ahUKEwi_14eF0ZLSAhXoJ5oKHUIHB0AQ6AEIHzAB#v=onepage&q=holland%20and%20zaffos%202011&f=false) A paper I co-wrote using ordination and gaussian logistic regression techniques.
