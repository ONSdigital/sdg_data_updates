#' Create datetime that can be used in filename
#'
#' Replaces the '-' and ':' in the date time created by `sys.time()` with a dash.
#'
#' @param date_time output of `sys.time()`
#'
#' @return date and time with dash separators
#'
#' @examples
#' date_time <- Sys.time()
#' filename_date_time <- create_datetime_for_filename(date_time)
#' filename_date_time
#'
#' @export

create_datetime_for_filename <- function(date_time) {
  datetime <- substr(date_time, 1, 16)
  reformatted <- gsub("[:|' '']", '-', datetime)
}
