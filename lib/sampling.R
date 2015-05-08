library(dplyr)

ContributionsDataWrapper <- function(dataSet) {
  wrapper <- within(list(), {
    set <- dataSet
    PostalCodeSampleSubset <- function(pCodes, w=wrapper) {
      sub <- filter(w$set, postal_code %in% pCodes)
      sub <- select(sub,
        postal_code, contributor_id, full_name, clean_first_last_name
      )
      sub <- sub[!duplicated(sub),]
      pCodesToReview <- filter(tally(group_by(sub, postal_code)), n>1)$postal_code

      sub$review <- 0
      sub$review[sub$postal_code %in% pCodesToReview] <- 2
      sub <- arrange(sub, desc(review), postal_code)
      return(sub)
    }
    ContributorIdSampleSubset <- function(cIds, w=wrapper) {
      sub <- filter(w$set, contributor_id %in% cIds)
      sub <- select(sub,
        contributor_id, full_name, clean_first_last_name
      )
      sub <- sub[!duplicated(sub),]

      cIdsToReview <-
        filter(tally(group_by(sub, contributor_id)), n>1)$contributor_id

      sub$review <- 0
      sub$review[sub$contributor_id %in% cIdsToReview] <- 2
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

MinSampleSizeToInferProportion <- function(c, p, E) {
  zstar <- qnorm(1 - ((1 - c)/ 2))
  sampleSize <- zstar^2 * p * (1-p) / (E/2)^2
  return(ceiling(sampleSize))
}