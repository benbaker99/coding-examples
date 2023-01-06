
/***************************************************************
* Stata program for summary stats
* using data from ESPN.com play-by-play data
* Author: Ben Baker
***************************************************************/

clear all //clear everything in memory
cd "G:\econ_6217_me\paper\paper_updated"
set scheme s1color //color scheme for graphs (makes the graphs look nicer)
capture log close //close log if there is one open

local path "G:\econ_6217_me\paper\paper_updated"
log using "`path'\summarystats.log", replace //create a log file
ssc install estout, replace

/***************************************************************
* Load Data
***************************************************************/

use "`path'\minute_data_final.dta", clear

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

drop if score==.

drop if minu <3

****minimize size of data set so can have room for fe poisson regression
quietly xi: reg tod homeg ha attend sd1 sd2 sd3 sd4 i.quarter, robust cluster(date)
keep if e(sample)

***Table 2: summary stats
bysort homeg: eststo: estpost sum tod travel threesec ofoul ogt tond badpass lostball sclock fnons fpers floose finb fclear faway fsh fshoot fflag

gen winning = 0
replace winning = 1 if sd > 0

bysort winning: eststo: estpost sum tod travel threesec ofoul ogt tond badpass lostball sclock fnons fpers floose finb fclear faway fsh fshoot fflag

esttab est*, label noobs title("Table II. Minute-Level Summary Statistics") mtitle("Away" "Home" "Losing/Tied" "Winning") cells((mean(fmt(4)) sd(par fmt(3)))) nonumbers

esttab est* using "summarystats.csv", csv label noobs title("Table II. Minute-Level Summary Statistics") mtitle("Away" "Home" "Losing/Tied" "Winning") cells((mean(fmt(4)) sd(par fmt(3)))) nonumbers replace

//esttab hadiff* lwdiff* using "diff.csv", csv star(* 0.1 ** 0.05 *** 0.01) label noobs nonumbers replace


//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/
