# Italian emigrants 2022

This project aims to show a graphical rappresentation of italians moving abroad in the year 2021-2022. 

The data were collected by A.I.R.E ("Anagrafe Italiani Residenti all'Estero") and the dataset was downloaded from the official minister [website](http://ucs.interno.gov.it/ucs/contenuti/Anagrafe_degli_italiani_residenti_all_estero_a.i.r.e._int_00041-8067961.htm) (you could also find a copy of the dataset in this repository).

Another source of data was the Wikipedia's page of the italian subregions ([province](https://it.wikipedia.org/wiki/Province_d%27Italia)), the table data was web-scraped using the library `rvest`. This second dataset was useful for calculating the rate of emigrants for each subregion and also to uniform the data. Indeed the primary dataset from AIRE is semi-structered and some data wrangling was necessary to extract the informations correctly. 

When using different dataset it's important to standardize the records (in this case the subregions, "province"),
indeed we can have different way to call a place. In order to gather succesfully the two source of data I've used the `agrep` function, it's a string fuzzy matching function. It's not perfect, indeed I had to type a couple of subregions manually, overall it makes the trick! After the matching it's possible to create the new "rate" variable. 

The ultimate join it's between the geographical coordinates, extracted by the library `map`, and the new dataset obtained in the last step. 
Now it's possible to plot the data, for this I've used the well known `ggplot2` package. (more info about the libraries used is in the script above in the repository)

The final cherry (on the cake) it's that you can interact with the plot, indeed if you click on the subregion of your interest it'll show you the name and the rate!

![samples](italy_plot.png)


## Instructions

The "italian_emigrants22" it's a reproducible code, written in R language, that only needs in input the AIRE dataset.
Just pay attention that all the packages are correctly installed on your device and that you've settled the path where the AIRE dataset is. 











