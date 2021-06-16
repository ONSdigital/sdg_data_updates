country <- "England, Scotland"
multiple_country_warning("foo.xlsx", "Tab 1", "sex_by_age disaggregation")


test_that("multiple_country_warning gives expected message", {
  
  expect_warning(multiple_country_warning("foo.xlsx", "Tab 1", "sex_by_age disaggregation"), 
                 "More than one country identified in foo.xlsx Tab 1 where only one was expected.\n TO DO: Please check that Country is correct in the output for sex_by_age disaggregation")
})

country <- "England and Wales"

test_that("multiple_country_warning doesn't give a message when there is only one country", {
  expect_warning(multiple_country_warning("foo.xlsx", "Tab 1", "sex_by_age disaggregation"), regexp = NA)
})
