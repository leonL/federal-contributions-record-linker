source("../lib/constants.R")
source("../lib/record_linking/link_accuracy.R")

library(plyr); library(dplyr)
library(GetoptLong)

config <- within(list(), {
  dataStore <- commandArgs(TRUE)
  dataStoreDir <- switch(dataStore[1], mock="0_mock_data",
                                reviewed="as_reviewed", "as_submitted")

  sourceDir <- paste("../linked_data/", dataStoreDir, sep="")
  print(paste("The source directory is", sourceDir))
  targetDir <- dataStoreDir
  print(paste("The target directory is", targetDir))
})

print("Reading data...")
data <- ContributionsDataWrapper(
  read.csv(
    GetoptLong::qq("@{config$sourceDir}/@{all_data_csv_file_name}"),
    encoding="UTF-8"
  )
)

# maxmum probability that a postal code has distinct contributor_ids for
# the same contributor (i.e. the records were not linked successfully)
maxProbPcodeHasMissingLinks <-
  data$PostalCodesWithMultipleContributorIdsCount() /
    length(levels(data$set$postal_code))

# maxmum probability that a contributor will have misassigned records
# (i.e records for two different contributors were mistakenly linked)
maxProbContributorHasMisassignedRecord <-
  data$ContribIdsWithMultipleNamesCount() / max(data$set$contributor_id)