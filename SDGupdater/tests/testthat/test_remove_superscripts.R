
test_that("remove_superscripts returns expected value", {

  expect_equal(remove_superscripts("Ab10"), "Ab10")
  expect_equal(remove_superscripts("Ab 1"), "Ab 1")
  expect_equal(remove_superscripts("Ab1, 2"), "Ab1, 2")

  expect_equal(remove_superscripts("Ab"), "Ab")

  expect_equal(remove_superscripts("Ab1"), "Ab")
  expect_equal(remove_superscripts("Ab9"), "Ab")
  expect_equal(remove_superscripts("Ab1,2"), "Ab")
  expect_equal(remove_superscripts("Ab1,2,3"), "Ab")
  expect_equal(remove_superscripts("Ab1,2,3,4,5,6"), "Ab")

  expect_equal(remove_superscripts("Ab1-3"), "Ab")
  expect_equal(remove_superscripts("Ab1-3,5,7-9"), "Ab")

  expect_equal(remove_superscripts(c("abc 11", "abc Ab1")), c("abc 11", "abc Ab"))
  expect_equal(remove_superscripts(c("11", "Ab1")), c("11", "Ab"))
  expect_equal(remove_superscripts(c(NA, "Ab")), c(NA, "Ab"))
})
