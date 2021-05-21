
test_that("remove_multiple_superscripts returns expected value", {

  expect_equal(remove_multiple_superscripts("Ab10"), "Ab10")
  expect_equal(remove_multiple_superscripts("Ab 1"), "Ab 1")
  expect_equal(remove_multiple_superscripts("Ab1, 2"), "Ab1, 2")

  expect_equal(remove_multiple_superscripts("Ab"), "Ab")
  expect_equal(remove_multiple_superscripts("Ab1"), "Ab1")

  expect_equal(remove_multiple_superscripts("Ab1,2"), "Ab")
  expect_equal(remove_multiple_superscripts("Ab1,2,3"), "Ab")
  expect_equal(remove_multiple_superscripts("Ab1,2,3,4,5,6"), "Ab")

  expect_equal(remove_multiple_superscripts("Ab1-3"), "Ab")
  expect_equal(remove_multiple_superscripts("Ab1-3,5-6"), "Ab")
  expect_equal(remove_multiple_superscripts("Ab1,5-6"), "Ab")
  expect_equal(remove_multiple_superscripts("Ab1-3,5"), "Ab")
  expect_equal(remove_multiple_superscripts("Ab1,3-5,7"), "Ab")
  expect_equal(remove_multiple_superscripts("Ab1-3,5,7-9"), "Ab")

  expect_equal(remove_multiple_superscripts(c("1", "Ab")), c("1", "Ab"))
  expect_equal(remove_multiple_superscripts(c(NA, "Ab")), c(NA, "Ab"))
})
