# House of Representatives Voting Networks

## Sources

This analysis was originally perfomed in:

> The Rise of Partisanship and Super-Cooperators in the U.S. House of Representatives
Andris C, Lee D, Hamilton MJ, Martino M, Gunning CE, et al. (2015) The Rise of Partisanship and Super-Cooperators in the U.S. House of Representatives. PLOS ONE 10(4): e0123507. https://doi.org/10.1371/journal.pone.0123507

The data comes from voteview.com:

> Lewis, Jeffrey B., Keith Poole, Howard Rosenthal, Adam Boche, Aaron Rudkin, and Luke Sonnet (2020). Voteview: Congressional Roll-Call Votes Database. https://voteview.com/ 

## How to Run

First, you need to acquire two files from voteview:

- Member Ideology (House, All Congresses, CSV)
- Members' Votes (House, All Congresses, CSV)

The first file is cranked through `agreements.py` to produce a tab-delimited file that shows the number of agreements (if >0) between any pair of congressmen across every congressional session. Running this over multiple cores will speed up the result. I think I used about 10 cores, and it took like 15 minutes.

Next, to find the vote thresholds, use `thresholds.R` to combine the pairwise data from `agreements.tsv` with the member ideology data you've downloaded. This script will output a file called `thresholds.tsv`.

Finally, we have the data we need to construct networks. Use `networkize.R` to finish the job.
