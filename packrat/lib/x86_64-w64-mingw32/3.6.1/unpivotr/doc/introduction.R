## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(here)

# print every row of a data frame
library(knitr)
knit_print.data.frame = function(...) {
  print(..., n = Inf)
}
# register the method
registerS3method("knit_print", "data.frame", knit_print.data.frame)

## ----image-tidy, echo = FALSE-------------------------------------------------
knitr::include_graphics(here("vignettes/images/hp-tidy.png"))

## ----tidy-readxl--------------------------------------------------------------
library(readxl) # for read_excel()

hp_xlsx <- system.file("extdata/harry-potter.xlsx", package = "unpivotr")

tidy <- read_excel(hp_xlsx, sheet = "tidy")

tidy

## ----image-untidy, echo = FALSE-----------------------------------------------
knitr::include_graphics(here("vignettes/images/hp-untidy.png"))

## ----untidy-readxl------------------------------------------------------------
untidy <- read_excel(hp_xlsx, sheet = "untidy")

untidy

## ----image-untidy2, echo = FALSE----------------------------------------------
knitr::include_graphics(here("vignettes/images/hp-pivoted.png"))

## ----tidyxl-unpivotr-demo-----------------------------------------------------
library(dplyr)
library(tidyr)
library(tidyxl)
library(unpivotr)

hp_xlsx <- system.file("extdata/harry-potter.xlsx", package = "unpivotr")

cells <- xlsx_cells(hp_xlsx, sheet = "pivoted")
formats <- xlsx_formats(hp_xlsx)

indent <- formats$local$alignment$indent

tidied <-
  cells %>%
  filter(!is_blank) %>%
  behead("up-left", "dormitory") %>%
  behead("up", "name") %>%
  behead_if(indent[local_format_id] == 0,
            direction = "left-up",
            name = "location") %>%
  behead("left", "subject") %>%
  select(address, dormitory, name, location, subject, mark = numeric) %>%
  arrange(dormitory, name, location, subject)

tidied

## ----xlsx_cells---------------------------------------------------------------
cells <-
  xlsx_cells(hp_xlsx, sheet = "pivoted") %>%
  # Drop some columns to make it clearer what is going on
  select(row, col, is_blank, data_type, character, numeric, local_format_id)

cells

## ----filter-numeric-----------------------------------------------------------
cells %>%
  filter(data_type == "numeric")

## ----filter-position----------------------------------------------------------
cells %>%
  filter(row == 2, col == 4)

## ----filter-blank-------------------------------------------------------------
cells %>%
  filter(!is_blank)

## ----image-untidy-header-row-1, echo = FALSE----------------------------------
knitr::include_graphics(here("vignettes/images/untidy-header-row-1.png"))

## ----behead-row-1-------------------------------------------------------------
cells %>%
  filter(!is_blank) %>%
  behead("up-left", "dormitory")

## ----image-untidy-header-row-1-2, echo = FALSE--------------------------------
knitr::include_graphics(here("vignettes/images/untidy-header-row-1.png"))

## ----up-right-----------------------------------------------------------------
cells %>%
  filter(!is_blank) %>%
  behead("up-right", "dormitory")

## ----image-untidy-header-row-2, echo = FALSE----------------------------------
knitr::include_graphics("images/untidy-header-row-2.png")

## -----------------------------------------------------------------------------
cells %>%
  filter(!is_blank) %>%
  behead("up-left", "dormitory") %>%
  behead("up", "name")

## ----image-untidy-header-col-1, echo = FALSE----------------------------------
knitr::include_graphics("images/untidy-header-col-1.png")

## ----indented-----------------------------------------------------------------
formats <- xlsx_formats(hp_xlsx) # load the format lookup table from the file

indent <- formats$local$alignment$indent # find the 'indent' property

indent[cells$local_format_id] # look up the indent property of each cell

## ----indented-behead-if-------------------------------------------------------
formats <- xlsx_formats(hp_xlsx) # load the format lookup table from the file
indent <- formats$local$alignment$indent # find the 'indent' property

cells %>%
  filter(!is_blank) %>%
  behead("up-left", "dormitory") %>%
  behead("up", "name") %>%
  behead_if(indent[local_format_id] == 0,
            direction = "left-up", # This argument has to be named now.
            name = "location")     # So does this one.

## ----indented-bold-behead-if--------------------------------------------------
formats <- xlsx_formats(hp_xlsx)
indent <- formats$local$alignment$indent
bold <- formats$local$font$bold # find the 'bold' property

cells %>%
  filter(!is_blank) %>%
  behead("up-left", "dormitory") %>%
  behead("up", "name") %>%
  behead_if(indent[local_format_id] == 0, # First rule
            bold[local_format_id],        # Second rule. Both must be TRUE
            direction = "left-up",
            name = "location")

## ----image-untidy-header-col-2, echo = FALSE----------------------------------
knitr::include_graphics("images/untidy-header-col-2.png")

## -----------------------------------------------------------------------------
cells %>%
  filter(!is_blank) %>%
  behead("up-left", "dormitory") %>%
  behead("up", "name") %>%
  behead_if(indent[local_format_id] == 0,
            direction = "left-up",
            name = "location") %>%
  behead("left", "subject")

## ----cleanup------------------------------------------------------------------
cells %>%
  filter(!is_blank) %>%
  behead("up-left", "dormitory") %>%
  behead("up", "name") %>%
  behead_if(indent[local_format_id] == 0,
            direction = "left-up",
            name = "location") %>%
  behead("left", "subject") %>%
  select(dormitory, name, location, subject, mark = numeric, other = character)

## ----final--------------------------------------------------------------------
library(dplyr)
library(tidyr)
library(tidyxl)
library(unpivotr)

hp_xlsx <- system.file("extdata/harry-potter.xlsx", package = "unpivotr")

cells <- xlsx_cells(hp_xlsx, sheet = "pivoted")
formats <- xlsx_formats(hp_xlsx)

indent <- formats$local$alignment$indent

tidied <-
  cells %>%
  filter(!is_blank) %>%
  behead("up-left", "dormitory") %>%
  behead("up", "name") %>%
  behead_if(indent[local_format_id] == 0,
            direction = "left-up",
            name = "location") %>%
  behead("left", "subject") %>%
  select(address, dormitory, name, location, subject, mark = numeric) %>%
  arrange(dormitory, name, location, subject)

tidied

