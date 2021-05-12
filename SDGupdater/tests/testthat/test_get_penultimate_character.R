
test_that("get_penultimate_character returns expected value", {
  expect_equal(get_penultimate_character("a"), "")
  expect_equal(get_penultimate_character("ab"), "a")
  expect_equal(get_penultimate_character("a b"), " ")
  expect_equal(get_penultimate_character("a.b"), ".")
  expect_equal(get_penultimate_character("abcdefg hijkl mnopq rstuv wxyz"), "y")

  expect_equal(get_penultimate_character(c("a", "ab", "abc")), c("", "a", "b"))

})

test_that("get_penultimate_character returns expected data datatype", {
  expect_equal(typeof(get_penultimate_character("abc")), "character")
  expect_equal(typeof(get_penultimate_character("123")), "character")
})

