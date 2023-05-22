# Mattia Lombardi 

#-------------------------------------------------------------------------------
#LIBRARIES:
#don't use other libraries for reading the xlsx files
library(xlsx)

#web scraping package:
library(rvest) 
#data manipulation packages:
library(tidyverse)
library(purrr) 
library(dplyr)
library(stringr)
#data visualization packages:
library(ggplot2)
library(plotly)
library(ggmap)
library(maps)
library(scico)


#download the First Excel file from: 
#http://ucs.interno.gov.it/ucs/contenuti/Anagrafe_degli_italiani_residenti_all_estero_a.i.r.e._int_00041-8067961.htm

#save where you prefer and set the path:
#(you can do it also manually from the settings *)
setwd("C:/Users/39349/OneDrive/Desktop/try_italy")

#-------------------------------------------------------------------------------
#DATA READING
#reading the 6' sheets of the AIRE xls file
aire_data <- xlsx::read.xlsx("INT00041_AIRE_DATI_2021_ed_2022.xls",6)
str(aire_data)  

#renames
names(aire_data)[1] <- "provincia"
names(aire_data)[2] <- "num"
aire_data <- aire_data %>% select( c(provincia,num) )
View(aire_data) #semi-structured data


#-------------------------------------------------------------------------------
#WEB SCRAPING 

#reading the table's "Provincie" from Wikipedia
page = read_html("https://it.wikipedia.org/wiki/Province_d%27Italia")

#we need this official data for 2 main reasons: 
#1) data wrangling the AIRE data
#2) extract the tot num of population of each "provincia"

#node's position
wiki_table = html_node(page, ".wikitable")
#convert the html table element into a data_frame
wiki_table = html_table(wiki_table, fill = TRUE)

#cleaning the rows
wiki_table$Provincia <- gsub("[^[:alnum:][:blank:]+?&/\\-]"," ", wiki_table$Provincia)
wiki_table$Provincia <- str_squish(gsub("[[:digit:]]+","", wiki_table$Provincia))
View(wiki_table)

#-------------------------------------------------------------------------------
#DATA WRANGLING
# to confront the 2 datasets we need to standardize the "province" columns

#wiki_table$Provincia
#aire_data$provincia

#these can't be approximated by the agrep function
#(agrep it's a string fuzzy matching function)
wiki_table$Provincia[16]<-"Bolzano-Bozen"
wiki_table$Provincia[4]<-"Aosta"
aire_data$provincia[21]<-"Monza e Brianza"

#return the position
pos<-c()
for(i in 1:length(wiki_table$Provincia)){
  pos[i]<-agrep(wiki_table$Provincia[i],aire_data$provincia)
}

#we can finally match the data :D

#adding the column:
#aire_data$num[pos]  #107 lenght

#binding the columns of interest
fin_table<-cbind(wiki_table$Provincia,
                 wiki_table$`Popolazione(ab)`,
                 aire_data$num[pos]
)

#as_tibble and rename
fin_table<-as_tibble(head(fin_table,-1))
label<-c(provincia="V1",tot_population="V2",num_emigrates="V3")
fin_table<-rename(fin_table, all_of(label))

#string as numeric:
#removing the middle-space in the number of tot_population
fin_table$tot_population<-as.numeric(gsub("[[:space:]]","",fin_table$tot_population))
fin_table$num_emigrates<-as.numeric(fin_table$num_emigrates)

#calculate the % of italian emigrants for each "provincia"
fin_table <- fin_table %>% 
  select(provincia,tot_population,num_emigrates) %>%
  mutate(rate = (num_emigrates/tot_population)*100)

str(fin_table)
View(fin_table)

#-------------------------------------------------------------------------------
#DATA GEOGRAPHICAL VISUALIZATION 

ita<-map_data("italy")

ita %>%
  group_by(region)

#only these 2 "provincia" differs
ita[ita=="Forli'"]<-"Forlì-Cesena"
ita[ita=="L'Aquila"]<-"L Aquila"

#QUERY to join the geographical position with the data gathered before
#(region equal to our "province" in the English language)
geo_data<-left_join(ita,fin_table,by=c("region" = "provincia"))

#anyNA(geo_data$tot_population) #FALSE
View(geo_data)

#the Graph:

#(other styles)
#scale_fill_distiller(palette = "YlOrRd", direction = 1)+
#scico::scale_fill_scico(palette = "devon",direction=-1)+
#scale_fill_viridis_c(option = "magma", direction = -1)+

graph <- ggplot(geo_data,aes(long,lat,text = paste0(region,": ",format(round(rate,2)), "%")))+
  geom_polygon(aes(x=long,y=lat,group=group,fill=rate))+
  geom_path(aes(x=long, y=lat, group=group), color="gray24",size=0.15)+
  scale_fill_gradient2(low = "#ccffcc", mid = "#ff9933",
                       high = "#330000", midpoint = 20) +
  labs(title="Italian Emigrants 2022")+
  theme_bw()

ggplotly(graph, tooltip = list("text"))

#descriptive STATISTICS --------------------------------------------------------

lista<-aggregate(geo_data$rate,
          by = list(prov = geo_data$region),
          mean)

ord_lista<-format(lista[order(lista$x,decreasing = T),],digits=3)
names(ord_lista)[2]<-"mean"
ord_lista$mean<-as.numeric(ord_lista$mean)
ord_lista


lista %>% summarise(across(where(is.numeric), .fns = 
                          list(min = min,
                               median = median,
                               mean = mean,
                               stdev = sd,
                               q25 = ~quantile(., 0.25),
                               q75 = ~quantile(., 0.75),
                               max = max))) %>%
  pivot_longer(everything(), names_sep='_', names_to=c('variable', '.value'))

