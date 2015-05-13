library(dplyr, quietly=TRUE, warn.conflicts=FALSE)

ContributionsDataWrapper <- function(dataSet) {
  wrapper <- within(list(), {
    set <- dataSet
    postalCodeLevels <- levels(set$postal_code)
    maxContributorId <- max(set$contributor_id)
    PostalCodeSampleSubset <- function(pCodes, set=wrapper$set) {
      sub <- filter(set, postal_code %in% pCodes)
      sub <- select(sub,
        postal_code, contributor_id, full_name, clean_first_last_name
      )
      sub <- sub[!duplicated(sub),]
      pCodesToReview <- filter(tally(group_by(sub, postal_code)), n>1)$postal_code

      sub$review <- FALSE
      sub$review[sub$postal_code %in% pCodesToReview] <- NA
      sub <- arrange(sub, desc(review), postal_code, contributor_id)
      return(sub)
    }
    ContributorIdSampleSubset <- function(cIds, set=wrapper$set) {
      sub <- filter(set, contributor_id %in% cIds)
      sub <- select(sub,
        contributor_id, full_name, clean_first_last_name
      )
      sub <- sub[!duplicated(sub),]

      cIdsToReview <-
        filter(tally(group_by(sub, contributor_id)), n>1)$contributor_id

      sub$review <- FALSE
      sub$review[sub$contributor_id %in% cIdsToReview] <- NA
      sub <- arrange(sub, desc(review), contributor_id)
    }
    ContribIdsWithMultipleNamesCount <- function(w=wrapper) {
      tally <- w$TallyUniqueYPerX(colX="contributor_id", colY="full_name")
      contribIdsWithMultipleNames <- filter(tally, n > 1)
      return(nrow(contribIdsWithMultipleNames))
    }
    PostalCodesWithMultipleContributorIdsCount <- function (w=wrapper) {
      tally <- w$TallyUniqueYPerX(colX="postal_code", colY="contributor_id")
      postalCodesWithMultipleContributorIds <- filter(tally, n > 1)
      return(nrow(postalCodesWithMultipleContributorIds))
    }
    TallyUniqueYPerX <- function(w=wrapper, colX, colY) {
      subset <- w$set[, c(colX, colY)]
      subset <- subset[!duplicated(subset), ]
      yPerXTally <- eval(
        substitute(tally(group_by(subset, col)), list(col=as.name(colX)))
      )
      return(yPerXTally)
    }
  })
  return(wrapper)
}

SampleVectorToInferProportion <- function(v, c, i, p=0.5) {
  sampleSize <- MinSampleSizeToInferProportion(c, i, p)
  indicesOfSampleCases <- sample(length(v), sampleSize)
  return(v[indicesOfSampleCases])
}

MinSampleSizeToInferProportion <- function(c, E, p=0.5) {
  # Minimum sample size necessary to be able to estimate population proportion
  # to a range of size E, with a confidence of c. Set p to the
  # probability that any test case is succesful if such information is available
  # (based on a previous estimation perhaps)

  zstar <- qnorm(1 - ((1 - c)/ 2))
  sampleSize <- zstar^2 * p * (1-p) / (E/2)^2
  return(ceiling(sampleSize))
}