
test_that("collapse_list_to_strings returns expected value", {

  expect_equal(collapse_list_to_strings(list(c(NA))), NA)
  expect_equal(collapse_list_to_strings(list(c(NA, "b"))), "NA, b")
  expect_equal(collapse_list_to_strings(list(c(NA), c("A"))), c(NA, "A"))

  expect_equal(collapse_list_to_strings(list(c("A", "b"))), "A, b")
  expect_equal(collapse_list_to_strings(list(c("A", "b"), c("c", "d"))), c("A, b", "c, d"))

  expect_equal(collapse_list_to_strings(list(as.matrix(c("England", "UK")),
                                             as.matrix(c("Wales")))),
               c("England, UK", "Wales"))
})

test_that("collapse_list_to_strings returns expected datatype", {
  expect_equal(typeof(collapse_list_to_strings(list(c(0, 10, 0)))), "character")
  expect_equal(typeof(collapse_list_to_strings(list(c("A", "b"), c("c")))), "character")
})

test_that("collapse_list_to_strings returns an error if input is not a list", {
  expect_warning(collapse_list_to_strings(c(1,2)),
               "input is of class numeric but should be a list")
  expect_warning(collapse_list_to_strings(c("a", "b")),
               "input is of class character but should be a list")
  expect_warning(collapse_list_to_strings(data.frame(data = c("a", "b"))),
               "input is of class data.frame but should be a list")
})
