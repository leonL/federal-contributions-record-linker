source("../link_accuracy/sampling.R")

context("Sampling ~ ContributionsDataWrapper")

mock <- within(list(), {
  postalCodeA <- c("A0A0A3")
  cIdA <- (1)

  rawData <- data.frame(
    postal_code=c("A0A0A1", "A0A0A2", "A0A0A2", postalCodeA, postalCodeA, postalCodeA),
    contributor_id=c(cIdA,12,123,13,13,13),
    full_name=c("Michael Anthony", "David Lee Roth", "David Roth",
                  "Eddie Van Halen", "Eddie Halen", "Edith Valen"),
    clean_first_last_name=c("michael Anthony", "david roth", "david roth",
                              "eddie halen", "eddie halen", "edith valen")
  )
  wrappedData <- ContributionsDataWrapper(rawData)
})

test_that("TallyUniqueYPerX dependent methods are accurate", {

  expect_equal(mock$wrappedData$ContribIdsWithMultipleNamesCount(), 1)
  expect_equal(mock$wrappedData$PostalCodesWithMultipleContributorIdsCount(), 1)

})

test_that("...SampleSubset functions return the expect subsets", {

  expect_equal(nrow(mock$wrappedData$PostalCodeSampleSubset(mock$postalCodeA)), 3)
  expect_equal(nrow(mock$wrappedData$ContributorIdSampleSubset(mock$cIdA)), 1)

})

context("Sampling ~ Helper Functions")

test_that("MinSampleSizeToInferProportion is accurate", {

  # In order to infer proportion to a 95% accurrate, 10 point interval, where
  # the probability of success for any trail is 80%, the inference must based on
  # a sample of at least 246 observations.
  # Source: Statistics in a nutshell; Boslaugh, Sarah; O'Reilly Media, 2008

  confidence <- 0.95
  interval <- 0.10
  p <- 0.8
  sampleSize <- 246

  expect_equal(MinSampleSizeToInferProportion(confidence, interval, p), sampleSize)
})

test_that("SampleVectorToInferProportion returns a reasonable subset", {
  confidence <- 0.90
  interval <- 0.20
  p <- 0.99

  expectedNumberOfCases <- MinSampleSizeToInferProportion(confidence, interval, p)
  nameSample <- SampleVectorToInferProportion(mock$wrappedData$set$full_name, confidence, interval, p)
  numberOfCases <- length(nameSample)

  expect_equal(expectedNumberOfCases, numberOfCases)
  expect_false(any(!(nameSample %in% mock$wrappedData$set$full_name)))
})