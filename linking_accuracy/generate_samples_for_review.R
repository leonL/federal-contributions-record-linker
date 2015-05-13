source("../lib/sampling.R")
source("../lib/constants.R")

library(dplyr)
library(GetoptLong)

config <- within(list(), {
  dataStore <- commandArgs(TRUE)
  dataStoreDir <- switch(dataStore[1], mock="0_mock_data",
                                reviewed="as_reviewed", "as_submitted")

  sourceDir <- paste("../linked_data/", dataStoreDir, sep="")
  print(paste("The source directory is", sourceDir))
  targetDir <- paste("samples/", dataStoreDir, sep="")
  print(paste("The target directory is", targetDir))
})

print("Reading data...")
data <- ContributionsDataWrapper(
  read.csv(
    GetoptLong::qq("@{config$sourceDir}/@{all_data_csv_file_name}"),
    encoding="UTF-8"
  )
)

print("Sampling postal_codes...")
# maxmum probability that a postal code has 'missing links' (i.e. distinct
# contributor_ids for the same contributor)
maxProbOfMissingLinks <-
  data$PostalCodesWithMultipleContributorIdsCount() / length(data$postalCodeLevels)

pCodesSample <- SampleVectorToInferProportion(data$postalCodeLevels, k$Confidence, k$Interval, maxProbOfMissingLinks)

print(GetoptLong::qq("Generating review subset for @{length(pCodesSample)} postal_codes"))
pCodesSampleSet <- data$PostalCodeSampleSubset(pCodesSample)


print("Sampling contributor_ids...")
# maxmum probability that a contributor will have 'misassigned records'
# (i.e records for two different contributors are have the same contributor_id)
maxProbOfMisassignedRecord <-
  data$ContribIdsWithMultipleNamesCount() / data$maxContributorId

cIdsSample <- SampleVectorToInferProportion(c(1:data$maxContributorId), k$Confidence, k$Interval, maxProbOfMisassignedRecord)

print(GetoptLong::qq("Generating review subset for @{length(cIdsSample)} contibutor_ids"))
contribIdsSampleSet <- data$ContributorIdSampleSubset(cIdsSample)


print("Saving subsets as CSV files...")
write.csv(pCodesSampleSet,
  file=GetoptLong::qq("@{config$targetDir}/postal_code_sample.csv"), row.names=FALSE
)
write.csv(contribIdsSampleSet,
  file=GetoptLong::qq("@{config$targetDir}/contributor_id_sample.csv"), row.names=FALSE
)