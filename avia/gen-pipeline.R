library(rixpress)

# Step 0: Load the data
avia <- rxp_r_file(
  name = avia,
  path = "avia_par_lu.tsv",
  read_function = readr::read_tsv
)

avia_clean_names <- rxp_r(
  name = avia_clean_names,
  expr = clean_names(avia)
)

# Step 1: Select and reshape (wide → long)
avia_long <- rxp_r(
  name = avia_long,
  expr = avia_clean_names %>%
    select("freq_unit_tra_meas_airp_pr_time_period", contains("x20")) %>%
    gather(date, passengers, -"freq_unit_tra_meas_airp_pr_time_period") %>%
    mutate(date = str_sub(date, 2, 10))
)

# Step 2: Split composite key column
avia_split <- rxp_r(
  name = avia_split,
  expr = avia_long %>%
    separate(
      col = "freq_unit_tra_meas_airp_pr_time_period",
      into = c("freq", "unit", "tra_meas", "airpr_pr_time_period"),
      sep = "_"
    )
)

# Step 6: Final cleaned dataset
avia_clean <- rxp_r(
  name = avia_clean,
  expr = avia_split %>%
    mutate(passengers = as.numeric(passengers)) %>%
    select(unit, tra_meas, destination = airpr_pr_time_period, date, passengers)
)

# Step 7: Quarterly arrivals
avia_clean_quarterly <- rxp_r(
  name = avia_clean_quarterly,
  expr = avia_clean %>%
    filter(
      tra_meas == "ARR,LU",
      !is.na(passengers),
      str_detect(date, "q")
    ) %>%
    mutate(date = yq(date))
)

# Step 8: Monthly arrivals
avia_clean_monthly <- rxp_r(
  name = avia_clean_monthly,
  expr = avia_clean %>%
    filter(
      tra_meas == "ARR,LU",
      !is.na(passengers),
      str_detect(date, "_(0|1)")
    ) %>%
    mutate(date = ymd(paste0(date, "01"))) %>%
    select(destination, date, passengers)
)

# Populate and build the pipeline
rxp_populate(
  list(
    avia,
    avia_clean_names,
    avia_long,
    avia_split,
    avia_clean,
    avia_clean_quarterly,
    avia_clean_monthly
  )
)

rxp_make(verbose = 1)
