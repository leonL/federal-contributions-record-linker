AllRecordsReviewed <- function(set) {
  !any(is.na(set$review))
}

IncompleteReviewErrorMessage <- function(filename) {
  paste("Not all records in", filename, "have been reviewed")
}

ReviewErrorProportion <- function(reviewSet) {
  groupedReviews <- reviewSet %>% group_by(key) %>% summarise(error=any(review))
  recordsWithErrors <- filter(groupedReviews, error)
  proportion <- nrow(recordsWithErrors) / nrow(groupedReviews)
  round(proportion*100, 1)
}

DecimalToPercent <- function(dec) {
  round(dec * 100, 0)
}

IntervalFromPoint <- function(pt, interval) {
  halfInterval <- interval / 2
  lowerBound <- pt - halfInterval
  if(lowerBound < 0) { lowerBound <- 0 }
  upperBound <- pt + halfInterval
  if(upperBound > 100) { upperBound <- 100 }
  c(lowerBound, upperBound)
}
