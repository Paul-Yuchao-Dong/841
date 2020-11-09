# Simulate the Negotiation + Completion Step
# Treat it as a single step

library(tidyverse)

N <- 1000000

set.seed(1984)
# all numbers in weeks unless otherwise specified

df <- tibble(
  negotiation = rexp(N,1/4),
  proceed = rbernoulli(N, p = 0.2),
  completion = rexp(N,1/5),
  combine = if_else(
    proceed,
    negotiation + completion,
    negotiation
  )
)

# Sanity check

df %>%
  summarize(avg_nego = mean(negotiation),
            avg_proceed = mean(proceed),
            avg_completion = mean(completion),
            avg_combined = mean(combine))

hist(df$combine)

# Calculate the Coef of Variance

combine_mean <- mean(df$combine)
combine_sd <- sd(df$combine)

CV_p <- combine_sd / combine_mean

CV_p

combine_mean
