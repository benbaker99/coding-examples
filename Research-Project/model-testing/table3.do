
/***************************************************************
* Stata program for microeconometrics paper part 1
* using data from ESPN.com play-by-play data
* Author: Ben Baker
***************************************************************/

clear all //clear everything in memory
cd "G:\econ_6217_me\paper\paper_updated"
set scheme s1color //color scheme for graphs (makes the graphs look nicer)
capture log close //close log if there is one open

local path "G:\econ_6217_me\paper\paper_updated"
log using "`path'\table3.log", replace //create a log file
ssc install estout, replace

/***************************************************************
* Load Data
***************************************************************/


**********************
***regressions
***With matchup fixed effects
***standard errors clustered by game (date = game identifier)

use minute_data_final.dta, clear

label variable travel "Travel"
label variable threesec "Three Seconds"
label variable ofoul "Offensive Foul"
label variable ogt "Offensive Goal-Tend"
label variable badpass "Bad Pass"
label variable lostball "Lost Ball"
label variable sclock "Shot Clock"
label variable fpers "Personal Foul"
label variable floose "Loose Ball Foul"
label variable finb "Inbounds Foul"
label variable fclear "Clearing Foul"
label variable faway "Away From Ball Foul"
label variable fshoot "Nonflagrant Foul"
label variable fflag "Flagrant Foul"
label variable homegame "Home"
label variable dmattend "Attendance"
label variable dha "Attendance x Home"
label variable playoff "Playoff"
label variable sd1 "Score Diff < -10"
label variable sd2 "-10 <= Score Diff <= -4"
label variable sd3 "4 <= Score Diff <= 10"
label variable sd4 "10 < Score Diff"

drop if minu <3

****minimize size of data set so can have room for fe poisson regression
keep tele totalmkt tod homeg ha attend sd1-sd4 quarter date fsh fnons tond minu dmattend dha bf ba playoff sd homecd awaycd season fos fs month otod otond score seriesd2 

drop if score==.
quietly xi: reg tod homeg ha attend sd1 sd2 sd3 sd4 i.quarter, robust cluster(date)
keep if e(sample)


*** generate panel identifier (matchup id)
gen teamcd = homecd if homeg==1
replace teamcd = awaycd if homeg==0

gen oteam = homecd if homeg==0
replace oteam = awaycd if homeg==1

gen mtemp = string(season,"%04.0f") + string(teamcd,"%02.0f") + string(oteam,"%02.0f")
egen matchid = group(mtemp)

bysort matchid: egen mct = count(matchid)

xtset matchid

gen hp = homeg*playoff
label variable hp "Playoff x Home"


/********************************************************************
*****Table 3, home and close bias
*****fe poisson without home-quarter, robust SE (need Stata 11)
********************************************************************/

/********
*DTOs
********/

xi: quietly xtpoisson tod homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store T1_p

gen log_tod = log(tod)
xi: quietly xtreg log_tod homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store T1_ols

xi: quietly xtreg tod homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store T1_ols2

/********
*NTOs
********/

xi: quietly xtpoisson tond homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store T2_p

gen log_tond = log(tond)
xi: quietly xtreg log_tond homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store T2_ols

xi: quietly xtreg tond homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store T2_ols2

/********
*Shooting Fouls
********/

xi: quietly xtpoisson fsh homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store FS_p

gen log_fsh = log(fsh)
xi: quietly xtreg log_fsh homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store FS_ols

xi: quietly xtreg fsh homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store FS_ols2

/********
*Nonshooting Fouls
********/

xi: quietly xtpoisson fnons homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store FNS_p

gen log_fnons = log(fnons)
xi: quietly xtreg log_fnons homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store FNS_ols

xi: quietly xtreg fnons homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store FNS_ols2

***gen home-quarter interactions
gen hq = homeg*quarter

gen hq1 = 0
gen hq2 = 0
gen hq3 = 0
gen hq4 = 0
replace hq1 = 1 if hq==1
replace hq2 = 1 if hq==2
replace hq3 = 1 if hq==3
label variable hq1 "Q1 x Home"
label variable hq2 "Q2 x Home"
label variable hq3 "Q3 x Home"


*****fe poisson with home-quarter interactions

/********
*DTOs
********/

xi: quietly xtpoisson tod homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store T1b_p

xi: quietly xtreg log_tod homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store T1b_ols

xi: quietly xtreg tod homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store T1b_ols2

/********
*NTOs
********/

xi: quietly xtpoisson tond homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store T2b_p

xi: quietly xtreg log_tond homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store T2b_ols

xi: quietly xtreg tond homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store T2b_ols2

/********
*Shooting Fouls
********/

xi: quietly xtpoisson fsh homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store FSb_p

xi: quietly xtreg log_fsh homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store FSb_ols

xi: quietly xtreg fsh homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store FSb_ols2

/********
*Nonshooting Fouls
********/

xi: quietly xtpoisson fnons homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store FNSb_p

xi: quietly xtreg log_fnons homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store FNSb_ols

xi: quietly xtreg fnons homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store FNSb_ols2

est stats _all


//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/
