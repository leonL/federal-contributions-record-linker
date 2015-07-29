if(!exists("k")) { k <- list() }

k <- within(k, {
  PartyNicknames <- c('Bloc', 'Conservative', 'Green', 'Liberal', 'NDP')
  PartyFullNames <- c("Bloc Québécois", "Conservative Party of Canada",
      "Green Party of Canada", "Liberal Party of Canada", "New Democratic Party")
  PartyNames <- data.frame(name=PartyFullNames, nick_name=PartyNicknames)
  AllContribYears <- as.character(c(2004:2014))
})