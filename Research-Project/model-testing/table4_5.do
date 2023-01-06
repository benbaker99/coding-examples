
/***************************************************************
* Stata program for microeconometrics paper part 2
* using data from ESPN.com play-by-play data
* Author: Ben Baker
***************************************************************/

clear all //clear everything in memory
cd "G:\econ_6217_me\paper\paper_updated"
set scheme s1color //color scheme for graphs (makes the graphs look nicer)
capture log close //close log if there is one open

local path "G:\econ_6217_me\paper\paper_updated"
log using "`path'\table4_5part3.log", replace //create a log file
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


***********
***Playoff bias regressions 
***With regular season matchup means (instead of FE)
***Uses attendance demeaned from playoffs


bysort matchid: egen tod_rs = mean(tod) if playoff==0
bysort matchid: egen tod_rs2 = max(tod_rs)

bysort matchid: egen tond_rs = mean(tond) if playoff==0
bysort matchid: egen tond_rs2 = max(tond_rs)

bysort matchid: egen f_rs = mean(fsh) if playoff==0
bysort matchid: egen f_rs2 = max(f_rs)

bysort matchid: egen fn_rs = mean(fnons) if playoff==0
bysort matchid: egen fn_rs2 = max(fn_rs)

egen pattmean = mean(attend) if playoff==1
gen pdmattend = attend - pattmean
gen pdha = pdmatt*homeg


***create Series Diff (own games won so far in series - opponent games won so far)
gen serdiff = 0
replace serdiff = 3 if homeg==1 & seriesd2==16
replace serdiff = 3 if homeg==0 & seriesd2==1
replace serdiff = 2 if homeg==1 & seriesd2>=14 & seriesd2 <=15
replace serdiff = 2 if homeg==0 & seriesd2>=2 & seriesd2<=3
replace serdiff = 1 if homeg==1 & seriesd2>=11 & seriesd2 <=13
replace serdiff = 1 if homeg==0 & seriesd2>=4 & seriesd2<=6

replace serdiff = -3 if homeg==0 & seriesd2==16
replace serdiff = -3 if homeg==1 & seriesd2==1
replace serdiff = -2 if homeg==0 & seriesd2>=14 & seriesd2 <=15
replace serdiff = -2 if homeg==1 & seriesd2>=2 & seriesd2<=3
replace serdiff = -1 if homeg==0 & seriesd2>=11 & seriesd2 <=13
replace serdiff = -1 if homeg==1 & seriesd2>=4 & seriesd2<=6

gen log_tod = log(tod)
gen log_tond = log(tond)
gen log_fsh = log(fsh)
gen log_fnons = log(fnons)
********Playoff Regression******
***Table 4

/********
*DTOs
********/

xi: quietly poisson tod serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
estat gof
est store T1_p

xi: quietly nbreg tod serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
est store T1_nb

xi: quietly reg tod serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
est store T1_ols

xi: quietly reg log_tod serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
est store T1_ols2

/********
*NTOS
********/

xi: quietly poisson tond serdiff homeg pdmattend pdha sd1-sd4 i.quarter tond_rs2  if playoff==1, robust cluster(date)
estat gof
est store T2_p

xi: quietly nbreg tond serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date) nolog
est store T2_nb

xi: quietly reg tond serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
est store T2_ols

xi: quietly reg log_tond serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
est store T2_ols2

/********
*Shooting Fouls
********/

xi: quietly poisson fsh serdiff homeg pdmattend pdha sd1-sd4 i.quarter f_rs2 if playoff==1, robust cluster(date)
estat gof
est store FS_p

xi: quietly nbreg fsh serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
est store FS_nb

xi: quietly reg fsh serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
est store FS_ols

xi: quietly reg log_fsh serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
est store FS_ols2

/********
*Nonshooting Fouls
********/

xi: quietly poisson fnons serdiff homeg pdmattend pdha sd1-sd4 i.quarter fn_rs2  if playoff==1, robust cluster(date)
estat gof
est store FNS_p

xi: quietly nbreg fnons serdiff homeg pdmattend pdha sd1-sd4 i.quarter fn_rs2  if playoff==1, robust cluster(date)
est store FNS_nb

xi: quietly reg fnons serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
est store FNS_ols

xi: quietly reg log_fnons serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2 if playoff==1, robust cluster(date)
est store FNS_ols2



***interactions of serdif and mins remaining/score diff

gen serdq4 = minu*serdi

gen serds = 0
replace serds = serdi if sd1==0 & sd4==0 

gen serdsq = serds*minu

*win/lose < 11 and min
gen x = 0
replace x = minu if sd1==0 & sd4==0 

label variable serdiff "Series Diff"
label variable pdha "Home x Attendance"
label variable serdq4 "Series Diff x mins remaining"
label variable serds "Series Diff x |Score Diff| <= 10"
label variable serdsq "Series Diff x |Score Diff| <= 10 x mins remaining"
label variable x "|Score Diff| <= 10 x mins remaining"

/********
*DTOs
********/

xi: quietly poisson tod minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter tod_rs2  if playoff==1 ,robust cluster(date)
estat gof
est store T1c_p

xi: quietly nbreg tod minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter tod_rs2  if playoff==1 ,robust cluster(date)
est store T1c_nb

xi: quietly reg tod minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter tod_rs2  if playoff==1 ,robust cluster(date)
est store T1c_ols

xi: quietly reg log_tod minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter tod_rs2  if playoff==1 ,robust cluster(date)
est store T1c_ols2

/********
*NTOs
********/

xi: quietly poisson tond minu serdif serdq4 serds serdsq  x homeg pdha pdmattend sd1-sd4 i.quarter tond_rs2  if playoff==1,robust cluster(date)
estat gof
est store T2c_p

xi: quietly nbreg tond minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter tod_rs2  if playoff==1 ,robust cluster(date)
est store T2c_nb

xi: quietly reg tond minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter tod_rs2  if playoff==1 ,robust cluster(date)
est store T2c_ols

xi: quietly reg log_tond minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter tod_rs2  if playoff==1 ,robust cluster(date)
est store T2c_ols2

/********
*Shooting Fouls
********/

xi: quietly poisson fsh minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter f_rs2 if playoff==1 ,robust cluster(date)
estat gof
est store FSc_p

xi: quietly nbreg fsh minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter f_rs2 if playoff==1 ,robust cluster(date)
est store FSc_nb

xi: quietly reg fsh minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter f_rs2 if playoff==1 ,robust cluster(date)
est store FSc_ols

xi: quietly reg log_fsh minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter f_rs2 if playoff==1 ,robust cluster(date)
est store FSc_ols2

/********
*Nonshooting Fouls
********/

xi: quietly poisson fnons minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter fn_rs2  if playoff==1 ,robust cluster(date)
estat gof
est store FNSc_p

xi: quietly nbreg fnons minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter f_rs2 if playoff==1 ,robust cluster(date)
est store FNSc_nb

xi: quietly reg fnons minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter f_rs2 if playoff==1 ,robust cluster(date)
est store FNSc_ols

xi: quietly reg log_fnons minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter f_rs2 if playoff==1 ,robust cluster(date)
est store FNSc_ols2


est stats _all


//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/
