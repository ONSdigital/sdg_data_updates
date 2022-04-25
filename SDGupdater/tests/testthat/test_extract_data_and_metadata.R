
# -------------------test data--------------------------------------------------
test_data <- data.frame(X1 = c("test data for Wales, 2022", "sex", "F"),
                        X2 = c("", "age", "35"))
metadata_return <- list("year" = "2022", "country" = "Wales")

multiple_meta_rows <- data.frame(X1 = c("test data for Wales,", 
                                        "for data collected in 2022", 
                                        rep("", 10), 
                                        "sex", "F"),
                                 X2 = c(rep("", 12), "age", "35"))
  
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

set.seed(1)
random_numbers <- runif(10000) 
large_data <- data.frame(X1 = c("test data for Wales,", 
                                "for data collected in 2022", 
                                "sex", 
                                rep(c("M", "F"), 5000)),
                         X2 = c(rep("", 2), "value", random_numbers))


#--------------extract_metadata-------------------------------------------------

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

test_that("extract_metadata works with multiple metadata rows", {
  
  expect_equal(extract_metadata(multiple_meta_rows, 13), metadata_return)
})

#--------------extract_data-----------------------------------------------------

test_that("extract_data returns a dataframe when given a dataframe", {
  
  expect_equal(is.data.frame(extract_data(test_data, 2)), TRUE)

  })

test_that("extract_data accepts dataframes but not simple vectors", {
  
  expect_equal(is.data.frame(extract_data(test_data, 2)), TRUE)
  expect_error(extract_data(test_data[1, 1], 2))
})

test_that("extract_data returns untouched data if headers are on row 1", {
  expect_equal(extract_data(no_metadata, 1), no_metadata)
})

test_that("extract_data returns data with correct column names", {
  expect_equal(names(extract_data(test_data, 2)), c("sex", "age"))
  expect_equal(names(extract_data(multiple_meta_rows, 13)), c("sex", "age"))
})

test_that("extract_data returns all data rows", {
  expect_equal(nrow(extract_data(test_data, 2)), 1)
  expect_equal(nrow(extract_data(large_data, 3)), 10000)
})