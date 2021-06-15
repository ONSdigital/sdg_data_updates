#' Turn a list of character vectors/matrices into a vector of character strings
#'
#' Turns a list of vectors/matrices that hold only character strings into a
#' single vector of character strings, separated by ", ". The elements that make
#' up each component of the input list are pasted into a single string. Each
#' element of the new vector is formed from one component of the input list.
#'
#' (Initially called this function list_into_vector_of_strings)
#'
#' @param input_list List of vectors or matrices, or a vector.
#'
#' @return Each element of a list is collapsed to a string. Each element of the
#'   list becomes an element of a vector. If the input_list is a matrix, the
#'   order is first down rows then across columns.
#'
#' @examples
#' matrix_1 <- as.matrix(c("England", "UK"))
#' matrix_2 <- as.matrix(c("Wales"))
#' matrix_3 <- as.matrix(c("NA"))
#' matrix_list <- list(matrix_1, matrix_2, matrix_3)
#' collapse_list_to_strings(matrix_list)
#'
#' @export

collapse_list_to_strings <- function (input_list) {

  input_class <- class(input_list)

  if(input_class != "list"){
    warning(paste("input is of class", input_class, "but should be a list"))
  }

  vector_of_strings <- c()

  for (i in 1:length(input_list)) {

    vector_of_strings[i] <- paste(unlist(input_list[[i]]), collapse = ", ")

  }

  ifelse(vector_of_strings == "NA", NA, vector_of_strings)

}

