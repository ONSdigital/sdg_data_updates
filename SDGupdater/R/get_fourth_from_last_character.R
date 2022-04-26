#' Get fourth from last character
#'
#' Get the fourth from last character of a string
#'
#' @param variable Character string.
#'
#' @return Character.
#'
#' @examples
#' get_fourth_from_last_character("abcde")
#'
#' @export
get_fourth_from_last_character <- function(variable) {
  
  if(is.character(variable) != TRUE) {
    stop("variable must be a character string")
  } 
  
  output <- substr(variable, nchar(variable) - 3, nchar(variable) - 3)

  number_of_characters <- nchar(variable)

  if(any(number_of_characters < 4, na.rm = TRUE) ){
    warning("At least one string had fewer than four characters. Where this is the case, '' is returned")
  }

  return(output)

}
