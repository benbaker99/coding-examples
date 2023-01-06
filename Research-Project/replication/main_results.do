
/***************************************************************
* Stata program for main results of Subperfect Game: Profitable Biases of NBA Referees
* using data from ESPN.com play-by-play data
* Author: Ben Baker
* Latest update: 02/20/2022
***************************************************************/

clear all //clear everything in memory
cd "G:\econ_6901_rm1\replication\sub-perfect game (1)\sub-perfect game\replication_data_code"
set scheme s1color //color scheme for graphs (makes the graphs look nicer)
capture log close //close log if there is one open

local path "G:\econ_6901_rm1\replication\sub-perfect game (1)\sub-perfect game\replication_data_code"
log using "`path'\main_results.log", replace //create a log file
ssc instal estout, replace
ssc instal poisml, replace

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
xi: xtpoisson tod homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
xi: xtpoisson tod homeg dmattend dha playoff hp sd1-sd4 i.quarter, robust fe
xi: xtnbreg tod homeg dmattend dha playoff hp sd1-sd4 i.quarter, robust fe
stop
estat ic
est store T1
countfit tod,prm
xi: quietly xtnbreg tod homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe
estat ic
//est store T1
countfit tod,nbreg
stop
stop
xi: quietly xtpoisson tond homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store T2
xi: quietly xtpoisson fsh homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store FS
xi: quietly xtpoisson fnons homeg dmattend dha playoff hp sd1-sd4 i.quarter, fe vce(robust)
est store FNS


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


*****fe poisson with home-quarter
xi: quietly xtpoisson tod homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store T1b
xi: quietly xtpoisson tond homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store T2b
xi: quietly xtpoisson fsh homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store FSb
xi: quietly xtpoisson fnons homeg dmattend dha playoff hp sd1-sd4 i.quarter hq1 hq2 hq3, fe vce(robust)
est store FNSb


estout T1 T1b T2 T2b FS FSb FNS FNSb, keep ( homegame dmattend dha playoff hp sd1 sd2 sd3 sd4 hq1 hq2 hq3 ) cells(b(star fmt(4)) se(par)) starlevels(* 0.10 ** 0.05 *** 0.01) label title("Table III. Home and Close Bias Poisson Regression Results") mlabels(,none) collabels(,none) mgroups("Discretionary Turnovers" "Nondiscretionary Turnovers" "Shooting Fouls" "Nonshooting Fouls", pattern(1 0 1 0 1 0 1 0)) nonumbers eqlabels(none)

esttab T1 T1b T2 T2b FS FSb FNS FNSb using "table3.csv", csv keep ( homegame dmattend dha playoff hp sd1 sd2 sd3 sd4 hq1 hq2 hq3 ) cells(b(star fmt(4)) se(par)) starlevels(* 0.10 ** 0.05 *** 0.01) label noobs title("Table III. Home and Close Bias Poisson Regression Results") mlabels(,none) collabels(,none) mgroups("Discretionary Turnovers" "Nondiscretionary Turnovers" "Shooting Fouls" "Nonshooting Fouls", pattern(1 0 1 0 1 0 1 0)) nonumbers eqlabels(none) replace

esttab T1 T1b T2 T2b FS FSb FNS FNSb using "table3b.rtf", rtf keep ( homegame dmattend dha playoff hp sd1 sd2 sd3 sd4 hq1 hq2 hq3 ) cells(b(star fmt(4)) se(par)) starlevels(* 0.10 ** 0.05 *** 0.01) label noobs title("Table III. Home and Close Bias Poisson Regression Results") mlabels(,none) collabels(,none) mgroups("Discretionary Turnovers" "Nondiscretionary Turnovers" "Shooting Fouls" "Nonshooting Fouls", pattern(1 0 1 0 1 0 1 0)) nonumbers eqlabels(none) replace


****robustness check for referee - home-score diff interactions
//Not used within the article but mentions part of the results in the close bias section
gen hsd1 = homeg*sd1
gen hsd2 = homeg*sd2
gen hsd3 = homeg*sd3
gen hsd4 = homeg*sd4

xi: quietly xtpoisson tod homeg dha dmattend sd1-sd4 hsd1-hsd4 i.quarter, fe vce(robust)
est store T1b
xi: quietly xtpoisson tond homeg dha dmattend sd1-sd4 i.quarter hsd1-hsd4 , fe vce(robust)
est store T2b
xi: quietly xtpoisson fsh homeg dha dmattend sd1-sd4 i.quarter hsd1-hsd4 , fe vce(robust)
est store FSb
xi: quietly xtpoisson fnons homeg dha dmattend sd1-sd4 i.quarter hsd1-hsd4 , fe vce(robust)
est store FNSb

estout T1b T2b FSb FNSb , keep ( homegame dha sd1 hsd1 sd2 hsd2 sd3 hsd3 sd4  hsd4) style(tex) cells(b(star fmt(4)) se(par)) starlevels(* 0.10 ** 0.05 *** 0.01)

esttab T1b T2b FSb FNSb using "table3supp.rtf", rtf keep ( homegame dha sd1 hsd1 sd2 hsd2 sd3 hsd3 sd4  hsd4 ) cells(b(star fmt(4)) se(par)) starlevels(* 0.10 ** 0.05 *** 0.01) label noobs title("Table III Robustness Check. Home - Score Differenital Interactions") mlabels(,none) collabels(,none) mtitles("Discretionary Turnovers" "Nondiscretionary Turnovers" "Shooting Fouls" "Nonshooting Fouls") nonumbers eqlabels(none) replace


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


********Playoff Regression******
***Table 4
xi: quietly poisml tod serdiff homeg pdmattend pdha sd1-sd4 i.quarter tod_rs2  if playoff==1, robust cluster(date)
est store T1

