# functions for reading and cleaning data for 3-2-2 automation
# These are largely taken from template for type 1 data, but have been put into 
# functions for this indicator because they are exactly the same for 4 scripts.

# read in data -----------------------------------------------------------------

get_data <- function(header_row, filename, tabname) {
  
  if (header_row == 1) {
    source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                       sheet = tabname, 
                                       colNames = TRUE)  
  } else {
    source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                       sheet = tabname, 
                                       colNames = FALSE, skipEmptyRows = FALSE) 
  }  
  
  return(source_data)
}
  
# clean the columns that contain strings ---------------------------------------

clean_strings <- function(source_data) {
  
  clean_data <- source_data %>% 
    mutate(across(where(is.factor), as.character)) %>% 
    mutate(across(where(is.character), str_squish)) %>% 
    mutate(across(everything(), ~ SDGupdater::remove_superscripts(.x)))
  
}

# separate the data from the above-table metadata ------------------------------

extract_metadata <- function(clean_data, header_row) {
  
  metadata <- NULL
  
  if (header_row > 1) {

    metadata_cells <- get_info_cells(clean_data, header_row, "xlsx")
    metadata$year <- unique_to_string(metadata_cells$Year) 
    metadata$country <- unique_to_string(metadata_cells$Country) 
    
  } else {
    
    metadata$year <- NA
    metadata$country <- NA
    
  }
  
  return(metadata)
}

extract_data <- function(clean_data, header_row) {
  
  if (header_row > 1) {
    data_no_headers <- clean_data[(header_row + 1):nrow(clean_data), ]
  } else {
    data_no_headers <- clean_data[(header_row + 1):nrow(clean_data), ]
  }
  
  return(data_no_headers)
}

#-------------------------------------------------------------------------------

remove_symbols <- function(column) {
  ifelse(column %in% c("z", ":"),
         NA, 
         as.numeric(column))
}