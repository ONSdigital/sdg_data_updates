
test_data <- data.frame(
  "factor1" = c("these", "are", "alphanumeric2", 
                          "  strings  with too many spaces      "),
  "numbers" = c(1:4),
  "another_factor" = c("1", "2", "3", "4"),
  stringsAsFactors = TRUE
)

#----------------tests----------------------------------------------------------
test_that("clean_strings returns a dataframe when given a dataframe", {
  expect_equal(
      is.data.frame(
        suppressWarnings(
          clean_strings(test_data))), TRUE)
})

test_that("clean_strings changes all factors to character strings", {
  expect_equal(
        is.character(clean_strings(test_data, FALSE)$factor1), 
                     TRUE)
  expect_equal(
    is.character(clean_strings(test_data, FALSE)$another_factor), 
    TRUE)
  
})

test_that("clean_strings removes unwanted spaces", {
  expect_equal(
    clean_strings(test_data, FALSE)$factor1[4], 
    "strings with too many spaces")
})

test_that("clean_strings superscripts arg works as expected", {
  expect_equal(
    suppressWarnings(clean_strings(test_data, TRUE)$factor1[3]), 
    "alphanumeric")
  
  expect_equal(
    clean_strings(test_data, FALSE)$factor1[3], 
    "alphanumeric2")
  
  expect_equal(
    suppressWarnings(clean_strings(test_data, TRUE)$another_factor), 
    c("1", "2", "3", "4"))
  
  expect_equal(
    suppressWarnings(
      names(clean_strings(test_data, TRUE))
      ), 
    names(test_data))

})