xi: quietly poisml tond serdiff homeg pdmattend pdha sd1-sd4 i.quarter tond_rs2  if playoff==1, robust cluster(date)
est store T2

xi: quietly poisml fsh serdiff homeg pdmattend pdha sd1-sd4 i.quarter f_rs2 if playoff==1, robust cluster(date)
est store FS

xi: quietly poisml fnons serdiff homeg pdmattend pdha sd1-sd4 i.quarter fn_rs2  if playoff==1, robust cluster(date)
est store FNS


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

xi: quietly poisml tod minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter tod_rs2  if playoff==1 ,robust cluster(date)
est store T1c

xi: quietly poisml tond minu serdif serdq4 serds serdsq  x homeg pdha pdmattend sd1-sd4 i.quarter tond_rs2  if playoff==1,robust cluster(date)
est store T2c

xi: quietly poisml fsh minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter f_rs2 if playoff==1 ,robust cluster(date)
est store FSc

xi: quietly poisml fnons minu serdif serdq4 serds serdsq x homeg pdha pdmattend sd1-sd4 i.quarter fn_rs2  if playoff==1 ,robust cluster(date)
est store FNSc


estout T1 T1c T2 T2c FS FSc FNS FNSc , keep ( serdiff serdq4 serds serdsq homegame pdha sd1 sd2 sd3 sd4 x) style(tex) cells(b(star fmt(3)) se(par)) starlevels(* 0.10 ** 0.05 *** 0.01)

esttab T1 T1c T2 T2c FS FSc FNS FNSc using "table4.csv", csv keep ( serdiff serdq4 serds serdsq homegame pdha sd1 sd2 sd3 sd4 x) cells(b(star fmt(3)) se(par)) starlevels(* 0.10 ** 0.05 *** 0.01) label noobs title("Table IV. Playoff Bias Poisson Regression Results") mlabels(,none) collabels(,none) mgroups("Discretionary Turnovers" "Nondiscretionary Turnovers" "Shooting Fouls" "Nonshooting Fouls", pattern(1 0 1 0 1 0 1 0)) nonumbers eqlabels(none) replace


***************
*** Table 5: Box score playoff analysis
use box_playoff_9-16-10.dta, clear


gen seriesd2 = .
* home down 0-3
replace seriesd2 = 1 if  seriesdu == 10 
* down 1-3
replace seriesd2 = 2 if  seriesdu == 11
* down 0-2
replace seriesd2 = 3 if  seriesdu == 6
* down 2-3
replace seriesd2 = 4 if  seriesdu == 15
* down 1-2
replace seriesd2 = 5 if  seriesdu == 8
* down 0-1
replace seriesd2 = 6 if  seriesdu == 3
* 3-3
replace seriesd2 = 7 if  seriesdu == 16 
* 2-2
replace seriesd2 = 8 if  seriesdu == 12
* 0-0
replace seriesd2 = 9 if  seriesdu == 1
* 1-1
replace seriesd2 = 10 if  seriesdu == 5
* 1-0
replace seriesd2 = 11 if  seriesdu == 2
* 2-1
replace seriesd2 = 12 if  seriesdu == 7
* 3-2
replace seriesd2 = 13 if  seriesdu == 14
* 2-0
replace seriesd2 = 14 if  seriesdu == 4
* 3-1
replace seriesd2 = 15 if  seriesdu == 13
* 3-0
replace seriesd2 = 16 if  seriesdu == 9



gen serdiff = 0
replace serdiff = 3 if home==1 & seriesd2==16
replace serdiff = 3 if home==0 & seriesd2==1
replace serdiff = 2 if home==1 & seriesd2>=14 & seriesd2 <=15
replace serdiff = 2 if home==0 & seriesd2>=2 & seriesd2<=3
replace serdiff = 1 if home==1 & seriesd2>=11 & seriesd2 <=13
replace serdiff = 1 if home==0 & seriesd2>=4 & seriesd2<=6

replace serdiff = -3 if home==0 & seriesd2==16
replace serdiff = -3 if home==1 & seriesd2==1
replace serdiff = -2 if home==0 & seriesd2>=14 & seriesd2 <=15
replace serdiff = -2 if home==1 & seriesd2>=2 & seriesd2<=3
replace serdiff = -1 if home==0 & seriesd2>=11 & seriesd2 <=13
replace serdiff = -1 if home==1 & seriesd2>=4 & seriesd2<=6


xtset matchid

*drop seasons with no regular season data
drop if season==1991 | season==2008

*playoff bias check

xi: quietly poisml tov serdif home to_rs2 if playoff==1, robust 
est store aa
xi: quietly poisson pf serdif home f_rs2 if playoff==1, robust
est store ab
xi: quietly poisson blk serdif home b_rs2 if playoff==1, robust
est store ac
xi: quietly poisson trb serdif home r_rs2 if playoff==1, robust
est store ad
xi: quietly poisson ast serdif home a_rs2 if playoff==1, robust
est store ae
xi: quietly poisson fg serdif home fg_rs2 if playoff==1, robust
est store af

estout aa ab ac ad ae af, keep ( serdiff ) style(tex) cells(b(star fmt(3)) se(par)) starlevels(* 0.10 ** 0.05 *** 0.01)

esttab aa ab ac ad ae af using "table5.csv", csv keep ( serdiff ) cells(b(star fmt(3)) se(par)) starlevels(* 0.10 ** 0.05 *** 0.01) label noobs title("Table V. Playoff Bias Game-Level Sample Poisson Regression Results") mlabels(,none) collabels(,none) mtitles("Turnovers" "Fouls" "Blocks" "Rebounds" "Assists" "Field Goals Made") nonumbers eqlabels(none) replace


//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/
