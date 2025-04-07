library(dplyr)
library(ggplot2)
library(quarto)
library(reticulate)
clean_coords <- function(coords) {
  as.data.frame(py$coords) %>%
    dplyr::sample_n(1768) %>%
    dplyr::mutate(bmi = V2 * 17 + 15, steps = 15000 - V1 * 15000 / max(V1)) %>%
    dplyr::mutate(
      randvar = rnorm(n(), mean = 0, sd = 10),
      randi = steps * (1 + randvar),
      gender = dplyr::case_when(randi < median(steps) ~ "Female", TRUE ~ "Male")
    )
}

gender_distribution <- function(coords) {
  dplyr::count(coords, gender)
}

make_plot1 <- function(coords) {
  coords %>%
    ggplot(aes(x = bmi, y = steps)) +
    geom_point() +
    theme_void() +
    xlim(0, 15000)
}

make_plot2 <- function(coords) {
  coords %>%
    ggplot(aes(x = bmi, y = steps, color = gender)) +
    geom_point() +
    theme_void() +
    xlim(0, 15000)
}
