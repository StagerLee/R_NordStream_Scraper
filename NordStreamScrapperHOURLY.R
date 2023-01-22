#libraries
library(httr)
library(jsonlite)
library(purrr)
library(dplyr)
library(lubridate)

#Site request function
url <- "https://www.nord-stream.info/ajax.php"

get_hourly_nord_response <- function(url, 
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
      basis = "hourly"
    )
    
    json_response <- 
      POST(url, 
           body = args) |> 
      content(as = "text") |> 
      parse_json()
    
    json_response |> 
      pluck("data") |> 
      map_dfr( # map_dfr returns a dataframe as the output by binding rows together (no clue about anything else)
        ~tibble(
          "date" = pluck(.x, 1) |> as_date() # extract the first item of every element in "data" as the date
          "hour" = pluck(.x, 2), # extract the second item of every element in "data" as the hour
          "kwh" = pluck(.x, 3) # extract the 3rd item of every element in "data" as the kwh
        )
      ) |> 
      mutate(
        kwh = stringr::str_replace_all(kwh, "[^[:alnum:]]", "") |> as.integer() # formatting cleanup - I think this is just an integer?
      )
  }
  
}

get_hourly_nord_response(url, 
                         start_date = "2022-08-01", #Set the dates for which you want data (this would ideally be 'present date' all the time)
                         end_date = "2022-08-10",
                         n_records = 100, # number of rows (min. 10; max. 100)
                         record_type = "nom") #type of data you want. There are 4 options on the website.

# Note: Sometimes it pulls data from more dates than is specified. I checked and it is like that on the website for some reason.
# e.g. start date: 2022/01/01; end date: 2022/01/02 = the website give data for 2022/01/03. 