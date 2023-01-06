
/***************************************************************
* Stata program for extension
* using data from 
* Author: Ben Baker
* Latest update: 10/20/2022
***************************************************************/

clear all //clear everything in memory
cd "G:\econ_6901_rm1_2\extension\final_extension"
set scheme s2color //color scheme for graphs (makes the graphs look nicer)
capture log close //close log if there is one open

local path "G:\econ_6901_rm1_2\extension\final_extension"
log using "`path'\updated_extension2.log", replace //create a log file

/***************************************************************
* Load Data
***************************************************************/

use nba-merged2-half,clear

sum htov hpf


gen homefav = slhome<0
tab homefav

gen homediff = -(hpts-apts)
gen favdiff = (hpts-apts)*homefav + (apts-hpts)*(1-homefav)
replace favdiff = -favdiff
sum favdiff

gen slfav = slhome*homefav + slaway*(1-homefav)
sum slfav

* here arbitrary rule of 1.5 times the predicted impacts on fouls and turnovers
* 1.5 can be changed to 1.25 or up to 2?

gen heavyhpf = hpf<20.19-1.5*5.79
tab heavyhpf
gen heavyhtov = htov<13.49-1.5*3.95
tab heavyhtov

gen slhomeheavyhtov = slhome*heavyhtov
gen slhomeheavyhpf = slhome*heavyhpf

sum htov hpf homediff slhome
sum htov hpf homediff slhome if season_year<2008

reg homediff slhome slhomeheavyhtov slhomeheavyhpf
test slhome=1
test slhome+slhomeheavyhtov+slhomeheavyhpf =1

reg homediff slhome slhomeheavyhtov slhomeheavyhpf if season_year<2009
test slhome=1
test slhome+slhomeheavyhtov=1

reg favdiff slfav
test slfav=1
test _b[_cons]=0

test slfav=1
test _b[_cons]=0,accum

reg favdiff slfav if season_year<2008
test slfav=1
test _b[_cons]=0

test slfav=1
test _b[_cons]=0,accum

reg homediff slhome slhomeheavyhtov slhomeheavyhpf
test slhome=1
test slhome+slhomeheavyhtov+slhomeheavyhpf=1

reg homediff slhome slhomeheavyhtov slhomeheavyhpf if season_year<2008
test slhome=1
test slhome+slhomeheavyhtov+slhomeheavyhpf=1

reg homediff slhome slhomeheavyhtov slhomeheavyhpf,r
test slhome=1
test slhome+slhomeheavyhtov+slhomeheavyhpf=1

reg homediff slhome slhomeheavyhtov slhomeheavyhpf if season_year<2008,r
test slhome=1
test slhome+slhomeheavyhtov+slhomeheavyhpf=1


label var slhome "Home Side-Lines"
label var homediff "Home Point Differential"

* some graphs
hist homediff, name(hist_homediff) normal
graph export "hist_homediff.wmf", name(hist_homediff) as(wmf) replace

hist slhome, name(hist_slhome) normal
graph export "hist_slhome.wmf", name(hist_slhome) as(wmf) replace

twoway (scatter homediff slhome) (scatter homediff slhome if heavyhtov, color(green))(lfit homediff slhome, lcolor(red)), name(scat_tov) legend(label(1 "Home Point Differential") label(2 "Heavy Turnover Games")) ytitle("Home Point Differential") title("Figure 1.2")

graph export "scat_tov.wmf", name(scat_tov) as(wmf) replace

twoway (scatter homediff slhome) (scatter homediff slhome if heavyhpf, color(green))(lfit homediff slhome, lcolor(red)), name(scat_pf) legend(label(1 "Home Point Differential") label(2 "Heavy Personal Foul Games")) ytitle("Home Point Differential") title("Figure 1.1")

graph export "scat_pf.wmf", name(scat_pf) as(wmf) replace


//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/


