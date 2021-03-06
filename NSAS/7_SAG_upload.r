# ============================================================================
# UPload Assessment Data in SAG
#
# 21/03/2018 First coding of adding historical data to standardgraphs
# 27/04/2018 Change to Historical in the Purpose Field
# 15/11/2018 Change just the comments of an assessment (trial)
# 19/03/2019 Updated for HAWG 2019
# 21/03/2020 Updated for HAWG 2020
# ============================================================================

rm(list=ls())

library(FLCore)
library(FLSAM)
library(icesSAG)  # devtools::install_github("ices-tools-prod/icesSAG")
library(tidyverse)

# path <- "C:/git/wg_HAWG/NSAS/"
path <- "D:/git/wg_HAWG/NSAS/"
try(setwd(path),silent=TRUE)

output.dir          <-  file.path(".","assessment")              # result directory
assessment_name     <- 'NSH_HAWG2020_sf'

# use token
options(icesSAG.use_token = TRUE)

# Load utils code
# source("../_Common/get_dropbox.r")

# Set dropbox folder
# advicedir <- paste(get_dropbox(), "/iAdvice", sep="")

# Get the assessment data and convert to dataframe
#load("//community.ices.dk@SSL/DavWWWRoot/ExpertGroups/HAWG/2020 Meeting Docs/06. Data/her.27.3a47d/NSH_HAWG2020_sf.Rdata")
 load(file.path(output.dir,paste0(assessment_name,'.RData')))

# Set years and ranges
FiY   <- dims(NSH)$minyear
DtY   <- dims(NSH)$maxyear
LaY   <- dims(NSH.sam)$maxyear
nyrs  <- ((DtY)-(FiY))+1
nyrs2 <- ((LaY)-(FiY))+1

# Meta information
stockkeylabel  <- "her.27.3a47d"
assessmentyear <- 2020
contactperson  <- "benoit.berges@wur.nl"

# SSB in intermediate year 
SSBint <- 1288765

# Create the input data for uploading  
info     <- stockInfo(
  StockCode      = stockkeylabel, 
  AssessmentYear = assessmentyear, 
  ContactPerson  = contactperson)

info$StockCategory             <- "1"
info$MSYBtrigger               <- 1400000
info$Blim                      <- 800000
info$Bpa                       <- 900000
info$Flim                      <- 0.34
info$Fpa                       <- 0.30
info$FMSY                      <- 0.26
info$Fage                      <- "2-6" 
info$RecruitmentAge            <- 0
info$CatchesLandingsUnits      <- "t"
info$RecruitmentDescription    <- "wr"
info$RecruitmentUnits          <- "NE3" 
info$FishingPressureDescription<- "F"
info$FishingPressureUnits      <- NA 
info$StockSizeDescription      <- "SSB"
info$StockSizeUnits            <- "t"
info$Purpose                   <- "Advice"
info$CustomSeriesName1         <- "model catch"
info$CustomSeriesName2         <- "model catch low"
info$CustomSeriesName3         <- "model catch high"
info$CustomSeriesName4         <- "F0-1"
info$CustomSeriesName5         <- "F2-6"
info$CustomSeriesName6         <- "F7-8"
info$CustomSeriesUnits1        <- "t"
info$CustomSeriesUnits2        <- "t"
info$CustomSeriesUnits3        <- "t"
info$CustomSeriesUnits4        <- NA
info$CustomSeriesUnits5        <- NA
info$ModelName                 <- "SAM"
info$ModelType                 <- "A"
info$ConfidenceIntervalDefinition <- "tst"

# Create the fish data
fishdata                          <- stockFishdata(FiY:LaY)

fishdata$Catches[1:nyrs]          <- an(NSH@landings)[1:nyrs]

fishdata$Low_Recruitment          <- rec(NSH.sam)$lbnd
fishdata$Recruitment              <- rec(NSH.sam)$value
fishdata$High_Recruitment         <- rec(NSH.sam)$ubnd 

fishdata$Low_StockSize[1:nyrs]    <- ssb(NSH.sam)$lbnd[1:nyrs]
fishdata$StockSize                <- c(ssb(NSH.sam)$value[1:nyrs], SSBint)
fishdata$High_StockSize[1:nyrs]   <- ssb(NSH.sam)$ubnd[1:nyrs]

fishdata$Low_TBiomass[1:nyrs]     <- tsb(NSH.sam)$lbnd[1:nyrs]
fishdata$TBiomass                 <- tsb(NSH.sam)$value
fishdata$High_TBiomass[1:nyrs]    <- tsb(NSH.sam)$ubnd[1:nyrs]

fishdata$Low_FishingPressure[1:nyrs] <- fbar(NSH.sam)$lbnd[1:nyrs]
fishdata$FishingPressure[1:nyrs]     <- fbar(NSH.sam)$value[1:nyrs]
fishdata$High_FishingPressure[1:nyrs]<- fbar(NSH.sam)$ubnd[1:nyrs]

fishdata$CustomSeries1[1:nyrs]    <- catch(NSH.sam)$value[1:nyrs]
fishdata$CustomSeries2[1:nyrs]    <- catch(NSH.sam)$lbnd[1:nyrs]
fishdata$CustomSeries3[1:nyrs]    <- catch(NSH.sam)$ubnd[1:nyrs]

fishdata$CustomSeries4[1:nyrs]    <- c(quantMeans(harvest(NSH.sam)[ac(0:1),]))[1:nyrs]
fishdata$CustomSeries5[1:nyrs]    <- c(quantMeans(harvest(NSH.sam)[ac(2:6),]))[1:nyrs]
fishdata$CustomSeries6[1:nyrs]    <- c(quantMeans(harvest(NSH.sam)[ac(7:8),]))[1:nyrs]

View(fishdata)

# upload to SAG
key <- icesSAG::uploadStock(info, fishdata)

# Get SAG settings
# getSAGSettingsForAStock(assessmentKey=key) %>% View()

# Add comment to SAG settings
# setSAGSettingForAStock(assessmentKey=key, 
#                        chartKey=0,
#                        settingKey=21,
#                        settingValue="My text for the comment field",
#                        copyNextYear=FALSE) 

# plot F's
# fishdata %>% 
#   dplyr::select(Year, FishingPressure, CustomSeries4, CustomSeries5) %>% 
#   setNames(c("year", "F26", "F01", "F78")) %>% 
#   gather(key=F, value=value, F26:F78) %>% 
#   filter(year >= 1980) %>% 
#   
#   ggplot(aes(x=year, y=value, group=F)) +
#   theme_bw() +
#   geom_line(aes(colour=F), size=1)

