#' Isolate cells above column headings
#'
#' Gets year and country info from the rows above the column headings.
#' Can be used for data imported using xlsx_cells, without first changing it to
#' a more standard format. Alternatively it can be used on a more standard 
#' dataframe, for example one imported with read.xlsx. 
#'
#' @importFrom dplyr %>% filter distinct mutate
#'
#' @param dat Dataframe imported using xlsx_cells where there are header cells
#'   above the column names containing info on date and year.
#' @param first_header_row Numeric value. The row number in the excel file
#'   containing the first set of column headings.
#'
#' @return Tibble containing all year and country info.
#'
#' @examples
#' first_header_row <- 4
#' test_dat <- data.frame(row = c(1:5), character = c("data for 2017 ", "England and", "Wales", "impala", "elephant"))
#' get_info_cells(test_dat, first_header_row)
#'
#' @export
get_info_cells <- function(dat, first_header_row) {

  if(type == "xlsx_cells") {
    
    clean_data <- dat %>% 
      filter(row %in% 1:(first_header_row - 1)) %>% 
      distinct(character) %>% 
      filter(!is.na(character)) %>% 
      mutate(character = trimws(character, which = "both")) 
    
  } else { 
    
    above_headers <- dat[1:(first_header_row - 1), ]
    clean_data <- data.frame(character = c(t(above_headers)))
    
  }
  
  output <- clean_data %>% 
    mutate(Year = get_all_years(character)) %>%
    mutate(Country = get_all_country_names(character))

  number_of_country_NAs <- sum(is.na(output$Country))
  number_of_year_NAs <- sum(is.na(output$Year))

  if(number_of_country_NAs == nrow(output)){
    warning(paste("No countries were identified in the header section of", substitute(dat)))
  }

  if(number_of_year_NAs == nrow(output)){
    warning(paste("No years were identified in the header section of", substitute(dat)))
  }

  return(output)


}
