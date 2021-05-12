
test_that("remove_false_superscripts returns expected value", {
  expect_equal(remove_false_superscripts(NA), NA)
  expect_equal(remove_false_superscripts(1), 1)
  expect_equal(remove_false_superscripts("1"), "1")
  expect_equal(remove_false_superscripts("123"), "123")
  expect_equal(remove_false_superscripts("A1"), "A1")
  expect_equal(remove_false_superscripts("a1"), "a1")
  expect_equal(remove_false_superscripts("A1b1"), "A1b1")
  expect_equal(remove_false_superscripts("Ab10"), "Ab10")
  expect_equal(remove_false_superscripts("Ab0"), "Ab0")
  expect_equal(remove_false_superscripts("$1"), "$1")

  expect_equal(remove_false_superscripts("A $1"), "A $1")
  expect_equal(remove_false_superscripts("A £1"), "A £1")
  expect_equal(remove_false_superscripts("A 1"), "A 1")
  expect_equal(remove_false_superscripts("Ab 1"), "Ab 1")
  expect_equal(remove_false_superscripts("Ab1, 2"), "Ab1, 2")

  expect_equal(remove_false_superscripts("Ab"), "Ab")

  expect_equal(remove_false_superscripts("Ab1"), "Ab")
  expect_equal(remove_false_superscripts("Ab9"), "Ab")
  expect_equal(remove_false_superscripts("Ab Cd1"), "Ab Cd")
  expect_equal(remove_false_superscripts("Ab1,2"), "Ab1,") # comma is removed by remove_double_superscripts

  expect_equal(remove_false_superscripts(c("1", "Ab")), c("1", "Ab"))
  expect_equal(remove_false_superscripts(c(NA, "Ab")), c(NA, "Ab"))
  expect_equal(remove_false_superscripts(c(NA, "Ab1")), c(NA, "Ab"))
})
