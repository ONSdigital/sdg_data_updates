
test_that("get_all_years returns expected value", {
  expect_equal(get_all_years("1900"), "1900")
  expect_equal(get_all_years("2099"), "2099")
  expect_equal(get_all_years("1990A"), "1990")
  expect_equal(get_all_years("A1990"), "1990")

  expect_equal(get_all_years("1899"), NA)
  expect_equal(get_all_years("2100"), NA)
  expect_equal(get_all_years("1234"), NA)
  expect_equal(get_all_years("0000"), NA)
  expect_equal(get_all_years("year: 200"), NA)

  expect_equal(get_all_years("1999 2020"), "1999, 2020")
  expect_equal(get_all_years("Year: 1950"), "1950")
  expect_equal(get_all_years("1950 is the year"), "1950")

  expect_equal(get_all_years(c("1950", "2020")), c("1950", "2020"))
})

test_that("get_all_years returns expected datatype", {
  expect_equal(typeof(get_all_years("1950")), "character")
  expect_equal(typeof(get_all_years(1950)), "character")
  expect_equal(typeof(get_all_years(c("1950", "2020"))), "character")
})


