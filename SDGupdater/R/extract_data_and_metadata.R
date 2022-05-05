#' get year and country from info above headers
#'
#' Extract the year and country from info above the headers. If headers are in 
#' the first row NAs are returned.
#'
#' @param dat dataframe or tibble
#' @param header_row numeric. The row number on which the headers are located
#' @param type "xlsx_cells" if data format is from xlsx_cells. Default is not 
#' xlsx_cells
#' @return a list containing years and countries found in the info above the headers
#'
#' @examples
#' test_dat <- data.frame(
#'   col1 = c("Data relating to England and Wales, 2021", "", "Sex", "Female"),
#'   col2 = c("", "", "Age", "Under 16"))
#' clean_data <- extract_metadata(test_dat, 3)
#' 
#' @export

extract_metadata <- function(dat, header_row, type="not") {
  
  metadata <- NULL
  
  if (header_row > 1) {
    
    metadata_cells <- get_info_cells(dat, header_row, type)
    metadata$year <- unique_to_string(metadata_cells$Year) 
    metadata$country <- unique_to_string(metadata_cells$Country) 
    
  } else {
    
    metadata$year <- NA
    metadata$country <- NA
    
  }
  
  return(metadata)
}

#' remove information above the headers
#'
#' Sometimes there will be metadata stored above the header rows. Remove this 
#' information, leaving just the data (and potentially also footnotes) with 
#' headers as column names. If there is no metadata above the headers, the 
#' original data are returned.
#' 
#'
#' @param dat dataframe or tibble
#' @param header_row numeric. The row number on which the headers are located
#' @return a list containing years and countries found in the info above the headers
#'
#' @examples
#' test_dat <- data.frame(
#'   col1 = c("Data relating to England and Wales, 2021", "", "Sex", "Female"),
#'   col2 = c("", "", "Age", "Under 16"))
#' clean_data <- extract_metadata(test_dat, 3)
#' 
#' @export
extract_data <- function(dat, header_row) {
  
  if (header_row > 1) {
    
    isolated_data <- dat[(header_row + 1):nrow(dat), ]
    names(isolated_data) <- dat[header_row, ]
    
  } else {
    
    isolated_data <- dat
    
  }
  
  return(isolated_data)
}



