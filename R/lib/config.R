if(!exists("config")) { config <- list() }

config <- within(config, {
  SetDataStore <- function(subDirCode='') {
    config$dataStoreDir <<-
      switch(subDirCode, mock="0_mock_data/", reviewed="as_reviewed/", "as_submitted/")
  }
  BuildSourcePath <- function(prefix='../', store=config$dataStoreDir, suffix='') {
    paste(prefix, 'data/source/', store, suffix, sep="")
  }
  BuildOutputPath <- function(prefix='../', store=config$dataStoreDir, suffix='') {
    paste(prefix, 'data/output/', store, suffix, sep="")
  }
  allContribsFileName <- "all_contributions.csv"
})