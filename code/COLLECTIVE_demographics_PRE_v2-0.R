# script for compiling all known demographic and questionnaire data from the
# PRE_dataset_organization spreadsheet.

# version 2-0
#   1.  Pulling in CDI data differently. Originally had both CDI1 and CDI2 in the same CDI columns, but I 
# think ultimately that makes analysis and looking at the data dictionary complicated. 
#   2.  Changed the SCARED_parent computed variables (total, SAD, etc.) to have "Par" instead of "par" in the name.
#   3.  Add FASA and RPBI for parent and child
#   4.  Removed a spreadsheet for finaldx bc it was confusing which columns to use and there were only 2 participants in the NR that were using it

# version 1-2:
#   1. corrected the already-scored SCARED totals from copying the previous subscale data instead of staying NA.
#   This was an issue found in other for loops with ifs in them. You have to make sure that all possible values
#   are addressed across all if loops within a for loop, including NA. I forgot to apply this logic to the 
#   scoring of SCARED Ch and Par in v.1-1.
#   2. Corrected the ACS reverse scoring issue. for Rv_09, I was reverse scoring column 10.

# Notes:

# When you see the following warning, it means one of several things:
#   1. that the script wasn't able to find the participant in the location listed in PRE_dataset_organization. 
#   2. the spreadsheet was being read in wrong due to NAs in the ID column, but that's resolved now in the code.
#   3. the spreadsheet has duplicates, so the native_age variable contains two values
# I determined this by running "options(warn=2)" in the console. That stopped the script when it hit an issue.
# changed it back by running "options(warn=1)" in the console
# These warnings were causing issues that were hard to spot- they caused some values to be entered wrong which makes 
# it look like it worked, but in reality the values entered (for only a few!) were incorrect
# "Warning messages:
# 1: In combodemo1$age[combodemo1$subject == subListCombo[i]] <- native_age :
#   number of items to replace is not a multiple of replacement length"


# In order to recode values (e.g., in INFOSHEET, a "1" value in childrace column needs to represent Black 
# instead of original White to match data from other spreadsheets), I'm using "mapvalues" from the plyr 
# package bc the numbers were getting overwritten by the next line of code when I used alternative 
# recoding methods like regular ifs and lists of "df_Infos_14$chrace[df_Infos_14$chrace==1] <- as.integer(2)" code.
# Also, you can't use the "recode" function from the plyr package because it can't handle numbers. 


# After checking out data dictionaries (datadicos), I realized that several sheets don't have sources for
# what their numbers mean. For example, datasetCSstatus$gender uses 1s and 2s, but there's no .sav sheet
# or datadico verifying that 1=male and 2=female. See the spreadsheet "organize_datadico_for_COLLECTIVE.xlsx" 
# for more details.


################# START ########################################

library("readxl")
library("openxlsx")
library("plyr")

# Call in PRE_dataset_organization spreadsheet. 
PREdataOrg <- read_excel("~/OneDrive - Florida International University/Research/DDM project/masters-project/masters-data/PRE_dataset_organization.xlsx")

# # make "NA" values actually NA
# turns out this messes stuff up later for reasons I don't understand. leaving code for posterity
# PREdataOrg[PREdataOrg=="NA"] <- NA


############# Call in all spreadsheets ##################

setwd("~/OneDrive - Florida International University/Research/DDM project/masters-project/masters-data/questionnaire_data/")

### "name of spreadsheet" ###
# [what variable this spreadsheet is used for] = [how to call the column in native csv] = [what text is written in PREdataOrg]


### "main_dataset" ###
# id = df_maind_et$ID
# age = $age = "main_dataset"
# gender= $gender = "main_dataset"
df_maind_et <- read.csv("main_dataset.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_maind_et <-df_maind_et[!is.na(df_maind_et$ID), ]
# recoding the text values to be numbers 
df_maind_et[df_maind_et == "MALE"] <- as.integer(1)
df_maind_et[df_maind_et == "FEMALE"] <- as.integer(2)
df_maind_et$gender <- sapply(df_maind_et$gender, as.integer)
# checking that I have the code right by comparing the tables before and after
table(df_maind_et$income)
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
df_maind_et$income <- mapvalues(df_maind_et$income, from = c("0-20,999","21,000-40,999","41,000-60,999","61,000-80,999","81, 000-99,999","100,000-149,000","over 150,000","N/A"), to = c("1","2","3","4","5","6","7","NA"))
table(df_maind_et$income)
#converting to integer
df_maind_et$income <- sapply(df_maind_et$income, as.integer)


### "Infosheet(sub)_091514" ###
# id = df_Infos_14$ID
# age = df_Infos_14$chage = "Infosheet(sub)_091514-chage"
# race = $chrace = "Infosheet(sub)_091514- chrace"
# prior treatment = 
# ethnicity = $chethnic = "Infosheet(sub)_091514- chethnic"
# medication= [,105:120] = "Infosheet(sub)_091514- childmedpre, med1name, med2name, med3name"
# prior tx and med = [,c(75:79,81:84,86:89,91:94)]= "Infosheet(sub)_091514- chpasttx, problem1, txtype1, chpattx_2, problem_2, txtype2, chpattx_3, problem_3, txtype3, chpattx_4, problem_4, txtype4," 
df_Infos_14 <- read.csv("Infosheet(sub)_091514.csv", na.strings=c(""," ","NA", 999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_Infos_14 <-df_Infos_14[!is.na(df_Infos_14$ID), ]
# recoding race and ethnicity
# white in df_Infos_14 is 1, but needs to be 2. See "organizing_datadico_for_COLLECTIVE.xlsx"
# checking that I have the code right by comparing the tables before and after
table(df_Infos_14$chrace)
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
df_Infos_14$chrace <- mapvalues(df_Infos_14$chrace, from = c("1","2","3","4","5","6","7","8"), to = c("2","1","3","6","7",NA,"5","4"))
table(df_Infos_14$chrace)
table(df_Infos_14$chethnic)
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
df_Infos_14$chethnic <- mapvalues(df_Infos_14$chethnic, from = c("1","2","3","4","5","6","7","8","9"), to = c("6","2","1","4","5","7","8",NA,"3"))
table(df_Infos_14$chethnic)
# converting to integer
df_Infos_14$chrace <- sapply(df_Infos_14$chrace, as.integer)
df_Infos_14$chethnic <- sapply(df_Infos_14$chethnic, as.integer)


### "SC_CS_Sub_Main dataset latest" ###
# id = $ID
# age = $age = "SC_CS_Sub_Main dataset latest-age"
# gender = $gender = "SC_CS_Sub_Main dataset latest-gender"
# race = $childrace = "SC_CS_Sub_Main dataset latest$childrace" 
# ethicity = #childethnicity = "SC_CS_Sub_Main dataset latest$childethnicity"
# income = $income and $income_new = "SC_CS_Sub_Main dataset latest$income" and "SC_CS_Sub_Main dataset latest$income_new"
# diagnosis = df_SCCS_late[,c(219:236)] = "SC_CS_Sub_Main dataset latest- finaldx1, finaldx1int, finaldx1sx,  finaldx2, finaldx2int, finaldx2sx,  finaldx3, finaldx3int, finaldx3sx,  finaldx4, finaldx4int, finaldx4sx,  finaldx5, finaldx5int, finaldx5sx,  finaldx6, finaldx6int, finaldx6sx"
# medication = [,573:579] = "SC_CS_Sub_Main dataset latest$ichildmedpre"
df_SCCS_late <- read.csv("SC_CS_Sub_Main dataset latest_deidentify.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_SCCS_late <-df_SCCS_late[!is.na(df_SCCS_late$ID), ]
#renaming column to make copying code in the trawls and recoding easier
names(df_SCCS_late)[names(df_SCCS_late) == "childrace"] <- "chrace"
names(df_SCCS_late)[names(df_SCCS_late) == "childethnicity"] <- "chethnic"
# recoding race and ethnicity
# white in df_SCCS_late is 1, but needs to be 2. See "organizing_datadico_for_COLLECTIVE.xlsx"
# checking that I have the code right by comparing the tables before and after
table(df_SCCS_late$chrace)
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
df_SCCS_late$chrace <- mapvalues(df_SCCS_late$chrace, from = c("1","2","3","4","5","6","7","8"), to = c("2","1","3","6","7",NA,"5","4"))
table(df_SCCS_late$chrace)
table(df_SCCS_late$chethnic)
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
df_SCCS_late$chethnic <- mapvalues(df_SCCS_late$chethnic, from = c("1","2","3","4","5","6","7","8","9"), to = c("6","2","1","4","5","7","8",NA,"3"))
table(df_SCCS_late$chethnic)
# converting to integer
df_SCCS_late$chrace <- sapply(df_SCCS_late$chrace, as.integer)
df_SCCS_late$chethnic <- sapply(df_SCCS_late$chethnic, as.integer)
df_SCCS_late$gender <- sapply(df_SCCS_late$gender, as.integer)
# $income_new is values that need to be coded
#making sublist first
subList_SCCS <- unique(df_SCCS_late$ID)
# just checking
SCCS_test1 <- data.frame(table(df_SCCS_late$income_new))
# making a table to compare later- using "table()" by itself isn't super helpful since there's a lot
# of unique values.
colnames(SCCS_test1) <- c("Var", "Freq")
numbers <- data.frame(c((sum(SCCS_test1$Freq[0:24])),
                        (sum(SCCS_test1$Freq[25:48])),
                        (sum(SCCS_test1$Freq[49:67])),
                        (sum(SCCS_test1$Freq[68:81])),
                        (sum(SCCS_test1$Freq[82:92])),
                        (sum(SCCS_test1$Freq[93:110])),
                        (sum(SCCS_test1$Freq[111:127]))))
colnames(numbers) <- c("Freq")
# for loop to recode
# the warnings are because 5726 is listed twice. We don't use that participant so I'm leaving it
for (i in 1:length(subList_SCCS)){
  if (is.na(df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]])){
    df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]] <- NA
  }else{ 
    if (df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]]<21000){
      df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]] <- as.integer(1)
    }else{
      if (df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]]<41000){
        df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]] <- as.integer(2)
      }else {
        if (df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]]<61000){
          df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]] <- as.integer(3)
        }else{
          if (df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]]<81000){
            df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]] <- as.integer(4)
          }else{
            if (df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]]<100000){
              df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]] <- as.integer(5)
            }else{
              if (df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]]<150000){
                df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]] <- as.integer(6)
              }else{
                if (df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]]>=150000){
                  df_SCCS_late$income_new[df_SCCS_late$ID==subList_SCCS[i]] <- as.integer(7)
                }
              }
            }
          }
        }
      }
    }
  }
}
#checking that I recoded right by checking this table with the one right before the loop
table(df_SCCS_late$income_new)


### "INFO SHEET" ###
# id = df_INFO_EET$ID
# age = df_INFO_EET$chage = "INFO SHEET- chage"
# race = $chrace = "INFO SHEET- chrace" 
# ethnicity = $chethnic = "INFO SHEET- chethnic" 
# medication = [,107:122] = "INFO SHEET-childmedpre, med1name, med2name, med3name" 
# prior tx and med = [,c(77:81,83:86,88:91,93:96)]= "INFO SHEET- chpasttx, problem1, txtype1, chpattx_2, problem_2, txtype2, chpattx_3, problem_3, txtype3, chpattx_4, problem_4, txtype4," 
df_INFO_EET <- read.csv("INFO SHEET.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_INFO_EET <-df_INFO_EET[!is.na(df_INFO_EET$ID), ]
# recoding race and ethnicity
# white in df_Infos_14 is 1, but needs to be 2. See "organizing_datadico_for_COLLECTIVE.xlsx"
# checking that I have the code right by comparing the tables before and after
table(df_INFO_EET$chrace)
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
df_INFO_EET$chrace <- mapvalues(df_INFO_EET$chrace, from = c("1","2","3","4","5","6","7","8"), to = c("2","1","3","6","7",NA,"5","4"))
table(df_INFO_EET$chrace)
table(df_INFO_EET$chethnic)
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
df_INFO_EET$chethnic <- mapvalues(df_INFO_EET$chethnic, from = c("1","2","3","4","5","6","7","8","9"), to = c("6","2","1","4","5","7","8",NA,"3"))
table(df_INFO_EET$chethnic)
# converting to integer
df_INFO_EET$chrace <- sapply(df_INFO_EET$chrace, as.integer)
df_INFO_EET$chethnic <- sapply(df_INFO_EET$chethnic, as.integer)


### "datasetCSstatus" ###
# id = $ID
# age = $age = "datasetCSstatus"
# gender = $gender = "datasetCSstatus"
df_datas_stat <- read.csv("datasetCSstatus.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_datas_stat <-df_datas_stat[!is.na(df_datas_stat$ID), ]
# converting to numeric- snafu with gender, it was reading as a double. 
# did try as.integer, but it didn't work for some reason
df_datas_stat$gender <- sapply(df_datas_stat$gender, as.integer)


### "STEPPED CARE_DX_deidentified" ###
# id = df_STEPP_deid$ID
# age = df_STEPP_deid$age = "STEPPED CARE_DX_deidentified- age"
# child
df_STEPP_deid <- read.csv("STEPPED CARE_DX_deidentified.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_STEPP_deid <-df_STEPP_deid[!is.na(df_STEPP_deid$ID), ]


### "CSallPRE" ###
# id = $cs_id
# age = $chage = "CSallPRE-chage"
# SCARED child raw = df_CSallPRE[,c(741:781)] = "CSallPRE- scaredpr01-scaredpr41"
# SCARED child scored= NA
# SCARED parent raw = df_CSallPRE[,c(450:490)] = "CSallPRE- scaredpr01-scaredpr41"
# SCARED parent scored= NA
# race = $chrace = "CSallPRE- chrace" 
# ethnicity = $chethnic = "CSallPRE- chethnic" 
# ACS = df_CSallPRE[,c(569:588)] = "CSallPRE- acspr01-acspr20"
# CDI = df_CSallPRE[,c(634:666)] = "CSallPRE- cdi2cpr01-cdi2cpr33" 
# medication= [,c(277:282, 285:289,292:296)] = "CSallPRE- childmedcurr, med1name, childmedcur_2, med2name, childmedcur_3, med3name" 
# prior tx and med = [,c(243:247,250:253,256:259,262:265)]= "CSallPRE- chpasttx, problem1, txtype1, chpattx_2, problem_2, txtype2, chpattx_3, problem_3, txtype3, chpattx_4, problem_4, txtype4,"
# FASA child = [,c(680:695)] = "CSallPRE_deidentify"
# FASA parent = [,c(407:418)] = "CSallPRE_deidentify"
# CRPBI child = df_CSallPRE[,c(711:740)] = "CSallPRE_deidentify"
# PRPBI parent = df_CSallPRE[,c(420:449)] = "CSallPRE_deidentify"
df_CSallPRE <- read.csv("CSallPRE_deidentify.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_CSallPRE <-df_CSallPRE[!is.na(df_CSallPRE$cs_id), ]
#renaming ID column to make copying code in the trawls easier
names(df_CSallPRE)[names(df_CSallPRE) == "cs_id"] <- "ID"
# comparing my mapvalues function to below
table(df_CSallPRE[,711])
# CRPBI and PRPBI were run with 0,1,2 instead of 1,2,3. This code corrects that
df_CSallPRE[,c(420:449,711:740)] <- lapply(df_CSallPRE[,c(420:449,711:740)], mapvalues, from = c("0","1","2"), to = c(1,2,3))
# comparing my mapvalues function to above
table(df_CSallPRE[,711])



### "joined_SCARED_AGE_Data" ###
# id = df_join_SCARED$ID
# age = df_join_SCARED$Age_ch = "joined_SCARED_AGE_Data: Age_ch"
# SCARED child raw = NA
# SCARED child scored= df_join_SCARED$SCAREDCpr = "joined_SCARED_AGE_Data- SCAREDCpr"
df_join_SCARED <- read.csv("joined_SCARED_AGE_Data.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_join_SCARED <-df_join_SCARED[!is.na(df_join_SCARED$ID), ]


### "SCARED CH PRE" ###
# id = df_SCA_CHPR$ID
# SCARED child raw = df_SCA_CHPR[,c(2:42)] = "SCARED CH PRE"
# SCARED child scored= NA
df_SCA_CHPR <- read.csv("SCARED CH PRE.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_SCA_CHPR <-df_SCA_CHPR[!is.na(df_SCA_CHPR$ID), ]


### "SCARED CH PRE - Subthreshold" ###
# id = $id
# SCARED child raw = df_SCA_CHPR_Sub[,c(4:44)] = "SCARED CH PRE - Subthreshold"
# SCARED child scored = df_SCA_CHPR_Sub[,3]
df_SCA_CHPR_Sub <- read.csv("SCARED CH PRE - Subthreshold.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_SCA_CHPR_Sub <-df_SCA_CHPR_Sub[!is.na(df_SCA_CHPR_Sub$id), ]
#renaming ID column to make copying code in the trawls easier
names(df_SCA_CHPR_Sub)[names(df_SCA_CHPR_Sub) == "id"] <- "ID"


### "CS REDCAP BACK UP OF DATA - ENG 3.30.21" ###
# id = df_CS_BACK_21$cs_id
# SCARED child raw = df_CS_BACK_21[,c(745:785)] = "CS REDCAP BACK UP OF DATA - ENG 3.30.21"
# SCARED child scored = NA
df_CS_BACK_21 <- read.csv("CS REDCAP BACK UP OF DATA - ENG 3.30.21_deidentify.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_CS_BACK_21 <-df_CS_BACK_21[!is.na(df_CS_BACK_21$cs_id), ]
#renaming ID column to make copying code in the trawls easier
names(df_CS_BACK_21)[names(df_CS_BACK_21) == "cs_id"] <- "ID"


### "Redcap_and_nonRedcap_and_status_integrated_viaExcel_PrelimCNS21" ###
# id = df_Red_integ$ID
# SCARED child raw = df_Red_integ[,c(51:91)] = "Redcap_and_nonRedcap_and_status_integrated_viaExcel_PrelimCNS21"
# SCARED child scored = df_Red_integ[,92]
# SCARED parent raw =  df_Red_integ[,c(4:49)] = Redcap_and_nonRedcap_and_status_integrated_viaExcel_PrelimCNS21
# SCARED parent scored = df_Red_integ[,50] or df_Red_integ$preP_ScaredTot
df_Red_integ <- read.csv("Redcap_and_nonRedcap_and_status_integrated_viaExcel_PrelimCNS21.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_Red_integ <-df_Red_integ[!is.na(df_Red_integ$ID), ]


### "CS REDCAP SCAREDCP DATA TOTAL SCORES" ###
# id = $ID
# SCARED child raw = NA
# SCARED child scored = $scaredpre_sum = "CS REDCAP SCAREDCP DATA TOTAL SCORES- scaredpre_sum"
# SCARED parent raw = NA
# SCARED parent scored = $scaredppre_sum = "CS REDCAP SCAREDCP DATA TOTAL SCORES- scaredppre_sum"
df_CS_SCORES <- read.csv("CS REDCAP SCAREDCP DATA TOTAL SCORES.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_CS_SCORES <-df_CS_SCORES[!is.na(df_CS_SCORES$ID), ]

### "CS REDCap data (infosheet_cdi2_scared_txhx - English (final)" ###
# id = $ID
# race = $chrace = "CS REDCap data (infosheet_cdi2_scared_txhx - English (final)-chrace"
# ethnicity = $chethnic = "CS REDCap data (infosheet_cdi2_scared_txhx - English (final)-chethnic"
# CDI = df_CS_ENG_final[,c(140:172)] = "CS REDCap data (infosheet_cdi2_scared_txhx - English (final)-cdi2cpr01-cdi2cpr33"
df_CS_ENG_final <- read.csv("CS REDCap data (infosheet_cdi2_scared_txhx - English (final).csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_CS_ENG_final <-df_CS_ENG_final[!is.na(df_CS_ENG_final$ID), ]

### "SCARED PARENT PRE" ###
# id = df_SCA_PA_PRE$ID 
# SCARED parent raw = df_SCA_PA_PRE[,c(2:42)] = "SCARED PARENT PRE"
# SCARED parent scored = NA
df_SCA_PA_PRE <- read.csv("SCARED PARENT PRE.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_SCA_PA_PRE <-df_SCA_PA_PRE[!is.na(df_SCA_PA_PRE$ID), ]

### "SCARED PARENT PRE-Subthreshold" ###
# id = df_SCA_PA_sub$ID 
# SCARED parent raw = df_SCA_PA_sub[,c(5:45)] = "SCARED PARENT PRE-Subthreshold"
# SCARED parent scored = df_SCA_PA_sub$SCAREDPpre
df_SCA_PA_sub <- read.csv("SCARED PARENT PRE-Subthreshold.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_SCA_PA_sub <-df_SCA_PA_sub[!is.na(df_SCA_PA_sub$ID), ]

### "CS Spn Project RC Data latest 1.17.22" ###
# id = $cs_id
# race = $chrace = "CS Spn Project RC Data latest 1.17.22- chrace"
# ethnicity = $chethic = "CS Spn Project RC Data latest 1.17.22- chethnic"
df_CS_Spn_proj <- read.csv("CS Spn Project RC Data latest 1.17.22_deidentify.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_CS_Spn_proj <-df_CS_Spn_proj[!is.na(df_CS_Spn_proj$cs_id), ]
#renaming ID column to make copying code in the trawls easier
names(df_CS_Spn_proj)[names(df_CS_Spn_proj) == "cs_id"] <- "ID"

### "CAPP Tracking Log 4.24.22_deidentify" ###
# id = $CAPP ID
# race = $Child Race ="CAPP Tracking Log 4.24.22- Child Race" 
# ethnicity= $Child Ethnicity= "CAPP Tracking Log 4.24.22- Child Ethnicity"
df_CAPP_track <- read.csv("CAPP Tracking Log 4.24.22_deidentify.csv", na.strings=c(""," ","NA",999, "blank","BLANK"))
# R automatically named the columns with spaces "CAPP.ID" instead of "CAPP ID"
#renaming ID column to make copying code in the trawls easier
names(df_CAPP_track)[names(df_CAPP_track) == "CAPP.ID"] <- "ID"
#Just changing these to be congruent with other names to facilitate copy/paste
names(df_CAPP_track)[names(df_CAPP_track) == "Child.Race"] <- "chrace"
names(df_CAPP_track)[names(df_CAPP_track) == "Child.Ethnicity"] <- "chethnic"
names(df_CAPP_track)[names(df_CAPP_track) == "Income"] <- "income"
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_CAPP_track <-df_CAPP_track[!is.na(df_CAPP_track$ID), ]
# Replacing text for corresponding numbers- e.g., white=2
# using this method instead of the mapvalues method bc there's only one participant
df_CAPP_track[df_CAPP_track == "White"] <- as.integer(2)
df_CAPP_track[df_CAPP_track == "Hispanic or Latino"] <- as.integer(2)
# converting to numeric- snafu with gender, it was reading as an integer
# this method does induce NA for all other subs in the sheet, but I just need the one participant so imma ignore it.
df_CAPP_track$chrace <- sapply(df_CAPP_track$chrace, as.integer)
df_CAPP_track$chethnic <- sapply(df_CAPP_track$chethnic, as.integer)
# income is weird bc everything is in a different format.
# removing dollar signs and commas
# testing the removal of "$" and ",". It coerces NA for all values with "/" or characters
# income_test <- data.frame(df_CAPP_track$ID, df_CAPP_track$income)
# income_test$income_edit <- as.numeric(gsub('[$,]', '', df_CAPP_track$income))
df_CAPP_track$income <- as.numeric(gsub('[$,]', '', df_CAPP_track$income))
# $income is values that need to be coded
#making sublist first
subList_CAPP <- unique(df_CAPP_track$ID)
# just checking
CAPP_test1 <- data.frame(table(df_CAPP_track$income))
# making a table to compare later- using "table()" by itself isn't super helpful since there's a lot
# of unique values.
colnames(CAPP_test1) <- c("Var", "Freq")
numbers <- data.frame(c((sum(CAPP_test1$Freq[0:24])),
                        (sum(CAPP_test1$Freq[25:50])),
                        (sum(CAPP_test1$Freq[51:68])),
                        (sum(CAPP_test1$Freq[69:82])),
                        (sum(CAPP_test1$Freq[83:93])),
                        (sum(CAPP_test1$Freq[94:112])),
                        (sum(CAPP_test1$Freq[113:128])),
                        (sum(CAPP_test1$Freq))))
colnames(numbers) <- c("Freq")
# for loop to recode
# the warnings are because 5726 is listed twice. We don't use that participant so I'm leaving it
for (i in 1:length(subList_CAPP)){
  if (is.na(df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]])){
    df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]] <- NA
  }else{ 
    if (df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]]<21000){
      df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]] <- as.integer(1)
    }else{
      if (df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]]<41000){
        df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]] <- as.integer(2)
      }else {
        if (df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]]<61000){
          df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]] <- as.integer(3)
        }else{
          if (df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]]<81000){
            df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]] <- as.integer(4)
          }else{
            if (df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]]<100000){
              df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]] <- as.integer(5)
            }else{
              if (df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]]<150000){
                df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]] <- as.integer(6)
              }else{
                if (df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]]>=150000){
                  df_CAPP_track$income[df_CAPP_track$ID==subList_CAPP[i]] <- as.integer(7)
                }
              }
            }
          }
        }
      }
    }
  }
}
#checking that I recoded right by checking this table with the one right before the loop
table(df_CAPP_track$income)
#the numbers are off so now I'm manually checking each subject that needs this sheet using the income_test df
# 5223: 42,000 = 3
# 5246: 100,000= 6
# 5273: 50,000 = 3
# 5291: 69,000 = 4
# 5327: 0 = 1
# 5341: 65,000 = 4
# 5426: 30,000 = 2
# 5485: 12,000 = 1

