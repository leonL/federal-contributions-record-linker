ContributionsDataWrapper <- function(dataSet) {
  newObj <- within(list(), {
    set <- dataSet
    TallyUniqueYPerX <- function(obj=newObj, colX, colY) {
      subset <- obj$set[, c(colX, colY)]
      subset <- subset[!duplicated(subset), ]
      yPerXTally <- eval(
        substitute(tally(group_by(subset, col)), list(col=as.name(colX)))
      )
      return(yPerXTally)
    }
    ContribIdsWithMultipleNamesCount <- function(obj=newObj) {
      tally <- obj$TallyUniqueYPerX(colX="contributor_id", colY="full_name")
      contribIdsWithMultipleNames <- filter(tally, n > 1)
      return(nrow(contribIdsWithMultipleNames))
    }
    PostalCodesWithMultipleContributorIdsCount <- function (obj=newObj) {
      tally <- obj$TallyUniqueYPerX(colX="postal_code", colY="contributor_id")
      postalCodesWithMultipleContributorIds <- filter(tally, n > 1)
      return(nrow(postalCodesWithMultipleContributorIds))
    }
  })
  return(newObj)
}

MinSampleSizeToInferProportion <- function(c, p, E) {
  zstar <- qnorm(1 - ((1 - c)/ 2))
  sampleSize <- zstar^2 * p * (1-p) / (E/2)^2
  return(ceiling(sampleSize))
}


# linkAccuracy$calculateContributorSampleSize <- function(dataSet) {
#   library(dplyr)

#   dataSet <- select(dataSet, contributor_id, full_name)
#   dataSet <- dataSet[!duplicated(dataSet), ]
#   uniqueNamesPerContribId <- tally(group_by(dataSet, contributor_id))
#   monoNamedContribIds <- filter(uniqueNamesPerContribId, n>1)

#   # maxmum probability that a contributor will have misassigned records
#   # (i.e records for two different contributors were mistakenly linked)
#   pMax <- 1 - (length(monoNamedContribIds$n) / max(dataSet$contributor_id))

#   # calculate the sample size necessary to estimate with 95% confidence,
#   # the proportion of contributors, within a 5 point interval, that have a misassigned record
#   linkAccuracy$contributorSampleSize <<- linkAccuracy$calcSampleSize(0.95, pMax, 0.01)
# }

# linkAccuracy$calculatePostalCodeSampleSize <- function(dataSet) {
#   library(dplyr)

#   dataSet <- select(data_set, contributor_id, postal_code)
#   dataSet <- dataSet[!duplicated(dataSet), ]
#   uniqueContribIdsPerPostalCode <- tally(group_by(dataSet, postal_code))
#   monoPeopledPostalCodes <- filter(uniqueContribIdsPerPostalCode, n>1)

#   # maxmum probability that a postal code has distinct contributor_ids for
#   # the same contributor (i.e. the records were not linked successfully)
#   pMax <- 1 - (length(monoPeopledPostalCodes$n) / length(levels(dataSet$postal_code)))

#   # calculate the sample size necessary to estimate with 95% confidence,
#   # the proportion of postal codes, within a 5 point interval, that have
#   # contributor_ids that failed to be linked
#   linkAccuracy$postalCodeSampleSize <<- linkAccuracy$calcSampleSize(0.95, pMax, 0.01)
# }

# all_unique_ids_over_max_total_contribution <- function()
# {
#   data_set <- read.csv("../../2_link_records_by_name_output/all_contributions_2004_to_2013.csv", encoding="UTF-8", as.is=TRUE)
#   data_set_w_year <- mutate(data_set, year = strftime(contribution_date, "%Y"))

#   data_04_06 <- filter(data_set_w_year, year >= 2004, year <= 2006)
#   data_04_06_grouped <- group_by(data_04_06, party_name, contributor_id, year)
#   data_04_06_summarised <- summarise(data_04_06_grouped, total_contribution=sum(contribution_amount)/100)
#   over_04 <- filter(data_04_06_summarised, total_contribution > 5000, year == 2004)
#   over_05 <- filter(data_04_06_summarised, total_contribution > 5100, year == 2005)
#   over_06 <- filter(data_04_06_summarised, total_contribution > 5200, year == 2006)

#   data_07_13 <- filter(data_set_w_year, year >= 2007, year <= 2013)
#   data_07_13_grouped <- group_by(data_07_13, federal_contribution, party_name, contributor_id, year)
#   data_07_13_summarised <- summarise(data_07_13_grouped, total_contribution=sum(contribution_amount)/100)
#   over_07_11 <- filter(data_07_13_summarised, total_contribution > 1100, year <= 2007, year <= 2011)
#   over_12_13 <- filter(data_07_13_summarised, total_contribution > 1200, year <= 2012, year <= 2013)

#   over <- rbind(over_04, over_05, over_06)
#   over$federal_contribution <- NA
#   over <- rbind(over, over_07_11, over_12_13)

#   return(unique(over$contributor_id))
# }

# unique_ids_over_max <- all_unique_ids_over_max_total_contribution()

# linked_names <- read.csv("../../2_link_records_by_name_output/linked_unique_names.CSV", encoding="UTF-8", as.is=TRUE)
# suspect_linked_names <- filter(linked_names, contributor_id %in% unique_ids_over_max)
