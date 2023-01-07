
clear all //clear everything in memory
set scheme s2color //color scheme for graphs (makes the graphs look nicer)
capture log close //close log if there is one open

cd "G:\econ_6219_fe\ps1"
local path "G:\econ_6219_fe\ps1"
log using "`path'\economic_forecasting_ex2.log", replace //create a log file

/***************************************************************
* Load Data
***************************************************************/


************Problem 1
*Part A.
	ssc install freduse, replace
	ssc install tsmktim, replace

	freduse INDPRO
	
*generates a time variable, labeled as datem, that converts the variable daten to be in months, and sets datem to time series data
	gen datem = mofd(daten)
	format datem %tm
	tsset datem

*Time plot of the data for industrial production, changes the graph name, and changes the x-axis and y-axis labels
	tsline INDPRO if tin(1972m1, 2017m12), name(q1_parta) xtitle("Date") ytitle("Output") ///
	title("U.S. Industrial 	Production")
	graph export "`output'q1_parta.wmf", name(graph_parta) as(wmf) replace
	
*Part B.
	clear
	ssc install freduse, replace
	ssc install tsmktim
	
	freduse IPGMFN
	
*generates a time variable, labeled as datem, that converts the variable daten to be in months, and sets datem to time series data
	gen datem = mofd(daten)
	format datem %tm
	tsset datem

*Time plot of the data for industrial production, changes the graph name, and changes the x-axis and y-axis labels
	tsline IPGMFN if tin(1972m1, 2017m12), name(q1_partb) xtitle("Date") ytitle("Output") ///
	title("U.S. Industrial 	Production: Manufacturing (NAICS)")
	graph export "`output'q1_partb.wmf", name(graph_partb) as(wmf) replace
	
*Part C.
	clear
	ssc install freduse, replace
	ssc install tsmktim
	
	freduse INDPRO IPGMFN

*generates a time variable, labeled as datem, that converts the variable daten to be in months, and sets datem to time series data
	gen datem = mofd(daten)
	format datem %tm
	tsset datem
	
	gen ln_indpro = log(INDPRO)
	gen ln_ipgmfn = log(IPGMFN)

*Time plot of the data for industrial production, changes the graph name, and changes the x-axis and y-axis labels
	tsline ln_indpro ln_ipgmfn if tin(1972m1, 2017m12), name(q1_partc) xtitle("Date") ytitle("Log of Output") title("Growth Rate of U.S. Industrial Production")
	graph export "`output'q1_partc.wmf", name(graph_partc) as(wmf) replace

	
************Problem 2
* Monte Carlo simulation
clear all

	program findmean, rclass
		drop _all
		set obs 100
		gen x = rnormal(-1,sqrt(2))
		quietly summarize x, detail
		return scalar mu = r(mean)
		return scalar med = r(p50)
	end

*Part A/B.
	set seed 6219
	simulate xmean=r(mu) xmedian=r(med), reps(5000): findmean
	
	gen smean_bias = xmean+1
	gen smedian_bias = xmedian+1
	summarize, detail

*Part C.
clear all
	
	program findmean, rclass
		drop _all
		set obs 100
		gen x = rnormal(-1,sqrt(2))
		gen y = exp(x)
		quietly summarize y, detail
		return scalar mu = r(mean)
		return scalar med = r(p50)
	end
	
	set seed 6219
	simulate ymean=r(mu) ymedian=r(med), reps(5000): findmean
	
	gen smean_bias2 = ymean-1
	gen smedian_bias2 = ymedian-1
	summarize, detail
	
	
************Problem 3
* Replcating results in http://econbrowser.com/archives/2014/01/on_rsquared_and
clear all

*Part A
use "`path'\SPShiller.dta", clear

	gen time = tm(1871m1) + _n-1
	format time %tm
	tsset time
	rename var1 p
	
//regressing the stock price on last periods stock price
	reg p L1.p if tin(1953m4, 2013m12)
//regressing the change in stock price on last periods stock price
	reg D.p L1.p  if tin(1953m4, 2013m12)

*Part B
clear all

	freduse GS10

	gen datem = mofd(daten)
	format datem %tm
	tsset datem
	rename GS10 r

//regressing the interest rate on the previous three months
	reg r L(1/3).r if tin(1953m4, 2013m12)
//regressing the change in the interest rate on the previous three months
	reg D.r L(1/3).r if tin(1953m4, 2013m12)

*Part C
clear all

//generates y by sampling 100 observations from a N(0,1) distribution
//returns the R2 for (i) a regression of y on the lagged value of y,
//(ii) a regression of the difference in y on the lagged value of y
program findrsq, rclass
	drop _all
	set obs 100
	gen time= _n
	tsset time
	gen y = rnormal(0,1)
	quietly regress y L.y
	return scalar rsq = e(r2)
	quietly regress D.y L.y
	return scalar rsqdiff = e(r2)
end

	set seed 6219
	simulate r2=r(rsq) r2diff=r(rsqdiff), reps(1000): findrsq
	summarize
	
	
//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/