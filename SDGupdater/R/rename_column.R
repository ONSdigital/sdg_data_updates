#' Rename columns based on patterns in current name
#'
#' Use patterns that are expected to always appear in a column name to rename
#' the column. This provides some future-proofing for changes to column names in 
#' future input data. Columns will only be renamed if exactly one column is identified.
#' If this is not the case a warning will be returned, and the column will remain 
#' with it's original name
#'
#' @param dat dataframe or tibble.
#' @param primary vector of expected patterns in the column to be renamed
#' @param alternate alternative pattern to pattern. Only used if pattern is unmatched
#' @param not_pattern vector of patterns that must not be present in the column to be renamed
#' @param new_name new name for the column
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
  
  column_index <- pinpoint_indices(names(dat), primary, alternate, not_pattern)
  
  if(length(column_index) > 1 | length(column_index) == 0) {
    warning(paste(length(column_index), 
                  "columns identified for", new_name, 
                  ". Please refine 'primary', 'alternate', and 'not_pattern' arguments. Column name not replaced"))
  } else {
    names(dat)[column_index] <- new_name
  }
  
  return(dat)
  
}

#' Get indices where a set of pattern conditions are met
#'
#' Allows the user to specify a set of pattern conditions and returns all
#' inidces of a vector where those conditions are met. 
#' 
#' If multiple patterns are given for an argument, the condition will only be
#' met if ALL patterns in that argument are matched.
#'
#' @param dat vector.
#' @param primary first pattern or patterns to look for. Alternate will be 
#' ignored if this is found
#' @param alternate pattern(s) to look for if nothing is returned for primary
#' @param not_pattern exclude any indices where this pattern is matched
#'
#' @return vector of all indices where conditions are met
#'
#' @examples
#' test_data <- c("numbers_1_4", "numbers_10_14", "rates_1_4" = c(4, 7))
#' indices <- get_indices(test_data, c("numbers", "1"))
#' 
#' @export

pinpoint_indices <- function(dat, primary, alternate, not_pattern){
  
  indices <- get_indices(dat, primary)
  
  if(length(indices) == 0 & !missing(alternate)){
    indices <- get_indices(dat, alternate)
  }
  
  if(!missing(not_pattern)) {
    not_indices <- get_indices(dat, not_pattern)
    indices <- setdiff(indices, not_indices)
  }
  
  return(indices)
  
}


#' Get indices of vector where a pattern is matched
#'
#' Returns all indices of a vector where a pattern is matched. If multiple
#' patterns are passed, only indices where all patterns are matched will be 
#' returned.
#'
#' @param dat vector.
#' @param pattern vector of strings to look for
#'
#' @return indices of all columns matching the pattern(c)
#'
#' @examples
#' test_data <- c("numbers_1_4", "numbers_10_14", "rates_1_4")
#' indices <- get_indices(test_data, c("numbers", "1"))
#' 
#' @export

get_indices <- function(dat, pattern) {
  
  if (is.vector(dat) == FALSE |
      length(dat) == 1) {
    stop("dat must be a vector of more than one value")
  }

  which(apply(sapply(pattern, grepl, dat), 1, all) == TRUE)
  
}

#' Get index of column name where a pattern is matched
#'
#' Returns all indices of a vector of column names where a pattern is matched. 
#' If multiple patterns are passed, only indices where all patterns are matched 
#' will be  returned.
#'
#' @param dat vector.
#' @param pattern vector of strings to look for
#' @return indices of all columns matching the pattern(c)
#'
#' @examples
#' test_data <- c("numbers_1_4", "numbers_10_14", "rates_1_4")
#' indices <- get_indices(test_data, c("numbers", "1"))
#'
#' @name get_column_index-deprecated
#' @usage get_column_index(dat, pattern)
#' @seealso \code{\link{SDGupdater-deprecated}}
#' @keywords internal
NULL

#' @rdname get_column_index-deprecated
#' @section \code{get_column_index}:
#' For \code{get_column_index}, use \code{\link{get_indices}}.
#'
#' @export

get_column_index <- function(dat, pattern) {
  
  .Deprecated("get_indices")
  which(apply(sapply(pattern, grepl, names(dat)), 1, all) == TRUE)
  
}