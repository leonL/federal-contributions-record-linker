find_probable_name_matches <- function(names_by_pcode) {

  library(RecordLinkage, quietly=TRUE, warn.conflicts=FALSE)
  library(plyr, quietly=TRUE, warn.conflicts=FALSE)

  print("Calculating contributor name string distances...")
  link_probabilities <- compare.linkage(
    names_by_pcode, names_by_pcode,
    blockfld="postal_code",
    strcmp=c("clean_first_last_name")
  )

  print("Classifying link probabilities...")
  link_probabilities <- epiWeights(link_probabilities)
  link_probabilities <- epiClassify(link_probabilities, 0.945)

  # define a subset of record pairs that are links
  links <- with(link_probabilities, {
    pairs[prediction == "L", 1:2]
  })

  print("Remove self-referential links...")
  links <- links[links$id1 != links$id2, ]

  print("removing inverted pairs...")
  links <- adply(links, 1, smallest_first)
  unique_links <- links[!duplicated(links), ]

  return(unique_links)
}

smallest_first <- function(row) {
  if (row$id1 > row$id2) {
    data.frame(id1=row$id2, id2=row$id1)
  } else {
    row
  }
}

next_id <- 1

link_contributors_by_id <- function(ids) {
  ids <- unique(as.vector(as.matrix(ids)))
  current_ids <- unique_name_and_postal$contributor_id[ids]
  if (!any(is.na(current_ids))) { return() }
  current_ids <- current_ids[!is.na(current_ids)]
  if (length(current_ids) > 0) {
    contrib_id <- current_ids[1]
  } else {
    contrib_id <- next_id
    next_id <<- next_id + 1
  }
  unique_name_and_postal$contributor_id[ids] <<- contrib_id
  return()
}