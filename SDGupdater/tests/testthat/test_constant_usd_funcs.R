# values tested to 4dp only due to rounding differences in r and excel
test_that("gbp_to_constant_usd returns expected values", {
  expect_equal(
    round(
    gbp_to_constant_usd(
      system.file("testdata", "Exchange-rates.xlsx", package = "SDGupdater"), 
      system.file("testdata", "Deflators-base-2020.xlsx", package = "SDGupdater"), 
      read.csv(
        system.file("testdata", "year_value.csv", package = "SDGupdater")))$value,
    4),
    round(
      read.csv(
        system.file(
          "testdata", "constant_usd.csv", package = "SDGupdater"))$constant_usd,
      4)
  )
})

test_that("gbp_to_constant_usd returns expected columns", {
  expect_equal(
    names(
      gbp_to_constant_usd(
        system.file("testdata", "Exchange-rates.xlsx", package = "SDGupdater"), 
        system.file("testdata", "Deflators-base-2020.xlsx", package = "SDGupdater"), 
        read.csv(
          system.file("testdata", "year_value.csv", package = "SDGupdater")))
    ),
    c("year", "value", "units")
  )
})

test_that("gbp_to_constant_usd returns expected units", {
  expect_equal(
    unique(
      gbp_to_constant_usd(
        system.file("testdata", "Exchange-rates.xlsx", package = "SDGupdater"), 
        system.file("testdata", "Deflators-base-2020.xlsx", package = "SDGupdater"), 
        read.csv(
          system.file("testdata", "year_value.csv", package = "SDGupdater")
        )
      )$units
    ),
    "Constant USD ($ thousands)"
  )
  
  expect_equal(
    unique(
      gbp_to_constant_usd(
        system.file("testdata", "Exchange-rates.xlsx", package = "SDGupdater"), 
        system.file("testdata", "Deflators-base-2020.xlsx", package = "SDGupdater"), 
        read.csv(
          system.file("testdata", "year_value.csv", package = "SDGupdater")
        ),
        "($ thousands)"
      )$units
    ),
    "Constant USD ($ thousands)"
  )
  
  expect_equal(
    unique(
      gbp_to_constant_usd(
        system.file("testdata", "Exchange-rates.xlsx", package = "SDGupdater"), 
        system.file("testdata", "Deflators-base-2020.xlsx", package = "SDGupdater"), 
        read.csv(
          system.file("testdata", "year_value.csv", package = "SDGupdater")
        ),
        "($)"
      )$units
    ),
    "Constant USD ($)"
  )
  
  expect_equal(
    unique(
      gbp_to_constant_usd(
        system.file("testdata", "Exchange-rates.xlsx", package = "SDGupdater"), 
        system.file("testdata", "Deflators-base-2020.xlsx", package = "SDGupdater"), 
        read.csv(
          system.file("testdata", "year_value.csv", package = "SDGupdater")
        ),
        ""
      )$units
    ),
    "Constant USD"
  )
})

