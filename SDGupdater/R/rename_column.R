#' Rename columns based on patterns in current name
#'
#' Use patterns that are expected to always appear in a column name to rename
#' the column. This provides some future-proofing for changes to column names in 
#' future input data. Columns will only be renamed if exactly one column is identified.
#' If this is not the case a warning will be returned, and the column will remain 
#' with it's original name
#'
#' @param dat dataframe or tibble.
#' @pattern vector of expected string patterns in the column to be renamed
#' @alternate alternative pattern to pattern. Only used if pattern is unmatched
#' @not_pattern vector of patterns that must not be present in the column to be renamed
#' @new_name new name for the column
#'
#' @return dat with columns renamed
#'
#' @examples
#'
#' test_data <- data.frame("numbers_1_4" = c(10, 5),
#'                         "numbers_10_14" = c(1, 3),
#'                         "rates_1_4" = c(4, 7))
#' renamed <- rename_column(dat = test_data,
#'                         primary = c("number", "1", "4"),
#'                         alternate = c("death", "1", "4"),
#'                         not_pattern = c("10"),
#'                         new_name = "number_deaths_1_to_4")
#'                         
#' @export

rename_column <- function(dat, primary, alternate, not_pattern, new_name){
  
  column_indices <- get_column_index(dat, primary)
  
  if(length(column_indices) == 0 & !missing(alternate)){
    column_indices <- get_column_index(dat, alternate)
  }
  
  if(missing(not_pattern)) {
    column_index <- column_indices
  } else {
    not_indices <- get_column_index(dat, not_pattern)
    column_index <- setdiff(column_indices, not_indices)
  }
  
  if(length(column_index) > 1 | length(column_index) == 0) {
    warning(paste(length(column_index), 
               "columns identified for", new_name, 
               ". Please refine 'primary', 'alternate', and 'not_pattern' arguments. Column name not replaced"))
  } else {
    names(dat)[column_index] <- new_name
  }
  
  return(dat)
  
}


#' Get index of column names matching a pattern
#'
#' Use patterns that are expected to always appear in a column name to rename
#' the column. This provides some future-proofing for changes to column names in 
#' future input data. Columns will only be renamed if exactly one column is identified.
#' If this is not the case a warning will be returned, and the column will remain 
#' with it's original name
#'
#' @param dat dataframe or tibble.
#' @pattern vector of strings to look for
#'
#' @return index of columns matching the pattern
#'
#' @examples
#' test_data <- data.frame("numbers_1_4" = c(10, 5),
#'                         "numbers_10_14" = c(1, 3),
#'                         "rates_1_4" = c(4, 7))
#' indices <- get_column_index(test_data, c("numbers", "1"))
#' 
#' @export

get_column_index <- function(dat, pattern) {
  
  which(apply(sapply(pattern, grepl, names(dat)), 1, all) == TRUE)
  
}