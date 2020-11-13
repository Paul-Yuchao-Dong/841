df <- rio::import("by_collection.csv") %>%
  select(-lec_id,-start,-end) %>%
  mutate(log_sales = log(sales)) %>%
  select(-sales)

glimpse(df)

normalize <- function(x){
  (x-mean(x))/sd(x)
}

fit_normalize <- function(x, ref) {
  (x - mean(ref)) / sd(ref)
}

reverse_normalize <- function(x,ref){
  x * sd(ref) + mean(ref)
}

df_scaled <- df %>%
  mutate(across(c(duration,log_sales, weekends), normalize))

library(brms)

N <- 100000

iter <- floor(N / 4) * 2 # 4 chains and half goes to warmup

lec_brm <- brm(log_sales ~ duration  + weekends + have_black_friday + have_boxing , data = df_scaled, iter = iter)

newdata <- data.frame(duration = fit_normalize(21, df$duration),
                      weekends = fit_normalize(6, df$weekends),
                      have_black_friday = F, have_boxing = F)


pred <- predict(lec_brm, newdata = newdata, summary = F) %>%
  reverse_normalize(df$log_sales) %>%
  exp

hist(pred)
