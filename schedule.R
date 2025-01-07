library(lubridate)
library(purrr)
library(stringr)
library(clipr)

start1 <- as.Date("2025-01-23") # first class
start2 <- as.Date("2025-01-27") # second class
recess <- as.Date("2025-03-15") # start of spring break

c(start1 + weeks(0:14), start2 + weeks(0:14)) |>
    keep(\(d) d < recess | d > recess + weeks(1)) |>
    stamp("## Monday, September 1.")() |>
    sort() |>
    str_replace(' 0(\\d)', ' \\1') |> # remove unavoidable 0-padding of day no.
    paste(collapse="\n\n") |>
    write_clip() # NB manually insert spring recess

stamp("## (Monday, September 1. Spring recess.)")(recess) |>
    write_clip()