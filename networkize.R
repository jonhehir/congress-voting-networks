library(tidyverse)
library(network)

# read the data

agreements <- read_tsv("agreements-senate.tsv",
                       col_names = c("congress", "a", "b", "agreements"))
thresholds <- read_tsv("thresholds-senate.tsv")
members <- read_csv("Sall_members.csv")

# build a network

networkize <- function(c, chamber_name, force_connected = T) {
  # currently restricted to dem and repub only
  # could expand this to k largest parties or some other logic
  
  threshold <- filter(thresholds, congress == c)$threshold
  agreements <- filter(agreements, congress == c)
  if(force_connected) {
    agreements <- filter(agreements, agreements > threshold)
  }
  
  icpsrs <- unique(c(agreements$a, agreements$b))
  members <- filter(members,
                    icpsr %in% icpsrs &
                    congress == c &
                    party_code %in% c(100, 200) &
                    tolower(chamber) == chamber_name) %>%
    mutate(node_index = row_number())
  
  agreements %>%
    filter(agreements > threshold) %>%
    inner_join(members, by = c("a" = "icpsr"), suffix = c("", ".a")) %>%
    inner_join(members, by = c("b" = "icpsr"), suffix = c("", ".b")) %>%
    select(node_index, node_index.b) %>%
    write_tsv(sprintf("networks-%s/edges-%03d.tsv", chamber_name, c), col_names = F)
  
  members %>%
    arrange(node_index) %>% # this is really unnecessary
    select(party_code) %>%
    write_tsv(sprintf("networks-%s/nodes-%03d.tsv", chamber_name, c), col_names = F)
}

networkize(80, "senate")

# view a network

plot_network <- function(c, chamber_name) {
  nodes <- read_tsv(sprintf("networks-%s/nodes-%03d.tsv", chamber_name, c), col_names = c("party"))
  edges <- read_tsv(sprintf("networks-%s/edges-%03d.tsv", chamber_name, c), col_names = c("a", "b"), col_types = "ii")
  
  net <- network.initialize(length(nodes$party), directed = F)
  net %v% "party" <- nodes$party
  add.edges(net, edges$a, edges$b)
  
  plot(net, vertex.col = net %v% "party")
}

plot_network(80, "senate")

# mass export networks

for(i in 50:116) {
  networkize(i, "senate")
}
