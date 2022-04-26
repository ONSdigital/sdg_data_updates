
test_that("unique_to_string returns expected value", {
  expect_equal(unique_to_string(c("A", "b", "c")), "A, b, c")
  expect_equal(unique_to_string(c(NA, "A", "b")), "A, b")
  expect_equal(unique_to_string(c("A", NA, "b")), "A, b")

  expect_equal(unique_to_string(c(1, 10)), "1, 10")

  expect_equal(unique_to_string(c("A")), "A")
  expect_equal(unique_to_string(c("A, b, c")), "A, b, c")
  expect_equal(unique_to_string(c("A, b", "c")), "A, b, c")

  expect_equal(unique_to_string(c("A", "A", "b")), "A, b")
  expect_equal(unique_to_string(c("A", "a", "b")), "A, a, b")

  expect_equal(unique_to_string(c("A", "A", "b", "b")), "A, b")
  expect_equal(unique_to_string(c("A", "b", "A", "b")), "A, b")
  expect_equal(unique_to_string(c("A", "b", NA, "A", "b")), "A, b")

    })

test_that("unique_to_string returns expected datatype", {
  expect_equal(typeof(unique_to_string(c(0, 10, 0))), "character")
  expect_equal(typeof(unique_to_string(c("A", "b", "c"))), "character")
})
