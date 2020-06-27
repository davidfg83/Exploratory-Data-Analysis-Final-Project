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

#Compare emissions from motor vehicle sources in Baltimore 
#City with emissions from motor vehicle sources in Los 
#Angeles County, California (fips == "06037"). Which city 
#has seen greater changes over time in motor vehicle 
#emissions?

#subset Baltimore & LA data
dat <- NEI[NEI$fips %in% c("24510", "06037"), ]  

#retitle fips as city
dat <- rename(dat, city = fips)
#replace fips codes with city names
dat$city <- gsub("24510", "Baltimore", dat$city)
dat$city <- gsub("06037", "LA", dat$city)

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

#subset data for motor vehicles only
dat_mv <- dat[dat$SCC %in% SCC_mv,]

#create dataframe with total motor vehicles emissions by year
dat_te_mv <- dat_mv %>% group_by(city, year) %>% summarize(emissions = sum(Emissions))

#create variable emissions as % of 1999
dat_te_mv <- dat_te_mv %>% mutate(percent1999 = case_when(city == "Baltimore" ~ 100*emissions/dat_te_mv$emissions[[1]], city == "LA" ~ 100*emissions/dat_te_mv$emissions[[5]]))

#open png file
png(filename = "plot6.png")

#create plot
g6 <- ggplot(dat_te_mv, aes(year, percent1999))
# fill plot
g6 + geom_point(aes(color = city), size = 2) + labs(x = "Year", y = "Motor Vehicle Emissions as % of 1999 Emissions", title = "PM2.5 Emissions by Motor Vehicles in Baltimore and LA as % of 1999 Emissions") + geom_path(aes(group = city, color = city)) + scale_x_continuous(breaks = dat_te_mv$year, labels = dat_te_mv$year)
dev.off()