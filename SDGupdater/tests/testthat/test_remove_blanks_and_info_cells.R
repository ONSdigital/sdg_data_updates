# requires further tests

input1 <- dplyr::tibble(row = c(1:6),
                           character = c("2017", NA, "England",
                                         "Rates", NA, NA),
                           is_blank = c(FALSE, TRUE, FALSE, FALSE, TRUE, FALSE),
                           data_type = c("character", "blank", "character", "character", "blank",
                                         "numeric"),
                           numeric = c(NA, NA, NA, NA, NA, 20))
output1 <- dplyr::tibble(row = c(4,6),
                         character = c("Rates", NA),
                         is_blank = c(FALSE, FALSE),
                         data_type = c("character", "numeric"),
                         numeric = c(NA, 20))


test_that("remove_blanks_and_info_cells returns expected value", {
  expect_equal(remove_blanks_and_info_cells(input1, 4), output1)
})

test_that("remove_blanks_and_info_cells returns expected data class", {
  expect_equal(data.class(remove_blanks_and_info_cells(input1, 4)), "tbl_df")
})

test_that("remove_blanks_and_info_cells returns an error if input does not look like it comes from xlsx_cells input", {
  expect_error(remove_blanks_and_info_cells(dplyr::tibble(A = 1)),
               "requires columns 'row', 'character', and 'is_blank', which are created when importing using xlsx_cells.")

})
