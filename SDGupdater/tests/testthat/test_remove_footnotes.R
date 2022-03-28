footnotes_col1 <- data.frame("footnote_col" = letters[1:4], 
                      "data_col1" = c(letters[5:7], NA), 
                      "data_col2" = c(1:3, NA)) 

footnotes_2cols <- data.frame("footnote_col" = c(letters[1:3], "footnote", "footnote2"), 
                      "data_col1" = c(letters[5:7], "note1", "note2"), 
                      "data_col2" = c(1:3, NA, NA),
                      "data_col3" = c(letters[8:10], NA, NA)) 

footnotes_col2 <- data.frame("footnote_col" = c(letters[1:3], NA, NA), 
                              "data_col1" = c(letters[5:7], "note1", "note2"), 
                              "data_col2" = c(1:3, NA, NA),
                              "data_col3" = c(letters[8:10], NA, NA)) 

NAs_then_data <- data.frame("data_col1" = c(letters[1:3], NA, NA), 
                            "data_col2" = c(1:3, NA, NA),
                            "data_col3" = c(1:5),
                            "data_col4" = c(1:3, NA, NA)) 

two_footnote_rows <- data.frame("footnote_col" = c(letters[1:3], NA, "footnote", "footnote2"), 
                      "data_col1" = c(letters[5:7], NA, "note1", "note2"), 
                      "data_col2" = c(1:3, NA, NA, NA),
                      "data_col3" = c(letters[8:10], NA, NA, NA)) 

row_of_NAs <- data.frame("footnote_col" = c(letters[1:3], NA), 
                      "data_col1" = c(letters[5:7], NA), 
                      "data_col2" = c(1:3, NA),
                      "data_col3" = c(letters[8:10], NA)) 

footnote_type_row <- data.frame("footnote_col" = c("a", "not_a_footnote", letters[3:4]), 
                                "data_col1" = c("a", NA, letters[5:6]), 
                                "data_col2" = c(1, NA, 2:3)) 

matrix_data <- matrix(c(1,2,3, 11,12,13), nrow = 2, ncol = 3, byrow = TRUE,
               dimnames = list(c("row1", "row2"),
                               c("C.1", "C.2", "C.3")))


test_that("remove_footnotes removes rows when footnotes in first column", {
  expect_equal(remove_footnotes(footnotes_col1, 1), footnotes_col1[1:3, ])
})

test_that("remove_footnotes removes rows when footnotes are in the first and/or 
          second columns", {
  expect_equal(remove_footnotes(footnotes_2cols), footnotes_2cols[1:3, ])
  expect_equal(remove_footnotes(footnotes_col2), footnotes_col2[1:3, ])
})

test_that("remove footnotes does not remove rows when lots of NAs precede the data", {
  expect_equal(remove_footnotes(NAs_then_data), NAs_then_data)
})

test_that("remove_footnotes keeps all rows when check_columns equals number of 
          columns in the input", {
  expect_equal(suppressWarnings(remove_footnotes(NAs_then_data, 4)), 
               NAs_then_data)
    expect_equal(suppressWarnings(remove_footnotes(footnotes_col1, 3)), 
                 footnotes_col1)
})

test_that("remove_footnotes gives meaningful messages if check_columns is wrong", {
  expect_warning(remove_footnotes(NAs_then_data, 4))
  expect_error(remove_footnotes(NAs_then_data, 5), 
               "check_columns must be less than the number of columns in the dataframe")
})

test_that("remove_footnotes return original data when footnotes are in a column 
          further right than check_column", {
            expect_equal(remove_footnotes(footnotes_2cols, 1), footnotes_2cols)
            expect_equal(remove_footnotes(footnotes_col2, 1), footnotes_col2)
          })

test_that("remove_footnotes doesn't remove rows if the are non-NAs after the 
          column specified by check_columns", {
            expect_equal(remove_footnotes(NAs_then_data), NAs_then_data)
            expect_equal(remove_footnotes(two_footnote_rows, 1), two_footnote_rows)
          })

test_that("remove_footnotes works on multiple rows of footnotes", {
  expect_equal(remove_footnotes(two_footnote_rows), two_footnote_rows[1:3, ])
})


test_that("remove_footnotes removes all-NA rows", {
  expect_equal(remove_footnotes(row_of_NAs), row_of_NAs[1:3, ])
})

test_that("remove_footnotes does not remove rows in the main body of the table", {
  expect_equal(remove_footnotes(footnote_type_row), footnote_type_row)
})

test_that("remove_footnotes throuws error if data is not a dataframe", {
  expect_error(remove_footnotes(c(1:3)), "data must be a dataframe")
  expect_error(remove_footnotes(matrix_data), "data must be a dataframe")
})

