testing_data <- data.frame("numbers_1_4" = c(10, 5),
                          "numbers_10_14" = c(1, 3),
                          "rates_1_4" = c(4, 7))
no_match_testing_data <- data.frame("num" = 1:3, "let" = c("a", "b", "c"))

test_that("name_columns stops with incorrect dat input", {
  expect_error(name_columns(dat = c("numbers_1_4", 10), 
                            pattern = "numbers", 
                            new_name = "new_name"))
  expect_error(name_columns(dat = "numbers_1_4", 
                            pattern = "numbers", 
                            new_name = "new_name"))
  expect_error(name_columns(dat = matrix(c(1:4), nrow = 2, ncol = 2), 
                            pattern = "numbers", 
                            new_name = "new_name"))
})

test_that("name_columns gives warning when no columns are matched", {
  expect_warning(name_columns(dat = no_match_testing_data, 
                              pattern = "numbers", 
                              new_name = "new_name"),
                 "0 columns identified for new_name . Please refine 'pattern', 'alternate', and 'not_pattern' arguments",
                 fixed = TRUE)
})

test_that("name_columns returns original df when no columns are matched", {
  
})

test_that("name_columns gives warning when multiple columns are matched", {
  
})

test_that("name_columns returns original df when multiple columns are matched", {
  
})

test_that("name_columns uses pattern correctly", {
  
})

test_that("name_columns (only) uses alternate if pattern is not matched", {
  
})

test_that("name_columns uses not_pattern correctly", {
  
})

test_that("name_columns only affects the matched column name", {
  
})