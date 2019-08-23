/* CASE STUDY 1*/
proc import out=back2
datafile="/home/azgodic0/back.txt"
replace;
run;

proc sgscatter data=back2;
title 'Pairwise Scatter Plots of Alertness';
matrix y1 y2 y3 y4;
run; 

proc corr data=back2 plot=matrix cov ;
var y1 y2 y3 y4;
run; 



/* CASE STUDY 2*/
proc import out=ms
datafile=“…/afcr.txt"
replace;
run;

proc means data=ms min max mean median p1 p5 p10 p25 p50 p75 p90 p95 p99 n nmiss;
class group time;
var afcr;
output out=mdata mean=m;
run;
 
proc sort data=ms;
by id group time;
run;

proc glm data=ms;
model afcr=time;
where group=1;
output out=lowessLine1 P=average1;
run;

proc glm data=ms;
model afcr=time;
where group=2;
output out=lowessLine2 P=average2;
run;

proc sgplot data=ms noautolegend;
  title "AFCR Over Time by Treatment Group";
  scatter x=time y=afcr /jitter group=group ;
  lineparm x=0 y=13.13052412 slope=-0.16534701 / LINEATTRS=(Color= "blue") ; /** intercept, slope from the model of time vs acfr for group=1 **/
  lineparm x=0 y=13.36456730 slope=-0.25068902 / LINEATTRS=(Color= "red") ; /** intercept, slope from the model of time vs acfr for group=2 **/
  xaxis grid; yaxis grid;
run;

proc sgplot data=ms noautolegend;
  title "AFCR Over Time by Patient ID";
  series x=time y=afcr / group=id;
  lineparm x=0 y=13.13052412 slope=-0.16534701 / LINEATTRS=(Color= "blue") ; /** intercept, slope from the model of time vs acfr for group=1 **/
  lineparm x=0 y=13.36456730 slope=-0.25068902 / LINEATTRS=(Color= "red") ; /** intercept, slope from the model of time vs acfr for group=2 **/
  xaxis grid; yaxis grid;
run;



/* CASE STUDY 3*/

proc mixed data=ms;
class id;
model afcr= /solution;
random id;
run;
 
proc mixed data=ms;
class id;
model afcr=time /solution;
random id;
run;



/* CASE STUDY 4*/
proc sort data=cholong;
by descending group id time ;
run;

proc mixed data=cholong order=data;
class id group(ref='2') time(ref='0');
model y = group time group*time / s chisq covb corrb;
repeated time / type=un subject=id;
contrast "contrast3" group*time  1  0  0 0 -1  -1 0 0 0 1,
                     group*time  0  1  0 0 -1   0 -1 0 0 1,    
                     group*time  0  0  1 0 -1   0 0 -1 0 1
                     group*time  0  0  0 1 -1   0 0 0 -1 1;
run;

 