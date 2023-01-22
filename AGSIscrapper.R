#Libraries
library(giedata)
library(lubridate)
library(dplyr)
library(tidyr)
library(devtools)
library(DatawRappr) #note: unofficial library pulled from github.

# Download data for NL: 'get_giedata'
gasdata <- giedata::get_giedata(country = "nl",
                                from = "2019-01-01",
                                to = "2022-08-08", #This needs to be changed to 'present date'. 
                                size = 50,
                                verbose = TRUE,
                                apikey = "236656775ce556411977987e6c8a7eec") #API key never changes.



#Pipeline: Cleaning and formatting
#Note: I believe this should show percentage??? Visualization on DW looks weird. 

gasdatatest<-gasdata %>% 
  mutate(jaar=year(gasDayStart),
         datumnieuw=gasDayStart)
year(gasdatatest$datumnieuw)<-1997

gasdatatest2<-gasdatatest %>% 
  pivot_wider(id_cols =datumnieuw,
              names_from = jaar, 
              values_from = gasInStorage
              )

#DataWrapper
datawrapper_auth(api_key = "KtVSNiVhFvzOfWnG5ltnvGb4NFfSlKtEG7TNHgV2VhoIVBv0FQWdp6VdPxbJ2u7M") #not sure if this one changes

#Update Chart
dw_data_to_chart(gasdatatest2, "WwqOS")

#Publish chart (doesnt work for me for some reason. Mayeb I dont have privilage to publish yet.)
dw_publish_chart("WwqOS")
