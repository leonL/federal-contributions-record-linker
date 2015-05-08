library(dplyr)

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