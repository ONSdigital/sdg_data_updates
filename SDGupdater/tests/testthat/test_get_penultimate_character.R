
test_that("get_penultimate_character returns expected value", {

  expect_equal(get_penultimate_character(12), "1")
  
  expect_equal(get_penultimate_character("ab"), "a")
  expect_equal(get_penultimate_character("a b"), " ")
  expect_equal(get_penultimate_character("a.b"), ".")
  expect_equal(get_penultimate_character("abcdefg hijkl mnopq rstuv wxyz"), "y")

  expect_equal(get_penultimate_character(c("ab", "abc")), c("a", "b"))

})

test_that("get_penultimate_character returns expected data datatype", {
  expect_equal(typeof(get_penultimate_character(123)), "character")
  expect_equal(typeof(get_penultimate_character("abc")), "character")
  expect_equal(typeof(get_penultimate_character("123")), "character")
})

test_that("get_penultimate_character raises appropriate warnings", {
  expect_warning(get_penultimate_character(1),
                 "At least one string had fewer than two characters. Where this is the case, '' is returned")
  expect_warning(get_penultimate_character("a"),
                 "At least one string had fewer than two characters. Where this is the case, '' is returned")
  expect_warning(get_penultimate_character(c("a", "quick brown fox")),
                 "At least one string had fewer than two characters. Where this is the case, '' is returned")
  expect_warning(get_penultimate_character(c("quick brown fox", "a")),
                 "At least one string had fewer than two characters. Where this is the case, '' is returned")
})
