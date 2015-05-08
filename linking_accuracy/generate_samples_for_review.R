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

data$pcodes <- levels(data$set$postal_code)
data$maxContributorId <- max(data$set$contributor_id)

sP <- list(kConfidence = 0.99, kInterval = 0.05)

print("Sampling postal_codes...")
# maxmum probability that a postal code has 'missing links' (i.e. distinct
# contributor_ids for the same contributor)
sP$maxProbPcodeHasMissingLinks <-
  data$PostalCodesWithMultipleContributorIdsCount() / length(data$pcodes)

# minimum number of postal_codes to sample to be able to infer the proportion
# that have 'missing links'.
sP$missingLinksSampleSize <- MinSampleSizeToInferProportion(sP$kConfidence,
                                  sP$maxProbPcodeHasMissingLinks, sP$kInterval)

sP$pCodeIndices <- sample(length(data$pcodes), sP$missingLinksSampleSize)
sP$pCodesSample <- data$pcodes[sP$pCodeIndices]

print("Sampling contributor_ids...")
# maxmum probability that a contributor will have 'misassigned records'
# (i.e records for two different contributors are have the same contributor_id)
sP$maxProbContributorHasMisassignedRecord <-
                data$ContribIdsWithMultipleNamesCount() / data$maxContributorId

# minimum number of contributor_ids to sample to be able to infer the
# proportion that have 'misassigned records'
sP$misassignedRecordsSampleSize <-
  MinSampleSizeToInferProportion(sP$kConfidence,
                      sP$maxProbContributorHasMisassignedRecord, sP$kInterval)

sP$contributorIdsSample <-
  sample(data$maxContributorId, sP$misassignedRecordsSampleSize)

print(GetoptLong::qq("Generating review subset for @{sP$missingLinksSampleSize} postal_codes"))
pCodesSampleSet <- data$PostalCodeSampleSubset(sP$pCodesSample)

print(GetoptLong::qq("Generating review subset for @{sP$misassignedRecordsSampleSize} contibutor_ids"))
contribIdsSampleSet <- data$ContributorIdSampleSubset(sP$contributorIdsSample)

print("Saving subsets as CSV files...")
write.csv(pCodesSampleSet,
  file=GetoptLong::qq("@{config$targetDir}/postal_code_sample.csv"), row.names=FALSE
)
write.csv(contribIdsSampleSet,
  file=GetoptLong::qq("@{config$targetDir}/contributor_id_sample.csv"), row.names=FALSE
)