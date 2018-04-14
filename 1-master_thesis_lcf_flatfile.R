#   -------------------------------------------------------------------------------------------
# Author: Laura Carolin Freitag
# April 2nd, 2018
# Script job: Create flatfile 
# Running time: 1 min
#   -------------------------------------------------------------------------------------------

#TO DO
# match FDI US


# Setup ---------------------------------------------------------------------------------------

options(warn = 1) # All warning are printed as they occour
setwd("~/git_local/master_thesis_lcf") # Set working directory
# Load Libraries
library(tidyverse)
library(lubridate)
library(XML)

# Load Data -----------------------------------------------------------------------------------

dat_bit_us              <- read_csv("data/ExportCountryBits_USA.csv")
dat_bit_germany         <- read_csv("data/ExportCountryBits_germany.csv")
# source: http://investmentpolicyhub.unctad.org/IIA
dat_gdp             <- read_csv("data/API_NY.GDP.PCAP.CD_DS2_en_csv_v2.csv")
# source: https://data.worldbank.org/indicator/ny.gdp.pcap.cd
# already converted to current $
dat_fdi_us_66_76    <- read_csv("data/fdi_us_1966_1976.csv")
dat_fdi_us_77_81    <- read_csv("data/fdi_us_1977_1981.csv")
dat_fdi_us_82_16    <- read_csv("data/fdi_us_1982_2016.csv")
#source: https://www.bea.gov/international/di1usdbal.htm
dat_gdp_deflator    <- read_csv("data/API_NY.GDP.DEFL.ZS_DS2_en_csv_v2.csv")
#source: https://data.worldbank.org/indicator/NY.GDP.DEFL.ZS?locations=US


# Rename Columns ------------------------------------------------------------------------------

colnames(dat_bit_us)      <- c("parties", "parties_2", "status", "date_of_signature", 
                            "date_of_entry_into_force", "date_of_termination",
                            "type_of_termination", "amendment_protocols")
colnames(dat_bit_germany) <- c("parties", "parties_2", "status", "date_of_signature", 
                            "date_of_entry_into_force", "date_of_termination",
                            "type_of_termination", "amendment_protocols")

# Convert Data Types --------------------------------------------------------------------------

# US BIT
dat_bit_us$date_of_signature              <- dmy(dat_bit_us$date_of_signature) 
dat_bit_us$date_of_entry_into_force       <- dmy(dat_bit_us$date_of_entry_into_force) 
dat_bit_us$date_of_termination            <- dmy(dat_bit_us$date_of_termination) 

# Germany BIT
dat_bit_germany$date_of_signature         <- dmy(dat_bit_germany$date_of_signature) 
dat_bit_germany$date_of_entry_into_force  <- dmy(dat_bit_germany$date_of_entry_into_force) 
dat_bit_germany$date_of_termination       <- dmy(dat_bit_germany$date_of_termination) 


# Transform Data ------------------------------------------------------------------------------

# GDP Deflator
dat_gdp_deflator_us <- dat_gdp_deflator %>% filter(country_code == "USA")
dat_gdp_deflator_us <- gather(dat_gdp_deflator_us, year, gdp_deflator, -c(country_name, country_code))

# GDP
temp <- dat_gdp %>% select(-country_name)
temp <- gather(temp, year, gdp, -country_code) 
temp2 <- dat_gdp %>% select(country_name, country_code)
dat_gpd_long <- left_join(temp, temp2, "country_code")

# FDI
dat_fdi_us_66_76 <- dat_fdi_us_66_76 %>% filter(!is.na(country_name))
dat_fdi_us_77_81 <- dat_fdi_us_77_81 %>% filter(!is.na(country_name))
dat_fdi_us_66_81 <- left_join(dat_fdi_us_66_76, dat_fdi_us_77_81, "country_name")
dat_fdi_us_66_16 <- left_join(dat_fdi_us_66_81, dat_fdi_us_82_16, "country_name")
dat_fdi_us <- gather(dat_fdi_us_66_16, year, fdi, -country_name)
dat_fdi_us <- dat_fdi_us %>% filter(country_name != "Other") %>% 
  filter(fdi != "#")
rm(dat_fdi_us_66_16, dat_fdi_us_66_76, dat_fdi_us_66_81, dat_fdi_us_77_81,
     dat_fdi_us_82_16)
dat_fdi_us <- left_join(dat_fdi_us, (dat_gdp_deflator_us %>% select(year, gdp_deflator)), "year")
dat_fdi_us$fdi <- as.integer(sub(",", "", dat_fdi_us$fdi, fixed = TRUE)) # change data type for FDI to integer
dat_fdi_us$gdp_deflator <- as.numeric(dat_fdi_us$gdp_deflator) # change data type for GDP Deflator to binary
dat_fdi_us <- dat_fdi_us %>% mutate(fdi_current = fdi / (gdp_deflator/100)) # adjust to current 2010 US Dollar
