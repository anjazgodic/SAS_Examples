/* CASE STUDY 1*/
proc mixed data=aids method=reml noclprint=10 covtest;
 class id trt sex;
 model logcd4 = age week week_16 trt*week trt*week_16/ s chisq outpred=yhat;
 random intercept week week_16 / subject=id type=un g gcorr v vcorr;
run;

proc mixed data=aids method=reml noclprint=10 covtest;
 class id trt sex;
 model logcd4 = age week week_16 trt*week trt*week_16/ s chisq outpred=yhat;
 random intercept week week_16 / subject=id type=un g gcorr v vcorr;
  estimate "Change logCD4 in trt=4 <= 16 weeks"  intercept 0 week 1;
  estimate "Change logCD4 in trt=4 > than 16 weeks" intercept 0 week 1 week_16 1;
  estimate "Change logCD4 in trt=2 <= than 16 weeks" intercept 0 week 1 week*trt 0 1 0 0;
  estimate "Change logCD4 in trt=2 > than 16 weeks" intercept 0 week 1 week_16 1 week*trt 0 1 0 0 week_16*trt 0 1 0 0;
  estimate "Change logCD4 in trt=3 <= than 16 weeks"  intercept 0 week 1 week*trt 0 0 1 0;
  estimate "Change logCD4 in trt=3 > than 16 weeks" intercept 0 week 1 week_16 1 week*trt 0 0 1 0 week_16*trt 0 0 1 0;
  estimate "Change logCD4 in trt=1 <= than 16 weeks" intercept 0 week 1 week*trt 1 0 0 0;
  estimate "Change logCD4 in trt=1 > than 16 weeks"  intercept 0 week 1 week_16 1 week*trt 1 0 0 0 week_16*trt 1 0 0 0;
run;

ODS GRAPHICS ON / LOESSOBSMAX = 5050;
proc sgplot data=yhat;
  title "Predicted Average log CD4 Over Time (Week) by Treatment Group from Fixed Effects";
  loess x=week y=Pred /group=trt;
  yaxis label='Predicted Log CD4';
  xaxis label='Time';
run;
ODS GRAPHICS OFF;





/* CASE STUDY 2*/
proc mixed data=fev method=reml noclprint=10 covtest;
 class id;
 model logfev1 = age baseage loght logbht/ s chisq outpm=predm1 vciry;
 random intercept age / subject=id type=un v=1 vcorr g gcorr vc=1 vci=1;
run;

data predm2;
set predm1;
ScaledPred= scaleddep-scaledresid;
run;

proc print data=predm2; where id IN (1) ;run;

data file4id1; 
set predm2; 
where id=1; run;

proc mixed data=fev method=reml noclprint=10 covtest;
 class id;
 model logfev1 = age baseage loght logbht/ s chisq outpm=predm1 vciry;
 random intercept age / subject=id type=un v=1 vcorr g gcorr vc=1 vci=1 ;
 ods output CholV=InvCholV; 
run;

* create transformed covariates;
proc iml;
use InvCholV; 
read all; 
L_inv = Col1 || Col2 || Col3 || Col4 || Col5 || Col6 || Col7; 
use file4id1; 
read all; 
scaled_age = L_inv*age; 
scaled_loght=L_inv*loght; 
scaled_intAge=L_inv*baseage; 
scaled_logintHt=L_inv*logbht; 
create file4 var{scaled_age scaled_loght scaled_logintHt scaled_intAge}; append; close file4;
proc print data=file4; run;
