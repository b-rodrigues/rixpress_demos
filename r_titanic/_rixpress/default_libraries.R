library(data.table)
library(dplyr)
library(ggplot2)
library(readr)
library(rlang)
library(scales)
load_dataset <- function(path) {
  data.table::fread(
    path,
    stringsAsFactors = FALSE,
    blank.lines.skip = FALSE
  )
}

pre_process <- function(df) {
  df %>%
    na.omit() %>%
    dplyr::select(-PassengerId) %>%
    dplyr::mutate_if(is.character, as.factor)
}

bar_plot <- function(df, col, insight = "", flip = FALSE) {
  p <- df %>%
    dplyr::count(!!rlang::sym(col)) %>%
    ggplot2::ggplot(ggplot2::aes(x = !!rlang::sym(col), y = n)) +
    ggplot2::geom_bar(
      stat = 'identity',
      fill = "#008B8B",
      color = "#008B8B",
      alpha = .5,
      width = .5
    ) +
    ggplot2::labs(
      title = paste("Distribution of ", col, ""),
      x = paste("", col, ""),
      y = "Count",
      subtitle = paste(insight)
    ) +
    ggplot2::scale_y_continuous(label = scales::comma) +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(
        fill = "white",
        colour = "grey",
        size = 1,
        linetype = "solid"
      ),
      plot.title = ggplot2::element_text(
        color = 'black',
        size = 12,
        face = 'bold'
      ),
      axis.title.x = ggplot2::element_text(
        color = 'black',
        size = 11,
        face = 'bold'
      ),
      axis.title.y = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(size = 12, angle = 45, hjust = 1),
      axis.text.y = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_line(size = (0.2), colour = "grey"),
      panel.grid.major = ggplot2::element_line(size = (0.2), colour = "grey"),
      legend.position = 'right'
    )

  if (flip) {
    return(p + ggplot2::coord_flip())
  }
  return(p)
}
