#' @title Remove superscripts
#'
#' @description Remove superscripts, whether they are read as actual
#'   superscripts or just as numbers (which are referred to as 'false
#'   superscripts'). 
#'
#' @details  This function assumes that superscripts never follow: 
#' - a space 
#' - a number (superscripts over 9 are not recognised)
#' - a string consisting of just one other character
#' - a 'word' consisting of both numbers and letters
#' - a pound or dollar symbol
#' - a string starting with a number or a single letter  
#' 
#'  If it becomes apparent that these scenarios need to be covered, the function
#' will need updating.
#'   
#' @param variable Character vector you want superscripts removed from.
#'
#' @return Character vector for all but `could_contain_superscripts`, which
#'   returns a logical vector.
#'
#' @export
#'
#' @examples
#' character <- c("Wales1","Rates?", "Numbers1,2")
#' remove_superscripts(character)
#' remove_real_superscripts(character)
#' remove_multiple_superscripts(character)
#' remove_false_superscripts(character)

remove_superscripts <- function(variable) {

  no_real_superscripts <- remove_real_superscripts(variable)
  no_multiple_superscripts <- remove_multiple_superscripts(no_real_superscripts)

  remove_false_superscripts(no_multiple_superscripts)

}

#' @rdname remove_superscripts
#' @export
remove_real_superscripts <- function (variable) {

  superscript_regex_codes <- "[\u{2070}\u{00B9}\u{00B2}\u{00B3}\u{2074}-\u{2079}]"

  gsub(superscript_regex_codes, '', variable)

}

#' @rdname remove_superscripts
#' @export
remove_multiple_superscripts <- function (variable) {

  two_superscripts <- "[0-9],[0-9]$"
  three_superscripts <- "[0-9],[0-9],[0-9]$"
  four_superscripts <- "[0-9],[0-9],[0-9],[0-9]$"
  five_superscripts <- "[0-9],[0-9],[0-9],[0-9],[0-9]$"
  six_superscripts <- "[0-9],[0-9],[0-9],[0-9],[0-9],[0-9]$"

  dashed <- "[0-9]-[0-9]$"
  dashed_twice <- "[0-9]-[0-9],[0-9]-[0-9]$"
  dashed_at_start <- "[0-9]-[0-9],[0-9]$"
  dashed_at_end <- "[0-9],[0-9]-[0-9]$"
  dashed_before_2 <- "[0-9]-[0-9],[0-9],[0-9]$"
  dashed_after_2 <- "[0-9],[0-9],[0-9]-[0-9]$"
  dashed_in_middle <- "[0-9],[0-9]-[0-9],[0-9]$"
  dashed_bookends <- "[0-9]-[0-9],[0-9],[0-9]-[0-9]$"


  multiple_superscripts <- paste0(c(two_superscripts,
                                    three_superscripts,
                                    four_superscripts,
                                    five_superscripts,
                                    six_superscripts,
                                    dashed,
                                    dashed_twice,
                                    dashed_at_start,
                                    dashed_at_end,
                                    dashed_before_2,
                                    dashed_after_2,
                                    dashed_in_middle,
                                    dashed_bookends), collapse = "|")

  ifelse(could_contain_superscript(variable) == TRUE,
         gsub(multiple_superscripts, "", variable),
         variable)

}

#' @rdname remove_superscripts
#' @export
remove_false_superscripts <- function (variable) {

  ifelse(could_contain_superscript(variable) == TRUE, gsub("[1-9]$", '', variable), variable)

}

#' @rdname remove_superscripts
#' @export
could_contain_superscript <- function (variable) {

  # We don't want to accidentally identify a number that is not a superscript as
  # a superscript. e.g. we don't want to truncate a number, or a code that ends
  # in a number (e.g. an area code) because that number was misidentified as a
  # superscript
  #
  # If first TWO characters are 'letters', this identifies the string as a
  # string not a number (If we only required the FIRST character to be a letter,
  # Area code numbers would be affected) In addition, superscripts are unlikely
  # to be preceded by a number or a space

  allowed_characters <- c(LETTERS, letters, " ", "-", "#")

  ifelse(substr(variable, 1, 1) %in% allowed_characters &
           substr(variable, 2, 2) %in% allowed_characters &
           get_penultimate_character(variable) %not_in% c(" ", "$", "£", 0:9) &
           substr(variable, nchar(variable), nchar(variable)) != "0", # as superscripts start at 1
         TRUE, FALSE)

}
