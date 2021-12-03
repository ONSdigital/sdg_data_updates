#' Get all charcters following a dot
#'
#' Get all charcters following the last period in a character string
#'
#' @param variable Character string.
#'
#' @return Character string. If there was no period, returns a blank ("")
#'
#' @examples
#' get_characters_after_dot("ab.cde")
#' get_characters_after_dot("ab.cde.fgh")
#'
#' @export
get_characters_after_dot <- function(string) {

  input_type <- typeof(string)

  if(input_type != "character"){
    warning("input should be of type string. If input type is double, a character string will be returned")
  }

  ifelse(grepl("\\.", string) == TRUE,
         sub(".*[.]", "", string),
         "")
}
