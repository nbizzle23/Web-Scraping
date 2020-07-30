#Webscraping Extracting Table

library(rvest)

#Download the HTML and turn it into an XML file with read_html()
orlando <- read_html("http://www.bestplaces.net/climate/city/florida/orlando") 

#Use html_table
tables <- html_nodes(orlando, css = "table") 
html_table(tables, fill = TRUE)

#Create data frame of extact table
dftable <- html_table(tables, fill = TRUE)[[1]]
dftable


#Label columns accordingly
colnames(dftable) <- c("Climate", "Orlando, Florida", "United States")

#dftable <- dftable[-c(1),] removes first row
View(dftable)
