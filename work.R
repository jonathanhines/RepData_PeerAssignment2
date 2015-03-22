# If the source isn't downloaded yet go get it and download it
source_data_file <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
work_data_file <- "assignment.csv.bz2"
if (!file.exists(work_data_file)) {
  if( Sys.info()['sysname'] == "Windows" ) {
    download.file(source_data_file, destfile=work_data_file, mode="wb")
  } else {
    download.file(source_data_file, destfile=work_data_file, method = "curl")
  }
  write(date(), file="dateDownloaded.txt")
}

# Read the data
if(!exists("clean_data")){
  library(stringr)
  raw_data <- read.csv(bzfile(work_data_file), stringsAsFactors = F, strip.white = T)
  # before 1996 not all events were recorded, therefore eliminate them to remove bias
  raw_data$BGN_DATE <- strptime(raw_data$BGN_DATE, format = "%m/%d/%Y %T")
  clean_data <- raw_data[
    raw_data$BGN_DATE > strptime("12/31/1995 23:59:59", format = "%m/%d/%Y %T"),
    c("EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP", "CROPDMG",  "CROPDMGEXP")
  ]
  clean_data$EVTYPE <- as.factor(str_trim(clean_data$EVTYPE))
  clean_data$PROPDMGEXP <- as.factor(clean_data$PROPDMGEXP)
  clean_data$CROPDMGEXP <- as.factor(clean_data$CROPDMGEXP)
  clean_data[clean_data$PROPDMGEXP == "K","PROPDMG"] <- clean_data[clean_data$PROPDMGEXP == "K","PROPDMG"] * 1e3
  clean_data[clean_data$PROPDMGEXP == "M","PROPDMG"] <- clean_data[clean_data$PROPDMGEXP == "M","PROPDMG"] * 1e6
  clean_data[clean_data$PROPDMGEXP == "B","PROPDMG"] <- clean_data[clean_data$PROPDMGEXP == "B","PROPDMG"] * 1e9
  clean_data[clean_data$CROPDMGEXP == "K","CROPDMG"] <- clean_data[clean_data$CROPDMGEXP == "K","CROPDMG"] * 1e3
  clean_data[clean_data$CROPDMGEXP == "M","CROPDMG"] <- clean_data[clean_data$CROPDMGEXP == "M","CROPDMG"] * 1e6
  clean_data[clean_data$CROPDMGEXP == "B","CROPDMG"] <- clean_data[clean_data$CROPDMGEXP == "B","CROPDMG"] * 1e9
}

if(F) {
# Take a look at the event types that cause the most fatalities
fatalities_sum <- aggregate(clean_data$FATALITIES,list(EventType = clean_data$EVTYPE) ,sum)

#get the list sorted by fatalities descending
fso <- fatalities_sum[order(fatalities_sum$x,decreasing = TRUE),]

#Plot it to illustrate the most dangerous event types
barplot(head(fso$x, n = 10), names.arg=head(fso$EventType, n = 10), las=2)

#Assess Injuries
# Take a look at the event types that cause the most fatalities
injuries_sum <- aggregate(clean_data$INJURIES,list(EventType = clean_data$EVTYPE) ,sum)

#get the list sorted by fatalities descending
iso <- injuries_sum[order(injuries_sum$x,decreasing = TRUE),]

#Plot it to illustrate the most dangerous event types
barplot(head(iso$x, n = 10), names.arg=head(iso$EventType, n = 10), las=2)


## Property Damage
propdmg_sum <- aggregate(clean_data$PROPDMG,list(EventType = clean_data$EVTYPE) ,sum)
pso <- propdmg_sum[order(propdmg_sum$x,decreasing = TRUE),]
barplot(head(pso$x, n = 10), names.arg=head(pso$EventType, n = 10), las=2)


## Crop Damage
cropdmg_sum <- aggregate(clean_data$CROPDMG,list(EventType = clean_data$EVTYPE) ,sum)
cso <- cropdmg_sum[order(cropdmg_sum$x,decreasing = TRUE),]
barplot(head(cso$x, n = 10), names.arg=head(cso$EventType, n = 10), las=2)




top_n = 8
top_is = head(iso, n = top_n)
top_fs = head(fso, n = top_n)
length(unique(c(top_fs$EventType,top_is$EventType)))
combined_sums = rbind(top_fs,top_is)

# Get a set of everything in the top injuries and fatalities for both sets
is_tops = injuries_sum[injuries_sum$EventType %in% combined_sums$EventType, ]
fs_tops = fatalities_sum[fatalities_sum$EventType %in% combined_sums$EventType, ]
plotSums <- cbind(is_tops$x,fs_tops$x)
rownames(plotSums) <- is_tops$EventType
colnames(plotSums) <- c("Injury","Fatality")
# Sort it to get the biggest first
plotSums <- plotSums[order(plotSums[,2], decreasing = T),]

#Make the plot
plot_colors <- c("darkblue","red")
op <- par(no.readonly = TRUE)
par(mar=c(8,4,2,2))
barplot(t(plotSums), beside=T, las=2, col=plot_colors, cex.names=0.7, main="Harm to human Health across the United States")
legend("topright",colnames(plotSums), fill=plot_colors)
box(bty="l")
suppressWarnings(par(op))




## Assess cost
top_n = 8
top_ps = head(pso, n = top_n)
top_cs = head(cso, n = top_n)
length(unique(c(top_cs$EventType,top_cs$EventType)))
combined_sums = rbind(top_cs,top_ps)

# Get a set of everything in the top injuries and fatalities for both sets
ps_tops = propdmg_sum[propdmg_sum$EventType %in% combined_sums$EventType, ]
cs_tops = cropdmg_sum[cropdmg_sum$EventType %in% combined_sums$EventType, ]
plotSums <- cbind(ps_tops$x,cs_tops$x)
rownames(plotSums) <- ps_tops$EventType
colnames(plotSums) <- c("Property Damage","Crop Damage")
# Sort it to get the biggest first
plotSums <- plotSums[order(plotSums[,1], decreasing = T),]

#Make the plot
plot_colors <- c("darkblue","red")
op <- par(no.readonly = TRUE)
par(mar=c(8,5,2,2))
barplot(t(plotSums), beside=T, las=2, col=plot_colors, cex.names=0.7, main="Monitary Damage across the United States")
legend("topright",colnames(plotSums), fill=plot_colors)
box(bty="l")
suppressWarnings(par(op))
}









