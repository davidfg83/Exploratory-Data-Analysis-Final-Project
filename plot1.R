#check if data exist; otherwise download, unzip
if(!file.exists("./summarySCC_PM25.rds")){
        #download data in zip format
        fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
        download.file(fileUrl, destfile = "rawdata.zip")
        #unzip the data;
        unzip("rawdata.zip")
}

#check if dplyr package is installed&loaded
if(!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}

#read data
NEI <- readRDS("summarySCC_PM25.rds")

## QUESTION 1: Have total emissions from PM2.5 decreased 
# in the United States from 1999 to 2008? Using the base 
#plotting system, make a plot showing the total PM2.5 
# emission from all sources for each of the years 1999, 
#2002, 2005, and 2008.

#create dataframe with total emissions by year
te <- NEI %>% group_by(year) %>% summarize(emissions = sum(Emissions))


#open png file
png(filename = "plot1.png")

# set margins
par(mar = c(4, 4, 2, 0))

#create plot (type "o" adds dots and lines)
plot(te$year, te$emissions/1000000, xaxp = c(1999, 2008, 3), pch = 16, cex = 1.5, col = "blue", xlab = "Year", ylab = "Total Emissions (millions of tons)", type = "o")
#title
title(main = "Total Fine Particular Matter (PM2.5) Emissions in the US")
dev.off()