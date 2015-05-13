if(!exists("config")) { config <- list() }

config <- within(config, {
  SetDataStoreDir <- function(cmdArg) {
    config$dataStoreDir <<-
      switch(cmdArg, mock="0_mock_data", reviewed="as_reviewed", "as_submitted")
  }
})