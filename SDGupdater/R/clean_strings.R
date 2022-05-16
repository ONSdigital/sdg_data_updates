#' clean all character strings in dataframe 
#'
#' Change factors to character strings and remove superscripts and excess white 
#' space.
#'
#' @import dplyr
#' @import stringr
#'
#' @param source_data dataframe or tibble
#' @param remove_ss logical. Default is TRUE. If TRUE superscripts are removed. 
#'  Set to FALSE if there strings of letters that end in a number that you want 
#'  to keep. Where a number falls at the end of an alphanumeric code, it will 
#'  not be interpreted as a superscript and will not be removed. However, if the 
#'  ONLY number in an alphanumeric code is at the end, the number will be seen 
#'  as a superscript. 
#' @return dataframe
#'
#' @examples
#' clean_data <- clean_strings(source_data, remove_ss = TRUE)
#' 
#' @export

clean_strings <- function(dat, remove_ss = TRUE) {
  
  clean_data <- dat %>% 
    mutate(across(where(is.factor), as.character)) %>% 
    mutate(across(where(is.character), stringr::str_squish)) 
  
  if (remove_ss == TRUE) {
    
    clean_data <- clean_data %>% 
      mutate(across(everything(), ~ SDGupdater::remove_superscripts(.x)))
    
  }
  
  return(clean_data)
}