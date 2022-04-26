#' Extract country from string containing country name
#'
#' Identifies whether a string contains the name of one or more of the UK
#' countries and if it does, it gives the names of that country as a string,
#' otherwise it returns NA.
#'
#' Future improvements - return countries with correct capitalisation (possibly
#' as option in arguments)
#'
#' @param variable Character vector you want to check to see if it contains the
#'   name of a UK country.
#'
#' @return Character vector giving name of country or NA.
#'
#' @examples
#' test_dat <- c("England is a country of the UK", "this does not contain a
#' country name")
#' get_all_country_names(test_dat)
#'
#' @export
get_all_country_names <- function (variable) {
  
  possible_countries_vector <- c("England\ and\ Wales", "England",  "Wales", "Scotland", "Northern\ Ireland",
                                 "UK", "United\ Kingdom", "Great\ Britain", "Britain", "GB",
                                 "England\ And\ Wales", "england\ and\ wales",
                                 "northern\ Ireland", "Northern\ ireland",
                                 "United\ kingdom", "united\ Kingdom",
                                 "great\ Britain", "Great\ britain",
                                 "england",  "wales", "scotland", "northern\ ireland",
                                 "uk", "united\ kingdom", "great\ britain", "britain",
                                 "ENGLAND\ AND\ WALES", "ENGLAND",  "WALES", "SCOTLAND", "NORTHERN\ IRELAND",
                                 "UNITED\ KINGDOM", "GREAT\ BRITAIN", "BRITAIN")
  possible_countries <- paste(possible_countries_vector, collapse = "|")
  
  list_of_countries <- ifelse(stringr::str_detect(variable, possible_countries),
                              stringr::str_extract_all(variable, possible_countries), NA)
  
  if (is.list(list_of_countries)) {
    countries <- collapse_list_to_strings(list_of_countries)
  } else {
    countries <- NA
  }
  
  return(countries)
  
}

#' Warning for when multiple countries have been identified by
#' get_all_country_names(). When country is identified e.g. from the info cells
#' above a table in this way, if more than one country is identified, they are
#' put together and separated by a comma. If this is then used as the country in
#' the country column, it will not follow the style guide for the platform so
#' can be highlighted as an issue using this warning function.
#'
#' @param filename string giving name of the file (so warning is specific)
#' @param tab string giving name of the tab (so warning is specific)
#' @param description string describing the data that is affected (e.g. which
#'   disaggregation)
#'
#' @return a warning
#'
#' @describeIn get_all_country_names Extract country from string containing
#'   country name
#'
#' @examples
#' country <- "England, Scotland"
#' multiple_country_warning("foo.xlsx", "Tab 1", "sex_by_age disaggregation")
#'
#' @export
multiple_country_warning <- function (filename, tab, description) {

  if (grepl(",", country) == TRUE) {
    warning(paste("More than one country identified in", filename, tab, "where only one was expected.\n TO DO: Please check that Country is correct in the output for", description))
  }
}
