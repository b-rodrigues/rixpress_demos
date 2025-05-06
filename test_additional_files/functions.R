read_first_n_lines_two_files <- function(file1, file2, n = 5) {
  lines1 <- readLines(file1, n = n, warn = FALSE)
  lines2 <- readLines(file2, n = n, warn = FALSE)
  c(lines1, lines2)
}
