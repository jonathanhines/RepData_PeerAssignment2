# If the source isn't downloaded yet go get it and download it
source_data_file <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
work_data_file <- "assignment.bz2"
if (!file.exists(work_data_file)) {
  if( Sys.info()['sysname'] == "windows" ) {
    download.file(source_data_file, destfile=work_data_file, mode="wb")
  } else {
    download.file(source_data_file, destfile=work_data_file, method = "curl")
  }
  write(date(), file="dateDownloaded.txt")
}

# Read the data
if(!exists("raw_data")){
  raw_data <- read.csv(bzfile(work_data_file))
}

# Take a look at the event types that cause the most fatalities
fatalities_sum <- aggregate(raw_data$FATALITIES,list(EventType = raw_data$EVTYPE) ,sum)

#get the list sorted by fatalities descending
fso <- fatalities_sum[order(fatalities_sum$x,decreasing = TRUE),]

#Plot it to illustrate the most dangerous event types
barplot(head(fso$x), names.arg=head(fso$EventType))