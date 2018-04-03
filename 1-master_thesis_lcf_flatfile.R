#   -------------------------------------------------------------------------------------------
# Author: Laura Carolin Freitag
# June 20th, 2017
# Script job: Create flatfile 
# Running time: 1 min
#   -------------------------------------------------------------------------------------------

# Setup ---------------------------------------------------------------------------------------

options(warn = 1) # All warning are printed as they occour
setwd("~/git_local/master_thesis_lcf") # Set working directory
# Load Libraries
library(tidyverse)
library(lubridate)
library(XML)

# Load Data -----------------------------------------------------------------------------------

dat_us              <- read_csv("data/ExportCountryBits_USA.csv")
dat_germany         <- read_csv("data/ExportCountryBits_germany.csv")
# source: http://investmentpolicyhub.unctad.org/IIA
dat_gdp             <- read_csv("data/API_NY.GDP.PCAP.CD_DS2_en_csv_v2.csv")
# source: https://data.worldbank.org/indicator/ny.gdp.pcap.cd
dat_fdi_us_66_76    <- read_csv("data/fdi_us_1966_1976.csv")
dat_fdi_us_77_81    <- read_csv("data/fdi_us_1977_1981.csv")
#source: https://www.bea.gov/international/di1usdbal.htm


# Rename Columns ------------------------------------------------------------------------------

colnames(dat_us)      <- c("parties", "parties_2", "status", "date_of_signature", 
                            "date_of_entry_into_force", "date_of_termination",
                            "type_of_termination", "amendment_protocols")
colnames(dat_germany) <- c("parties", "parties_2", "status", "date_of_signature", 
                            "date_of_entry_into_force", "date_of_termination",
                            "type_of_termination", "amendment_protocols")

# Convert Data Types --------------------------------------------------------------------------

# US BIT
dat_us$date_of_signature              <- dmy(dat_us$date_of_signature) 
dat_us$date_of_entry_into_force       <- dmy(dat_us$date_of_entry_into_force) 
dat_us$date_of_termination            <- dmy(dat_us$date_of_termination) 

# Germany BIT
dat_germany$date_of_signature         <- dmy(dat_germany$date_of_signature) 
dat_germany$date_of_entry_into_force  <- dmy(dat_germany$date_of_entry_into_force) 
dat_germany$date_of_termination       <- dmy(dat_germany$date_of_termination) 



# Transform Data ------------------------------------------------------------------------------

#GDP
temp <- dat_gdp %>% select(-country_name)
temp <- gather(temp, year, gdp, -country_code) 
temp2 <- dat_gdp %>% select(country_name, country_code)
dat_gpd_long <- left_join(temp, temp2, "country_code")

#FDI
dat_fdi_us_66_76 <- dat_fdi_us_66_76 %>% filter(!is.na(country_name))
dat_fdi_us_77_81 <- dat_fdi_us_77_81 %>% filter(!is.na(country_name))
dat_fdi_us_66_81 <- left_join(dat_fdi_us_66_76, dat_fdi_us_77_81, "country_name")
dat_fdi_us_66_81_long <- gather(dat_fdi_us_66_81, year, fdi, -country_name)
