library(httr)
library(jsonlite)
library(purrr)
library(dplyr)
library(lubridate)

url <- "https://www.nord-stream.info/ajax.php"

get_nord_response <- function(url, 
                              start_date = "", 
                              end_date = "", 
                              n_records = 10, 
                              record_type = c("nom", "flow", "gcv", "wobi")){
  
  args <- list(
    draw = 2, 
    start = 0, 
    length = n_records, 
    timeto = end_date, 
    timefrom = start_date, 
    show = record_type, 
    basis = "daily" #Notice that this script only pulls 'daily' data.
  )
  
  json_response <- 
    POST(url, 
         body = args) |> 
    content(as = "text") |> 
    parse_json()
  
  json_response[["data"]] |> 
    map_depth(1, ~unlist(.x)) |> 
    map_depth(1, ~tibble(
      "date" = .x[1], 
      "kwh_per_day" = .x[2]
    )
    ) |> 
    bind_rows() |> 
    mutate(date = as_date(date, format = "%Y-%m-%d"),
           kwh_per_day = stringr::str_replace_all(kwh_per_day, "[^[:alnum:]]", "") |> as.integer())
}

get_nord_response(url, 
                  start_date = "2022-07-01", 
                  end_date = "2022-08-01", 
                  n_records = 100, 
                  record_type = "nom")