#' Get penultimate character
#'
#' Get the second to last character of a string
#'
#' @param variable Character string.
#'
#' @return Character.
#'
#' @examples
#' get_penultimate_character("abcde")
#'
#' @export
get_penultimate_character <- function(variable) {
  output <- substr(variable, nchar(variable) - 1, nchar(variable) - 1)

  number_of_characters <- nchar(variable)

  if(any(number_of_characters < 2, na.rm = TRUE)){
    warning("At least one string had fewer than two characters. Where this is the case, '' is returned")
  }

  return(output)

}
