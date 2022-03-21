testing_data <- data.frame("numbers_1_4" = c(10, 5),
                          "numbers_10_14" = c(1, 3),
                          "rates_1_4" = c(4, 7))

col_1_renamed <- data.frame("new_name" = c(10, 5),
                                   "numbers_10_14" = c(1, 3),
                                   "rates_1_4" = c(4, 7))
col_2_renamed <- data.frame("numbers_1_4" = c(10, 5),
                            "new_name" = c(1, 3),
                            "rates_1_4" = c(4, 7))
col_3_renamed <- data.frame("numbers_1_4" = c(10, 5),
                            "numbers_10_14" = c(1, 3),
                            "new_name" = c(4, 7))

no_match_testing_data <- data.frame("num" = 1:3, "let" = c("a", "b", "c"))

context('testing top function - rename_column')

test_that("rename_column stops with incorrect dat input", {
  expect_error(rename_column(dat = c("numbers_1_4", 10), 
                            primary = "numbers", 
                            new_name = "new_name"))
  expect_error(rename_column(dat = "numbers_1_4", 
                            primary = "numbers", 
                            new_name = "new_name"))
  expect_error(rename_column(dat = matrix(c(1:4), nrow = 2, ncol = 2), 
                            primary = "numbers", 
                            new_name = "new_name"))
})

test_that("rename_column gives warning when no columns are matched", {
  expect_warning(rename_column(dat = no_match_testing_data, 
                              primary = "numbers", 
                              new_name = "new_name"),
                 "0 columns identified for new_name . Please refine 'primary', 'alternate', and 'not_pattern' arguments. Column name not replaced",
                 fixed = TRUE)
})

test_that("rename_column returns original df when no columns are matched", {
  expect_identical(suppressWarnings(rename_column(dat = no_match_testing_data, 
                                primary = "numbers", 
                                new_name = "new_name")),
                   no_match_testing_data)
})

test_that("rename_column gives warning when multiple columns are matched", {
  expect_warning(rename_column(dat = testing_data, 
                              primary = "numbers", 
                              new_name = "new_name"),
                 "2 columns identified for new_name . Please refine 'primary', 'alternate', and 'not_pattern' arguments. Column name not replaced",
                 fixed = TRUE)
})

test_that("rename_column returns original df when multiple columns are matched", {
  expect_identical(suppressWarnings(rename_column(dat = testing_data, 
                              primary = "numbers", 
                              new_name = "new_name")),
                 testing_data)
})

test_that("rename_column doesn't replace alternate if primary is matched", {
  expect_identical(rename_column(dat = testing_data,
                                primary = c("numbers", "1", "4"),
                                alternate = "rates",
                                not_pattern = "0",
                                new_name = "new_name"),
                   col_1_renamed)
})

test_that("rename_column (only) uses alternate if primary is not matched", {
  expect_identical(rename_column(dat = testing_data,
                                primary = "nope",
                                alternate = "rates",
                                new_name = "new_name"),
                   col_3_renamed)
})

test_that("rename_column doesn't rename columns contaning not_pattern", {
  expect_identical(rename_column(dat = testing_data,
                                primary = "numbers",
                                not_pattern = "10",
                                new_name = "new_name"),
                   col_1_renamed)
  
  expect_warning(rename_column(dat = testing_data,
                                primary = "10",
                                not_pattern = "numbers",
                                new_name = "new_name"),
                 "0 columns identified for new_name . Please refine 'primary', 'alternate', and 'not_pattern' arguments. Column name not replaced",
                 fixed = TRUE)
})


context('testing underlying function - get_column_index')
