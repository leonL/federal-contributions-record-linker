### data/source/as_submitted

Roughly 2 million records, the set of contribtions made by individuals to Canada's five major federal political parties from 2004 to 2014. Contribtuion recrods for those who gave less than $200 total for a given year are anonymous, and therefore are not included. The data was [scraped](https://github.com/leonL/federal-contributions-scraper) from [Elections Canada's website](http://www.elections.ca/WPAPPS/WPF/), and pre-processed by a [munging script](https://github.com/leonL/federal-contributions-munger). Beyond cleaning and normalizing the data, the munging script filters out certain types of records (e.g. estate contributions and those with invalid postal codes). See that repo for further details.

### R/link_data.R

A script linking together every individual's set of contributions by a common id.
Records that have the same postal code, and for which the Jaro-Winkler string distance of the contributor names is greater than or equal to 0.945 are assumed to represent donations from the same person.

### data/output/as_submitted

The linked data set (unique contributor_ids denote unique individuals). It’s been split over a number of files – organized by party and year – for the sake of portability (files over 100MB cannot be pushed to GitHub). To concatenate the data into a single CSV file run the script R/manage_csvs/concatenate_csvs.R.

### R/link_accuracy

Random samples of the linked data set were manually reviewed to infer two guiding statistics about the accuracy of the links as a whole. The following claims are 99% accurate:

1. For every 100 postal codes, less than 5 include any donations by the same contributor that failed to be linked.
2. For every 100 contributors, less than 5 include misassigned donations, that is, records that were attributed to their contributor_id, but should not have been.

* There are two sources of error in the linking process that are not possible to account for: donations made by different contributors with the same name, from the same postal code (e.g. a father and son) will be linked, whereas donations from a single contributor made from different postal codes (e.g. before and after moving house) wont be linked.

### Context

Since the per-vote subsidy was cancelled in recent years, Canadian federal political parties are principally financed by donations from individual citizens. Only a small proportion of the population gives (less than 2%), and in turn decides how a vast amount of public money (~$46 million in 2009), through tax credits, is distributed among the parties.