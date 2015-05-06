source("../record_linking/link_accuracy.R")

test_that("MinSampleSizeToInferProportion is implemented to return the correct value", {

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