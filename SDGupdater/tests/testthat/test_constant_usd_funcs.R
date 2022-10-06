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

test_that("gbp_to_constant_usd returns expected warnings", {
  expect_warning(
    gbp_to_constant_usd(
      system.file("testdata", "Exchange-rates-too-low.xlsx", package = "SDGupdater"), 
      system.file("testdata", "Deflators-base-2020.xlsx", package = "SDGupdater"),
      read.csv(
        system.file("testdata", "year_value.csv", package = "SDGupdater")
      )
    ), 
    "Some UK exchange rates were lower than  0.1 . Please check that the  UK exchange rates does not contain errors"
  )
  expect_warning(
    gbp_to_constant_usd(
      system.file("testdata", "Exchange-rates-too-high.xlsx", package = "SDGupdater"), 
      system.file("testdata", "Deflators-base-2020.xlsx", package = "SDGupdater"),
      read.csv(
        system.file("testdata", "year_value.csv", package = "SDGupdater")
      )
    ), 
    "Some UK exchange rates were hihger than  2 . Please check that the  UK exchange rates does not contain errors"
  )
  
  expect_warning(
    gbp_to_constant_usd(
      system.file("testdata", "Exchange-rates.xlsx", package = "SDGupdater"), 
      system.file("testdata", "Deflators-too-low.xlsx", package = "SDGupdater"),
      read.csv(
        system.file("testdata", "year_value.csv", package = "SDGupdater")
      )
    ),
    "Some UK deflators were lower than  9 . Please check that the  UK deflators does not contain errors"
  )
  expect_warning(
    gbp_to_constant_usd(
      system.file("testdata", "Exchange-rates.xlsx", package = "SDGupdater"), 
      system.file("testdata", "Deflators-too-high.xlsx", package = "SDGupdater"),
      read.csv(
        system.file("testdata", "year_value.csv", package = "SDGupdater")
      )
    ),
    "Some UK deflators were hihger than  160 . Please check that the  UK deflators does not contain errors"
  )

  })
