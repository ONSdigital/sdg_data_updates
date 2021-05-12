input1 <- data.frame(row = c(1:4),
                           character = c("data for 2017", "England and", "Wales", "data"))
output1 <- data.frame(character = c("data for 2017", "England and", "Wales"),
                     Year = c("2017", NA, NA),
                     Country = c(NA, "England", "Wales"))
output1[] <- lapply(output1, as.character)


input2_no_countries <- input1 %>%
  mutate(character = ifelse(character == "England and", NA,  as.character(character)),
         character = ifelse(character == "Wales", NA,  as.character(character)))
output2_no_countries <- output1 %>%
  filter(character == "data for 2017") %>%
  mutate(Country = as.logical(Country))


input3_no_years <- input1 %>%
  filter(character != "Wales" &
           character != "data for 2017") %>%
  mutate(row = ifelse(row == 2, 1, row),
         row = ifelse(row == 4, 2, row))



test_that("get_info_cells returns expected info", {
  expect_equal(get_info_cells(input1, 4), output1)
})

test_that("get_info_cells returns expected data datatype", {
  expect_equal(typeof(get_info_cells(input1, 4)), "list")
  expect_equal(class(get_info_cells(input1, 4)), "data.frame")
})

test_that("get_info_cells returns meaningful warning when no countries are found", {
  expect_warning(get_info_cells(input2_no_countries, 2),
                "No countries were identified in the header section of input2_no_countries")

})

test_that("get_info_cells returns meaningful warning when no years are found", {
  expect_warning(get_info_cells(input3_no_years, 2),
                 "No years were identified in the header section of input3_no_years")
})

