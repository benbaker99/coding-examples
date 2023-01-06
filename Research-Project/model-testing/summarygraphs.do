
/***************************************************************
* Stata program for sumamry graphs
* using data from ESPN.com play-by-play data
* Author: Ben Baker
***************************************************************/

clear all //clear everything in memory
cd "G:\econ_6217_me\paper\paper_updated"
set scheme s2color //color scheme for graphs
capture log close //close log if there is one open

local path "G:\econ_6217_me\paper\paper_updated"
log using "`path'\summarygraphs.log", replace //create a log file
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

sum tod tond fsh fnons
bysort homeg: sum tod tond fsh fnons

gen winning = 0
replace winning = 1 if sd > 0
bysort winning: sum tod tond fsh fnons

tab tod
tab tond
tab fsh
tab fnons

graph bar (count), over(tod) name(tod) title("Discretionary Turnovers")
graph export "tod.wmf", name(tod) as(wmf) replace

graph bar (count), over(tond) name(tond) title("Non-Discretionary Turnovers")
graph export "tond.wmf", name(tond) as(wmf) replace

graph bar (count), over(fsh) name(fsh) title("Shooting Fouls")
graph export "fsh.wmf", name(fsh) as(wmf) replace

graph bar (count), over(fnons) name(fnons) title("Non-Shooting Fouls")
graph export "fnons.wmf", name(fnons) as(wmf) replace


//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/
