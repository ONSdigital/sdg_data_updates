#' read type 1 data
#'
#' Read in a single sheet of excel data, where there is only one row of headers.
#' Data are read in slightly differently depending on whether headers are in the
#' first row or not 
#'
#' @importFrom openxlsx read.xlsx
#'
#' @param header_row numeric. The row number on which the headers are located
#' @param filename character string. name of an excel file including the extension.
#' This is pasted to input_folder to create the filepath
#' @param tabname character string. The name of the sheet, exactly as it is in the 
#' excel file
#' @param na.strings A character vector of strings which are to be interpreted as NA.
#' Defaults to "". Note that for csv files the test happens after white space is 
#' stripped from the input, so na.strings values may need their own white space 
#' stripped in advance.
#' @return dataframe
#'
#' @examples
#' source_data <- get_type1_data(header_row, filename, tabname)
#' 
#' @export

get_type1_data <- function(header_row, filename, tabname, na.strings = "") {
  
  filepath <- paste0(input_folder, "/", filename)
  
  if (SDGupdater::get_characters_after_dot(filename) == "xlsx") {
    
    if (header_row == 1) {
      source_data <- openxlsx::read.xlsx(filepath,
                                         sheet = tabname, 
                                         colNames = TRUE,
                                         na.strings = na.strings)  
    } else {
      source_data <- openxlsx::read.xlsx(filepath,
                                         sheet = tabname, 
                                         colNames = FALSE, 
                                         skipEmptyRows = FALSE,
                                         na.strings = na.strings) 
    }  
    
  } else if (SDGupdater::get_characters_after_dot(filename) == "csv") {
    
    if (header_row == 1) {
      source_data <- read.csv(filepath,
                              header = TRUE,
                              na.strings = na.strings,
                              check.names = TRUE)
    } else {
      source_data <- read.csv(filepath,
                              header = FALSE,
                              na.strings = na.strings)
    }
    
  } else {
    
    stop(paste("File must be an xlsx or csv file. Re-save ", filename, " and re-run script"))
    
  }
  
  return(source_data)
}