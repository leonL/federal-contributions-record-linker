source("../lib/config.R")
source("../lib/constants.R")
source("../lib/accuracy.R")

library(GetoptLong, quietly=TRUE, warn.conflicts=FALSE)
library(dplyr, quietly=TRUE, warn.conflicts=FALSE)

config$SetDataStoreDir(commandArgs(TRUE)[1])
config$sourceDir <- paste("samples/", config$dataStoreDir, sep="")
config$pCodeReviewFilename <- "postal_code_sample_REVIEWED.csv"
config$cIdReviewFilename <- "contributor_id_sample_REVIEWED.csv"

pCodeReview <- read.csv(
  GetoptLong::qq("@{config$sourceDir}/@{config$pCodeReviewFilename}"),
  encoding="UTF-8"
) %>% select(key=postal_code, review)

if(!AllRecordsReviewed(pCodeReview)) {
  stop(IncompleteReviewErrorMessage(config$pCodeReviewFilename))
}

cIdReview <- read.csv(
  GetoptLong::qq("@{config$sourceDir}/@{config$cIdReviewFilename}"),
  encoding="UTF-8"
) %>% select(key=contributor_id, review)

if(!AllRecordsReviewed(cIdReview)) {
  stop(IncompleteReviewErrorMessage(config$cIdReviewFilename))
}

pCodesWithMissedLinksPercent <- ReviewErrorProportion(pCodeReview)
cIdsWithMisassignedContribsPercent <- ReviewErrorProportion(cIdReview)

intervalSize <- DecimalToPercent(k$Interval)
missedInterval <- IntervalFromPoint(pCodesWithMissedLinksPercent, intervalSize)
misassignedInterval <- IntervalFromPoint(cIdsWithMisassignedContribsPercent, intervalSize)

print(paste("Accurate to " , DecimalToPercent(k$Confidence), "%:", sep=""))
print(paste("Percent of postal codes with a missed link: ",
              missedInterval[1], "%", " to ", missedInterval[2], "%", sep=""))
print(paste("Percent of contributors with misassigned contributions: ",
              misassignedInterval[1], "%", " to ", misassignedInterval[2], "%", sep=""))