### "ACS pre_2020-10-03"
# id = $ID
# ACS = df_ACS_pre_03[,c(2:21)] = "ACS pre_2020-10-03- ACQ01pre-ACQ20pre"
df_ACS_pre_03 <- read.csv("ACS pre_2020-10-03.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_ACS_pre_03 <-df_ACS_pre_03[!is.na(df_ACS_pre_03$ID), ]

### "ACS pre_2020-06-20" ###
# id = $ID
# ACS = df_ACS_pre_20[,c(2:21)] = "ACS pre_2020-06-20- ACQ01pre-ACQ20pre"
df_ACS_pre_20 <- read.csv("ACS pre_2020-06-20.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_ACS_pre_20 <-df_ACS_pre_20[!is.na(df_ACS_pre_20$ID), ]

### cdi pre before REDCAP) ###
# id = $ID
# CDI = df_cdi_b4_REDCAP[,c(2:28)] = "cdi pre before REDCAP)"
df_cdi_b4_REDCAP <- read.csv("cdi pre before REDCAP).csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_cdi_b4_REDCAP <-df_cdi_b4_REDCAP[!is.na(df_cdi_b4_REDCAP$ID), ]

### CDI PRE ###
# id = $ID
# CDI = df_CDI_PRE[,c(2:28)] = "CDI PRE"
df_CDI_PRE <- read.csv("CDI PRE.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_CDI_PRE <-df_CDI_PRE[!is.na(df_CDI_PRE$ID), ]

### CDI2C pre items ###
# id = $ID
# CDI = df_CDI2C_items[,c(5,6,8,9,10,11,13,15,16,18,19,20,22,23,25,27,28,30,31,32,34,35,36,38,40,41,42,43,44,46,47,49,50)] = "CDI PRE"
df_CDI2C_items <- read.csv("CDI2C pre items.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_CDI2C_items <-df_CDI2C_items[!is.na(df_CDI2C_items$ID), ]


### CDI2 Child pretx (Predated REDCap) ###
# id = $ID
# CDI = df_CDI2_pretx_REDCap[,c(2:34)] = "CDI2 Child pretx (Predated REDCap)"
df_CDI2_pretx_REDCap <- read.csv("CDI2 Child pretx (Predated REDCap).csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_CDI2_pretx_REDCap <-df_CDI2_pretx_REDCap[!is.na(df_CDI2_pretx_REDCap$ID), ]


# commented out because there's no datadico, so no way to tell whether a 1 in race is "white" or "black", etc.
# ### "datasetInfoPre" 
# # id = $ID
# # race = $chrace = "datasetInfoPre-chrace" 
# df_datInfoPre <- read.csv("datasetInfoPre.csv", na.strings=c(""," ","NA",999))
# #removing the rows that have NA in the subject column. It was interfering with pulling data
# df_datInfoPre <-df_datInfoPre[!is.na(df_datInfoPre$ID), ]


### Pre fasa_pbi_masc FINAL 5.25.20 merged ###
# id = $ID
# FASA child PRE = [,c(45:61)] = "Pre fasa_pbi_masc FINAL 5.25.20 merged" (16 items)
# FASA parent PRE = [,c(2:14)] = "Pre fasa_pbi_masc FINAL 5.25.20 merged" (13 items)
# CRPBI ch PRE = df_pre_fasa_pbi[,c(61:90)] = "Pre fasa_pbi_masc FINAL 5.25.20 merged" 
# PRPBI par PRE = df_pre_fasa_pbi[,c(15:44)] = "Pre fasa_pbi_masc FINAL 5.25.20 merged" 
df_pre_fasa_pbi <- read.csv("Pre fasa_pbi_masc FINAL 5.25.20 merged.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_pre_fasa_pbi <-df_pre_fasa_pbi[!is.na(df_pre_fasa_pbi$ID), ]
# CRPBI and PRPBI were run with 0,1,2 instead of 1,2,3. This code corrects that
table(df_pre_fasa_pbi[,44])
df_pre_fasa_pbi[,c(15:44,61:90)] <- lapply(df_pre_fasa_pbi[,c(15:44,61:90)], mapvalues, from = c("0","1","2"), to = c(1,2,3))



### FASACpre ###
# id = $ID
# FASA child PRE = df_FASACpre[,c(2:17)] = "FASACpre"
df_FASACpre <- read.csv("FASACpre.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_FASACpre <-df_FASACpre[!is.na(df_FASACpre$ID), ]


### FASAPpre ###
# id = $ID
# FASA parent PRE = df_FASAPpre[,c(2:14)] = "FASAPpre"
df_FASAPpre <- read.csv("FASAPpre.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_FASAPpre <-df_FASAPpre[!is.na(df_FASAPpre$ID), ]


### FASAPpre_subthreshold ###
# id = $ID
# FASA parent PRE = df_FASAPpre_sub[,c(2:14)] = "FASAPpre_subthreshold"
df_FASAPpre_sub <- read.csv("FASAPpre_subthreshold.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_FASAPpre_sub <-df_FASAPpre_sub[!is.na(df_FASAPpre_sub$ID), ]


### CRPBI (mom) pre ###
# id = $ID
# RPBI ch PRE = df_CRPBImom[,c(2:31)] = "CRPBI (mom) pre" 
df_CRPBImom <- read.csv("CRPBI (mom) pre.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_CRPBImom <-df_CRPBImom[!is.na(df_CRPBImom$ID), ]


### CRPBI (mom) pre_subthreshold ###
# id = $ID
# RPBI ch PRE = df_CRPBImom_sub[,c(2:31)] = "CRPBI (mom) pre_subthreshold" 
df_CRPBImom_sub <- read.csv("CRPBI (mom) pre_subthreshold.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_CRPBImom_sub <-df_CRPBImom_sub[!is.na(df_CRPBImom_sub$ID), ]


### PRPBI pre ###
# id = $ID
# PRPBI par PRE = df_PRPBIpre[,c(2:31)] = "PRPBI pre" 
df_PRPBIpre <- read.csv("PRPBI pre.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_PRPBIpre <-df_PRPBIpre[!is.na(df_PRPBIpre$ID), ]


### PRPBI pre_subthreshold ###
# id = $ID
# PRPBI par PRE = df_PRPBIpre_sub[,c(2:31)] = "PRPBI pre_subthreshold" 
df_PRPBIpre_sub <- read.csv("PRPBI pre_subthreshold.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling data
df_PRPBIpre_sub <-df_PRPBIpre_sub[!is.na(df_PRPBIpre_sub$ID), ]



############# temp ##################





## Non-Responder spreadsheets ###

### "PARENT MED and ABMT_DX_DEMOS_deidentified" ###
# id = $ID
# age = $AMBT_age = "PARENT MED and ABMT_DX_DEMOS_deidentified-ABMT_age"
# gender = $gender = "PARENT MED and ABMT_DX_DEMOS_deidentified-gender"
# race = $chrace = "PARENT MED and ABMT_DX_DEMOS_deidentified-chrace" 
# ethnicity = $chethic = "PARENT MED and ABMT_DX_DEMOS_deidentified-chethnic"
# diagnosis = df_PARE_deid[,175:189] = "PARENT MED and ABMT_DX_DEMOS_deidentified- finaldx1, finaldx1int, finaldx1sx,  finaldx2, finaldx2int, finaldx2sx,  finaldx3, finaldx3int, finaldx3sx,  finaldx4, finaldx4int, finaldx4sx,  finaldx5, finaldx5int, finaldx5sx"
# medication= [,c(17,2,18,3,19,4,20)] = "PARENT MED and ABMT_DX_DEMOS_deidentified-childmedpre,med1, med1dosage, med 2, med2dosage, med3, med3dosage"
df_PARE_deid <- read.csv("PARENT MED and ABMT_DX_DEMOS_deidentified.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_PARE_deid <-df_PARE_deid[!is.na(df_PARE_deid$ID), ]
# converting to numeric- snafu with gender, it was reading as an integer
df_PARE_deid$gender <- sapply(df_PARE_deid$gender, as.integer)
# recoding race and ethnicity
# white in df_Infos_14 is 1, but needs to be 2. See "organizing_datadico_for_COLLECTIVE.xlsx"
# checking that I have the code right by comparing the tables before and after
table(df_PARE_deid$chrace)
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
df_PARE_deid$chrace <- mapvalues(df_PARE_deid$chrace, from = c("1","2","3","4","5","6","7","8"), to = c("2","1","3","6","7",NA,"5","4"))
table(df_PARE_deid$chrace)
table(df_PARE_deid$chethnic)
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
df_PARE_deid$chethnic <- mapvalues(df_PARE_deid$chethnic, from = c("1","2","3","4","5","6","7","8","9"), to = c("6","2","1","4","5","7","8",NA,"3"))
table(df_PARE_deid$chethnic)
# converting to integer
df_PARE_deid$chrace <- sapply(df_PARE_deid$chrace, as.integer)
df_PARE_deid$chethnic <- sapply(df_PARE_deid$chethnic, as.integer)


### "NR ABM (mplus) working 5.27.18" ###
# id = $ID
# age = $AGE = "NR ABM (mplus) working 5.27.18- AGE"
# gender = $Dsex = "NR ABM (mplus) working 5.27.18- Dsex"
# race = $chrace = "NR ABM (mplus) working 5.27.18- chrace" 
# ethnicity = $cheth ="NR ABM (mplus) working 5.27.18- cheth" 
df_NRABM_18 <- read.csv("NR ABM (mplus) working 5.27.18_EDITED-ID.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_NRABM_18 <-df_NRABM_18[!is.na(df_NRABM_18$ID), ]
#renaming Dsex column to make copying code in the trawls easier
names(df_NRABM_18)[names(df_NRABM_18) == "Dsex"] <- "gender"
names(df_NRABM_18)[names(df_NRABM_18) == "cheth"] <- "chethnic"
# recoding the text values to be numbers 
df_NRABM_18$gender <- mapvalues(df_NRABM_18$gender, from = c("male", "female"), to = c("1","2"))
# Replacing text for corresponding numbers- e.g., white=2
# this sheet did not ask about Hawaiian or pacific islander I don't think
table(df_NRABM_18$chrace)
df_NRABM_18$chrace <- mapvalues(df_NRABM_18$chrace, from = c("ASIAN", "black", "mixed", "other", "white", "native american"), to = c("3","1","6","7","2","5"))
table(df_NRABM_18$chrace)
table(df_NRABM_18$chethnic)
df_NRABM_18$chethnic <- mapvalues(df_NRABM_18$chethnic, from = c("Euro American","Hispanic-Latino","African-American","Asian-American","American-Indian","Native Hawaiian-Pacific Islander","Other","NA","Afro-Carribean"), to = c("6","2","1","4","5","7","8","NA","3"))
table(df_NRABM_18$chethnic)
# converting to integer
df_NRABM_18$gender <- sapply(df_NRABM_18$gender, as.integer)
df_NRABM_18$chrace <- sapply(df_NRABM_18$chrace, as.integer)
df_NRABM_18$chethnic <- sapply(df_NRABM_18$chethnic, as.integer)


### "nr-controls-demographics" ###
# id = $ID
# age = $age_year = "nr-controls-demographics: age" (choosing age_year bc my date-birthday calculation didnt match exisiting ages)
# gender = $Gender
# race = $Race = "nr-controls-demographics: Race"
# ethnicity = $Ethnicity = "nr-controls-demographics: Ethnicity" 
df_nrcon_demo <- read.csv("nr_controls_demographics_EDITED-ID.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_nrcon_demo <-df_nrcon_demo[!is.na(df_nrcon_demo$ID), ]
#renaming Dsex column to make copying code in the trawls easier
names(df_nrcon_demo)[names(df_nrcon_demo) == "Gender"] <- "gender"
names(df_nrcon_demo)[names(df_nrcon_demo) == "Race"] <- "chrace"
names(df_nrcon_demo)[names(df_nrcon_demo) == "Ethnicity"] <- "chethnic"
# converting to numeric- snafu with gender, it was reading as a double.
df_nrcon_demo$gender <- sapply(df_nrcon_demo$gender, as.integer)
df_nrcon_demo$chrace <- sapply(df_nrcon_demo$chrace, as.integer)
df_nrcon_demo$chethnic <- sapply(df_nrcon_demo$chethnic, as.integer)


### "PRE_ALL_JL_4.10.14" ###
# id = $CaseID  
# SCARED child raw = df_PRE_JL_14[,c(43:83)] = "PRE_ALL_JL_4.10.14"
# SCARED child scored = NA
# SCARED parent raw = df_PRE_JL_14[,c(43:83)] = "PRE_ALL_JL_4.10.14"
# SCARED parent scored = NA
# ACS = df_PRE_JL_14[,c(84:103)]= "PRE_ALL_JL_4.10.14 PACSC1-PACSC20"
# CDI = df_PRE_JL_14[,c(235:261)]= "PRE_ALL_JL_4.10.14- PCDI1-PCDI27"
df_PRE_JL_14 <- read.csv("PRE_ALL_JL_4.10.14_EDITED-ID.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_PRE_JL_14 <-df_PRE_JL_14[!is.na(df_PRE_JL_14$CaseID), ]
#renaming ID column to make copying code in the trawls easier
names(df_PRE_JL_14)[names(df_PRE_JL_14) == "CaseID"] <- "ID"


### "Nonresponder pre-post-2mo SCARED_full" ###
# id = df_NR_SCA_full$ID  #4021
# SCARED child raw = df_NR_SCA_full[,c(18:58)] = "Nonresponder pre-post-2mo SCARED_full"
# SCARED child scored = So there's actually two columns and idk which is the score i want. df_NR_SCA_full$pre_SCARED_child_total, df_NR_SCA_full$pre_child_SCARED
# SCARED parent raw = df_NR_SCA_full[,c(59:99)] = "Nonresponder pre-post-2mo SCARED_full- pre_SCARED_p_Q1-pre_SCARED_p_Q41"
# SCARED parent scored = So there's actually two columns and idk which is the score i want. df_NR_SCA_full$pre_SCARED_parent_total, df_NR_SCA_full$pre_parent_SCARED
df_NR_SCA_full <- read.csv("Nonresponder pre-post-2mo SCARED_full.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_NR_SCA_full <-df_NR_SCA_full[!is.na(df_NR_SCA_full$ID), ]
# recoding the text values to be numbers 
df_NR_SCA_full[df_NR_SCA_full == "Not True or Hardly Ever True"] <- 0
df_NR_SCA_full[df_NR_SCA_full == "Somewhat True or Sometimes True"] <- 1
df_NR_SCA_full[df_NR_SCA_full == "Very True or Often True"] <- 2
df_NR_SCA_full[, 18:99] <- sapply(df_NR_SCA_full[, 18:99], as.integer)

### "(SCARED) Child_ACON" ###
# id = df_SCA_Ch_ACON$ID  #ACON-007
# SCARED child raw = df_SCA_Ch_ACON[,c(3:43)] = "(SCARED) Child_ACON- Q1-Q41"
# SCARED child scored = df_SCA_Ch_ACON$SCARED_child_total
df_SCA_Ch_ACON <- read.csv("(SCARED) Child_ACON_EDITED-ID.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_SCA_Ch_ACON <-df_SCA_Ch_ACON[!is.na(df_SCA_Ch_ACON$ID), ]
# recoding the text values to be numbers 
df_SCA_Ch_ACON[df_SCA_Ch_ACON == "Not True or Hardly Ever True"] <- 0
df_SCA_Ch_ACON[df_SCA_Ch_ACON == "Somewhat True or Sometimes True"] <- 1
df_SCA_Ch_ACON[df_SCA_Ch_ACON == "Very True or Often True"] <- 2
df_SCA_Ch_ACON[, 3:43] <- sapply(df_SCA_Ch_ACON[, 3:43], as.integer)

### "(SCARED) Parent_ACON" ###
# id = df_SCA_Pa_ACON$ID  #ACON-007
# SCARED child raw = df_SCA_Pa_ACON[,c(3:43)] = "(SCARED) Parent_ACON- Q1-Q41"
# SCARED child scored = df_SCA_Pa_ACON$SCARED_parent_total
df_SCA_Pa_ACON <- read.csv("(SCARED) Parent_ACON_EDITED-ID.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_SCA_Pa_ACON <-df_SCA_Pa_ACON[!is.na(df_SCA_Pa_ACON$ID), ]
# recoding the text values to be numbers 
df_SCA_Pa_ACON[df_SCA_Pa_ACON == "Not True or Hardly Ever True"] <- 0
df_SCA_Pa_ACON[df_SCA_Pa_ACON == "Somewhat True or Sometimes True"] <- 1
df_SCA_Pa_ACON[df_SCA_Pa_ACON == "Very True or Often True"] <- 2
df_SCA_Pa_ACON[, 3:43] <- sapply(df_SCA_Pa_ACON[, 3:43], as.integer)

### (ACS-S)_ACON ###
# id = $ID
# ACS = [,c(3:22)] = "(ACS-S)_ACON- Q1-Q20"
df_ACS_ACON <- read.csv("(ACS-S)_ACON_EDITED_ID.csv", na.strings=c(""," ","NA",999))
#removing the rows that have NA in the subject column. It was interfering with pulling scared data
df_ACS_ACON <-df_ACS_ACON[!is.na(df_ACS_ACON$ID), ]
# recoding the text values to be numbers 
df_ACS_ACON[df_ACS_ACON == "Almost Never"] <- 1
df_ACS_ACON[df_ACS_ACON == "Sometimes"] <- 2
df_ACS_ACON[df_ACS_ACON == "Often"] <- 3
df_ACS_ACON[df_ACS_ACON == "Always"] <- 4
df_ACS_ACON[, 3:22] <- sapply(df_ACS_ACON[, 3:22], as.integer)




#################### making new df to hold all new variables ############# 


combodemo1 <- PREdataOrg["Subject"]
colnames(combodemo1)<- c("subject")


subListCombo <- unique(combodemo1$subject)




#################### trawl for age data #################

# Add a column for age to combodemo1
combodemo1$age <- NA

# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for age
# if you get an error like "replacement has length zero" or "number of items to replace is not a multiple of replacement length"
# then check to see which subs still have NA and double check in the excel sheet what sheet its calling.
for (i in 1:length(subListCombo)){
 
  # if the location is listed as "spreadsheet" for the subject in PREdataOrg, 
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]=="main_dataset"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    native_age <- df_maind_et$age[df_maind_et$ID == subListCombo[i]]
  }
  # if the location is listed as "[spreadsheet]",
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "Infosheet(sub)_091514-chage"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    native_age <- df_Infos_14$chage[df_Infos_14$ID == subListCombo[i]]
  }
  # df_SCCS_late$age = "SC_CS_Sub_Main dataset latest-age"
  # if the location is listed as "[spreadsheet]",
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "SC_CS_Sub_Main dataset latest-age"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    native_age <- df_SCCS_late$age[df_SCCS_late$ID == subListCombo[i]]
  }
  # id = df_INFO_EET$ID
  # age = df_INFO_EET$chage = "INFO SHEET- chage"
  # if the location is listed as "[spreadsheet]",
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "INFO SHEET- chage"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    native_age <- df_INFO_EET$chage[df_INFO_EET$ID == subListCombo[i]]
  }
  ### "datasetCSstatus" ###
  # id = df_datas_stat$ID
  # age = df_datas_stat$age = "datasetCSstatus"
  # if the location is listed as "[spreadsheet]",
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "datasetCSstatus"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    native_age <- df_datas_stat$age[df_datas_stat$ID == subListCombo[i]]
  }

  ### "STEPPED CARE_DX_deidentified" ###
  # id = df_STEPP_deid$ID
  # age = df_STEPP_deid$age = "STEPPED CARE_DX_deidentified- age"
  # if the location is listed as "[spreadsheet]",
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "STEPPED CARE_DX_deidentified- age"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    native_age <- df_STEPP_deid$age[df_STEPP_deid$ID == subListCombo[i]]
  }

  ### "CSallPRE" ###
  # id = df_CSallPRE$cs_id
  # age = df_CSallPRE$chage = "CSallPRE-chage"
  # if the location is listed as "[spreadsheet]",
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "CSallPRE-chage"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    native_age <- df_CSallPRE$chage[df_CSallPRE$ID == subListCombo[i]]
  }

  ### "joined_SCARED_AGE_Data: Age_ch" ###
  # id = df_SCA_data$ID
  # age = df_SCA_data$Age_ch = "joined_SCARED_AGE_Data: Age_ch"
  # if the location is listed as "[spreadsheet]",
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "joined_SCARED_AGE_Data: Age_ch"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    native_age <- df_join_SCARED$Age_ch[df_join_SCARED$ID == subListCombo[i]]
  }

  
  
   if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "PARENT MED and ABMT_DX_DEMOS_deidentified-ABMT_age"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    # doing NA for nonresponders until I can sort out the sub names
    native_age <- df_PARE_deid$ABMT_age[df_PARE_deid$ID == subListCombo[i]]
  }

  ### "NR ABM (mplus) working 5.27.18" ###
  # id = df_NRABM_18$ID
  # age = df_NRABM_18$AGE = "NR ABM (mplus) working 5.27.18- AGE"
  # if the location is listed as "[spreadsheet]",
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "NR ABM (mplus) working 5.27.18- AGE"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    native_age <- df_NRABM_18$AGE[df_NRABM_18$ID == subListCombo[i]]
  }

  ### "nr-controls-demographics" ###
  # id = df_nrcon_demo$ID
  # age = df_nrcon_demo$age = "nr-controls-demographics: age"
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "nr-controls-demographics: age"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    # doing NA for nonresponders until I can sort out the sub names
    native_age <- df_nrcon_demo$age_year[df_nrcon_demo$ID == subListCombo[i]]
  }

  #making sure that NA values in age-location stay NA. otherwise they fill in with the last non-NA value in combodemo1
  if (PREdataOrg$location_age[PREdataOrg$Subject == subListCombo[i]]== "NA"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    # doing NA for nonresponders until I can sort out the sub names
    native_age <- NA
    }

  #change NA for the current sub's age to native_age in the combodemo1 df
  combodemo1$age[combodemo1$subject == subListCombo[i]] <- native_age
  
} #end age trawl

# making sure the NAs work
combodemo1[combodemo1=="NA"] <- NA

#renaming so I don't f something up
combodemo2 <- combodemo1

#checking to see what format the data is in (char, num, logic, etc.)
sapply(combodemo2, mode)

#Making age numeric
combodemo2[, 2] <- sapply(combodemo2[, 2], as.integer)

# checking that age is now numeric
sapply(combodemo2, mode)

# Mean, minimum, maximum while excluding NA values
mean(combodemo2$age, na.rm = TRUE) #mean 10.23
min(combodemo2$age, na.rm = TRUE) #min 3
max(combodemo2$age, na.rm = TRUE) #max 18




#################### trawl for SCARED child data ############################

#renaming this to preserve combodemo2
combodemo3 <- combodemo2

# Add columns for child SCARED to combodemo3
combodemo3$SCARED_01_Ch_PRE <- NA
combodemo3$SCARED_02_Ch_PRE <- NA
combodemo3$SCARED_03_Ch_PRE <- NA
combodemo3$SCARED_04_Ch_PRE <- NA
combodemo3$SCARED_05_Ch_PRE <- NA
combodemo3$SCARED_06_Ch_PRE <- NA
combodemo3$SCARED_07_Ch_PRE <- NA
combodemo3$SCARED_08_Ch_PRE <- NA
combodemo3$SCARED_09_Ch_PRE <- NA
combodemo3$SCARED_10_Ch_PRE <- NA
combodemo3$SCARED_11_Ch_PRE <- NA
combodemo3$SCARED_12_Ch_PRE <- NA
combodemo3$SCARED_13_Ch_PRE <- NA
combodemo3$SCARED_14_Ch_PRE <- NA
combodemo3$SCARED_15_Ch_PRE <- NA
combodemo3$SCARED_16_Ch_PRE <- NA
combodemo3$SCARED_17_Ch_PRE <- NA
combodemo3$SCARED_18_Ch_PRE <- NA
combodemo3$SCARED_19_Ch_PRE <- NA
combodemo3$SCARED_20_Ch_PRE <- NA
combodemo3$SCARED_21_Ch_PRE <- NA
combodemo3$SCARED_22_Ch_PRE <- NA
combodemo3$SCARED_23_Ch_PRE <- NA
combodemo3$SCARED_24_Ch_PRE <- NA
combodemo3$SCARED_25_Ch_PRE <- NA
combodemo3$SCARED_26_Ch_PRE <- NA
combodemo3$SCARED_27_Ch_PRE <- NA
combodemo3$SCARED_28_Ch_PRE <- NA
combodemo3$SCARED_29_Ch_PRE <- NA
combodemo3$SCARED_30_Ch_PRE <- NA
combodemo3$SCARED_31_Ch_PRE <- NA
combodemo3$SCARED_32_Ch_PRE <- NA
combodemo3$SCARED_33_Ch_PRE <- NA
combodemo3$SCARED_34_Ch_PRE <- NA
combodemo3$SCARED_35_Ch_PRE <- NA
combodemo3$SCARED_36_Ch_PRE <- NA
combodemo3$SCARED_37_Ch_PRE <- NA
combodemo3$SCARED_38_Ch_PRE <- NA
combodemo3$SCARED_39_Ch_PRE <- NA
combodemo3$SCARED_40_Ch_PRE <- NA
combodemo3$SCARED_41_Ch_PRE <- NA

combodemo3$SCARED_total_Ch_PRE <- NA


#renaming while I figure out the scared trawl and merging sheets. easier than re-highlighting all the column creating part
combodemo3_1<-combodemo3


# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for SCARED
# if you get an error like "replacement has length zero" or "number of items to replace is not a multiple of replacement length"
# then check to see which subs still have NA and double check in the excel sheet what sheet its calling.
for (i in 1:length(subListCombo)){
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]=="SCARED CH PRE"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_ch_scared_raw <- df_SCA_CHPR[df_SCA_CHPR$ID == subListCombo[i],c(2:42)]
    native_ch_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE- scaredpr01-scaredpr41"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_ch_scared_raw <- df_CSallPRE[df_CSallPRE$ID == subListCombo[i],c(741:781)]
    native_ch_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]=="SCARED CH PRE - Subthreshold"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_ch_scared_raw <- df_SCA_CHPR_Sub[df_SCA_CHPR_Sub$ID == subListCombo[i],c(4:44)]
    native_ch_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]=="CS REDCAP BACK UP OF DATA - ENG 3.30.21"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_ch_scared_raw <- df_CS_BACK_21[df_CS_BACK_21$ID == subListCombo[i],c(745:785)]
    native_ch_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]=="Redcap_and_nonRedcap_and_status_integrated_viaExcel_PrelimCNS21"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_ch_scared_raw <- df_Red_integ[df_Red_integ$ID == subListCombo[i],c(51:91)]
    native_ch_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]=="CS REDCAP SCAREDCP DATA TOTAL SCORES- scaredpre_sum"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_ch_scared_raw <- NA
    native_ch_scared_scored <- df_CS_SCORES$scaredpre_sum[df_CS_SCORES$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]=="joined_SCARED_AGE_Data- SCAREDCpr"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_ch_scared_raw <- NA
    native_ch_scared_scored <- df_join_SCARED$SCAREDCpr[df_join_SCARED$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]=="PRE_ALL_JL_4.10.14"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_ch_scared_raw <- df_PRE_JL_14[df_PRE_JL_14$ID == subListCombo[i],c(43:83)]
    native_ch_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]=="Nonresponder pre-post-2mo SCARED_full"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_ch_scared_raw <- df_NR_SCA_full[df_NR_SCA_full$ID == subListCombo[i],c(18:58)]
    native_ch_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]=="(SCARED) Child_ACON- Q1-Q41" ){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_ch_scared_raw <- df_SCA_Ch_ACON[df_SCA_Ch_ACON$ID == subListCombo[i],c(3:43)]
    native_ch_scared_scored <- NA
  }
  
  #making sure that NA values in ch-scared-location stay NA. otherwise they fill in with the last value
  if (PREdataOrg$location_child_SCARED[PREdataOrg$Subject == subListCombo[i]]== "NA"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    # doing NA for nonresponders until I can sort out the sub names
    native_ch_scared_raw <- NA
    native_ch_scared_scored <- NA
  }

  #merging native_ch_scared_raw to combodemo3. 
  combodemo3_1[combodemo3_1$subject==subListCombo[i], c(3:43)] <- native_ch_scared_raw
  
  #merging native_ch_scared_scored to combodemo3. 
  combodemo3_1[combodemo3_1$subject==subListCombo[i], 44] <- native_ch_scared_scored
  
} #end of child SCARED raw trawl


#################### Scoring SCARED child ############################

combodemo3_1[combodemo3_1 == "999"] <- NA

# how many people are missing at least one item? 
countScaredNA <- combodemo3_1[, c(1,3:43)]
countScaredNA$numberNA <- rowSums(is.na(combodemo3_1[,3:43]))
table(countScaredNA$numberNA)


combodemo3_1$SCARED_panic_Ch_PRE <- NA
combodemo3_1$SCARED_GAD_Ch_PRE <- NA
combodemo3_1$SCARED_separation_Ch_PRE <- NA
combodemo3_1$SCARED_SAD_Ch_PRE <- NA
combodemo3_1$SCARED_school_Ch_PRE <- NA

# For each subject, calculate its scores for each facet of SCARED
for (i in 1:length(subListCombo)){
  
  # when subject equals subListCombo[i],
  # if the score for SCARED total is NA, then sum across all SCARED columns
  if (is.na(combodemo3_1$SCARED_total_Ch_PRE[combodemo3_1$subject==subListCombo[i]])){
    
    # Anxiety Disorder- total score greater than 25
    SCAREDtotal <- sum(combodemo3_1[combodemo3_1$subject==subListCombo[i], 3:43])
    
    # Panic Disorder or Significant Somatic symptoms- score greater than 7 for 
    # items 1, 6, 9, 12, 15, 18, 19, 22, 24, 27, 30, 34, 38
    # items +2 (for col numbers)
    SCA_panic <- sum(combodemo3_1[combodemo3_1$subject==subListCombo[i], c(3, 8, 11, 14, 17, 20, 21, 24, 26, 29, 32, 36, 40)])
    
    # Generalized Anxiety Disorder- score greater than 9 for
    # items 5, 7, 14, 21, 23, 28, 33, 35, 37
    SCA_GAD <- sum(combodemo3_1[combodemo3_1$subject==subListCombo[i], c(7, 9, 16, 23, 25, 30, 35, 37, 39)])
    
    # Separation Anxiety Disorder- score greater than 5 for
    # items 4, 8, 13, 16, 20, 25, 29, 31
    SCA_separ <- sum(combodemo3_1[combodemo3_1$subject==subListCombo[i], c(6, 10, 15, 18, 22, 27, 31, 33)])
    
    # Social Anxiety Disorder- score greater than 8 for 
    # items 3, 10, 26, 32, 39, 40, 41
    SCA_SAD <- sum(combodemo3_1[combodemo3_1$subject==subListCombo[i], c(5, 12, 28, 34, 41, 42, 43)])
    
    # Significan School Avoidance- score greater than 3 for
    # items 2, 11, 17, 36
    SCA_school <- sum(combodemo3_1[combodemo3_1$subject==subListCombo[i], c(4, 13, 19, 38)])
  }
  
  # if it's already scored, then keep everything as is!
  # otherwise the total, SAD, GAD, etc, fills in with the above scores.
  if(!is.na(combodemo3_1$SCARED_total_Ch_PRE[combodemo3_1$subject==subListCombo[i]])){
    SCAREDtotal <- combodemo3_1[combodemo3_1$subject==subListCombo[i], 44]
    SCA_panic <- NA
    SCA_GAD <- NA
    SCA_separ <- NA
    SCA_SAD <- NA
    SCA_school <- NA
  }
  
  #merging Scared scales to combodemo3. 
  combodemo3_1[combodemo3_1$subject==subListCombo[i], 44] <- SCAREDtotal
  combodemo3_1[combodemo3_1$subject==subListCombo[i], 45] <- SCA_panic
  combodemo3_1[combodemo3_1$subject==subListCombo[i], 46] <- SCA_GAD
  combodemo3_1[combodemo3_1$subject==subListCombo[i], 47] <- SCA_separ
  combodemo3_1[combodemo3_1$subject==subListCombo[i], 48] <- SCA_SAD
  combodemo3_1[combodemo3_1$subject==subListCombo[i], 49] <- SCA_school
  

  # This chunk is if we want to do average scared score so we can use people with some NAs for items
  #   # if the percentage of NAs for the SCARED is <.20, then average across all SCARED columns
  # if (rowSums(is.na(combodemo3_1[combodemo3_1$subject==subListCombo[i], 3:43]))<9){
  #   SCARED_total <- rowMeans(combodemo3_1[combodemo3_1$subject==subListCombo[i], 3:43], na.rm = TRUE)
  # }
    # if the percentage of NAs for SCARED total is >.20, then put NA
}



#################### trawl for SCARED parent data  ############################


# Add columns for child SCARED to combodemo3_1
combodemo3_1$SCARED_01_Par_PRE <- NA
combodemo3_1$SCARED_02_Par_PRE <- NA
combodemo3_1$SCARED_03_Par_PRE <- NA
combodemo3_1$SCARED_04_Par_PRE <- NA
combodemo3_1$SCARED_05_Par_PRE <- NA
combodemo3_1$SCARED_06_Par_PRE <- NA
combodemo3_1$SCARED_07_Par_PRE <- NA
combodemo3_1$SCARED_08_Par_PRE <- NA
combodemo3_1$SCARED_09_Par_PRE <- NA
combodemo3_1$SCARED_10_Par_PRE <- NA
combodemo3_1$SCARED_11_Par_PRE <- NA
combodemo3_1$SCARED_12_Par_PRE <- NA
combodemo3_1$SCARED_13_Par_PRE <- NA
combodemo3_1$SCARED_14_Par_PRE <- NA
combodemo3_1$SCARED_15_Par_PRE <- NA
combodemo3_1$SCARED_16_Par_PRE <- NA
combodemo3_1$SCARED_17_Par_PRE <- NA
combodemo3_1$SCARED_18_Par_PRE <- NA
combodemo3_1$SCARED_19_Par_PRE <- NA
combodemo3_1$SCARED_20_Par_PRE <- NA
combodemo3_1$SCARED_21_Par_PRE <- NA
combodemo3_1$SCARED_22_Par_PRE <- NA
combodemo3_1$SCARED_23_Par_PRE <- NA
combodemo3_1$SCARED_24_Par_PRE <- NA
combodemo3_1$SCARED_25_Par_PRE <- NA
combodemo3_1$SCARED_26_Par_PRE <- NA
combodemo3_1$SCARED_27_Par_PRE <- NA
combodemo3_1$SCARED_28_Par_PRE <- NA
combodemo3_1$SCARED_29_Par_PRE <- NA
combodemo3_1$SCARED_30_Par_PRE <- NA
combodemo3_1$SCARED_31_Par_PRE <- NA
combodemo3_1$SCARED_32_Par_PRE <- NA
combodemo3_1$SCARED_33_Par_PRE <- NA
combodemo3_1$SCARED_34_Par_PRE <- NA
combodemo3_1$SCARED_35_Par_PRE <- NA
combodemo3_1$SCARED_36_Par_PRE <- NA
combodemo3_1$SCARED_37_Par_PRE <- NA
combodemo3_1$SCARED_38_Par_PRE <- NA
combodemo3_1$SCARED_39_Par_PRE <- NA
combodemo3_1$SCARED_40_Par_PRE <- NA
combodemo3_1$SCARED_41_Par_PRE <- NA

combodemo3_1$SCARED_total_Par_PRE <- NA

#renaming bc it's easier than re-highlighting all the column creating part
combodemo4<-combodemo3_1

# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for SCARED
for (i in 1:length(subListCombo)){
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_parent_SCARED[PREdataOrg$Subject == subListCombo[i]]=="SCARED PARENT PRE"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_par_scared_raw <- df_SCA_PA_PRE[df_SCA_PA_PRE$ID == subListCombo[i],c(2:42)]
    native_par_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_parent_SCARED[PREdataOrg$Subject == subListCombo[i]]=="SCARED PARENT PRE-Subthreshold"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_par_scared_raw <- df_SCA_PA_sub[df_SCA_PA_sub$ID == subListCombo[i],c(5:45)]
    native_par_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_parent_SCARED[PREdataOrg$Subject == subListCombo[i]]== "Redcap_and_nonRedcap_and_status_integrated_viaExcel_PrelimCNS21" ){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_par_scared_raw <- df_Red_integ[df_Red_integ$ID == subListCombo[i],c(9:49)]
    native_par_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_parent_SCARED[PREdataOrg$Subject == subListCombo[i]]== "CSallPRE- scaredppr01-scaredppr41"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_par_scared_raw <- df_CSallPRE[df_CSallPRE$ID == subListCombo[i],c(450:490)]
    native_par_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_parent_SCARED[PREdataOrg$Subject == subListCombo[i]]== "CS REDCAP SCAREDCP DATA TOTAL SCORES- scaredppre_sum"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_par_scared_raw <- NA
    native_par_scared_scored <- df_CS_SCORES$scaredppre_sum[df_CS_SCORES$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_parent_SCARED[PREdataOrg$Subject == subListCombo[i]]== "PRE_ALL_JL_4.10.14"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_par_scared_raw <- df_PRE_JL_14[df_PRE_JL_14$ID == subListCombo[i],c(43:83)]
    native_par_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_parent_SCARED[PREdataOrg$Subject == subListCombo[i]]=="Nonresponder pre-post-2mo SCARED_full"){
    # then native_ch_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_par_scared_raw <- df_NR_SCA_full[df_NR_SCA_full$ID == subListCombo[i],c(59:99)]
    native_par_scared_scored <- NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_parent_SCARED[PREdataOrg$Subject == subListCombo[i]]=="(SCARED) Parent_ACON- Q1-Q41"){
    # then native_par_scared is the scores listed on native spreadsheet for scared01:scared41 when the ID equals the current subListCombo ID
    native_par_scared_raw <- df_SCA_Pa_ACON[df_SCA_Pa_ACON$ID == subListCombo[i],c(3:43)]
    native_par_scared_scored <- NA
  }
  
  #making sure that NA values in ch-scared-location stay NA. otherwise they fill in with the last value
  if (PREdataOrg$location_parent_SCARED[PREdataOrg$Subject == subListCombo[i]]== "NA"){
    # then native_age is the age listed on native spreadsheet when the ID equals the current subListCombo ID
    # doing NA for nonresponders until I can sort out the sub names
    native_par_scared_raw <- NA
    native_par_scared_scored <- NA
  }
  
  #merging native_ch_scared_raw to combodemo3. 
  combodemo4[combodemo4$subject==subListCombo[i], c(50:90)] <- native_par_scared_raw
  
  #merging native_ch_scared_scored to combodemo3. 
  combodemo4[combodemo4$subject==subListCombo[i], 91] <- native_par_scared_scored
  
} # end parent SCARED data trawl

#################### Scoring SCARED parent ############################

combodemo4[combodemo4 == "999"] <- NA

# how many people are missing at least one item?
countScaredNA <- combodemo4[, c(1,50:90)]
countScaredNA$numberNA <- rowSums(is.na(combodemo4[,50:90]))
table(countScaredNA$numberNA)


combodemo4$SCARED_panic_Par_PRE <- NA
combodemo4$SCARED_GAD_Par_PRE <- NA
combodemo4$SCARED_separation_Par_PRE <- NA
combodemo4$SCARED_SAD_Par_PRE <- NA
combodemo4$SCARED_school_Par_PRE <- NA

# For each subject, calculate its scores for each facet of SCARED
for (i in 1:length(subListCombo)){
  
  # when subject equals subListCombo[i],
  # if the score for SCARED total is NA, then sum across all SCARED columns
  if (is.na(combodemo4$SCARED_total_Par_PRE[combodemo4$subject==subListCombo[i]])){
    
    # Anxiety Disorder- total score greater than 25
    SCAREDtotal <- sum(combodemo4[combodemo4$subject==subListCombo[i], 50:90])
    
    # Panic Disorder or Significant Somatic symptoms- score greater than 7 for 
    # items 1, 6, 9, 12, 15, 18, 19, 22, 24, 27, 30, 34, 38
    # items +49 (for col numbers)
    SCA_panic <- sum(combodemo4[combodemo4$subject==subListCombo[i], c(50, 55, 58, 61, 64, 67, 68, 71, 73, 76, 79, 83, 87)])
    
    # Generalized Anxiety Disorder- score greater than 9 for
    # items 5, 7, 14, 21, 23, 28, 33, 35, 37
    SCA_GAD <- sum(combodemo4[combodemo4$subject==subListCombo[i], c(54, 56, 63, 70, 72, 77, 82, 84, 86)])
    
    # Separation Anxiety Disorder- score greater than 5 for
    # items 4, 8, 13, 16, 20, 25, 29, 31
    SCA_separ <- sum(combodemo4[combodemo4$subject==subListCombo[i], c(53, 57, 62, 65, 69, 74, 78, 80)])
    
    # Social Anxiety Disorder- score greater than 8 for 
    # items 3, 10, 26, 32, 39, 40, 41
    SCA_SAD <- sum(combodemo4[combodemo4$subject==subListCombo[i], c(52, 59, 75, 81, 88, 89, 90)])
    
    # Significan School Avoidance- score greater than 3 for
    # items 2, 11, 17, 36
    SCA_school <- sum(combodemo4[combodemo4$subject==subListCombo[i], c(51, 60, 66, 85)])
    
  } # end of if not NA, then score loop
  
  # if it's already scored, then keep everything as is!
  # otherwise the total, SAD, GAD, etc, fills in with the above scores.
  if(!is.na(combodemo4$SCARED_total_Par_PRE[combodemo4$subject==subListCombo[i]])){
    SCAREDtotal <- combodemo4[combodemo4$subject==subListCombo[i], 91]
    SCA_panic <- NA
    SCA_GAD <- NA
    SCA_separ <- NA
    SCA_SAD <- NA
    SCA_school <- NA
  }
  
  #merging Scared scales to combodemo4. 
  combodemo4[combodemo4$subject==subListCombo[i], 91] <- SCAREDtotal
  combodemo4[combodemo4$subject==subListCombo[i], 92] <- SCA_panic
  combodemo4[combodemo4$subject==subListCombo[i], 93] <- SCA_GAD
  combodemo4[combodemo4$subject==subListCombo[i], 94] <- SCA_separ
  combodemo4[combodemo4$subject==subListCombo[i], 95] <- SCA_SAD
  combodemo4[combodemo4$subject==subListCombo[i], 96] <- SCA_school 
  
  
  # This chunk is if we want to do average scared score so we can use people with some NAs for items
  #   # if the percentage of NAs for the SCARED is <.20, then average across all SCARED columns
  # if (rowSums(is.na(combodemo4[combodemo4$subject==subListCombo[i], 3:43]))<9){
  #   SCARED_total <- rowMeans(combodemo4[combodemo4$subject==subListCombo[i], 3:43], na.rm = TRUE)
  # }
  # if the percentage of NAs for SCARED total is >.20, then put NA
  
} # end of parent SCARED scoring loop


#################### trawl for gender data ############################

# Add columns for gender to combodemo4
combodemo4$chgender <- NA

#renaming so I can go back while I work on code
combodemo5<-combodemo4

# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for gender
for (i in 1:length(subListCombo)){
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_gender[PREdataOrg$Subject == subListCombo[i]]=="main_dataset"){
    # then native_gender is the scores listed on native spreadsheet for $gender when the ID equals the current subListCombo ID
    native_gender <- df_maind_et$gender[df_maind_et$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_gender[PREdataOrg$Subject == subListCombo[i]]=="SC_CS_Sub_Main dataset latest-gender"){
    # then native_gender is the scores listed on native spreadsheet for $gender when the ID equals the current subListCombo ID
    native_gender <- df_SCCS_late$gender[df_SCCS_late$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_gender[PREdataOrg$Subject == subListCombo[i]]=="datasetCSstatus"){
    # then native_gender is the scores listed on native spreadsheet for $gender when the ID equals the current subListCombo ID
    # doing NA for this bc there's no datadico for this- only numbers and I can't verify that 1=male and 2=female
    native_gender <- NA #df_datas_stat$gender[df_datas_stat$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_gender[PREdataOrg$Subject == subListCombo[i]]=="PARENT MED and ABMT_DX_DEMOS_deidentified-gender"){
    # then native_gender is the scores listed on native spreadsheet for $gender when the ID equals the current subListCombo ID
    native_gender <- df_PARE_deid$gender[df_PARE_deid$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_gender[PREdataOrg$Subject == subListCombo[i]]=="NR ABM (mplus) working 5.27.18- Dsex"){
    # then native_gender is the scores listed on native spreadsheet for $gender when the ID equals the current subListCombo ID
    native_gender <- df_NRABM_18$gender[df_NRABM_18$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_gender[PREdataOrg$Subject == subListCombo[i]]=="nr-controls-demographics: Gender"){
    # then native_gender is the scores listed on native spreadsheet for $gender when the ID equals the current subListCombo ID
    # doing NA for this bc there's no datadico for this- only numbers and I can't verify that 1=male and 2=female
    native_gender <- NA #df_nrcon_demo$gender[df_nrcon_demo$ID == subListCombo[i]]
  }
  
  #making sure that NA values in ch-scared-location stay NA. otherwise they fill in with the last value
  if (PREdataOrg$location_gender[PREdataOrg$Subject == subListCombo[i]]== "NA"){
    native_gender <- NA
  }
  
  #merging native_ch_scared_raw to combodemo3. 
  combodemo5[combodemo5$subject==subListCombo[i], 97] <- native_gender
  
}

#checking why some are being pulled in as character
# sapply(combodemo5$chgender, mode)
# test <- data.frame(combodemo5$subject, combodemo5$chgender)

#writing a csv so I can work on analysis
#write.csv(combodemo5, "~/OneDrive - Florida International University/Research/DDM project/masters-project/masters-data/temp_COLLECTIVE_age_SCARED_gender_v1.csv")


#################### trawl for race data ############################


#renaming so I can go back while I work on code
combodemo6<-combodemo5

# Add columns for race to combodemo6
combodemo6$chrace <- NA


# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for race
for (i in 1:length(subListCombo)){
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]=="SC_CS_Sub_Main dataset latest$childrace"){
    # then native_race is the scores listed on native spreadsheet for $chrace when the ID equals the current subListCombo ID
    native_race <- df_SCCS_late$chrace[df_SCCS_late$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]=="INFO SHEET- chrace"){
    # then native_race is the scores listed on native spreadsheet for $chrace when the ID equals the current subListCombo ID
    native_race <- df_INFO_EET$chrace[df_INFO_EET$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]=="Infosheet(sub)_091514- chrace"){
    # then native_race is the scores listed on native spreadsheet for $chrace when the ID equals the current subListCombo ID
    native_race <- df_Infos_14$chrace[df_Infos_14$ID == subListCombo[i]]
  }
  
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]=="CS REDCap data (infosheet_cdi2_scared_txhx - English (final)-chrace"){
    # then native_race is the scores listed on native spreadsheet for $chrace when the ID equals the current subListCombo ID
    native_race <- df_CS_ENG_final$chrace[df_CS_ENG_final$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE- chrace"){
    # then native_race is the scores listed on native spreadsheet for $chrace when the ID equals the current subListCombo ID
    native_race <- df_CSallPRE$chrace[df_CSallPRE$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]=="CS Spn Project RC Data latest 1.17.22- chrace"){
    # then native_race is the scores listed on native spreadsheet for $chrace when the ID equals the current subListCombo ID
    native_race <- df_CS_Spn_proj$chrace[df_CS_Spn_proj$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]=="CAPP Tracking Log 4.24.22- Child Race"){
    # then native_race is the scores listed on native spreadsheet for $chrace when the ID equals the current subListCombo ID
    native_race <- df_CAPP_track$chrace[df_CAPP_track$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]=="PARENT MED and ABMT_DX_DEMOS_deidentified-chrace"){
    # then native_race is the scores listed on native spreadsheet for $chrace when the ID equals the current subListCombo ID
    native_race <- df_PARE_deid$chrace[df_PARE_deid$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]=="NR ABM (mplus) working 5.27.18- chrace"){
    # then native_race is the scores listed on native spreadsheet for $chrace when the ID equals the current subListCombo ID
    native_race <- df_NRABM_18$chrace[df_NRABM_18$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]=="nr-controls-demographics: Race"){
    # then native_race is the scores listed on native spreadsheet for $chrace when the ID equals the current subListCombo ID
    # doing NA for this bc there's no datadico for this- only numbers and I can't verify that 1=black, 2=white, etc.
    native_race <- NA #df_nrcon_demo$chrace[df_nrcon_demo$ID == subListCombo[i]]
  }
  
  #making sure that NA values in ch-scared-location stay NA. otherwise they fill in with the last value
  if (PREdataOrg$location_race[PREdataOrg$Subject == subListCombo[i]]== "NA"){
    native_race <- NA
  }
  
  # On some sheets (looking at you, df_CS_ENG_final), There are two rows for a subject with different data
  # in each row, preventing me from deleting an empty row. It messes up this part because instead of 
  # native_race being a single value, it's a vector. 
  
  # making a function that says if the variable (x) is a scalar (aka single value and not a vector)
  is.scalar <- function(x) is.atomic(x) && length(x) == 1L
  
  # if native_race is NOT a scalar...
  if (is.scalar(native_race)==FALSE){
    # then... 
    # if the first value in native_race is not NA....
    if(!is.na(native_race[1])){
      # ... then native race gets renamed as the first value in the vector. Otherwise...
      native_race<- as.numeric(native_race[1])}else{
        # ... native race gets renamed as the second value in the vector
        native_race<- as.numeric(native_race[2])
      }
  }
      
  #merging native_race to combodemo6. 
  combodemo6[combodemo6$subject==subListCombo[i], 98] <- native_race
  
}


#################### trawl for ethnicity data  ############################


#renaming so I can go back while I work on code
combodemo7<-combodemo6

# Add columns for ethnicity to combodemo7
combodemo7$chethnic <- NA


# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for ethnicity
for (i in 1:length(subListCombo)){
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]=="SC_CS_Sub_Main dataset latest$childethnicity"){
    # then native_ethnic is the scores listed on native spreadsheet for $chethnic when the ID equals the current subListCombo ID
    native_ethnic <- df_SCCS_late$chethnic[df_SCCS_late$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]=="INFO SHEET- chethnic"){
    # then native_ethnic is the scores listed on native spreadsheet for $chethnic when the ID equals the current subListCombo ID
    native_ethnic <- df_INFO_EET$chethnic[df_INFO_EET$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]=="Infosheet(sub)_091514- chethnic"){
    # then native_ethnic is the scores listed on native spreadsheet for $chethnic when the ID equals the current subListCombo ID
    native_ethnic <- df_Infos_14$chethnic[df_Infos_14$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]=="CS REDCap data (infosheet_cdi2_scared_txhx - English (final)-chethnic"){
    # then native_ethnic is the scores listed on native spreadsheet for $chethnic when the ID equals the current subListCombo ID
    native_ethnic <- df_CS_ENG_final$chethnic[df_CS_ENG_final$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE- chethnic"){
    # then native_ethnic is the scores listed on native spreadsheet for $chethnic when the ID equals the current subListCombo ID
    native_ethnic <- df_CSallPRE$chethnic[df_CSallPRE$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]=="CS Spn Project RC Data latest 1.17.22- chethnic"){
    # then native_ethnic is the scores listed on native spreadsheet for $chethnic when the ID equals the current subListCombo ID
    native_ethnic <- df_CS_Spn_proj$chethnic[df_CS_Spn_proj$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]=="CAPP Tracking Log 4.24.22- Child Ethnicity"){
    # then native_ethnic is the scores listed on native spreadsheet for $chethnic when the ID equals the current subListCombo ID
    native_ethnic <- df_CAPP_track$chethnic[df_CAPP_track$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]=="PARENT MED and ABMT_DX_DEMOS_deidentified-chethnic"){
    # then native_ethnic is the scores listed on native spreadsheet for $chethnic when the ID equals the current subListCombo ID
    native_ethnic <- df_PARE_deid$chethnic[df_PARE_deid$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]=="NR ABM (mplus) working 5.27.18- cheth"){
    # then native_ethnic is the scores listed on native spreadsheet for $chethnic when the ID equals the current subListCombo ID
    native_ethnic <- df_NRABM_18$chethnic[df_NRABM_18$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]=="nr-controls-demographics: Ethnicity"){
    # then native_ethnic is the scores listed on native spreadsheet for $chethnic when the ID equals the current subListCombo ID
    # doing NA for this bc there's no datadico for this- only numbers and I can't verify that 1=african-american, 2= Hispanic/Latino, etc.
    native_ethnic <- NA #df_nrcon_demo$ethnic[df_nrcon_demo$ID == subListCombo[i]]
  }
  
  #making sure that NA values in ch-scared-location stay NA. otherwise they fill in with the last value
  if (PREdataOrg$location_ethnicity[PREdataOrg$Subject == subListCombo[i]]== "NA"){
    native_ethnic <- NA
  }
  
  # On some sheets (looking at you, df_CS_ENG_final), There are two rows for a subject with different data
  # in each row, preventing me from deleting an empty row. It messes up this part because instead of 
  # native_ethnic being a single value, it's a vector. 
  
  # making a function that says if the variable (x) is a scalar (aka single value and not a vector)
  is.scalar <- function(x) is.atomic(x) && length(x) == 1L
  
  # if native_ethnic is NOT a scalar...
  if (is.scalar(native_ethnic)==FALSE){
    # then... 
    # if the first value in native_ethnic is not NA....
    if(!is.na(native_ethnic[1])){
      # ... then native ethnic gets renamed as the first value in the vector. Otherwise...
      native_ethnic<- as.numeric(native_ethnic[1])}else{
        # ... native ethnic gets renamed as the second value in the vector
        native_ethnic<- as.numeric(native_ethnic[2])
      }
  }
  
  #merging native_ethnic to combodemo6. 
  combodemo7[combodemo7$subject==subListCombo[i], 99] <- native_ethnic
  
}


