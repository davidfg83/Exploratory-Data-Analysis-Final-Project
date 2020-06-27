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

#Question 5: How have emissions from motor vehicle 
#sources changed from 1999–2008 in Baltimore City?

#subset Baltimore data
bal <- NEI[NEI$fips == "24510", ]  

#Motor vehicle definition: https://www.justice.gov/archives/jm/criminal-resource-manual-1303-definitions-motor-vehicle-aircraft-security 
# matches loosely those in EI.Sectors (number in [] is corresponding element in output of unique[SCC$EI.Sector])
        #Mobile - On-Road Gasoline Light Duty Vehicles [21]
        #Mobile - On-Road Gasoline Heavy Duty Vehicles [22]
        #Mobile - On-Road Diesel Light Duty Vehicles [23]       
        #Mobile - On-Road Diesel Heavy Duty Vehicles [24]
        #Mobile - Non-Road Equipment - Gasoline [25]           
        #Mobile - Non-Road Equipment - Other [26]             
        #Mobile - Non-Road Equipment - Diesel [27]

#define SCCs corresponding to motor vehicles
mv <- unique(SCC$EI.Sector)[21:27]
SCC_mv <- SCC[SCC$EI.Sector %in% mv, 1]

#subset Baltimore data for motor vehicles only
bal_mv <- bal[bal$SCC %in% SCC_mv,]

#create dataframe with total motor vehicles emissions by year in Baltimore
te_mv <- bal_mv %>% group_by(year) %>% summarize(emissions = sum(Emissions))

#open png file
png(filename = "plot5.png")

#create plot
g5 <- ggplot(te_mv, aes(year, emissions))
# fill plot
g5 + geom_point(size = 2, color = "steelblue") + labs(x = "Year", y = "Motor Vehicle Emissions (tons)", title = "PM2.5 Emissions from Motor Vehicles in Baltimore") + geom_line(color = "steelblue") + scale_x_continuous(breaks = te_mv$year, labels = te_mv$year)
dev.off()