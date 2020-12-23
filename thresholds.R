library(tidyverse)

# read data

agreements <- read_tsv("agreements.tsv",
                 col_names = c("congress", "a", "b", "agreements"))
members <- read_csv("Hall_members.csv")

# play with data

agreements_p <- agreements %>%
  inner_join(members, by = c("a" = "icpsr", "congress"), suffix = c("", ".a")) %>%
  inner_join(members, by = c("b" = "icpsr", "congress"), suffix = c("", ".b")) %>%
  transmute(congress, a, b, same_party = party_code == party_code.b, agreements)

find_threshold <- function(data, density_adjust = 2) {
  M <- max(data$agreements)
  d <- function(filtered) {
    density(filtered$agreements, kernel = "gaussian", adjust = 2, from = 0, to = M, n = 2048)
  }
  
  d_same <- d(filter(data, same_party))
  d_diff <- d(filter(data, !same_party))
  
  modes <- sort(c(which.max(d_diff$y), which.max(d_same$y)))
  obj <- function(x, y_1, y_2) {
    case_when(
      x < modes[0] ~ Inf,
      x > modes[1] ~ Inf,
      T ~ abs(y_1 - y_2) / (y_1 + y_2)^2
    )
  }
  
  # try to find equal points with a preference for larger average y
  # (this idea works maybe 90% of the time)
  obj <- abs(d_same$y - d_diff$y) / (d_same$y + d_diff$y)^2
  # but only in between our two modes (exclude tails, fixes the other 10%)
  obj[1:modes[1]] <- Inf
  obj[modes[2]:length(obj)] <- Inf
  thresh_idx <- which.min(obj)
  floor(d_same$x[thresh_idx])
}

thresholds <- tibble(congress = unique(agreements_p$congress)) %>%
  mutate(threshold = map_dbl(congress, function(c) find_threshold(filter(agreements_p, congress == c))))

write_tsv(thresholds, "thresholds.tsv")

# plot data

plot_threshold <- function(c) {
  ggplot(filter(agreements_p, congress == c)) +
    geom_density(aes(x = agreements, color = same_party), adjust = 2, kernel = "gaussian") +
    geom_vline(xintercept = filter(thresholds, congress == c)$threshold)
}

for(congress in thresholds$congress) {
  plot_threshold(congress) +
    ggsave(sprintf("plots/threshold-%03d.png", congress))
}

# All look good to me except 15, 16, 17.
# The shape of these years is different, and it's not clear
# what a reasonable threshold would be.
