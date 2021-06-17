

test_that("create_datetime_for_filename returns expected value", {

  expect_equal(create_datetime_for_filename("2021-05-13 10:38:54 BST"), "2021-05-13_at_10-38")
  expect_equal(create_datetime_for_filename( "2021-05-13"),  "2021-05-13")

})

test_that("create_datetime_for_filename returns expected datatype", {
  expect_equal(typeof(create_datetime_for_filename("2021-05-13 10:38:54 BST")), "character")
})


