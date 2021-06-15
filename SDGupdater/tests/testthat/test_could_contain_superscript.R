
test_that("could_contain_superscript returns expected value", {
  expect_equal(could_contain_superscript(NA), FALSE)
  expect_equal(suppressWarnings(could_contain_superscript(1)), FALSE)
  expect_equal(suppressWarnings(could_contain_superscript("1")), FALSE)
  expect_equal(could_contain_superscript("123"), FALSE)
  expect_equal(could_contain_superscript("A1"), FALSE)
  expect_equal(could_contain_superscript("a1"), FALSE)
  expect_equal(could_contain_superscript("A1b1"), FALSE)
  expect_equal(could_contain_superscript("Ab10"), FALSE)
  expect_equal(could_contain_superscript("Ab0"), FALSE)
  expect_equal(could_contain_superscript("$1"), FALSE)

  expect_equal(could_contain_superscript("A $1"), FALSE)
  expect_equal(could_contain_superscript("A £1"), FALSE)
  expect_equal(could_contain_superscript("A 1"), FALSE)
  expect_equal(could_contain_superscript("Ab 1"), FALSE)
  expect_equal(could_contain_superscript("Ab1, 2"), FALSE)

  expect_equal(could_contain_superscript("Ab"), TRUE) # identification of superscript at end of string is done in other functions
  expect_equal(could_contain_superscript("Ab1"), TRUE)
  expect_equal(could_contain_superscript("Ab9"), TRUE)
  expect_equal(could_contain_superscript("Ab Cd1"), TRUE)
  expect_equal(could_contain_superscript("Ab1,2"), TRUE)

  expect_equal(suppressWarnings(could_contain_superscript(c("1", "Ab"))), c(FALSE, TRUE))
  expect_equal(could_contain_superscript(c(NA, "Ab")), c(FALSE, TRUE))
})
