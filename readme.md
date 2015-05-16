### Context

This is one element of a larger data science project, exploring patterns of donation to Canadian federal political parties. It is the final, data-wrangling stage, in which donation records for the same contributor are linked by a common id.

### data/output/as_submitted

The full data set contains roughly 1.5 million records. It’s been split over a number of files – organized by party and year – for the sake of portability (files over 100MB cannot be pushed to GitHub). To concatenate the data into a single CSV file run the script R/manage_csvs/concatenate_csvs.R.

### data/source/as_submitted

The source data was [scraped](https://github.com/saltire/election-contribs) from [Elections Canada](http://www.elections.ca/WPAPPS/WPF/), and processed by a [cleaning script](https://github.com/leonL/federal-contributions-cleaning).

### R/link_data.R

Records that have the same postal code, and for which the Jaro-Winkler string distance of the contributor names is greater than or equal to 0.945 are assumed to represent donations from the same person, and so are linked with a common id (contributor_id).

### R/link_accuracy

Random samples of the linked data set were manually reviewed to infer two guiding statistics about the accuracy of the links as a whole. The following claims are 99% accurate:

1. For every 100 postal codes, less than 5 include any donations by the same contributor that failed to be linked.
2. For every 100 contributors, less than 5 include misassigned donations, that is, records that were attributed to their contributor_id, but should not have been.

* There are two sources of error in the linking process that are not possible to account for: donations made by different contributors with the same name, from the same postal code (e.g. a father and son) will be linked, whereas donations from a single contributor made from different postal codes (e.g. before and after moving house) wont be linked.

### The Project

Canadian federal political parties are principally financed by donations from individual citizens. Only a small proportion of the population gives (less than 1%), and in turn decides how a vast amount of public money (~$46 million in 2009), through tax credits, is distributed among the parties.

The aim of this project is to explore the patterns of contribution among this relatively small set. How consistently do donors give, how are their contribution habits affected by political events, how do they split their proceeds between federal parties and their riding associations, and in general how do these patterns correlate to geography and demography. Questions among others to explore...

I’m aiming to complete the project by the end of summer, 2015.
