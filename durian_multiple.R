
SystemTime <- 52*16 # 6 years for warm up and 10 years for simulation

results <-lapply(1:100, function(i) {
  env <- simmer("durian")

  deal <- trajectory("deal's path") %>%

    ## add an prelim activity
    seize("junior", 1) %>%
    timeout(function() rexp(1, 48.75/150)) %>%
    release("junior", 1) %>%
    leave(function() runif(1) < 0.5, keep_seized = F) %>%

    ## add a DD activity
    seize("mid", 1) %>%
    timeout(function() rexp(1, 1/4)) %>%
    release("mid", 1) %>%
    leave(function() runif(1) < 2/3, keep_seized = F) %>%

    ## add a Negotiation + Closing activity
    seize("senior", 1) %>%
    log_("New deal fall to the seniors") %>% # add a log
    set_attribute("Negotiation_pass", function() runif(1)<0.2) %>%
    log_(function() {paste("Negotiation_pass:", get_attribute(env,"Negotiation_pass"))}) %>%
    timeout(function() if(get_attribute(env,"Negotiation_pass")) rexp(1, 1/4) + rexp(1, 1/5) else rexp(1, 1/4)) %>%
    release("senior", 1)

  env %>%
    add_resource("junior", 6) %>%
    add_resource("mid", 5) %>%
    add_resource("senior", 2) %>%
    add_generator("deal", deal, function() rexp(1, 90/52), mon = 2) %>%
    run(until = SystemTime)
})

results_nego <- results %>% get_mon_attributes()
results_arr <- results %>% get_mon_arrivals()
# View(results_arr)
# View(results_nego)
results_features <- results_arr %>%
  left_join(
    results_nego %>%
      dplyr::select(name, replication, value)
  )

resources <- get_mon_resources(results)
plot(resources, metric = "utilization",  c("junior", "mid", "senior"))
# result is very close to excel

results_features %>%
  filter(start_time>52*6) %>% # leave only the last 10 years
  filter(value==1) %>%
  summarise(sum(value)) %>%
  {./100/10} # sanity check should be around 3



results_post <- results_features %>%
  filter(start_time>52*6) %>% # leave only the last 5 years
  filter(value==1)

hist(results_post$activity_time)

mean(results_post$activity_time>26)

results_post <- results_post %>%
  mutate(revenue = 4 * 0.99^activity_time ) %>%
  mutate(profit = revenue - 3.64)

results_post %>%
  ggplot(aes(profit))+
  geom_histogram()

mean(results_post$profit)

