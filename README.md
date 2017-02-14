# portfolio
The following is a collection of excerpts from scientific projects, educational resources, or programming scripts developed by [Dr. Andrew Zaffos](www.azstrata.org). Many of these examples have been slightly edited from their original versions to protect proprietary information or ongoing research.

## table of contents
+ [Quantitative Paleobiology](#quantitative-paleobiology): R, git, web APIs
+ [Paleogeographic Analyses](#paleogeographic-analyses): postGIS, R, postgreSQL, web APIs
+ Machine Learning in GeoDeepDive: R, postgreSQL, Condor (high-throughput computing)
+ Velociraptr Package: R, web APIs
+ Multivariate Fossil Analyses: R

## quantitative paleobiology
I taught an upper-level Quantitative Paleobiology course at the University of Wisconsin-Madison during the Spring 2016 semester. The course focused on points of ecological and geological theory, statistical principles, programming in R, web API usage, and used GitHub as the primary course assignment submission, material distribution, and grading platform. This project was funded as part of an NSF research grant to develop educational tools related to the [Paleobiology Database](www.paleobiodb.org) data service ([API](https://paleobiodb.org/data1.2/)). 

### excerpt
I have forked one of the [lab assignments](https://github.com/aazaff/portfolio/blob/master/lab_9v2.md#the-migration-of-paleocontinents) from the class to this repository. It deals with plotting paleogeographic maps and fossil data in R using the [Macrostrat Database](www.macrostrat.org) API, [Paleobiology Database](www.paleobiodb.org) API, and the [rgdal](https://cran.r-project.org/web/packages/rgdal/rgdal.pdf) geospatial analysis package. A paleogeographic map is a depiction of where the continents were located n-million years ago.

### example figure
This is one of the maps that students create over the course of the lab.
![Paleocontinent Image](/images/Alice.png)
> A graphic of paleocontinent orientations in the Albian (110 mya; green), Masstrichtian (66 mya; blue), and present (red), using [Macrostrat's](www.macrostrat.org) implementation of the [GPlates](www.gplates.org) rotation model in R.

### further information
+ [Course GitHub Repository](https://github.com/paleobiodb/teachPaleobiology#geoscience-541-paleobiology): The courses main page (readme) has links to the syllabus, lectures, lab assignments, reading assignments, writing assignments, GitHub tutorial, and R tutorial.
+ [R Tutorial](https://github.com/aazaff/startLearn.R/blob/master/README.md#an-introduction-to-r): A lengthy R tutorial covering beginner, intermediate, advanced, and expert level topics in R.
+ [GitHub Tutorial](https://github.com/paleobiodb/teachPaleobiology/blob/master/GitTutorial/gitTutorial.md#introduction): A simple GitHub tutorial used to teach students how to create a GitHub account and repository, and how to pull and push to the repo.

## paleogeographic analyses
I generally conduct most of my geospatial analyses in [QuantumGIS](www.qgis.org) or [postGIS](http://www.postgis.net/). This is an example of some R scripts I wrote that clean and analyze 550 Paleogeographic Maps from the [EarthByte](www.earthbyte.org) paleocoordinate rotation model using the RPostgreSQL package and postGIS. They are a port/refactor of deprecated python/SQL code written by [John Czaplewski](https://github.com/UW-Macrostrat/alice). These maps and data products underlie several of our group's web applications (see below) and are also an important part of our paper currently under review at the Proceedings of the National Academy of Sciences.

### excerpt
I have forked a modified version of the original [R script](https://github.com/aazaff/portfolio/blob/master/quantifyPlate.RV2) from our lab group's private repository to here. This script ingests the original shapefiles and calculates various metrics about the Earth's former paleogeographic state. This includes, for example, the changing distance between all pairwise comparisons of tectonic plates throughout the history of the Phanerozoic. 

**This script will not run without the original datafiles.** It is only included as a demonstration of how R can be used to interact with postGIS.

### example figure
This is an example of how the maps and geographic indices created by the above R script can be used for scientific purposes. I take the maps used above to create a novel index of supercontinenent coalescence-breakup. It is a quantitative expression of how dispersed continental crustal blocks (i.e., tectonic plates) are throughout the history of complex animal life (541-0 mya). An index value of unity indicates no plates are touching; an index value of zero corresponds to the state that would be achieved if all of continental blocks were contiguous and arranged in a single mass with a minimal ratio of perimeter to area.

![Perimeter Index](/images/PerimeterIndexExample.png)
> Top - A visualization of how the fragmentation index is calculated. We divide the total perimeter of exposed plate borders by the total perimeter of all borders, then substract the circumference of a circle with area equal to all of the Earth's plates. We only use plates that persist throughout the entirety of the past 541 million years to keep the calculation consistent.
> Bottom - The history of continental fragmentation over the history of complex animal life. It initially rises in response to the breakup of the Proterozoic supercontinent of Rodinia. A series of alternating plateaus and declines follows reflecting the progressive re-aggregation of continental blocks into the Phanerozoic supercontinent Pangaea. A steady rise begins in the mid-Jurassic reflecting the breakup of Pangaea and, notably, the southern continent of Gondwana, which persisted largely intact throughput the Paleozoic. Today, Gondwana is represented by the distinct continents of South America, Africa, Antarctica, Australia, as well as the subcontinent of India. The marked decrease in the continental fragmentation index from the early Cenozoic maximum reflects the collision of dispersed Gondwanan continental blocks with northern hemisphere continents, a transition that is most dramatically represented by the isolation of India during peak continental fragmentation and its mid-Cenozoic collision with Asia to form the Himalayas. If present-day plate motions persist, the index will continue to decline as the last remnant of the ancient Tethys sea, the Mediterranean, is eliminated by the collision of Africa with Eurasia.

### further information
+ [Macrostrat Database Paleogeography](www.macrostrat.org/api/paleogeography) These maps can be accessed using the Macrostrat Database's paleogeography route.
+ [Paleobiology Database Navigator](www.paleobiodb.org/navigator) These maps underlie the paleogeographic maps in the Paleobiology Database's data visualization tool.

## machine learning in geodeepdive
Fifty percent of my current appointment is funded by the [GeoDeepDive Database](https://geodeepdive.org/) initiative. GeoDeepDive is a digital library of scientific documents (e.g., articles, books, reports). We take these documents from our publishing partners (e.g., Elsevier, Wiley) and process them into data analyzable products: natural language processing (NLP), optical character recognition (OCR), and sophisticated elasticsearch tuples for various dictionary terms (e.g., documents mentioning certain countries, minerals, or organisms).

### excerpt
I take these products and analyze them to produce scientific results. One project I am currently working on with my intern, [Erika Ito](https://github.com/ItoErika) attempts to identify fossiliferous formations in the scientific literature, and associated age and geolocation information. Because this is ongoing research, some of the code has been hidden.

### further information
+ [DeepDive](http://deepdive.stanford.edu/): Our machine learning partner at stanford.

## multivariate ordination
