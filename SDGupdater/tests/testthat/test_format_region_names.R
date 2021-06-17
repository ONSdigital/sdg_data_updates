
test_that("format_region_names returns expected value", {

  expect_equal(format_region_names("YORKSHIRE AND THE HUMBER"), "Yorkshire and The Humber")
  expect_equal(format_region_names("Yorkshire and the Humber"), "Yorkshire and The Humber")

  expect_equal(format_region_names("EAST OF ENGLAND"), "East")
  expect_equal(format_region_names("East of England"), "East")

  expect_equal(format_region_names("South West"), "South West")
  expect_equal(format_region_names("Any other word to sentence"), "Any Other Word To Sentence")

})

test_that("format_region_names returns expected datatype", {
  expect_equal(typeof(format_region_names("East")), "character")
})


