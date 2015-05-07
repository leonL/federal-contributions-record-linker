source("../record_linking/link_accuracy.R")

context("ContributionsDataWrapper")

mockData <- data.frame(
  postal_code=c("A0A0A1", "A0A0A2", "A0A0A2", "A0A0A3", "A0A0A3", "A0A0A3"),
  contributor_id=c(1,12,123,13,13,13),
  full_name=c("Michael Anthony", "David Lee Roth", "David Roth",
                "Eddie Van Halen", "Eddie Halen", "Edith Valen")
)

test_that("TallyUniqueYPerX dependent methods are accurate", {
  data <- ContributionsDataWrapper(mockData)

  expect_equal(data$ContribIdsWithMultipleNamesCount(), 1)
  expect_equal(data$PostalCodesWithMultipleContributorIdsCount(), 1)

})

context("Helpers")

test_that("MinSampleSizeToInferProportion is accurate", {

  # In order to infer proportion to a 95% accurrate, 10 point interval, where
  # the probability of success for any trail is 80%, the inference must based on
  # a sample of at least 246 observations.
  # Source: Statistics in a nutshell; Boslaugh, Sarah; O'Reilly Media, 2008

  confidence <- 0.95
  interval <- 0.10
  p <- 0.8
  sampleSize <- 246

  expect_equal(MinSampleSizeToInferProportion(confidence, p, interval), sampleSize)
})