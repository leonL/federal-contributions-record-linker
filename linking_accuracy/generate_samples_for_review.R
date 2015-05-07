source("../lib/record_linking/link_accuracy.R")
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

print("Generating postal_code sample parameters...")
# maxmum probability that a postal code has 'missing links' (i.e. distinct
# contributor_ids for the same contributor)
sP$maxProbPcodeHasMissingLinks <-
  data$PostalCodesWithMultipleContributorIdsCount() / length(data$pcodes)

# minimum number of postal_codes to sample to be able to infer the proportion
# that have 'missing links'.
sP$missingLinksSampleSize <- MinSampleSizeToInferProportion(sP$kConfidence,
                                  sP$maxProbPcodeHasMissingLinks, sP$kInterval)

sP$pCodeIndices <- sample(length(data$pcodes), sP$missingLinksSampleSize)
sP$pCodes <- data$pcodes[sP$pCodeIndices]

print("Generating contributor_ids sample parameters...")
# maxmum probability that a contributor will have 'misassigned records'
# (i.e records for two different contributors are have the same contributor_id)
sP$maxProbContributorHasMisassignedRecord <-
                data$ContribIdsWithMultipleNamesCount() / data$maxContributorId

# minimum number of contributor_ids to sample to be able to infer the
# proportion that have 'misassigned records'
sP$misassignedRecordsSampleSize <-
  MinSampleSizeToInferProportion(sP$kConfidence,
                      sP$maxProbContributorHasMisassignedRecord, sP$kInterval)

sP$contributorIds <-
  sample(data$maxContributorId, sP$misassignedRecordsSampleSize)

print(GetoptLong::qq("Generating random sample of @{sP$missingLinksSampleSize} postal_codes"))
pCodesSample <- filter(data$set, postal_code %in% sP$pCodes)
pCodesSample <- select(pCodesSample,
  postal_code, contributor_id, full_name, clean_first_last_name
)
pCodesSample <- pCodesSample[!duplicated(pCodesSample),]

pCodesToReview <-
  filter(tally(group_by(pCodesSample, postal_code)), n>1)$postal_code

pCodesSample$review <- 0
pCodesSample$review[pCodesSample$postal_code %in% pCodesToReview] <- 2
pCodesSample <- arrange(pCodesSample, desc(review), postal_code)


print(GetoptLong::qq("Generating random sample of @{sP$misassignedRecordsSampleSize} contibutor_ids"))
contribIdsSample <- filter(data$set, contributor_id %in% sP$contributorIds)
contribIdsSample <- select(contribIdsSample,
  contributor_id, full_name, clean_first_last_name
)
contribIdsSample <- contribIdsSample[!duplicated(contribIdsSample),]

cIdsToReview <-
  filter(tally(group_by(contribIdsSample, contributor_id)), n>1)$contributor_id

contribIdsSample$review <- 0
contribIdsSample$review[contribIdsSample$contributor_id %in% cIdsToReview] <- 2
contribIdsSample <- arrange(contribIdsSample, desc(review), contributor_id)

print("Saving samples as CSV files...")
write.csv(pCodesSample,
  file=GetoptLong::qq("@{config$targetDir}/postal_code_sample.csv"), row.names=FALSE
)
write.csv(contribIdsSample,
  file=GetoptLong::qq("@{config$targetDir}/contributor_id_sample.csv"), row.names=FALSE
)