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

## QUESTION 2: Have total emissions from PM2.5 decreased 
#in the Baltimore City, Maryland (fips = "24510") from 
#1999 to 2008? Use the base plotting system to make a 
#plot answering this question.

#subset Baltimore data
bal <- NEI[NEI$fips == "24510", ]  

# create data frame with total emissions by year
te_bal <- bal %>% group_by(year) %>% summarize(emissions = sum(Emissions))

#open png file
png(filename = "plot2.png")

# set margins
par(mar = c(4, 4, 2, 0))

#create plot
plot(te_bal$year, te_bal$emissions, xaxp = c(1999, 2008, 3), pch = 16, cex = 1.5, col = "red", xlab = "Year", ylab = "Total Emissions (tons)", type = "o")
#title
title(main = "Total Fine Particular Matter (PM2.5) Emissions in Baltimore")
dev.off()