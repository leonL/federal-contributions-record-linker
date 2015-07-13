source("../link_accuracy/inference.R")

library(dplyr, quietly=TRUE, warn.conflicts=FALSE)

context("Accuracy ~ Helper Functions")

mock <- within(list(), {
  dataSet <- data.frame(
    postal_code=c("A0A0A1", "A0A0A2", "A0A0A2", "A0A0A3", "A0A0A3", "A0A0A3"),
    contributor_id=c(1,12,123,13,13,13),
    donor.name=c("Michael Anthony", "David Lee Roth", "David Roth",
                  "Eddie Van Halen", "Eddie Halen", "Edith Valen"),
    clean_first_last_name=c("michael Anthony", "david roth", "david roth",
                              "eddie halen", "eddie halen", "edith valen"),
    review=c(FALSE)
  )
})

test_that("AllRecordsReviewed returns TRUE when the 'review' column DOES NOT include NAs", {
  expect_true(AllRecordsReviewed(mock$dataSet))
})

test_that("AllRecordsReviewed returns FALSE when the 'review' column includes NAs", {
  mock$dataSet$review[1] <- NA
  expect_false(AllRecordsReviewed(mock$dataSet))
})

test_that("ReviewErrorProportion returns a correctly formated percent", {
  mock$dataSet$review[1] <- TRUE
  reviewSet <- select(mock$dataSet, key=postal_code, review)
  expectedPercentage <- round((1 / length(levels(mock$dataSet$postal_code)) * 100), 1)
  expect_identical(ReviewErrorProportion(reviewSet), expectedPercentage)
})

test_that("IntervalFromPoint returns the reasonable values", {
  expect_identical(IntervalFromPoint(5.5, 3.2), c(3.9, 7.1))
  expect_identical(IntervalFromPoint(3, 10), c(0, 8))
  expect_identical(IntervalFromPoint(99, 10), c(94, 100))
})