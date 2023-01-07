
clear all //clear everything in memory
cd "G:\econ_6218_fore\ps3"
set scheme s1color //color scheme for graphs (makes the graphs look nicer)
capture log close //close log if there is one open
* FRED key: 2ca4d398b7664f234eb4d0132c3f34e8

cd "G:\econ_6218_fore\ps3"
local path "G:\econ_6218_fore\ps3"
log using "`path'\economic_forecasting_ex1.log", replace //create a log file

/***************************************************************
* Load Data
***************************************************************/

*Q1
//Import excel file
import excel using "`path'\canemp.xlsx", first cellrange(A1:A137) clear

ssc install freduse, replace
ssc install tsmktim, replace
ssc install dmariano, replace

tsmktim time, start (1961q1)
tsset time

/************
*Part A
************/

tsappend, add(20)
* Running an autoregressive AR(2) model
arima employ, ar(1/2)
est store r1
predict emp_hat1, y dynamic(tq(1995q1))
label variable emp_hat1 "AR2for"

/************
*Part B
************/
* Running a moving average MA(8) model
arima employ, ma(1/8)
est store r2
predict emp_hat2, y dynamic(tq(1995q1))
label variable emp_hat2 "MA8for"

twoway (line emp_hat1 time) (line emp_hat2 time) if time >= tq(1995q1) & time <= tq(1999q4), xtitle("Time") ytitle("Canadian Employment") title("Forcasts of Canadian Employment") name(q1partb)

/************
*Part C
************/
* Running an ARIMA(3,1) model
arima employ, ar(1/3) ma(1)
est store r3
predict emp_hat3, y dynamic(tq(1995q1))
predict emp_hat3_mse, mse dynamic(tq(1995q1))
label variable emp_hat3_mse "ARMA31forMSE"
label variable emp_hat3 "ARMA31for"

scalar z = 1.96
gen ubound = emp_hat3 + z*sqrt(emp_hat3_mse)
gen lbound = emp_hat3 - z*sqrt(emp_hat3_mse)

twoway (line emp_hat3 time, lpattern(solid)) (line ubound time, lpattern(dash)) (line lbound time, lpattern(dash)) if time >= tq(1995q1) & time <= tq(1999q4), name(q1partc) xtitle("Time") ytitle("Canadian Employment") title("Forcasts of Canadian Employment")

/************
*Part D
************/
* Displaying AIC and BIC values to decide which model is best for forecasting
est stats _all


*Q2
clear all

//Import excel file
import excel using "`path'\liquor.xlsx", first cellrange(A1:A337) clear

ssc install freduse, replace
ssc install tsmktim

tsmktim time, start (1967m1)
tsset time

/************
*Part A
************/

//Generating monthly indicator variables
gen m = month(dofm(time))
gen m1 = (m==1)
gen m2 = (m==2)
gen m3 = (m==3)
gen m4 = (m==4)
gen m5 = (m==5)
gen m6 = (m==6)
gen m7 = (m==7)
gen m8 = (m==8)
gen m9 = (m==9)
gen m10 = (m==10)
gen m11 = (m==11)
gen m12 = (m==12)

* Linear regression using intercept, time index, and 11 monthly seasonal indicator variables as regressors and then obtaining one-step ahead forecasts for the last year
reg liquor time m1-m11
est store r1
predict for1 if time > tm(1993m12)
label variable for1 "for1"

/************
*Part B
************/

gen int1 = m1*time
gen int2 = m2*time
gen int3 = m3*time
gen int4 = m4*time
gen int5 = m5*time
gen int6 = m6*time
gen int7 = m7*time
gen int8 = m8*time
gen int9 = m9*time
gen int10 = m10*time
gen int11 = m11*time

* Adding in interactions between monthly seasonal indicators and time
reg liquor time m1-m11 int*
est store r2
predict for2 if time > tm(1993m12)
label variable for2 "for2"

est stats _all

/************
*Part C
************/
* Seasonal differenced arima model
arima DS12.liquor m1-m11 L12.liquor, noconstant
predict for3 if time > tm(1993m12), y
predict for3_liq_res, residuals
label variable for3 "for3"

order liquor for1 for2 for3

twoway (line for1 time if time > tm(1993m12), lcolor(black)) || (line for2 time if time > tm(1993m12), lcolor(blue)) || (line for3 time if time > tm(1993m12), lcolor(red)), name(q2partc) xtitle("Time") ytitle("Liquor Sales") title("Forecasts of Liquor Sales")

/************
*Part D
************/
* Different method to perform a Seasonal ARIMA Model
arima liquor, arima(2,0,0) sarima(2,1,0,12)
predict arima_liq_res, residuals

/************
*Part E
************/
* Autocorrelation plots for the forecast residuals using 40 lags
ac for3_liq_res, lags(40) name(q4parte_c)
ac arima_liq_res, lags(40) name(q4parte_d)


*Q3
clear all

ssc install freduse, replace
ssc install dmariano, replace
import fred VIXCLS WILL5000PRFC, clear
//freduse WILL5000PRFC VIXCLS
rename WILL5000PRFC w
rename VIXCLS v

gen time = _n
tsset time

/************
*Part A
************/
* Computing daily percentage returns on the index
gen w_returns = 100*((w/L.w) -1)

drop if w_returns ==.
drop time

gen time = _n
tsset time

drop if daten > td(31dec2020)

sum w_returns

/************
*Part B
************/

gen sq_w_returns = (w_returns)^2
* Creating exponential smoothing forecast of the squared daily returns
tssmooth exponential x1=sq_w_returns

reg sq_w_returns x1
predict for1

/************
*Part C
************/

gen x2 = (L.v/12)^2

reg sq_w_returns x2
predict for2

/************
*Part D
************/
* Conducting a test of equal predictive accuracy for for1 and for2
* ANSWER: Since the p-value is greater than 0.05 (0.4423 > 0.05), we fail to reject the null hypothesis. This means that the two models are equivalent from a forecasting perspective.
dmariano sq_w_returns for1 for2, maxlag(10) kernel(bartlett)

/************
*Part E
************/
* Conducting tests of forecast encompassing using for1 and for2
* ANSWER: The null hypothesis for these individual tests indicates that the forecasts for one model can encompass those for another model. However, we reject the null hypothesis for both tests and conclude that neither forecast encompasses the other.
reg sq_w_returns for1 for2, noconstant
test (_b[for1]=1) (_b[for2]=0)
test (_b[for1]=0) (_b[for2]=1)


//close the log file	
log close

/***************************************************************
* End of file
***************************************************************/