
test_that("get_fourth_from_last_character returns expected value", {

  expect_equal(get_fourth_from_last_character(1234), "1")
  expect_equal(get_fourth_from_last_character(12345678), "5")

  expect_equal(get_fourth_from_last_character("abcd"), "a")
  expect_equal(get_fourth_from_last_character("a b c d"), " ")
  expect_equal(get_fourth_from_last_character("a.bcd"), ".")
  expect_equal(get_fourth_from_last_character("abcdefg hijkl mnopq rstuv wxyz"), "w")

  expect_equal(get_fourth_from_last_character(c("abcd", "abcde")), c("a", "b"))

})

test_that("get_fourth_from_last_character returns expected data datatype", {
  expect_equal(typeof(get_fourth_from_last_character("abcd")), "character")
  expect_equal(typeof(get_fourth_from_last_character("1234")), "character")
  expect_equal(typeof(get_fourth_from_last_character(1234)), "character")
})

test_that("get_fourth_from_last_character raises appropriate warnings", {
  expect_warning(get_fourth_from_last_character(123),
                 "At least one string had fewer than four characters. Where this is the case, '' is returned")
  expect_warning(get_fourth_from_last_character("abc"),
                 "At least one string had fewer than four characters. Where this is the case, '' is returned")
  expect_warning(get_fourth_from_last_character(c("abc", "quick brown fox")),
                 "At least one string had fewer than four characters. Where this is the case, '' is returned")
  expect_warning(get_fourth_from_last_character(c("quick brown fox", "abc")),
                 "At least one string had fewer than four characters. Where this is the case, '' is returned")
})