#################### trawl for income data ############################


#renaming so I can go back while I work on code
combodemo8<-combodemo7

# Add columns for income to combodemo8
combodemo8$income <- NA


# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for income
for (i in 1:length(subListCombo)){
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_income[PREdataOrg$Subject == subListCombo[i]]=="SC_CS_Sub_Main dataset latest-income"){
    # then native_income is the scores listed on native spreadsheet for $income when the ID equals the current subListCombo ID
    native_income <- df_SCCS_late$income[df_SCCS_late$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_income[PREdataOrg$Subject == subListCombo[i]]=="SC_CS_Sub_Main dataset latest-income_new"){
    # then native_income is the scores listed on native spreadsheet for $income when the ID equals the current subListCombo ID
    native_income <- df_SCCS_late$income_new[df_SCCS_late$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_income[PREdataOrg$Subject == subListCombo[i]]=="INFO SHEET- income"){
    # then native_income is the scores listed on native spreadsheet for $income when the ID equals the current subListCombo ID
    native_income <- df_INFO_EET$income[df_INFO_EET$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_income[PREdataOrg$Subject == subListCombo[i]]=="Infosheet(sub)_091514- income"){
    # then native_income is the scores listed on native spreadsheet for $income when the ID equals the current subListCombo ID
    native_income <- df_Infos_14$income[df_Infos_14$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_income[PREdataOrg$Subject == subListCombo[i]]=="main_dataset"){
    # then native_income is the scores listed on native spreadsheet for $income when the ID equals the current subListCombo ID
    native_income <- df_maind_et$income[df_maind_et$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_income[PREdataOrg$Subject == subListCombo[i]]=="CAPP Tracking Log-Income"){
    # then native_income is the scores listed on native spreadsheet for $income when the ID equals the current subListCombo ID
    native_income <- df_CAPP_track$income[df_CAPP_track$ID == subListCombo[i]]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_income[PREdataOrg$Subject == subListCombo[i]]=="PARENT MED and ABMT_DX_DEMOS_deidentified-income"){
    # then native_income is the scores listed on native spreadsheet for $income when the ID equals the current subListCombo ID
    native_income <- df_PARE_deid$income[df_PARE_deid$ID == subListCombo[i]]
  }
  
  #making sure that NA values in ch-scared-location stay NA. otherwise they fill in with the last value
  if (PREdataOrg$location_income[PREdataOrg$Subject == subListCombo[i]]== "NA"){
    native_income <- NA
  }
  
  # On some sheets (looking at you, df_CS_ENG_final), There are two rows for a subject with different data
  # in each row, preventing me from deleting an empty row. It messes up this part because instead of 
  # native_income being a single value, it's a vector. 
  
  # making a function that says if the variable (x) is a scalar (aka single value and not a vector)
  is.scalar <- function(x) is.atomic(x) && length(x) == 1L
  
  # if native_income is NOT a scalar...
  if (is.scalar(native_income)==FALSE){
    # then... 
    # if the first value in native_income is not NA....
    if(!is.na(native_income[1])){
      # ... then native income gets renamed as the first value in the vector. Otherwise...
      native_income<- as.numeric(native_income[1])}else{
        # ... native income gets renamed as the second value in the vector
        native_income<- as.numeric(native_income[2])
      }
  }
  
  #merging native_income to combodemo6. 
  combodemo8[combodemo8$subject==subListCombo[i], 100] <- native_income
  
}

# confirming that everything is coded correctly
#income_test <- data.frame(combodemo8$subject, combodemo8$income)


#################### trawl for ACS_child data  ############################

#renaming so I can go back while I work on code
combodemo9<-combodemo8

# Add columns for ACS to combodemo8
combodemo9$ACS_01_Ch_PRE <- NA
combodemo9$ACS_02_Ch_PRE <- NA
combodemo9$ACS_03_Ch_PRE <- NA
combodemo9$ACS_04_Ch_PRE <- NA
combodemo9$ACS_05_Ch_PRE <- NA
combodemo9$ACS_06_Ch_PRE <- NA
combodemo9$ACS_07_Ch_PRE <- NA
combodemo9$ACS_08_Ch_PRE <- NA
combodemo9$ACS_09_Ch_PRE <- NA
combodemo9$ACS_10_Ch_PRE <- NA
combodemo9$ACS_11_Ch_PRE <- NA
combodemo9$ACS_12_Ch_PRE <- NA
combodemo9$ACS_13_Ch_PRE <- NA
combodemo9$ACS_14_Ch_PRE <- NA
combodemo9$ACS_15_Ch_PRE <- NA
combodemo9$ACS_16_Ch_PRE <- NA
combodemo9$ACS_17_Ch_PRE <- NA
combodemo9$ACS_18_Ch_PRE <- NA
combodemo9$ACS_19_Ch_PRE <- NA
combodemo9$ACS_20_Ch_PRE <- NA


#renaming so I can go back while I work on code
combodemo9_1<-combodemo9


# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for ACS_child
for (i in 1:length(subListCombo)){
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ACS_child[PREdataOrg$Subject == subListCombo[i]]=="ACS pre_2020-10-03- ACQ01pre-ACQ20pre"){
    # then native_ACS_child is the scores listed on native spreadsheet for $ACS_child when the ID equals the current subListCombo ID
    native_ch_ACS_raw <- df_ACS_pre_03[df_ACS_pre_03$ID == subListCombo[i],c(2:21)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ACS_child[PREdataOrg$Subject == subListCombo[i]]=="ACS pre_2020-06-20- ACQ01pre-ACQ20pre"){
    # then native_ACS_child is the scores listed on native spreadsheet for $ACS_child when the ID equals the current subListCombo ID
    native_ch_ACS_raw <- df_ACS_pre_20[df_ACS_pre_20$ID == subListCombo[i],c(2:21)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ACS_child[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE- acspr01-acspr20"){
    # then native_ACS_child is the scores listed on native spreadsheet for $ACS_child when the ID equals the current subListCombo ID
    native_ch_ACS_raw <- df_CSallPRE[df_CSallPRE$ID == subListCombo[i],c(569:588)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ACS_child[PREdataOrg$Subject == subListCombo[i]]=="PRE_ALL_JL_4.10.14 PACSC1-PACSC20"){
    # then native_ACS_child is the scores listed on native spreadsheet for $ACS_child when the ID equals the current subListCombo ID
    native_ch_ACS_raw <- df_PRE_JL_14[df_PRE_JL_14$ID == subListCombo[i],c(84:103)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_ACS_child[PREdataOrg$Subject == subListCombo[i]]=="(ACS-S)_ACON- Q1-Q20"){
    # then native_ACS_child is the scores listed on native spreadsheet for $ACS_child when the ID equals the current subListCombo ID
    native_ch_ACS_raw <- df_ACS_ACON[df_ACS_ACON$ID == subListCombo[i],c(3:22)]
  }
  
  #making sure that NA values in ch-scared-location stay NA. otherwise they fill in with the last value
  if (PREdataOrg$location_ACS_child[PREdataOrg$Subject == subListCombo[i]]== "NA"){
    native_ch_ACS_raw <- NA
  }
  

  
  #merging native_ch_scared_raw to combodemo3. 
  combodemo9_1[combodemo9_1$subject==subListCombo[i], c(101:120)] <- native_ch_ACS_raw
  
}

# confirming that everything is coded correctly
#ACS_child_test <- data.frame(combodemo9_1$subject, combodemo9_1[,101:120])


#################### Scoring ACS child ############################

# how many people are missing at least one item? 
countACS_NA <- combodemo9_1[, c(1,101:120)]
countACS_NA$numberNA <- rowSums(is.na(combodemo9_1[,101:120]))
table(countACS_NA$numberNA)

# placeholder while I work on code
combodemo10 <- combodemo9_1

# Add columns for reverse scoring
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
combodemo10$ACS_Rv04_Ch_PRE <- mapvalues(combodemo10$ACS_04_Ch_PRE, from = c("1","2","3","4"), to = c(4,3,2,1))
combodemo10$ACS_Rv05_Ch_PRE <- mapvalues(combodemo10$ACS_05_Ch_PRE, from = c("1","2","3","4"), to = c(4,3,2,1))
combodemo10$ACS_Rv09_Ch_PRE <- mapvalues(combodemo10$ACS_09_Ch_PRE, from = c("1","2","3","4"), to = c(4,3,2,1))
combodemo10$ACS_Rv10_Ch_PRE <- mapvalues(combodemo10$ACS_10_Ch_PRE, from = c("1","2","3","4"), to = c(4,3,2,1))
combodemo10$ACS_Rv13_Ch_PRE <- mapvalues(combodemo10$ACS_13_Ch_PRE, from = c("1","2","3","4"), to = c(4,3,2,1))
combodemo10$ACS_Rv14_Ch_PRE <- mapvalues(combodemo10$ACS_14_Ch_PRE, from = c("1","2","3","4"), to = c(4,3,2,1))
combodemo10$ACS_Rv17_Ch_PRE <- mapvalues(combodemo10$ACS_17_Ch_PRE, from = c("1","2","3","4"), to = c(4,3,2,1))
combodemo10$ACS_Rv18_Ch_PRE <- mapvalues(combodemo10$ACS_18_Ch_PRE, from = c("1","2","3","4"), to = c(4,3,2,1))
combodemo10$ACS_Rv19_Ch_PRE <- mapvalues(combodemo10$ACS_19_Ch_PRE, from = c("1","2","3","4"), to = c(4,3,2,1))
#Just checking that the recode worked
table(combodemo10$ACS_19_Ch_PRE)
table(combodemo10$ACS_Rv19_Ch_PRE)

# Add scored ACS columns
combodemo10$ACS_total_Ch_PRE <- NA
combodemo10$ACS_attnFocus_Ch_PRE <- NA
combodemo10$ACS_attnShift_Ch_PRE <- NA


# For each subject, calculate its scores for each facet of ACS
for (i in 1:length(subListCombo)){
  
  # ACS total- 1, 2, 3, 4(R), 5(R), 6, 7, 8, 9(R), 10(R), 11, 12, 13(R), 14(R), 15, 16, 17(R), 18(R), 19(R), and 20
  ACS_total_Ch_PRE <- sum(combodemo10[combodemo10$subject==subListCombo[i], c(101,102,103,121,122,106,107,108,123,124,111,112,125,126,115,116,127,128,129,120)])
  
  # ACS Attentional Focusing- 1, 2, 3, 4(R), 5(R), 6, 7, 8, and 9(R)
  ACS_attnFocus_Ch_PRE <- sum(combodemo10[combodemo10$subject==subListCombo[i], c(101,102,103,121,122,106,107,108,123)])
  
  # ACS Attentional Shifting- 10(R), 11, 12, 13(R), 14(R), 15, 16, 17(R), 18(R), 19(R), and 20
  ACS_attnShift_Ch_PRE <- sum(combodemo10[combodemo10$subject==subListCombo[i], c(124,111,112,125,126,115,116,127,128,129,120)])
  
  
  #merging Scared scales to combodemo3. 
  combodemo10[combodemo10$subject==subListCombo[i], 130] <- ACS_total_Ch_PRE
  combodemo10[combodemo10$subject==subListCombo[i], 131] <- ACS_attnFocus_Ch_PRE
  combodemo10[combodemo10$subject==subListCombo[i], 132] <- ACS_attnShift_Ch_PRE
  
}


#################### trawl for CDI_child data  ############################

#renaming so I can go back while I work on code
combodemo11<-combodemo10

# Add columns for CDI to combodemo11

# being more efficient about it this time and doing it in all one go
cols <- c("CDI_version_Ch_PRE","CDI1_01_Ch_PRE","CDI1_02_Ch_PRE","CDI1_03_Ch_PRE","CDI1_04_Ch_PRE","CDI1_05_Ch_PRE",
          "CDI1_06_Ch_PRE","CDI1_07_Ch_PRE","CDI1_08_Ch_PRE","CDI1_09_Ch_PRE","CDI1_10_Ch_PRE",
          "CDI1_11_Ch_PRE","CDI1_12_Ch_PRE","CDI1_13_Ch_PRE","CDI1_14_Ch_PRE","CDI1_15_Ch_PRE",
          "CDI1_16_Ch_PRE","CDI1_17_Ch_PRE","CDI1_18_Ch_PRE","CDI1_19_Ch_PRE","CDI1_20_Ch_PRE",
          "CDI1_21_Ch_PRE","CDI1_22_Ch_PRE","CDI1_23_Ch_PRE","CDI1_24_Ch_PRE","CDI1_25_Ch_PRE",
          "CDI1_26_Ch_PRE","CDI1_27_Ch_PRE","CDI2_01_Ch_PRE","CDI2_02_Ch_PRE","CDI2_03_Ch_PRE",
          "CDI2_04_Ch_PRE","CDI2_05_Ch_PRE","CDI2_06_Ch_PRE","CDI2_07_Ch_PRE","CDI2_08_Ch_PRE",
          "CDI2_09_Ch_PRE","CDI2_10_Ch_PRE","CDI2_11_Ch_PRE","CDI2_12_Ch_PRE","CDI2_13_Ch_PRE",
          "CDI2_14_Ch_PRE","CDI2_15_Ch_PRE","CDI2_16_Ch_PRE","CDI2_17_Ch_PRE","CDI2_18_Ch_PRE",
          "CDI2_19_Ch_PRE","CDI2_20_Ch_PRE","CDI2_21_Ch_PRE","CDI2_22_Ch_PRE","CDI2_23_Ch_PRE",
          "CDI2_24_Ch_PRE","CDI2_25_Ch_PRE","CDI2_26_Ch_PRE","CDI2_27_Ch_PRE","CDI2_28_Ch_PRE",
          "CDI2_29_Ch_PRE","CDI2_30_Ch_PRE","CDI2_31_Ch_PRE","CDI2_32_Ch_PRE","CDI2_33_Ch_PRE")
combodemo11 <- cbind(combodemo11, setNames( lapply(cols, function(x) x=NA), cols) )


#renaming so I can go back while I work on code
combodemo11_1<-combodemo11



# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for CDI_child
for (i in 1:length(subListCombo)){
  
  # if they did CDI1, then native_CDI_raw is only 27 items
  if(PREdataOrg$CDI_child_version[PREdataOrg$Subject == subListCombo[i]]=="v1, 27 items"){
    
    CDI_version <- "v1"
    
    # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
    if (PREdataOrg$location_CDI_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="cdi pre before REDCAP)"){
      # then native_CDI_child is the scores listed on native spreadsheet for $CDI_child when the ID equals the current subListCombo ID
      native_CDI_raw <- df_cdi_b4_REDCAP[df_cdi_b4_REDCAP$ID == subListCombo[i],c(2:28)]
    }
    
    # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
    if (PREdataOrg$location_CDI_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="CDI PRE"){
      # then native_CDI_child is the scores listed on native spreadsheet for $CDI_child when the ID equals the current subListCombo ID
      native_CDI_raw <- df_CDI_PRE[df_CDI_PRE$ID == subListCombo[i],c(2:28)]
    }
    
    # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
    if (PREdataOrg$location_CDI_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="PRE_ALL_JL_4.10.14- PCDI1-PCDI27"){
      # then native_CDI_child is the scores listed on native spreadsheet for $CDI_child when the ID equals the current subListCombo ID
      native_CDI_raw <- df_PRE_JL_14[df_PRE_JL_14$ID == subListCombo[i],c(2:28)]
    }
    
    # having an issue with IDs with multiple rows in a sheet. e.g., 5417
    # if number of rows in native_CDI_raw is greater than 1, then do ifelse statement
    if(nrow(native_CDI_raw)>1){
      # if row 1 of native_CDI_raw is NA, then native_CDI_raw equals the second row. otherwise,native_CDI_raw equals the first row.
      ifelse(is.na(native_CDI_raw[1,]),native_CDI_raw <- native_CDI_raw[2,], native_CDI_raw <- native_CDI_raw[1,])
    }
    
    #merging native_CDI_raw to combodemo11_1 
    combodemo11_1[combodemo11_1$subject==subListCombo[i], c(133:160)] <- c(CDI_version,native_CDI_raw)
    
  } #end of CDI 1 loop
  
  
  # if they did CDI2, then native_CDI_raw is 33 items
  if(PREdataOrg$CDI_child_version[PREdataOrg$Subject == subListCombo[i]]=="v2, 33 items"){
    
    CDI_version <- "v2"
    
    # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
    if (PREdataOrg$location_CDI_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="CDI2C pre items"){
      # then native_CDI_child is the scores listed on native spreadsheet for $CDI_child when the ID equals the current subListCombo ID
      # this one is funky because the native sheet had the Reverse score columns intermixed so I couldn't just pull in like [1:33]
      native_CDI_raw <- df_CDI2C_items[df_CDI2C_items$ID == subListCombo[i],c(5,6,8,9,10,11,13,15,16,18,19,20,22,23,25,27,28,30,31,32,34,35,36,38,40,41,42,43,44,46,47,49,50)]
    }
    
    # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
    if (PREdataOrg$location_CDI_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="CDI2 Child pretx (Predated REDCap)"){
      # then native_CDI_child is the scores listed on native spreadsheet for $CDI_child when the ID equals the current subListCombo ID
      native_CDI_raw <- df_CDI2_pretx_REDCap[df_CDI2_pretx_REDCap$ID == subListCombo[i],c(2:34)]
    }
    
    # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
    if (PREdataOrg$location_CDI_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE- cdi2cpr01-cdi2cpr33"){
      # then native_CDI_child is the scores listed on native spreadsheet for $CDI_child when the ID equals the current subListCombo ID
      native_CDI_raw <- df_CSallPRE[df_CSallPRE$ID == subListCombo[i],c(634:666)]
    }
    
    # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
    if (PREdataOrg$location_CDI_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="CS REDCap data (infosheet_cdi2_scared_txhx - English (final)-cdi2cpr01-cdi2cpr33"){
      # then native_CDI_child is the scores listed on native spreadsheet for $CDI_child when the ID equals the current subListCombo ID
      native_CDI_raw <- df_CS_ENG_final[df_CS_ENG_final$ID == subListCombo[i],c(140:172)]
    }
    
    # having an issue with IDs with multiple rows in a sheet. e.g., 5417
    # if number of rows in native_CDI_raw is greater than 1, then do ifelse statement
    if(nrow(native_CDI_raw)>1){
      # if row 1 of native_CDI_raw is NA, then native_CDI_raw equals the second row. otherwise,native_CDI_raw equals the first row.
      ifelse(is.na(native_CDI_raw[1,]),native_CDI_raw <- native_CDI_raw[2,], native_CDI_raw <- native_CDI_raw[1,])
    }
    
    #merging native_CDI_raw to combodemo11_1 
    combodemo11_1[combodemo11_1$subject==subListCombo[i], c(133,161:193)] <- c(CDI_version,native_CDI_raw)
    
  } # end of CDI 2 trawl
 

  # if CDI_version is NA, then it stays NA
  if(PREdataOrg$CDI_child_version[PREdataOrg$Subject == subListCombo[i]]== "NA"){
    
    CDI_version <- NA
    
    #making sure that NA values in ch-scared-location stay NA. otherwise they fill in with the last value
    if (PREdataOrg$location_CDI_child_PRE[PREdataOrg$Subject == subListCombo[i]]== "NA"){
      native_CDI_raw <- NA
    }
    
    #merging native_CDI_raw to combodemo11_1 
    combodemo11_1[combodemo11_1$subject==subListCombo[i], c(133:193)] <- c(native_CDI_raw)
    
  }
  
} # end of trawl
# confirming that everything is coded correctly
#CDI_test <- data.frame(combodemo11_1$subject, combodemo11_1[,133:166])




#################### Scoring for CDI_child ############################

# # how many people are missing at least one item? 
# countCDI_NA <- combodemo11_1[, c(1,133:166)]
# countCDI_NA$numberNA <- rowSums(is.na(combodemo11_1[,133:166]))
# table(countCDI_NA$numberNA)


# placeholder while I work on code
combodemo12 <- combodemo11_1

# Add columns for reverse scoring
# This uses two lists to recode the values from the first list into the second. Needs library(plyr)
# CDI 1 rv score 2, 5, 7, 8, 10, 11, 13, 15, 16, 18, 21, 24, 25
combodemo12$CDI1_Rv02_Ch_PRE <- mapvalues(combodemo12$CDI1_02_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 194
combodemo12$CDI1_Rv05_Ch_PRE <- mapvalues(combodemo12$CDI1_05_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 195
combodemo12$CDI1_Rv07_Ch_PRE <- mapvalues(combodemo12$CDI1_07_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 196
combodemo12$CDI1_Rv08_Ch_PRE <- mapvalues(combodemo12$CDI1_08_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 197
combodemo12$CDI1_Rv10_Ch_PRE <- mapvalues(combodemo12$CDI1_10_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 198
combodemo12$CDI1_Rv11_Ch_PRE <- mapvalues(combodemo12$CDI1_11_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 199
combodemo12$CDI1_Rv13_Ch_PRE <- mapvalues(combodemo12$CDI1_13_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 200
combodemo12$CDI1_Rv15_Ch_PRE <- mapvalues(combodemo12$CDI1_15_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 201
combodemo12$CDI1_Rv16_Ch_PRE <- mapvalues(combodemo12$CDI1_16_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 202
combodemo12$CDI1_Rv18_Ch_PRE <- mapvalues(combodemo12$CDI1_18_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 203
combodemo12$CDI1_Rv21_Ch_PRE <- mapvalues(combodemo12$CDI1_21_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 204
combodemo12$CDI1_Rv24_Ch_PRE <- mapvalues(combodemo12$CDI1_24_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 205
combodemo12$CDI1_Rv25_Ch_PRE <- mapvalues(combodemo12$CDI1_25_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 206



# Hybrid CDI 2 rv score 2, 6, 7, 9, 12, 14, 15, 17, 20, 23, 24, 29, 31 (Original CDI 2 rv score: 2, 6, 7, 9, 10, 12, 14, 15, 17, 20, 23, 24, 26, 27)
combodemo12$CDI2_Rv02_Ch_PRE <- mapvalues(combodemo12$CDI2_02_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 207
combodemo12$CDI2_Rv06_Ch_PRE <- mapvalues(combodemo12$CDI2_06_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 208
combodemo12$CDI2_Rv07_Ch_PRE <- mapvalues(combodemo12$CDI2_07_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 209
combodemo12$CDI2_Rv09_Ch_PRE <- mapvalues(combodemo12$CDI2_09_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 210
combodemo12$CDI2_Rv12_Ch_PRE <- mapvalues(combodemo12$CDI2_12_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 211
combodemo12$CDI2_Rv14_Ch_PRE <- mapvalues(combodemo12$CDI2_14_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 212
combodemo12$CDI2_Rv15_Ch_PRE <- mapvalues(combodemo12$CDI2_15_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 213
combodemo12$CDI2_Rv17_Ch_PRE <- mapvalues(combodemo12$CDI2_17_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 214
combodemo12$CDI2_Rv20_Ch_PRE <- mapvalues(combodemo12$CDI2_20_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 215
combodemo12$CDI2_Rv23_Ch_PRE <- mapvalues(combodemo12$CDI2_23_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 216
combodemo12$CDI2_Rv24_Ch_PRE <- mapvalues(combodemo12$CDI2_24_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 217
combodemo12$CDI2_Rv29_Ch_PRE <- mapvalues(combodemo12$CDI2_29_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 218
combodemo12$CDI2_Rv31_Ch_PRE <- mapvalues(combodemo12$CDI2_31_Ch_PRE, from = c("0","1","2"), to = c(2,1,0)) # 219

# Add scored column
combodemo12$CDI1_total_Ch_PRE <- NA    # col 220

# #Just checking that the recode worked
# table(combodemo12$CDI1_Rv21_Ch_PRE)
# table(combodemo12$CDI1_21_Ch_PRE)
# table(combodemo12$CDI2_Rv02_Ch_PRE)
# table(combodemo12$CDI2_02_Ch_PRE)

# Scoring has to be different from CDI 1 and CDI 2 because the items that they share 
# are not the same number in both
# NOTE: this 33-question CDI 2 is a CAPP hybrid that I'm converting to CDI 1 so I can use all the data.
# So CDI 2 will be scored like it's CDI 1.
for (i in 1:length(subListCombo)){
  
  if(is.na(combodemo12$CDI_version_Ch_PRE[combodemo12$subject == subListCombo[i]])){
    # if version is NA, then total score is NA
    CDI1_total<- NA
  }else{
    # This is for version 1
    if(combodemo12$CDI_version_Ch_PRE[combodemo12$subject == subListCombo[i]]== "v1"){
      # We can use the average score if they have more than 70% of items (at least 19 items) complete (i.e., not NA)
      # if the sum of complete cases (is not NA) in a row for CDI1 columns is greater than 18,...
      ifelse(rowSums(!is.na(combodemo12[combodemo12$subject==subListCombo[i],c(134:160)]))>18,
             # ... then CDI_total equals the mean of the CDI 1 columns times the number of items (27)...
             ######################################################################## 001,02R,003,004,05R,006,07R,08R,009,10R,11R,012,13R,014,15R,16R,017,18R,019,020,21R,022,023,24R,25R,026,027
             CDI_total<- rowMeans(combodemo12[combodemo12$subject==subListCombo[i], c(134,194,136,137,195,139,196,197,142,198,199,145,200,147,201,202,150,203,152,153,204,155,156,205,206,159,160)], na.rm = TRUE)*27, 
             # .... else (the complete cases is below 19) CDI_total is NA
             CDI_total <- NA
      )
    }else{
      # This is for version 2
      if(combodemo12$CDI_version_Ch_PRE[combodemo12$subject == subListCombo[i]]== "v2"){
        # We can use the average score if they have more than 70% of items (at least 19 items) complete (i.e., not NA)
        # if the sum of complete cases (is not NA) in a row for CDI2 columns is greater than 18,...
        ifelse(rowSums(!is.na(combodemo12[combodemo12$subject==subListCombo[i],c(161:164,166:169,171:184,189:193)]))>18,
               # ... then CDI_total equals the mean of the Hybrid CDI 2 columns times the number of items (27)...
               ######################################################################## 001,02R,003,004,06R,07R,008,09R,011,12R,013,14R,15R,016,17R,018,019,20R,021,022,23R,24R,29R,030,31R,032,033
               CDI_total<- rowMeans(combodemo12[combodemo12$subject==subListCombo[i], c(161,207,163,164,208,209,168,210,171,211,173,212,213,176,214,178,179,215,181,182,216,217,218,190,219,192,193)], na.rm = TRUE)*27, 
               # .... else (the complete cases is below 19) CDI_total is NA
               CDI_total <- NA
        )
      }
    }
  }
  
  #merging CDI total to combodemo12. 
  combodemo12[combodemo12$subject==subListCombo[i], 220] <- CDI_total
}

# confirming that everything is coded correctly
# CDI_test <- data.frame(combodemo12$subject, combodemo12[,133:220])
# write.csv(CDI_test, "~/OneDrive - Florida International University/Research/DDM project/masters-project/masters-data/scrap/CDI_test.csv")



#################### trawl for diagnosis PRE data  ############################

#renaming so I can go back while I work on code
combodemo13<-combodemo12

# Add columns for diagnosis to combodemo13
combodemo13$finaldx1_PRE <- NA      # 221
combodemo13$finaldx1int_PRE <- NA
combodemo13$finaldx1sx_PRE <- NA
combodemo13$finaldx2_PRE <- NA
combodemo13$finaldx2int_PRE <- NA
combodemo13$finaldx2sx_PRE <- NA
combodemo13$finaldx3_PRE <- NA
combodemo13$finaldx3int_PRE <- NA
combodemo13$finaldx3sx_PRE <- NA
combodemo13$finaldx4_PRE <- NA
combodemo13$finaldx4int_PRE <- NA
combodemo13$finaldx4sx_PRE <- NA
combodemo13$finaldx5_PRE <- NA
combodemo13$finaldx5int_PRE <- NA
combodemo13$finaldx5sx_PRE <- NA
combodemo13$finaldx6_PRE <- NA
combodemo13$finaldx6int_PRE <- NA
combodemo13$finaldx6sx_PRE <- NA   # 238

# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for diagnosis
for (i in 1:length(subListCombo)){
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_diagnosis[PREdataOrg$Subject == subListCombo[i]]=="SC_CS_Sub_Main dataset latest- finaldx1, finaldx1int, finaldx1sx,  finaldx2, finaldx2int, finaldx2sx,  finaldx3, finaldx3int, finaldx3sx,  finaldx4, finaldx4int, finaldx4sx,  finaldx5, finaldx5int, finaldx5sx,  finaldx6, finaldx6int, finaldx6sx"){
    # then native_diagnosis is the scores listed on native spreadsheet when the ID equals the current subListCombo ID
    native_diagnosis <- df_SCCS_late[df_SCCS_late$ID == subListCombo[i],c(219:236)]
    # having an issue with IDs with multiple rows in a sheet. e.g., 5221
    # if number of rows in native_diagnosis is greater than 1, then do ifelse statement
    if(nrow(native_diagnosis)>1){
      # if row 1 of native_diagnosis is NA, then native_diagnosis equals the second row. otherwise, native_diagnosis equals the first row.
      ifelse(is.na(native_diagnosis[1,]),native_diagnosis <- native_diagnosis[2,], native_diagnosis <- native_diagnosis[1,])
    }
    #merging native_diagnosis to combodemo13. Doing this within the if loop bc one 
    # spreadsheet only has 5 final possible diagnoses (15 cols) but the other has all 6 (18 cols)
    combodemo13[combodemo13$subject==subListCombo[i], c(221:238)] <- native_diagnosis
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_diagnosis[PREdataOrg$Subject == subListCombo[i]]=="PARENT MED and ABMT_DX_DEMOS_deidentified- finaldx1, finaldx1int, finaldx1sx,  finaldx2, finaldx2int, finaldx2sx,  finaldx3, finaldx3int, finaldx3sx,  finaldx4, finaldx4int, finaldx4sx,  finaldx5, finaldx5int, finaldx5sx"){
    # then native_diagnosis is the scores listed on native spreadsheet when the ID equals the current subListCombo ID
    native_diagnosis <- df_PARE_deid[df_PARE_deid$ID == subListCombo[i],c(175:189)]
    # having an issue with IDs with multiple rows in a sheet. e.g., 5221
    # if number of rows in native_diagnosis is greater than 1, then do ifelse statement
    if(nrow(native_diagnosis)>1){
      # if row 1 of native_diagnosis is NA, then native_diagnosis equals the second row. otherwise, native_diagnosis equals the first row.
      ifelse(is.na(native_diagnosis[1,]),native_diagnosis <- native_diagnosis[2,], native_diagnosis <- native_diagnosis[1,])
    }
    #merging native_diagnosis to combodemo13. Doing this within the if loop bc one 
    # spreadsheet only has 5 final possible diagnoses (15 cols) but the other has all 6 (18 cols)
    combodemo13[combodemo13$subject==subListCombo[i], c(221:235)] <- native_diagnosis
  }
  
  # taking this one out because it's unclear which column and it's only two participants that were using this sheet
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  # if (PREdataOrg$location_diagnosis[PREdataOrg$Subject == subListCombo[i]]=="PARENT MED and ABMT_DX_DEMOS_032016- ABMT_preFINALDx1, ABMT_preFINALDx2, ABMT_preFINALDx3, ABMT_preFINALDx4, ABMT_preFINALDx5, ABMT_preFINALDx1sx, ABMT_preFINALDx2sx, ABMT_preFINALDx3sx, ABMT_preFINALDx4sx, ABMT_preFINALDx5sx, ABMT_preFINALDx1I, ABMT_preFINALDx2I, ABMT_preFINALDx3I, ABMT_preFINALDx4I, ABMT_preFINALDx5I"){
  #   # then native_diagnosis is the scores listed on native spreadsheet when the ID equals the current subListCombo ID
  #   # NA bc I'm not sure if the variables are equivalent to the others
  #   native_diagnosis <- NA
  #   #merging native_diagnosis to combodemo13. Doing this within the if loop bc one 
  #   # spreadsheet only has 5 final possible diagnoses (15 cols) but the other has all 6 (18 cols)
  #   combodemo13[combodemo13$subject==subListCombo[i], c(221:235)] <- native_diagnosis
  # }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_diagnosis[PREdataOrg$Subject == subListCombo[i]]=="NR ABM (mplus) working 5.27.18- dx1prNRr, dx1prNR, dx1prNR5"){
    # then native_diagnosis is the scores listed on native spreadsheet when the ID equals the current subListCombo ID
    # NA bc I'm not sure if the variables are equivalent to the others
    native_diagnosis <- NA
    #merging native_diagnosis to combodemo13. Doing this within the if loop bc one 
    # spreadsheet only has 5 final possible diagnoses (15 cols) but the other has all 6 (18 cols)
    combodemo13[combodemo13$subject==subListCombo[i], c(221:235)] <- native_diagnosis
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_diagnosis[PREdataOrg$Subject == subListCombo[i]]=="NA"){
    # then native_diagnosis is NA
    native_diagnosis <- NA
    #merging native_diagnosis to combodemo13. Doing this within the if loop bc one 
    # spreadsheet only has 5 final possible diagnoses (15 cols) but the other has all 6 (18 cols)
    combodemo13[combodemo13$subject==subListCombo[i], c(221:235)] <- native_diagnosis
  }
  
} # end diagnosis data trawl

# confirming that everything is coded correctly
#dx_test <- data.frame(combodemo13$subject, combodemo13[,221:238])


#################### trawl for medication PRE data  ############################

#renaming so I can go back while I work on code
combodemo14<-combodemo13

# Add columns for diagnosis to combodemo14
# being more efficient about it this time and doing it in all one go
medcols <- c("childmedpre","med1_name", "med1_dosage","med1_length",
             "med1_change","med1_stopped","med2_name","med2_dosage",
             "med2_length","med2_change","med2_stopped","med3_name",
             "med3_dosage","med3_length","med3_change","med3_stopped","stim_meds_PRE")
combodemo14 <- cbind(combodemo14, setNames( lapply(medcols, function(x) x=NA), medcols) )

# "childmedpre"[239],"med1_name"[240],"med1_dosage"[241],"med1_length"[242],
# "med1_change"[243],"med1_stopped"[244],"med2_name"[245],"med2_dosage"[246],
# "med2_length"[247],"med2_change"[248],"med2_stopped"[249],"med3_name"[250],
# "med3_dosage"[251],"med3_length"[252],"med3_change"[253],"med3_stopped"[254], stim_meds_PRE [255]


# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for medication
for (i in 1:length(subListCombo)){
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_medication[PREdataOrg$Subject == subListCombo[i]]=="SC_CS_Sub_Main dataset latest$ichildmedpre"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    # df_SCCS_late has childmedpre, med1, med1dosage, med2, med2dosage, med3, med3dosage (573:579)
    # which corresponds to combodemo14 210,211,212,216,217,221,222
    combodemo14[combodemo14$subject==subListCombo[i], c(239,240,241,245,246,250,251)] <- df_SCCS_late[df_SCCS_late$ID == subListCombo[i],c(573,574,575,576,577,578,579)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_medication[PREdataOrg$Subject == subListCombo[i]]=="Infosheet(sub)_091514- childmedpre, med1name, med2name, med3name"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    # df_Infos_14 has all the columns that are in combodemo14
    combodemo14[combodemo14$subject==subListCombo[i], 239:254] <- df_Infos_14[df_Infos_14$ID == subListCombo[i],105:120]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_medication[PREdataOrg$Subject == subListCombo[i]]=="INFO SHEET-childmedpre, med1name, med2name, med3name"){
    # having an issue with IDs with multiple rows in a sheet. e.g., 5368. Reverting to old style of coding for ease of reading it
    native_med <- df_INFO_EET[df_INFO_EET$ID == subListCombo[i],107:122]
    # if number of rows in native_med is greater than 1, then do ifelse statement
    if(nrow(native_med)>1){
      # if row 1, column 1 (childmedpre) of native_med is NA, then native_med equals the second row. otherwise, native_diagnosis equals the first row.
      ifelse(is.na(native_med[1,1]),native_med <- native_med[2,], native_med <- native_med[1,])
    }
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo14[combodemo14$subject==subListCombo[i], 239:254] <- native_med
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_medication[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE- childmedcurr, med1name, childmedcur_2, med2name, childmedcur_3, med3name"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo14[combodemo14$subject==subListCombo[i], 239:254] <- df_CSallPRE[df_CSallPRE$ID == subListCombo[i],c(277:282, 285:289,292:296)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_medication[PREdataOrg$Subject == subListCombo[i]]=="PARENT MED and ABMT_DX_DEMOS_deidentified-childmedpre,med1, med1dosage, med 2, med2dosage, med3, med3dosage"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo14[combodemo14$subject==subListCombo[i], 239:254] <- df_PARE_deid[df_PARE_deid$ID == subListCombo[i],c(17,2,18,3,19,4,20)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_medication[PREdataOrg$Subject == subListCombo[i]]=="NA"){
    # then the medication columns for that subject are NA
    combodemo14[combodemo14$subject==subListCombo[i], 239:254] <- NA
  }
  
} # end of medication trawl

# confirming that everything is coded correctly
#med_test <- data.frame(combodemo14$subject, combodemo14[,239:255])


#################### stim_meds_PRE  ############################
# this is to mark whether or not the child is on stimulants at the PRE timepoint

#renaming so I can go back while I work on code
combodemo15<-combodemo14

# List of common stimulants:
# Adderall, Concerta, Dexedrine, Focalin, Metadate, Methylin, Ritalin, Vyvanse, 
# amphetamine, methylphenidate, dextroamphetamine, dexmethylphenidate, lisdexamfetamine

# This loop is for med1 
# for each subject,
for(i in 1:length(subListCombo)){
    # if childmedpre is yes (1) and not NA, med1_name isn't NA, and med1 hasn't been 
    # stopped (0) and is not NA, then...
    if (!is.na(combodemo15$childmedpre[combodemo15$subject==subListCombo[i]]) &
        combodemo15$childmedpre[combodemo15$subject==subListCombo[i]]==1 &
        !is.na(combodemo15$med1_name[combodemo15$subject==subListCombo[i]]) &
        combodemo15$med1_stopped[combodemo15$subject==subListCombo[i]]== 0 &
        !is.na(combodemo15$med1_stopped[combodemo15$subject==subListCombo[i]])){
      # ... then ifelse
      # if med1_name is any of the following stimulant names, then...
      ifelse(
        combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== " Concerta" |
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Concerta" |
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "concerta" |
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "12" | #coded cencerta from SC_CS df
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Concerta 21mg" |
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Adderall" |
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "ES Citalopram" | #mispelling of Lexapro generic
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Fluoxetine" | #generic prozac
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "prozac" | 
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Prozac" |
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "focalin" |
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Focalin" |
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "LEXIPRO" | #mispelling of lexapro
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Lexapro" | 
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Methyrphenidate" |  # generic methylin, ritalin, metadate. spelled methylphenidate
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "20" | # coded methylphenidate
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Ritalin" |
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Seroplex (french name)" | # lexapro/Escitalopram
          combodemo15$med1_name[combodemo15$subject==subListCombo[i]]== "Vyvance", # misspelling of vyvanse
        #if true, stim_med is 1 for that subject
        combodemo15$stim_meds_PRE[combodemo15$subject==subListCombo[i]] <- 1,
        # if false, stim_med is 0 for that subject
        combodemo15$stim_meds_PRE[combodemo15$subject==subListCombo[i]] <- 0)
    }else{ # if the subject doesn't meet the first 5 qualifications, then...
      # if childmedpre is NA or childmedpre is 1 but also med1name is NA, then stim_med is NA.
      # otherwise, (if childmedpre is zero) then stim_med is zero
      ifelse(is.na(combodemo15$childmedpre[combodemo15$subject==subListCombo[i]]) |
               is.na(combodemo15$med1_name[combodemo15$subject==subListCombo[i]]) &
               combodemo15$childmedpre[combodemo15$subject==subListCombo[i]]==1,
             combodemo15$stim_meds_PRE[combodemo15$subject==subListCombo[i]] <- NA,
             combodemo15$stim_meds_PRE[combodemo15$subject==subListCombo[i]] <- 0)
    } # end of first if loop and subsequent else
} # end of for loop


# This loop is for med2 
# if med 2 is a stimulant, then stim-med is 1. else, stim-med stays the same
# for each subject,
for(i in 1:length(subListCombo)){
  # if childmedpre is yes (1) and not NA, med1_name isn't NA, and med1 hasn't been 
  # stopped (0) and is not NA, then...
  if (!is.na(combodemo15$childmedpre[combodemo15$subject==subListCombo[i]]) &
      combodemo15$childmedpre[combodemo15$subject==subListCombo[i]]==1 &
      !is.na(combodemo15$med2_name[combodemo15$subject==subListCombo[i]]) &
      combodemo15$med2_stopped[combodemo15$subject==subListCombo[i]]== 0 &
      !is.na(combodemo15$med2_stopped[combodemo15$subject==subListCombo[i]])){
    # ... then ifelse
    # if med2_name is any of the following stimulant names, then...
    ifelse(
        combodemo15$med2_name[combodemo15$subject==subListCombo[i]]== "Adderall" |
        combodemo15$med2_name[combodemo15$subject==subListCombo[i]]== "Vyvanse", 
      #if true, stim_med is 1 for that subject
      combodemo15$stim_meds_PRE[combodemo15$subject==subListCombo[i]] <- 1,
      # if false, stim_med stays the same for that subject
      combodemo15$stim_meds_PRE[combodemo15$subject==subListCombo[i]] <- combodemo15$stim_meds_PRE[combodemo15$subject==subListCombo[i]])
  }else{ # if the subject doesn't meet the first 5 qualifications, then...
    # stim meds stays the same
    combodemo15$stim_meds_PRE[combodemo15$subject==subListCombo[i]] <- combodemo15$stim_meds_PRE[combodemo15$subject==subListCombo[i]]
  } # end of first if loop and subsequent else
} # end of for loop


# med3 had no stimulants so I didn't bother coding the loop.

# confirming that everything is coded correctly
#med_test <- data.frame(combodemo15$subject, combodemo15[,239:255])

#################### trawl for prior treatment and med data  ############################

#renaming so I can go back while I work on code
combodemo16<-combodemo15

# Add columns for prior_med_tx to combodemo15
# being more efficient about it this time and doing it in all one go
txcols <- c("chpasttx","date1start","date1end","problem_1","TXtype1",
            "date2start","date2end","problem_2","TXtype2",
            "date3start","date3end","problem_3","TXtype3",
            "date4start","date4end","problem_4","TXtype4")
combodemo16 <- cbind(combodemo16, setNames( lapply(txcols, function(x) x=NA), txcols) )

# column names and their number in the df
# "chpasttx"[256],"date1start"[257],"date1end"[258],"problem_1"[259],"TXtype1"[260],
# "date2start"[261],"date2end"[262],"problem_2"[263],"TXtype2"[264],
# "date3start"[265],"date3end"[266],"problem_3"[267],"TXtype3"[268],
# "date4start"[269],"date4end"[270],"problem_4"[271],"TXtype4"[272]

# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for medication
for (i in 1:length(subListCombo)){
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_prior_tx_and_med[PREdataOrg$Subject == subListCombo[i]]=="INFO SHEET- chpasttx, problem1, txtype1, chpattx_2, problem_2, txtype2, chpattx_3, problem_3, txtype3, chpattx_4, problem_4, txtype4,"){
    # having an issue with IDs with multiple rows in a sheet. e.g., 5368. Reverting to old style of coding for ease of reading it
    native_tx <- df_INFO_EET[df_INFO_EET$ID == subListCombo[i],c(77:81,83:86,88:91,93:96)]
    # if number of rows in native_tx is greater than 1, then do ifelse statement
    if(nrow(native_tx)>1){
      # if row 1 of native_diagnosis is NA, then native_diagnosis equals the second row. otherwise, native_diagnosis equals the first row.
      ifelse(is.na(native_tx[1,1]),native_tx <- native_tx[2,], native_tx <- native_tx[1,])
    }
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo16[combodemo16$subject==subListCombo[i], 256:272] <- native_tx
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_prior_tx_and_med[PREdataOrg$Subject == subListCombo[i]]=="Infosheet(sub)_091514- chpasttx, problem1, txtype1, chpattx_2, problem_2, txtype2, chpattx_3, problem_3, txtype3, chpattx_4, problem_4, txtype4,"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo16
    combodemo16[combodemo16$subject==subListCombo[i], 256:272] <- df_Infos_14[df_Infos_14$ID == subListCombo[i],c(75:79,81:84,86:89,91:94)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_prior_tx_and_med[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE- chpasttx, problem1, txtype1, chpattx_2, problem_2, txtype2, chpattx_3, problem_3, txtype3, chpattx_4, problem_4, txtype4,"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo16
    combodemo16[combodemo16$subject==subListCombo[i], 256:272] <- df_CSallPRE[df_CSallPRE$ID == subListCombo[i],c(243:247,250:253,256:259,262:265)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_prior_tx_and_med[PREdataOrg$Subject == subListCombo[i]]=="PRE_ALL_JL_4.10.14- PTxHistmed1name, PTxHistothertx PTxHistmed1start, PTxHistmed1end, PTxHistmed1prob, PTxHistmed1type, PTxHistmed2start, PTxHistmed2end, PTxHistmed2type, PTxHistmed2prob, PTxHistnewmed, PTxHistmed1dos, PTxHistmed1length, PTxHistmed1changedos, PTxHistmed1stop, PTxHistmed1whenmo, PTxHistmed1whenyr, PTxHistmed2name, PTxHistmed2dos, PTxHistmed2length, PTxHistmed2changedos, PTxHistmed2stop, PTxHistmed2whenmo, PTxHistmed2whenyr"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo16
    # the non-responder collected data didn't line up perfectly with the steppedcare/clinicalservices data, so NA for now
    combodemo16[combodemo16$subject==subListCombo[i], 256:272] <-NA
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_prior_tx_and_med[PREdataOrg$Subject == subListCombo[i]]=="NA"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo16
    # keeping NAs as NA
    combodemo16[combodemo16$subject==subListCombo[i], 256:272] <-NA
  }
}

# confirming that everything is coded correctly
#tx_test <- data.frame(combodemo16$subject, combodemo16[,256:272])

#################### trawl for FASA child  ############################
#renaming so I can go back while I work on code
combodemo17<-combodemo16

# Add columns for prior_med_tx to combodemo15
# being more efficient about it this time and doing it in all one go
cols <- c("FASA_01_ch_PRE","FASA_02_ch_PRE","FASA_03_ch_PRE","FASA_04_ch_PRE",
            "FASA_05_ch_PRE","FASA_06_ch_PRE","FASA_07_ch_PRE","FASA_08_ch_PRE",
            "FASA_09_ch_PRE","FASA_10_ch_PRE","FASA_11_ch_PRE","FASA_12_ch_PRE",
            "FASA_13_ch_PRE","FASA_14_ch_PRE","FASA_15_ch_PRE","FASA_16_ch_PRE")

combodemo17 <- cbind(combodemo17, setNames( lapply(cols, function(x) x=NA), cols) )

# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for medication
for (i in 1:length(subListCombo)){
  
  # FASA child = df_CSallPRE[,c(680:695)] = "CSallPRE_deidentify"
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_FASA_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE_deidentify"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo17[combodemo17$subject==subListCombo[i], c(273:288)] <- df_CSallPRE[df_CSallPRE$ID == subListCombo[i],c(680:695)]
  }
  
  # FASA child PRE = df_pre_fasa_pbi[,c(45:61)] = "Pre fasa_pbi_masc FINAL 5.25.20 merged"
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_FASA_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="Pre fasa_pbi_masc FINAL 5.25.20 merged"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo17[combodemo17$subject==subListCombo[i], c(273:288)] <- df_pre_fasa_pbi[df_pre_fasa_pbi$ID == subListCombo[i],c(45:60)]
  }
  
  # FASA child PRE = df_FASACpre[,c(2:17)] = "FASACpre"
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_FASA_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="FASACpre"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo17[combodemo17$subject==subListCombo[i], c(273:288)] <- df_FASACpre[df_FASACpre$ID == subListCombo[i],c(2:17)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_FASA_child_PRE[PREdataOrg$Subject == subListCombo[i]]=="NA"){
    # then the medication columns for that subject are NA
    combodemo17[combodemo17$subject==subListCombo[i], 273:288] <- NA
  }
  
} # end of FASA child PRE trawl

# confirming that everything is coded correctly
#test <- data.frame(combodemo17$subject, combodemo17[,273:288])

#################### Scoring for FASA child  ############################

#renaming so I can go back while I work on code
combodemo18<-combodemo17

# Add columns
combodemo18$FASA_accomodate_score_ch_PRE <- NA 
combodemo18$FASA_participate_subscore_ch_PRE <- NA 
combodemo18$FASA_modify_subscore_ch_PRE <- NA 
combodemo18$FASA_distress_subscore_ch_PRE <- NA 
combodemo18$FASA_consequence_subscore_ch_PRE <- NA 

# For each subject, calculate its scores for each facet of FASA-CR
for (i in 1:length(subListCombo)){
  
  # Overall Accomodation score- items 1-9 summed
  FASA_accomodate_score_ch_PRE <- sum(combodemo18[combodemo18$subject==subListCombo[i], c(273:281)])
  
  # Participation subscale score- items 1-5 summed
  FASA_participate_subscore_ch_PRE <- sum(combodemo18[combodemo18$subject==subListCombo[i], c(273:277)])
  
  # Modification subscale score- items 6-9 summed
  FASA_modify_subscore_ch_PRE <- sum(combodemo18[combodemo18$subject==subListCombo[i], c(278:281)])
  
  # Distress subscale score- item 10
  FASA_distress_subscore_ch_PRE <- sum(combodemo18[combodemo18$subject==subListCombo[i], 282])
  
  # Consequence subscale score- item 11-13
  FASA_consequence_subscore_ch_PRE <- sum(combodemo18[combodemo18$subject==subListCombo[i], c(283:285)])
  
  
  #merging Scared scales to combodemo3. 
  combodemo18[combodemo18$subject==subListCombo[i], 289] <- FASA_accomodate_score_ch_PRE
  combodemo18[combodemo18$subject==subListCombo[i], 290] <- FASA_participate_subscore_ch_PRE
  combodemo18[combodemo18$subject==subListCombo[i], 291] <- FASA_modify_subscore_ch_PRE
  combodemo18[combodemo18$subject==subListCombo[i], 292] <- FASA_distress_subscore_ch_PRE
  combodemo18[combodemo18$subject==subListCombo[i], 293] <- FASA_consequence_subscore_ch_PRE
  
}

#test <- data.frame(combodemo18$subject, combodemo18[,273:293])

#################### trawl for FASA parent  ############################
#renaming so I can go back while I work on code
combodemo19<-combodemo18

# Add columns for prior_med_tx to combodemo15
# being more efficient about it this time and doing it in all one go
cols <- c("FASA_01_par_PRE","FASA_02_par_PRE","FASA_03_par_PRE","FASA_04_par_PRE",
          "FASA_05_par_PRE","FASA_06_par_PRE","FASA_07_par_PRE","FASA_08_par_PRE",
          "FASA_09_par_PRE","FASA_10_par_PRE","FASA_11_par_PRE","FASA_12_par_PRE",
          "FASA_13_par_PRE")

combodemo19 <- cbind(combodemo19, setNames( lapply(cols, function(x) x=NA), cols) )

# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for medication
for (i in 1:length(subListCombo)){
  
  # FASA parent = [,c(407:419)] = "CSallPRE_deidentify"
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_FASA_parent_PRE[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE_deidentify"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo19[combodemo19$subject==subListCombo[i], c(294:306)] <- df_CSallPRE[df_CSallPRE$ID == subListCombo[i],c(407:419)]
  }
  
  # # FASA parent PRE = [,c(2:14)] = "Pre fasa_pbi_masc FINAL 5.25.20 merged" (13 items)
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_FASA_parent_PRE[PREdataOrg$Subject == subListCombo[i]]=="Pre fasa_pbi_masc FINAL 5.25.20 merged"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo19[combodemo19$subject==subListCombo[i], c(294:306)] <- df_pre_fasa_pbi[df_pre_fasa_pbi$ID == subListCombo[i],c(2:14)]
  }
  
  # FASA parent PRE = df_FASAPpre[,c(2:14)] = "FASAPpre"
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_FASA_parent_PRE[PREdataOrg$Subject == subListCombo[i]]=="FASAPpre"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo19[combodemo19$subject==subListCombo[i], c(294:306)] <- df_FASAPpre[df_FASAPpre$ID == subListCombo[i],c(2:14)]
  }
  
  ## FASA parent PRE = df_FASAPpre_sub[,c(2:14)] = "FASAPpre_subthreshold"
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_FASA_parent_PRE[PREdataOrg$Subject == subListCombo[i]]=="FASAPpre_subthreshold"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo19[combodemo19$subject==subListCombo[i], c(294:306)] <- df_FASAPpre_sub[df_FASAPpre_sub$ID == subListCombo[i],c(2:14)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_FASA_parent_PRE[PREdataOrg$Subject == subListCombo[i]]=="NA"){
    # then the medication columns for that subject are NA
    combodemo19[combodemo19$subject==subListCombo[i], 294:306] <- NA
  }
  
} # end of FASA parent PRE trawl

# confirming that everything is coded correctly
#test <- data.frame(combodemo19$subject, combodemo19[,294:306])


#################### Scoring for FASA parent  ############################

#renaming so I can go back while I work on code
combodemo20<-combodemo19

# Add columns
combodemo20$FASA_accomodate_score_par_PRE <- NA 
combodemo20$FASA_participate_subscore_par_PRE <- NA 
combodemo20$FASA_modify_subscore_par_PRE <- NA 
combodemo20$FASA_distress_subscore_par_PRE <- NA 
combodemo20$FASA_consequence_subscore_par_PRE <- NA 


# For each subject, calculate its scores for each facet of FASA-CR
for (i in 1:length(subListCombo)){
  
  # Overall Accomodation score- items 1-9 summed
  FASA_accomodate_score_par_PRE <- sum(combodemo20[combodemo20$subject==subListCombo[i], c(294:302)])
  
  # Participation subscale score- items 1-5 summed
  FASA_participate_subscore_par_PRE <- sum(combodemo20[combodemo20$subject==subListCombo[i], c(294:298)])
  
  # Modification subscale score- items 6-9 summed
  FASA_modify_subscore_par_PRE <- sum(combodemo20[combodemo20$subject==subListCombo[i], c(299:302)])
  
  # Distress subscale score- item 10
  FASA_distress_subscore_par_PRE <- sum(combodemo20[combodemo20$subject==subListCombo[i], 303])
  
  # Consequence subscale score- item 11-13
  FASA_consequence_subscore_par_PRE <- sum(combodemo20[combodemo20$subject==subListCombo[i], c(304:306)])
  
  
  #merging scales to combodemo
  combodemo20[combodemo20$subject==subListCombo[i], 307] <- FASA_accomodate_score_par_PRE
  combodemo20[combodemo20$subject==subListCombo[i], 308] <- FASA_participate_subscore_par_PRE
  combodemo20[combodemo20$subject==subListCombo[i], 309] <- FASA_modify_subscore_par_PRE
  combodemo20[combodemo20$subject==subListCombo[i], 310] <- FASA_distress_subscore_par_PRE
  combodemo20[combodemo20$subject==subListCombo[i], 311] <- FASA_consequence_subscore_par_PRE
  
}

#test <- data.frame(combodemo20$subject, combodemo20[,294:311])


#################### trawl for CRPBI  ############################

#renaming so I can go back while I work on code
combodemo21<-combodemo20

# Add columns for prior_med_tx to combodemo15
# being more efficient about it this time and doing it in all one go
cols <- c("CRPBI_01_ch_mom_PRE","CRPBI_02_ch_mom_PRE","CRPBI_03_ch_mom_PRE","CRPBI_04_ch_mom_PRE","CRPBI_05_ch_mom_PRE",
          "CRPBI_06_ch_mom_PRE","CRPBI_07_ch_mom_PRE","CRPBI_08_ch_mom_PRE","CRPBI_09_ch_mom_PRE","CRPBI_10_ch_mom_PRE",
          "CRPBI_11_ch_mom_PRE","CRPBI_12_ch_mom_PRE","CRPBI_13_ch_mom_PRE","CRPBI_14_ch_mom_PRE","CRPBI_15_ch_mom_PRE",
          "CRPBI_16_ch_mom_PRE","CRPBI_17_ch_mom_PRE","CRPBI_18_ch_mom_PRE","CRPBI_19_ch_mom_PRE","CRPBI_20_ch_mom_PRE",
          "CRPBI_21_ch_mom_PRE","CRPBI_22_ch_mom_PRE","CRPBI_23_ch_mom_PRE","CRPBI_24_ch_mom_PRE","CRPBI_25_ch_mom_PRE",
          "CRPBI_26_ch_mom_PRE","CRPBI_27_ch_mom_PRE","CRPBI_28_ch_mom_PRE","CRPBI_29_ch_mom_PRE","CRPBI_30_ch_mom_PRE")

combodemo21 <- cbind(combodemo21, setNames( lapply(cols, function(x) x=NA), cols) )

# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for medication
for (i in 1:length(subListCombo)){
  
  # CRPBI child = df_CSallPRE[,c(711:740)] = "CSallPRE_deidentify"
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_CRPBI_PRE[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE_deidentify"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo21[combodemo21$subject==subListCombo[i], c(312:341)] <- df_CSallPRE[df_CSallPRE$ID == subListCombo[i],c(711:740)]
  }
  
  # RPBI ch PRE = df_CRPBImom[,c(2:31)] = "CRPBI (mom) pre" 
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_CRPBI_PRE[PREdataOrg$Subject == subListCombo[i]]=="CRPBI (mom) pre"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo21[combodemo21$subject==subListCombo[i], c(312:341)] <- df_CRPBImom[df_CRPBImom$ID == subListCombo[i],c(2:31)]
  }
  
  # RPBI ch PRE = df_CRPBImom_sub[,c(2:31)] = "CRPBI (mom) pre_subthreshold" 
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_CRPBI_PRE[PREdataOrg$Subject == subListCombo[i]]=="CRPBI (mom) pre_subthreshold"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo21[combodemo21$subject==subListCombo[i], c(312:341)] <- df_CRPBImom_sub[df_CRPBImom_sub$ID == subListCombo[i],c(2:31)]
  }
  
  # RPBI ch PRE = df_pre_fasa_pbi[,c(61:90)] = "Pre fasa_pbi_masc FINAL 5.25.20 merged" 
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_CRPBI_PRE[PREdataOrg$Subject == subListCombo[i]]=="Pre fasa_pbi_masc FINAL 5.25.20 merged"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo21[combodemo21$subject==subListCombo[i], c(312:341)] <- df_pre_fasa_pbi[df_pre_fasa_pbi$ID == subListCombo[i],c(61:90)]
  }

  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_CRPBI_PRE[PREdataOrg$Subject == subListCombo[i]]=="NA"){
    # then the medication columns for that subject are NA
    combodemo21[combodemo21$subject==subListCombo[i], 312:341] <- NA
  }
  
} # end of trawl

# confirming that everything is coded correctly
#test <- data.frame(combodemo21$subject, combodemo21[,312:341])


#################### Scoring for CRPBI  ############################

#renaming so I can go back while I work on code
combodemo22<-combodemo21

# Add columns

combodemo22$CRPBI_Rv15_ch_mom_PRE <- mapvalues(combodemo22$CRPBI_15_ch_mom_PRE, from = c("1","2","3"), to = c(3,2,1))
combodemo22$CRPBI_Rv18_ch_mom_PRE <- mapvalues(combodemo22$CRPBI_18_ch_mom_PRE, from = c("1","2","3"), to = c(3,2,1))
combodemo22$CRPBI_Rv21_ch_mom_PRE <- mapvalues(combodemo22$CRPBI_21_ch_mom_PRE, from = c("1","2","3"), to = c(3,2,1))
combodemo22$CRPBI_Rv24_ch_mom_PRE <- mapvalues(combodemo22$CRPBI_24_ch_mom_PRE, from = c("1","2","3"), to = c(3,2,1))
combodemo22$CRPBI_Rv27_ch_mom_PRE <- mapvalues(combodemo22$CRPBI_27_ch_mom_PRE, from = c("1","2","3"), to = c(3,2,1))
combodemo22$CRPBI_Rv30_ch_mom_PRE <- mapvalues(combodemo22$CRPBI_30_ch_mom_PRE, from = c("1","2","3"), to = c(3,2,1))

# #Just checking that the recode worked
# table(combodemo22$CRPBI_Rv30_ch_mom_PRE)
# table(combodemo22$CRPBI_30_ch_mom_PRE)
# table(combodemo12$CDI2_Rv02_Ch_PRE)
# table(combodemo12$CDI2_02_Ch_PRE)

combodemo22$CRPBI_acceptance_score_ch_mom_PRE <- NA 
combodemo22$CRPBI_psyc_control_score_ch_mom_PRE <- NA 
combodemo22$CRPBI_firm_control_score_ch_mom_PRE <- NA 


# For each subject, calculate its scores for each facet of CRPBI
for (i in 1:length(subListCombo)){
  
  # Acceptance score- 1, 4, 7, 10, 13, 16, 19, 22, 25, 28
  CRPBI_acceptance_score_ch_mom_PRE <- sum(combodemo22[combodemo22$subject==subListCombo[i], c(312,315, 318, 321, 324, 327, 330, 333, 336, 339)])
  
  # Psychological control score- 2, 5, 8, 11, 14, 17, 20, 23, 26, 29
  CRPBI_psyc_control_score_ch_mom_PRE <- sum(combodemo22[combodemo22$subject==subListCombo[i], c(313, 316, 319, 322, 325, 328, 331, 334, 337, 340)])
  
  # Firm control score- 3, 6, 9, 12, Rv15, Rv18, Rv21, Rv24, Rv27, Rv30
  CRPBI_firm_control_score_ch_mom_PRE <- sum(combodemo22[combodemo22$subject==subListCombo[i], c(314, 317, 320, 323,342:347)])
  
  
  #merging scales to combodemo
  combodemo22[combodemo22$subject==subListCombo[i], 348] <- CRPBI_acceptance_score_ch_mom_PRE
  combodemo22[combodemo22$subject==subListCombo[i], 349] <- CRPBI_psyc_control_score_ch_mom_PRE
  combodemo22[combodemo22$subject==subListCombo[i], 350] <- CRPBI_firm_control_score_ch_mom_PRE

  
}

#test <- data.frame(combodemo20$subject, combodemo20[,294:311])


#################### trawl for PRPBI  ############################

#renaming so I can go back while I work on code
combodemo23<-combodemo22

# Add columns for prior_med_tx to combodemo15
# being more efficient about it this time and doing it in all one go
cols <- c("PRPBI_01_par_PRE","PRPBI_02_par_PRE","PRPBI_03_par_PRE","PRPBI_04_par_PRE","PRPBI_05_par_PRE",
          "PRPBI_06_par_PRE","PRPBI_07_par_PRE","PRPBI_08_par_PRE","PRPBI_09_par_PRE","PRPBI_10_par_PRE",
          "PRPBI_11_par_PRE","PRPBI_12_par_PRE","PRPBI_13_par_PRE","PRPBI_14_par_PRE","PRPBI_15_par_PRE",
          "PRPBI_16_par_PRE","PRPBI_17_par_PRE","PRPBI_18_par_PRE","PRPBI_19_par_PRE","PRPBI_20_par_PRE",
          "PRPBI_21_par_PRE","PRPBI_22_par_PRE","PRPBI_23_par_PRE","PRPBI_24_par_PRE","PRPBI_25_par_PRE",
          "PRPBI_26_par_PRE","PRPBI_27_par_PRE","PRPBI_28_par_PRE","PRPBI_29_par_PRE","PRPBI_30_par_PRE")

combodemo23 <- cbind(combodemo23, setNames( lapply(cols, function(x) x=NA), cols) )

# for each subject, trawl thru the location spreadsheet listed in PREdataOrg for medication
for (i in 1:length(subListCombo)){
  
  # PRPBI parent = df_CSallPRE[,c(420:449)] = "CSallPRE_deidentify"
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_PRPBI_PRE[PREdataOrg$Subject == subListCombo[i]]=="CSallPRE_deidentify"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo23[combodemo23$subject==subListCombo[i], c(351:380)] <- df_CSallPRE[df_CSallPRE$ID == subListCombo[i],c(420:449)]
  }
  
  # PRPBI par PRE = df_pre_fasa_pbi[,c(15:44)] = "Pre fasa_pbi_masc FINAL 5.25.20 merged" 
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_PRPBI_PRE[PREdataOrg$Subject == subListCombo[i]]=="Pre fasa_pbi_masc FINAL 5.25.20 merged"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo23[combodemo23$subject==subListCombo[i], c(351:380)] <- df_pre_fasa_pbi[df_pre_fasa_pbi$ID == subListCombo[i],c(15:44)]
  }
  
  # PRPBI par PRE = df_PRPBIpre[,c(2:31)] = "PRPBI pre" 
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_PRPBI_PRE[PREdataOrg$Subject == subListCombo[i]]=="PRPBI pre"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo23[combodemo23$subject==subListCombo[i], c(351:380)] <- df_PRPBIpre[df_PRPBIpre$ID == subListCombo[i],c(2:31)]
  }
  
  # PRPBI par PRE = df_PRPBIpre_sub[,c(2:31)] = "PRPBI pre_subthreshold" 
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_PRPBI_PRE[PREdataOrg$Subject == subListCombo[i]]=="PRPBI pre_subthreshold"){
    # then the values for listed column numbers in the native sheet are added to the corresponding column numbers in combodemo14
    combodemo23[combodemo23$subject==subListCombo[i], c(351:380)] <- df_PRPBIpre_sub[df_PRPBIpre_sub$ID == subListCombo[i],c(2:31)]
  }
  
  # if the location is listed as "[text from PreDataOrg]" for the subject in PREdataOrg, 
  if (PREdataOrg$location_PRPBI_PRE[PREdataOrg$Subject == subListCombo[i]]=="NA"){
    # then the medication columns for that subject are NA
    combodemo23[combodemo23$subject==subListCombo[i], 351:380] <- NA
  }
  
} # end of trawl

# confirming that everything is coded correctly
#test <- data.frame(combodemo23$subject, combodemo23[,351:380])


#################### Scoring for PRPBI  ############################

#renaming so I can go back while I work on code
combodemo24<-combodemo23

# Add columns

combodemo24$PRPBI_Rv15_par_PRE <- mapvalues(combodemo24$PRPBI_15_par_PRE, from = c("1","2","3"), to = c(3,2,1))
combodemo24$PRPBI_Rv18_par_PRE <- mapvalues(combodemo24$PRPBI_18_par_PRE, from = c("1","2","3"), to = c(3,2,1))
combodemo24$PRPBI_Rv21_par_PRE <- mapvalues(combodemo24$PRPBI_21_par_PRE, from = c("1","2","3"), to = c(3,2,1))
combodemo24$PRPBI_Rv24_par_PRE <- mapvalues(combodemo24$PRPBI_24_par_PRE, from = c("1","2","3"), to = c(3,2,1))
combodemo24$PRPBI_Rv27_par_PRE <- mapvalues(combodemo24$PRPBI_27_par_PRE, from = c("1","2","3"), to = c(3,2,1))
combodemo24$PRPBI_Rv30_par_PRE <- mapvalues(combodemo24$PRPBI_30_par_PRE, from = c("1","2","3"), to = c(3,2,1))

# #Just checking that the recode worked
# table(combodemo24$PRPBI_Rv30_par_PRE)
# table(combodemo24$PRPBI_30_par_PRE)
# table(combodemo12$CDI2_Rv02_par_PRE)
# table(combodemo12$CDI2_02_par_PRE)

combodemo24$PRPBI_acceptance_score_par_PRE <- NA 
combodemo24$PRPBI_psyc_control_score_par_PRE <- NA 
combodemo24$PRPBI_firm_control_score_par_PRE <- NA 


# For each subject, calculate its scores for each facet of PRPBI
for (i in 1:length(subListCombo)){
  
  # Acceptance score- 1, 4, 7, 10, 13, 16, 19, 22, 25, 28
  PRPBI_acceptance_score_par_PRE <- sum(combodemo24[combodemo24$subject==subListCombo[i], c(351, 354, 357, 360, 363, 366, 369, 372, 375, 378)])
  
  # Psychological control score- 2, 5, 8, 11, 14, 17, 20, 23, 26, 29
  PRPBI_psyc_control_score_par_PRE <- sum(combodemo24[combodemo24$subject==subListCombo[i], c(352, 355, 358, 361, 364, 367, 370, 373, 376, 379)])
  
  # Firm control score- 3, 6, 9, 12, Rv15, Rv18, Rv21, Rv24, Rv27, Rv30
  PRPBI_firm_control_score_par_PRE <- sum(combodemo24[combodemo24$subject==subListCombo[i], c(353, 356, 359, 362, 381:386)])
  
  
  #merging scales to combodemo
  combodemo24[combodemo24$subject==subListCombo[i], 387] <- PRPBI_acceptance_score_par_PRE
  combodemo24[combodemo24$subject==subListCombo[i], 388] <- PRPBI_psyc_control_score_par_PRE
  combodemo24[combodemo24$subject==subListCombo[i], 389] <- PRPBI_firm_control_score_par_PRE
  
  
}

#test <- data.frame(combodemo20$subject, combodemo20[,294:311])




#################### THE GRAND FINALE  ############################

#write data to disk as a .csv
outPath <- "~/OneDrive - Florida International University/Research/DDM project/masters-project/masters-data/"
fileName <- "COLLECTIVE_PRE_dataset_"
versionName <- "v2-0"
write.csv(combodemo24, paste(outPath,fileName,versionName,".csv",
                                          sep="", collapse=NULL), row.names = FALSE)


