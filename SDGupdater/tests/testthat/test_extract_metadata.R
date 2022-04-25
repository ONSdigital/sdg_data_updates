test_data <- data.frame(X1 = c("test data for Wales, 2022", "sex", "F"),
                        X2 = c("", "age", "35"))
metadata_return <- list("year" = "2022", "country" = "Wales")

no_metadata <- data.frame(sex = "F", age = 35)
NA_return <- list("year" = NA, "country" = NA)

no_country_no_year <- data.frame(X1 = c("metadata not given", "sex", "F"),
                                 X2 = c("", "age", "35"))
both_blank <- list("year" = "", "country" = "")

no_country <- data.frame(X1 = c("year is 2022, country unknown", "sex", "F"),
                                 X2 = c("", "age", "35"))
country_blank <- list("year" = "2022", "country" = "")

no_year <- data.frame(X1 = c("year is unknown, country is Wales", "sex", "F"),
                         X2 = c("", "age", "35"))
year_blank <- list("year" = "", "country" = "Wales")



test_that("extract_metadata returns a list", {

  expect_equal(is.list(extract_metadata(test_data, 2)), TRUE)
  expect_equal(is.list(extract_metadata(no_metadata, 1)), TRUE)
  expect_equal(
    suppressWarnings(
      is.list(extract_metadata(no_country_no_year, 2))
    ), TRUE)
  
})

test_that("extract_metadata only accepts dataframes and matrices, not vectors", {
  
  expect_equal(is.list(extract_metadata(test_data, 2)), TRUE)
  expect_equal(is.list(extract_metadata(as.matrix(test_data), 2)), TRUE)
  
  expect_error(extract_metadata(test_data[1, 1], 2))
  
})


test_that("extract_metadata returns NAs where no metadata are given", {
  
  expect_equal(extract_metadata(no_metadata, 1), NA_return)

})

test_that("extract_metadata returns blanks where expected metadata is missing", {
  expect_equal(suppressWarnings(
    extract_metadata(no_country, 2)
  ), country_blank)
  expect_equal(
    suppressWarnings(
      extract_metadata(no_year, 2)
      ), year_blank)
  expect_equal(
    suppressWarnings(
    extract_metadata(no_country_no_year, 2)
  ), both_blank)
  
})
