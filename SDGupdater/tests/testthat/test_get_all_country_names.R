
test_that("get_all_country_names returns expected value", {

  expect_equal(get_all_country_names("England"), "England")
  expect_equal(get_all_country_names("Wales"), "Wales")
  expect_equal(get_all_country_names("Scotland"), "Scotland")
  expect_equal(get_all_country_names("Northern Ireland"), "Northern Ireland")
  expect_equal(get_all_country_names("Great Britain"), "Great Britain")
  expect_equal(get_all_country_names("UK"), "UK")
  expect_equal(get_all_country_names("United Kingdom"), "United Kingdom")
  expect_equal(get_all_country_names("England and Wales"), "England and Wales")
  expect_equal(get_all_country_names("The United Kingdom of Great Britain and Northern Ireland"),
               "United Kingdom, Great Britain, Northern Ireland")

  expect_equal(get_all_country_names("england"), "england")
  expect_equal(get_all_country_names("wales"), "wales")
  expect_equal(get_all_country_names("scotland"), "scotland")
  expect_equal(get_all_country_names("northern ireland"), "northern ireland")
  expect_equal(get_all_country_names("great britain"), "great britain")
  expect_equal(get_all_country_names("uk"), "uk")
  expect_equal(get_all_country_names("united kingdom"), "united kingdom")
  expect_equal(get_all_country_names("england and wales"), "england and wales")

  expect_equal(get_all_country_names("ENGLAND, WALES, SCOTLAND, NORTHERN IRELAND, GREAT BRITAIN, GB, UK, UNITED KINGDOM, ENGLAND AND WALES"),
               "ENGLAND, WALES, SCOTLAND, NORTHERN IRELAND, GREAT BRITAIN, GB, UK, UNITED KINGDOM, ENGLAND AND WALES")

  expect_equal(get_all_country_names("The United Kingdom of Great Britain and Northern Ireland"),
               "United Kingdom, Great Britain, Northern Ireland")

  expect_equal(get_all_country_names("This is England"), "England")

  expect_equal(get_all_country_names("Narnia"), NA)
})

test_that("get_all_country_names returns expected datatype", {
  expect_equal(typeof(get_all_country_names("uk")), "character")
  expect_equal(typeof(get_all_country_names(c("uk", "Wales"))), "character")
})


