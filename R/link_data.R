source("lib/config.R")
source("lib/link_data/normalize_names.R")
source("lib/link_data/linking.R")

library(plyr, quietly=TRUE, warn.conflicts=FALSE)
library(dplyr, quietly=TRUE, warn.conflicts=FALSE)

c = config
c$SetDataStore(commandArgs(TRUE)[1])
c$sourceDir <- c$BuildSourcePath()
print(paste('Source directory set to', c$sourceDir))
c$targetDir <- c$BuildOutputPath()
print(paste('Target directory set to', c$targetDir))

data_set <- read.csv(
  paste(c$sourceDir, c$allContribsFileName, sep=''),
  encoding="UTF-8"
)

print("create canonical table of normalized names (first and last only)...")
names_data <- data.frame(donor.name=levels(data_set$donor.name))
normed_first_last <- normalize_names(names_data$donor.name)
names_data <- cbind(names_data, normed_first_last)

print("merge normalized names into main data set...")
data_set <- merge(data_set, names_data)

print("Subsetting unique names by postal code...")
name_and_postal_data <- data_set[,c("clean_first_last_name", "postal_code")]
unique_name_and_postal <- name_and_postal_data[!duplicated(name_and_postal_data),]

print("Match similiar names...")
probable_links <- find_probable_name_matches(unique_name_and_postal)

# sets ids for linked names
print("assigning unique ids to linked names...")
unique_name_and_postal$contributor_id <- NA
d_ply(probable_links, .(id1), link_contributors_by_id)

# print("saving list of link names")
# linked_names <- filter(unique_name_and_postal, !is.na(contributor_id))
# write.csv(linked_names, file=paste(c$targetDir, "linked_unique_names.csv", sep=""), row.names=FALSE)

# set ids for all the unique names that were not matched
print("assigning unique ids to remaning unique names...")
number_without_id <- nrow(unique_name_and_postal[is.na(unique_name_and_postal$contributor_id),])
next_unique_contrib_id <- max(unique_name_and_postal$contributor_id, na.rm=TRUE)
last_unique_contrib_id <- next_unique_contrib_id + number_without_id - 1
unique_name_and_postal$contributor_id[is.na(unique_name_and_postal$contributor_id)] <-
  c(next_unique_contrib_id:last_unique_contrib_id)

# merge the newly defined contrib_ids back into the original data_set
print("Merging contributor_ids into data set...")
data_set <- merge(data_set, unique_name_and_postal)

print("Write CSV file...")
write.csv(data_set, file=paste(c$targetDir, c$allContribsFileName, sep=''), row.names=FALSE)