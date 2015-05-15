normalize_names <- function(full_names){

  # Clean a vector of names and output the clean string, first name, last name, and remaining characters.
  # Cleaning consists of the following steps:
  # 1. convert to all lower case
  # 2. convert accented characters (é) to their alphabetical counterparts (e)
  # 3. drop punctuation marks ("-")
  # 4. replace empty names by 'anon'

  library(dplyr, quietly=TRUE, warn.conflicts=FALSE)
  library(magrittr, quietly=TRUE, warn.conflicts=FALSE)
  library(stringr, quietly=TRUE, warn.conflicts=FALSE)

  ## iterate gsub over a vector of patterns (i.e. set of special characters)
  gsub2 <- function(pattern, replacement, x, ...) {
    for(i in 1:length(pattern))
      x <- gsub(pattern[i], replacement[i], x, ...)
    x
  }

  #coerce a character vector to only contain alphabetical characters
  coerce_to_alpha <- function(names){

    #convert accented characters to their alphabetical counterparts
    from <- c('Š', 'š', 'Ž', 'ž', 'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É',
              'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï', 'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', 'Ø', 'Ù',
              'Ú', 'Û', 'Ü', 'Ý', 'Þ', 'ß', 'à', 'á', 'â', 'ã', 'ä', 'å', 'æ', 'ç',
              'è', 'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï', 'ð', 'ñ', 'ò', 'ó', 'ô', 'õ',
              'ö', 'ø', 'ù', 'ú', 'û', 'ý', 'ý', 'þ', 'ÿ')

    to <- c('S', 's', 'Z', 'z', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'C', 'E', 'E',
            'E', 'E', 'I', 'I', 'I', 'I', 'N', 'O', 'O', 'O', 'O', 'O', 'O', 'U',
            'U', 'U', 'U', 'Y', 'B', 'Ss','a', 'a', 'a', 'a', 'a', 'a', 'a', 'c',
            'e', 'e', 'e', 'e', 'i', 'i', 'i', 'i', 'o', 'n', 'o', 'o', 'o', 'o',
            'o', 'o', 'u', 'u', 'u', 'y', 'y', 'b', 'y')

    normalized <- gsub2(from, to, names)

    # Remove titles, the words 'and' & 'or', and non-alphabetical characters
    normalized <- gsub("(^|\\s)((dr|ms|mr|mrs)\\W+)*|(prof(essor)?|miss)\\s", " ", normalized, ignore.case=TRUE)
    normalized <- gsub("(^|\\s)(and|or)\\s", " ", normalized, ignore.case=TRUE)
    normalized <- gsub("[^a-z| ]", "", normalized, ignore.case=TRUE)

    # Remove excessive white space
    normalized <- gsub("\\s{2, }", " ", normalized)
    normalized <- str_trim(normalized)

    return(normalized)
  }

  reduce_name <- function(names) {
    names <- unlist(names)

    suffixReg <- "(^|\\s)[js]r(\\s|$)"
    suffixIndex <- grep(suffixReg, names)

    if(length(suffixIndex)) {
      suffix <- names[suffixIndex[1]]
      names <- names[-suffixIndex[1]]
    } else {
      suffix <- ""
    }

    n <- length(names)
    first_name <- names[1]
    last_name <- ifelse(n > 1, names[n], "")

    reduced_name <- paste(first_name, last_name, suffix)
    reduced_name <- str_trim(reduced_name)

    data.frame(clean_first_last_name=reduced_name, stringsAsFactors=F)
  }

  full_names %>%
    tolower %>%
    coerce_to_alpha %>%
    strsplit(split=' ') %>%
    lapply(FUN=reduce_name) %>%
    rbind_all
}