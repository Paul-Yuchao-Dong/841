for (yr in c(5, 10, 15, 20)){
rmarkdown::render("Durian_again_again.Rmd", output_file = glue::glue("Preset652yr{yr}.html"),
                  params = list(
                    junior = 6,
                    mid = 5,
                    senior = 2,
                    prelim_yield = 0.5,
                    arrival_rate = 90,
                    sim_yr = yr
                  ))
}
