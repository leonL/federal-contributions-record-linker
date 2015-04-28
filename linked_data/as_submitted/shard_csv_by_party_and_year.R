# separate data by party name and year, and save each subset (for reasonably sized files)
library(GetoptLong)
source("../../lib/constants.R")

data_set <- read.csv(all_data_csv_file_name, encoding="UTF-8")

all_party_names <- levels(data_set$party_name)

for(pname in all_party_names)
{
  data_party_subset <- subset(data_set, party_name==pname)
  party_nickname <- names(official_party_names[official_party_names==pname])
  dir.create(GetoptLong::qq("@{party_nickname}"))
  for(year in all_years)
  {
    data_year_subset <- subset(data_party_subset, grepl(year, data_party_subset$contribution_date))
    print(GetoptLong::qq("@{party_nickname}_@{year}_contributions"))
    write.csv(data_year_subset,
      file=GetoptLong::qq("@{party_nickname}/@{pname}.@{year}.csv"),
      row.names=FALSE
    )
  }
}