test_that("count_mismatches returns expected value", {
  expect_equal(count_mismatches(1,2), 1)
  expect_equal(count_mismatches(c(1,1), c(2,2)), 2)
  expect_equal(count_mismatches(c(1,2), c(2,2)), 1)
  expect_equal(count_mismatches(c(2,2), c(2,2)), 0)
  
  expect_equal(count_mismatches("a", "b"), 1)
  expect_equal(count_mismatches(c("a","a"), c("b", "b")), 2)
  expect_equal(count_mismatches(c("a", "b"), c("b", "b")), 1)
  expect_equal(count_mismatches(c("b", "b"), c("b", "b")), 0)
})