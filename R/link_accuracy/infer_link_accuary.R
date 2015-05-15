source("../lib/config.R")
source("../lib/link_accuracy/constants.R")
source("../lib/link_accuracy/inference.R")

library(GetoptLong, quietly=TRUE, warn.conflicts=FALSE)
library(dplyr, quietly=TRUE, warn.conflicts=FALSE)

c = config
c$SetDataStore(commandArgs(TRUE)[1])
c$sourceDir <- c$BuildOutputPath(prefix='../../', suffix='samples')
print(paste('Source directory set to', c$sourceDir))
c$pCodeReviewFilename <- "postal_code_sample_REVIEWED.csv"
c$cIdReviewFilename <- "contributor_id_sample_REVIEWED.csv"

pCodeReview <- read.csv(
  GetoptLong::qq("@{c$sourceDir}/@{c$pCodeReviewFilename}"),
  encoding="UTF-8"
) %>% select(key=postal_code, review)

if(!AllRecordsReviewed(pCodeReview)) {
  stop(IncompleteReviewErrorMessage(c$pCodeReviewFilename))
}

cIdReview <- read.csv(
  GetoptLong::qq("@{c$sourceDir}/@{c$cIdReviewFilename}"),
  encoding="UTF-8"
) %>% select(key=contributor_id, review)

if(!AllRecordsReviewed(cIdReview)) {
  stop(IncompleteReviewErrorMessage(c$cIdReviewFilename))
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