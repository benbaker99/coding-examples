proc import datafile='C:\Users\bakem\Desktop\dsba_6201_bia\logit\CSM.xls'
DBMS=xls out=logit replace;

proc print data=logit;
run;

data logit2;
set logit;
hits = (Ratings>=6.0);
run;

proc print data=logit2;
run;

proc logistic data=logit2 descending;
model hits = Likes Comments Screens;
run;
