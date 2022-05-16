#' clean all character strings in dataframe 
#'
#' Change factors to character strings, remove excess white 
#' space. Removing superscripts and changing the case are optional. 
#'
#' @import dplyr
#' @import stringr
#'
#' @param source_data dataframe or tibble
#' @param remove_ss logical. Default is FALSE. If TRUE superscripts are removed. 
#'  Use default if there strings of letters that end in a number that you want 
#'  to keep. Where a number falls at the end of an alphanumeric code, it will 
#'  not be interpreted as a superscript and will not be removed. However, if the 
#'  ONLY number in an alphanumeric code is at the end, the number will be seen 
#'  as a superscript. 
#' @param case Used to change the case of the strings, using a stringr str_to...
#'  argument. Must be one of str_to_lower, str_to_upper, str_to_title, or
#'  str_to_sentence. If case is not given, the case will not be changed.
#' @return dataframe
#'
#' @examples
#' test_data <- data.frame(
#' "factor" = c("thEse      are ", "  alphaNumeric2", 
#'              "  factors  wITh too many spaces   ", "that ought to be character strings),
#'              stringsAsFactors = TRUE)
#'
#' clean_strings(test_data) 
#' clean_strings(test_data, case="str_to_title")
#' clean_strings(test_data, remove_ss = FALSE)
#' 
#' @export

clean_strings <- function(dat, remove_ss = FALSE, 
                          case = c(NA, "str_to_lower", "str_to_sentence", 
                                  "str_to_upper", "str_to_title")) {
  
  case <- match.arg(case) 
  
  clean_data <- dat %>% 
    mutate(across(where(is.factor), as.character)) %>% 
    mutate(across(where(is.character), stringr::str_squish)) 
  
  if (remove_ss == TRUE) {
    clean_data <- clean_data %>% 
      mutate(across(everything(), ~ SDGupdater::remove_superscripts(.x)))
  }

  if (!is.na(case)) {
    clean_data <- clean_data %>% 
      mutate(across(everything(), ~ switch(case,
                                           str_to_lower = str_to_lower(.x),
                                           str_to_sentence = str_to_sentence(.x),
                                           str_to_upper = str_to_upper(.x),
                                           str_to_title = str_to_title(.x))))
  }
  
  return(clean_data)
}