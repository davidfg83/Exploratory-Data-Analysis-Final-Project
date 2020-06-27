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
SCC <- readRDS("Source_Classification_Code.rds")

#rows of SCC with coal in EI.Sector 
coal <- grep(".*coal.*", SCC$EI.Sector, value = FALSE, ignore.case = TRUE)

#SCC codes corresponing to those rows
SCC_coal <- SCC[coal, 1]

#subset NEI by SCC codes corresponding to coal SCC codes
df_coal <- NEI[NEI$SCC %in% SCC_coal, ]

#group data by year calculate sum of total coal-burning emissions
tcbe <- df_coal %>% group_by(year) %>% summarise(emissions = sum(Emissions))

#open png file
png(filename = "plot4.png")

#create plot
g4 <- ggplot(tcbe, aes(year, emissions))
# fill plot
g4 + geom_point(size = 2, color = "steelblue") + labs(x = "Year", y = "Total Emissions (tons)", title = "PM2.5 Emissions fom Coal Combustion-related Sources") + geom_line(color = "steelblue") + scale_x_continuous(breaks = tcbe$year, labels = tcbe$year)
dev.off()