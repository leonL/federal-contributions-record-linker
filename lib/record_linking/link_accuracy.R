library(plyr); library(dplyr)

all_unique_ids_over_max_total_contribution <- function()
{
  data_set <- read.csv("../../2_link_records_by_name_output/all_contributions_2004_to_2013.csv", encoding="UTF-8", as.is=TRUE)
  data_set_w_year <- mutate(data_set, year = strftime(contribution_date, "%Y"))

  data_04_06 <- filter(data_set_w_year, year >= 2004, year <= 2006)
  data_04_06_grouped <- group_by(data_04_06, party_name, contributor_id, year)
  data_04_06_summarised <- summarise(data_04_06_grouped, total_contribution=sum(contribution_amount)/100)
  over_04 <- filter(data_04_06_summarised, total_contribution > 5000, year == 2004)
  over_05 <- filter(data_04_06_summarised, total_contribution > 5100, year == 2005)
  over_06 <- filter(data_04_06_summarised, total_contribution > 5200, year == 2006)

  data_07_13 <- filter(data_set_w_year, year >= 2007, year <= 2013)
  data_07_13_grouped <- group_by(data_07_13, federal_contribution, party_name, contributor_id, year)
  data_07_13_summarised <- summarise(data_07_13_grouped, total_contribution=sum(contribution_amount)/100)
  over_07_11 <- filter(data_07_13_summarised, total_contribution > 1100, year <= 2007, year <= 2011)
  over_12_13 <- filter(data_07_13_summarised, total_contribution > 1200, year <= 2012, year <= 2013)

  over <- rbind(over_04, over_05, over_06)
  over$federal_contribution <- NA
  over <- rbind(over, over_07_11, over_12_13)

  return(unique(over$contributor_id))
}

unique_ids_over_max <- all_unique_ids_over_max_total_contribution()

linked_names <- read.csv("../../2_link_records_by_name_output/linked_unique_names.CSV", encoding="UTF-8", as.is=TRUE)
suspect_linked_names <- filter(linked_names, contributor_id %in% unique_ids_over_max)
