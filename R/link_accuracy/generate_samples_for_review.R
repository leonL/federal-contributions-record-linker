source("../lib/config.R")
source("../lib/link_accuracy/constants.R")
source("../lib/link_accuracy/sampling.R")

library(dplyr, quietly=TRUE, warn.conflicts=FALSE)
library(GetoptLong, quietly=TRUE, warn.conflicts=FALSE)

c = config
c$SetDataStore(commandArgs(TRUE)[1])
c$sourceDir <- c$BuildOutputPath(prefix='../../')
print(paste('Source directory set to', c$sourceDir))
c$targetDir <- c$BuildOutputPath(prefix='../../', suffix='samples')
print(paste('Target directory set to', c$targetDir))

print("Reading data...")
data <- ContributionsDataWrapper(
  read.csv(
    paste(c$sourceDir, c$allContribsFileName, sep=''),
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
  file=GetoptLong::qq("@{c$targetDir}/postal_code_sample.csv"), row.names=FALSE
)
write.csv(contribIdsSampleSet,
  file=GetoptLong::qq("@{c$targetDir}/contributor_id_sample.csv"), row.names=FALSE
)