source("../lib/manage_csvs/util.R", chdir=TRUE)

util$ConfigDataStore(commandArgs(TRUE)[1])
c = config

data_set <- data.frame()
log <- data.frame()

for(subfolder in k$PartyNicknames) {
  subfolder_path <- paste(c$targetDir, subfolder, '/', sep = '')
  files <- list.files(subfolder_path)

  print(paste("Concatenating CSVs in", subfolder_path, "..."))
  for(file in files) {
    print(file)
    current_year <- strsplit(file, ".", fixed=TRUE)[[1]][2]

    csv <- read.csv(
      paste(subfolder_path, file, sep=''), encoding="UTF-8"
    )
    data_set <- rbind(data_set, csv)
    log_record <- data.frame(party_nickname=subfolder, year=current_year, nrow=nrow(csv))
    log <- rbind(log, log_record)
  }
}

util$AllRowsAccountedFor(sum(log$nrow), nrow(data_set))

write.csv(
  data_set, file=paste(c$targetDir, c$allContribsFileName, sep=''), row.names=FALSE
)