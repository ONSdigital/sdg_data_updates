
test_that("get_characters_after_dot returns expected value", {
  expect_equal(get_characters_after_dot(".d"), "d")
  expect_equal(get_characters_after_dot("abc.d"), "d")
  expect_equal(get_characters_after_dot("a b c. d"), " d")

  expect_equal(get_characters_after_dot("."), "")
  expect_equal(get_characters_after_dot(".."), "")
  expect_equal(get_characters_after_dot("..a"), "a")

  expect_equal(get_characters_after_dot(c(".a", "a.b")), c("a", "b"))
})

test_that("get_characters_after_dot returns expected data datatype", {
  expect_equal(typeof(get_characters_after_dot("abc.d")), "character")
  expect_equal(typeof(get_characters_after_dot("12.34")), "character")
  expect_equal(typeof(get_characters_after_dot(12.34)), "character")
  expect_equal(typeof(get_characters_after_dot(1234)), "character")
})

test_that("get_characters_after_dot gives an appropriate warning if input is not of character type", {
  expect_warning(get_characters_after_dot(12.34),
                 "input should be of type string. If input type is double, a character string will be returned")
  expect_warning(get_characters_after_dot(1234),
                 "input should be of type string. If input type is double, a character string will be returned")
  expect_warning(get_characters_after_dot(c(1234, 12.34)),
                 "input should be of type string. If input type is double, a character string will be returned")

})

