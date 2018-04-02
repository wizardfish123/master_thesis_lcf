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
library("tidyverse")

# Load Data -----------------------------------------------------------------------------------

dat_us <- read_csv("data/ExportCountryBits_USA.csv")
dat_germany <- read_csv("data/ExportCountryBits_germany.csv")
