source("../config.R")
source("constants.R")

if(!exists("util")) { util <- list() }

util <- within(util, {
  ConfigDataStore <- function(storeCode) {
    config$SetDataStore()

    config$arg <<- ifelse(is.na(storeCode), '', storeCode)

    if(config$arg == 'source') {
      config$targetDir <<- config$BuildSourcePath(prefix='../../')
    } else {
      config$targetDir <<- config$BuildOutputPath(prefix='../../')
    }
    print(paste('Target directory set to', config$targetDir))
    return(NULL)
  }
  AllRowsAccountedFor <- function(subsetRowCount, setRowCount) {
    if(subsetRowCount == setRowCount) {
      print(paste("All", setRowCount, "rows accounted for..."))
    } else {
      stop(
        paste(
          "There's a discrepancy between the subset and dataset.",
          "The subset row count is:", subsetRowCount,
          "The dataset row count is", setRowCount
        )
      )
    }
  }
})
