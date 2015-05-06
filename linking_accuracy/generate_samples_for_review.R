source("../lib/constants.R")

library(plyr); library(dplyr)
library(GetoptLong)

config <- within(list(), {
  data.store <- commandArgs(TRUE)
  data.store.subdir <- switch(data.store[1], mock="0_mock_data",
                                reviewed="as_reviewed", "as_submitted")

  source.dir <- paste("../linked_data/", data.store.subdir, sep="")
  print(paste("The source directory is", source.dir))
  target.dir <- data.store.subdir
  print(paste("The target directory is", target.dir))
})

CreateDataObject <- function(data.set=NULL) {
  new.obj <- within(list(), {
    if(is.null(data.set)) {
      print("Reading data set...")
      set <- read.csv(
        GetoptLong::qq("@{config$source.dir}/@{all_data_csv_file_name}"),
        encoding="UTF-8"
      )
    } else {
      set <- data.set
    }
    tally.unique.y.per.x <- function(obj=new.obj, col.x, col.y) {
      subset <- obj$set[, c(col.x, col.y)]
      subset <- subset[!duplicated(subset), ]
      y.per.x.tally <- eval(
        substitute(tally(group_by(subset, col)), list(col=as.name(col.x)))
      )
      return(y.per.x.tally)
    }
    contrib.ids.with.multiple.names.count <- function(obj=new.obj) {
      tally <- obj$tally.unique.y.per.x(col.x="contributor_id", col.y="full_name")
      contrib.ids.with.multiple.names <- filter(tally, n>1)
      return(nrow(contrib.ids.with.multiple.names))
    }
    postal.codes.with.multiple.contributor_ids.count <- function (obj=new.obj) {
      tally <- obj$tally.unique.y.per.x(col.x="postal_code", col.y="contributor_id")
      postal.codes.with.multiple.contributor.ids <- filter(tally, n>1)
      return(nrow(postal.codes.with.multiple.contributor.ids))
    }
  })
  class(new.obj) <- "data"
  return(new.obj)
}

# data <- CreateDataObject()



# ProbabilityEstitmate <- function(data) {
#   p.max <-
# }

# NewSampleForPropotionEsitmationBuilder <- function() {
#   obj <- within(list(), {
#     minSampleSize <- function(c, p, E) {
#       zstar <- qnorm(1 - ((1 - c)/ 2))
#       sampleSize <- zstar^2 * p * (1-p) / (E/2)^2
#       ceiling(sampleSize)
#     }

#   })
#   class(obj) <- "sampleBuilder"
# }

# linkAccuracy$calculateContributorSampleSize <- function(dataSet) {
#   library(dplyr)



#   # maxmum probability that a contributor will have misassigned records
#   # (i.e records for two different contributors were mistakenly linked)
#   pMax <- 1 - (length(monoNamedContribIds$n) / max(dataSet$contributor_id))

#   # calculate the sample size necessary to estimate with 95% confidence,
#   # the proportion of contributors, within a 5 point interval, that have a misassigned record
#   linkAccuracy$contributorSampleSize <<- linkAccuracy$calcSampleSize(0.95, pMax, 0.01)
# }

# # Proportion of postal codes with any missed links sample fields:
# # pcode, contributor_id, full_name, clean_first_last_name, review
# # Proporiton of contributors with misassigned contributions sample fields:
# # contributor_id, full_name, clean_first_last_name, review