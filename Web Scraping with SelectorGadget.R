#Web Scraping with SelectorGadget

#rvest
#A package that makes it easy to extract info from a webpage
library(rvest)

#Strategy

#Download the HTML and turn it into an XML file with read_html()

frozen <- read_html("https://www.imdb.com/title/tt2294629/")

#Use vignette("selectorgadget") select directly on page the cast name
cast<- html_nodes(frozen,"td:nth-child(2) a")

#Text list of the names
html_text(cast)

#Create data frame of cast names
castdf <- as.data.frame(html_text(cast))
View(castdf)

#Label dataframe
colnames(castdf) <- c('Name')

#Creates two columns for First and Last name
library(tidyr)
castdf2 <- extract(castdf, 'Name', c("First", "Last"), "([^ ]+) (.*)")
View(castdf2)









