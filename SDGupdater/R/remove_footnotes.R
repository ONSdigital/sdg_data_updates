#' Remove footnotes below table
#'
#' Assuming footnotes are in the first few columns, this function removes those
#' rows, leaving only rows with data.   
#'   
#' remove_footnotes starts at the bottom of the dataframe and stops looking
#' for footnotes as soon as a row that looks like a non-footnote row is 
#' encountered.
#'   
#' Footnotes must be in one or more of the first x columns, 
#' where x = check_columns.  
#' If the data are likely to have non-footnote (real) data in the first x 
#' column(s) and NAs in all other columns DO NOT use this function as it will 
#' likely remove more than just footnotes
#' 
#' @param data dataframe with footnotes in which the footnote is followed by NA cells on the same row.
#' @param check_columns numeric. The maximum column index in which you expect there to be footnotes. Default is 2.
#' @return data frame with footnote, and all-NA rows removed
#'
#' @examples
#'
#' test_data <- data.frame("A" = c(10, 5, "footnote:"),
#'                         "B" = c(1, 3, "this is a footnote"),
#'                         "C" = c(4, 7, NA),
#'                         "D" = c(5, 9, NA))
#' remove_footnotes(test_data, 2)
#'                         
#' @export

remove_footnotes <- function(data, check_columns=2) {
  
  if(!is.data.frame(data)) {
    stop("data must be a dataframe")
  } else {
    column_count <- ncol(data)
    
    if(check_columns == column_count) {
      warning("check_columns should be less than the number of columns in the dataframe. 
            \nNo changes have been made as check_columns == ncol(data)")
    }
    
    if(check_columns > column_count) {
      
      stop("check_columns must be less than the number of columns in the dataframe")
      
    } else {
      footnote_na_count <- (column_count - check_columns):column_count
      
      data_na_count <-  dplyr::mutate(data, na_count = rowSums(is.na(data)))
      
      for(i in nrow(data_na_count):1) {
        
        last_row <- data_na_count[i, ]
        
        na_count_end_columns <- sum(is.na(last_row[, (check_columns + 1):column_count]))
        end_columns_all_NA <- na_count_end_columns  == (column_count - check_columns)
        
        if (last_row$na_count %in% footnote_na_count & end_columns_all_NA) {
          
          data_na_count <- data_na_count[-i, ]
          
        } else {
          
          break
        }
        
      }
      
      no_footnotes <- dplyr::select(data_na_count, -na_count)
      
      return(no_footnotes)
    }
  }
}