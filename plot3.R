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

#check if ggplot2 package is installed&loaded
if(!require(ggplot2)){
        install.packages("ggplot2")
        library(ggplot2)
}


#read data
NEI <- readRDS("summarySCC_PM25.rds")

#Of the four types of sources indicated by the type 
#(point, nonpoint, onroad, nonroad) variable, which of 
#these four sources have seen decreases in emissions 
#from 1999–2008 for Baltimore City? Which have seen 
#increases in emissions from 1999–2008? Use the 
#ggplot2 plotting system to make a plot answer this question.

#subset Baltimore data
bal <- NEI[NEI$fips == "24510", ]  

#group data by type, year calculate sum
pm25_t_y <- bal %>% group_by(type,year) %>% summarise(emissions = sum(Emissions))

# make type lowercase
pm25_t_y$type <- tolower(pm25_t_y$type)
# make variable values consistent by changing nonpoint to non-point
pm25_t_y[pm25_t_y$type == "nonpoint", ]$type <- "non-point"

#open png file
png(filename = "plot3.png")

#create plot
g3 <- ggplot(pm25_t_y, aes(year, emissions))
# fill plot (scale color discrete command used to sort legend)
g3 + geom_point(aes(color = type), size = 3) + labs(x = "Year", y = "Total Emissions (tons)", title = "Fine Particular Matter (PM2.5) Emissions in Baltimore by Type") + geom_path(aes(group = type, color = type), size = 1.25) + scale_color_discrete(breaks=c("non-point","point","non-road", "on-road")) + scale_x_continuous(breaks = pm25_t_y$year, labels = pm25_t_y$year)
dev.off()