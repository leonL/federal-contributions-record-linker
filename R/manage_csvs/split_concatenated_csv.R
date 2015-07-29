source("../lib/manage_csvs/util.R", chdir=TRUE)

library(dplyr)

util$ConfigDataStore(commandArgs(TRUE)[1])
c = config

data_set <- read.csv(
  paste(c$targetDir, c$allContribsFileName, sep=''),
  encoding="UTF-8"
)
data_set$contrib.date <- as.Date(data_set$contrib.date)

log <- data.frame()

for(i in 1:nrow(k$PartyNames))
{
  party <- k$PartyNames[i, ]
  dir.create(paste(c$targetDir, party$nick_name, sep=''))

  for(current_year in k$AllContribYears)
  {
    subset <- filter(data_set, party==party$nick_name, contrib.year==current_year)
    file_name <- paste(party$name, '.', current_year, '.csv', sep='')
    log_record <- data.frame(party=party$nick_name, year=current_year, n=nrow(subset))
    log <- rbind(log, log_record)
    print(paste('Saving', file_name, '...'))
    write.csv(subset,
      file=paste(c$targetDir, party$nick_name, '/', file_name, sep=''),
      row.names=FALSE
    )
  }
}
print(log)
util$AllRowsAccountedFor(sum(log$n), nrow(data_set))