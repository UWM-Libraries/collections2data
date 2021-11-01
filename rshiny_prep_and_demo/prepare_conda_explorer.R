library(corporaexplorer)
library(readxl)
setwd("~/collections-as-data/code/rshiny_demo")
# Load transcript list
file.list <- list.files(path = "../../transcripts/", pattern="*.txt", full.names=TRUE)

df <- data.frame( files= sapply(file.list, 
                                FUN = function(x)readChar(x, file.info(x)$size)),
                  stringsAsFactors=FALSE)
names(df)[1]<-"Text"

#generate collection header based on library naming collection of objects
df$Collection <- substr(file.list, start=19, stop=27)

#generate filename
df$Filename <- substr(file.list, start=19, stop=100)

#load and merge metadata files
setwd("~/collections-as-data/metadata")
metadata <- purrr::map_dfr(list.files(pattern="*.xlsx"), readxl::read_excel)


#Drop extension to identify object name sans extension
df$DigitalObjectName = sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(df$Filename))
metadata$DigitalObjectName = sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(metadata$Digital.ID))

#Merge metadata with text of transcripts
joined_metadata <- merge(df,metadata, by="DigitalObjectName")

#Replace collection headers with collection names
unique(joined_metadata$Collection)
require(stringr)
joined_metadata$Collection[joined_metadata$Collection=="gpu_0000_"] <- "Gay Peoples Union Records"
joined_metadata$Collection[joined_metadata$Collection=="UWMMss200"] <- "LGBT History Project"
joined_metadata$Collection[joined_metadata$Collection=="UWMMss203"] <- "ACT UP Milwaukee"
joined_metadata$Collection[joined_metadata$Collection=="UWMMSS026"] <- "Shall Not Be Recognized"
joined_metadata$Collection[joined_metadata$Collection=="tri-cable"] <- "Tri-Cable Tonight"
joined_metadata$Collection[joined_metadata$Collection=="new_tri-c"] <- "Tri-Cable Tonight"
joined_metadata$Collection[joined_metadata$Collection=="uwmmss023"] <- "Miriam Ben-Shalom"
joined_metadata$Collection[joined_metadata$Collection=="uwmmss033"] <- "AIDS RESOURCE CENTER OF WISCONSIN"
joined_metadata$Collection[joined_metadata$Collection=="UWMMss205"] <- "Cream City Foundation"
joined_metadata$Collection[str_detect(joined_metadata$Collection,"[:digit:][:digit:][:digit:][:digit:]_")] <- "PrideFest Records, 1989-2001"

joined_metadata_no_timeline<-joined_metadata[-c(6,16)]
corpus_no_timeline <- prepare_data(joined_metadata_no_timeline,date_based_corpus = FALSE, corpus_name="LGBTQ+ AV Mining", grouping_variable="Collection", columns_doc_info= c("Collection","Filename","Title","CONTENDdm link","Finding aid","Type.DCMI"))
`%not in%` <- function (x, table) is.na(match(x, table, nomatch=NA_integer_))

#Identify objects that are not included in collections.
subset(df$DigitalObjectName,df$DigitalObjectName %not in% metadata$DigitalObjectName)
setwd("~/collections-as-data/code/rshiny_dashboard")
saveRDS(corpus_no_timeline, "saved_corporaexplorerobject_no_timeline.rds", compress = FALSE)
