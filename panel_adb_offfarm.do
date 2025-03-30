
**Women's mobile phone and off-farm employment and income**
**Author: Masanori Matsuura**
**2023/01/16**

clear all
set more off
/* Install reghdfe
ssc install reghdfe
* Install ftools (remove program if it existed previously)
ssc install ftools
* Install ivreg2, the core package
cap ado uninstall ivreg2
ssc install ivreg2

*install quantile regression
ssc install xtqreg

* Finally, install this package
cap ado uninstall ivreghdfe
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)

*install quantile regression
ssc install xtqreg
* depict lorenz curve
ssc install lorenz

* Propensity score matching
ssc install psmatch2
*/
global BIHS18Community = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Community"
global BIHS18Female = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Female"
global BIHS18Male = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Male"
global BIHS15 = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2015"
global BIHS12 = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2012"

global table = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\table"
global graph = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\graph"

/*creating a panel dataset*/
use 2012.dta, clear
append using 2015.dta, force
append using 2018.dta, force

/*some cleaning*/
gen lnfrm=log(farmsize) // logarithem of farm size 100 decimal = 0.4 ha
label var lnfrm "Farm size (log)"
recode year (2015=1)(nonm=0), gen(year2015)
label var year2015 "Year 2015"

recode disemp (1=0 "No")(0=1 "Yes"), gen(emp)
label var emp "Empowerment status"
recode dvcode (10 50 55=1)(nonm=0), gen(pov_div) //division dummy
*division
recode dvcode (10=1 "Barisal" )(20=2 "Chattogram") (30=3 "Dhaka") (40=4 "Khulna") (50=5 "Rajshahi") (55=6 "Rangpur") (60=7 "Sylhet"), gen(division)
label var lit_w "Literacy of women"
label var division "Division"
label var aginc "Farm self"
label var frmwage "Farm wage"
label var nonself "Off-farm self"
label var nonwage "Off-farm wage and salary"
label var nonearn "Non-earned"
label var ttinc "Total household income"
label var hdds "Household Dietary Diversity Score"
label var asset "Asset index"
label variable enex_d "Energy expenditure"
label variable elcex_d "Electricity expenditure"
label variable gasex_d "Gas expenditure"
label variable nonex_d "Non-clean engergy expenditure"
replace inc_div=. if inc_div==1
replace shni=. if inc_div==1
replace farmsize=0 if farmsize==.
label var saving "Saving" 
foreach m in mm_p mm_o remi_d saving_d mhlth_d fhlth_d hlth_d edu_d fedu_d medu_d shock e_shock ad_size ch_size leisure_d enex_d elcex_d gasex_d nonex_d dum_el dum_gas magency {
	replace `m'=0 if `m'==.
}
recode remi (0=0)(nonm=1), gen(rem_d)

*mobile phone
label var mobile "Mobile phone"

*create peer effect variables
sort uncode year
by uncode year: egen wmobile_nc=sum(wm) 
by uncode year: egen total_nc_w=count(a01)
gen wm_union=(wmobile_nc-wm)/(total_nc_w-1) //creating peer effect
label var wm_union "Share of households adopting mobile phones in the union"

sort uncode year
by uncode year: egen mobile_nc=sum(m) 
by uncode year: egen total_nc=count(a01)
gen m_union=(mobile_nc-m)/(total_nc-1) //creating peer effect
label var m_union "Share of households adopting mobile phones in the union"

*gender of household head
recode Male (1=0 "no")(0=1 "yes"), gen(female)
label var female "Female household head"

*create village-level average household characteristics
foreach m in female age_hh hh_size schll_hh farmsize asset road {
	bysort a01: egen mn_`m'= mean(`m')
}

** CRE household mean
foreach m in  age_w schll_w wrk_wf masst w_crdt hh_size age_hh schll_hh wrk_hs lwlth asset farmsize town {
	bysort a01: egen m_`m'= mean(`m')
}


*create log
gen lnhdds=log(hdds)
gen lnexp=log(pc_expm_d+1)
gen lnfexp=log(pc_foodxm_d+1)
gen lnnexp=log(pc_nonfxm_d+1)
gen lnrem=log(remi_d+1)
gen lnsaving=log(saving_d+1)
gen lnedu=log(edu_d+1)
gen lnmed=log(medu_d+1)
gen lnfed=log(fedu_d+1)
gen lnhl=log(hlth_d+1)
gen lnmh=log(mhlth_d+1)
gen lnfh=log(fhlth_d+1)
gen lnleisure=log(leisure_d+1)
foreach m in enex_d elcex_d gasex_d nonex_d {
	gen ln_`m'=log(`m'+1)
}
foreach m in ln_enex_d ln_elcex_d ln_gasex_d ln_nonex_d {
	label var `m' " `m' (log)"
}
label var lnsaving "Saving (log)"
label var lnexp "Per capita expenditure (log)"
label var lnfexp "Per capita food expenditure (log)"
label var lnnexp "Per capita non-food expenditure (log)"
label var lnrem "Remittance (log)"
label var lnedu "Educational expenditure (log)"
label var lnmed "Male educational expenditure (log)"
label var lnfed "Female educational expenditure (log)"
label var lnhl "Health expenditure (log)"
label var lnmh "Male health expenditure (log)"
label var lnfh "Female health expenditure (log)"
label var lnleisure "Leisure expenditure (log)"

*off-farm emlpoyment/self employment (dummy)
recode nonwage (0 .=0 "No")(nonm=1 "Yes"), gen("offfarm")
label var offfarm "Off-farm employment (dummy)"
recode nonself (0 .=0 "No")(nonm=1 "Yes"), gen("nonfarmself")
label var nonfarmself "Off-farm self employment (dummy)"
gen offincome=(offrminc+offself)
replace offincome=0 if offincome==.
gen ln_offinc=log(offincome+1)
gen ln_nonwage=log(nonwage+1)
gen ln_nonself=log(nonself+1)

*per capita total income
gen pcti=ttinc/hh_size
label var pcti "Per capita total income"

*log total income, per capita total income, and poverty
gen ln_ttlinc=log(ttinc+1)
gen ln_pctinc=log(pcti+1)
label var ln_ttlinc "Total household income (log)"
label var ln_pctinc "Per capita total income (log)"

gen povertyhead=p190hcgcpi/100
label var povertyhead "Povery headcount (1/0)"

replace off_i_m=0 if off_i_m==.
save panel_adb.dta, replace

*Descriptive statistics
recode year (2012 = 2012)(2015 = 2015)(2018 = 2019),gen(y)
graph bar wm if _est_est1==1, over(y) ytitle("Share of Mobile Phone Ownership") title(Women) scheme(s1mono) blabel(bar, format(%9.2f) size(large))  note("Source: Authors’ calculation from Bangladesh Integrated Household Surveys 2012, 2015, and 2019.")

graph export $graph/phone_women_overtime.jpg, replace
graph save women, replace

graph bar m if _est_est1==1, over(y) ytitle("Share of mobile phone ownership") title(Men) scheme(s1mono) blabel(bar, format(%9.2f) size(large)) 
graph export $graph/phone_men_overtime.jpg, replace
graph save men, replace

graph combine women.gph men.gph, ycommon
graph export $graph/phone_men_overtime.jpg, replace

graph bar off_emp csw_nawrk slr_emp slf_emp trdprd_emp if _est_est1==1, over(y) ytitle("Likelihood of Wife Working Outside Home") scheme(s1mono) note("Source: Authors’ calculation from Bangladesh Integrated Household Surveys 2012, 2015, and 2019.") blabel(bar, format(%9.2f) size(medium)) ///
legend(label(1 "Off-farm employment") ///
           label(2 "Casual work (non-agriculture)") ///
           label(3 "Salaried employment") ///
           label(4 "Self-employment") ///
           label(5 "Trade/production business") ///
           rows(2) size(small) region(lcolor(none)))
graph export $graph/offfarm_ex.jpg, replace
		   
graph bar off_h csw_nah slr_h slf_h trdprd_h if _est_est1==1, over(y) ytitle("Hours of wife working outside home per day") scheme(s1mono) blabel(bar, format(%9.2f) size(medium)) ///
legend(label(1 "Off-farm employment") ///
           label(2 "Casual work (non-agriculture)") ///
           label(3 "Salaried employment") ///
           label(4 "Self-employment") ///
           label(5 "Trade/production business") ///
           rows(2) size(small) region(lcolor(none)))
graph export $graph/offfarm_in.jpg, replace

bysort year: sum off_emp csw_nawrk slr_emp slf_emp off_h csw_nah slr_h slf_h if _est_est1==1
sum off_emp off_i off_i m age_w schll_w masst w_crdt ch_size age_hh schll_hh wrk_hs farmsize lwlth town wm_union m_union if _est_est1==1
bysort wm: su off_i off_i_m m age_w schll_w masst w_crdt ch_size age_hh schll_hh wrk_hs farmsize lwlth town wm_union m_union if _est_est1==1

foreach test in off_i off_i_m m age_w schll_w masst w_crdt ch_size age_hh schll_hh wrk_hs farmsize lwlth town wm_union m_union {
	ttest `test' if _est_est1==1, by(wm)
}

*the association between women's mobile phone ownership and women empowerment
use panel_adb, clear

global control  age_w schll_w masst w_crdt hh_size age_hh schll_hh wrk_hs lwlth farmsize town m_age_w m_schll_w m_masst m_w_crdt m_hh_size m_age_hh m_schll_hh m_wrk_hs m_lwlth m_farmsize m_town


*the association between WMP and income, w/heterogeneity
eststo clear

reghdfe wm wm_union $control, a(a01 year) vce(r) res
predict double res1_, r

eststo: reghdfe off_emp wm  $control res1_ , a(a01 dvcode year) vce(r)

ivreghdfe off_emp $control (wm=wm_union), a(a01 dvcode year)  //f statistics for weak instrument
xtset a01 year
eststo: bootstrap: xttobit off_i wm  $control res1_ i.dvcode i.year if _est_est1==1

gen wm_age=wm*age_w
gen wu_age=wm_union*age_w
label var wm_age "WMP # Age of women"

gen wm_ed=wm*schll_w
gen wu_ed=wm_union*schll_w
label var wm_ed "WMP # Secondary education of women"

gen wm_wlth=wm*lwlth
gen wu_wlth=wm_union*lwlth
label var wm_wlth "WMP # lwlth"

gen wm_twn=wm*town
gen wu_twn=wm_union*town
label var wm_twn "WMP # Distance to town"

reghdfe wm wm_union $control, a(a01 dvcode year) vce(r) res
predict double res1_age, r

reghdfe wm_age wu_age $control, a(a01 dvcode year) vce(r) res
predict double res2_age, r

eststo: bootstrap: xttobit off_i wm wm_age $control res1_age res2_age i.dvcode i.year if _est_est1==1

reghdfe wm wm_union $control, a(a01 dvcode year) vce(r) res
predict double res1_ed, r

reghdfe wm_ed wu_ed $control, a(a01 dvcode year) vce(r) res
predict double res2_ed, r

eststo: bootstrap: xttobit off_i wm wm_ed $control res1_ed res2_ed i.dvcode i.year if _est_est1==1

reghdfe wm wm_union $control, a(a01 dvcode year) vce(r) res
predict double res1_twn, r

reghdfe wm_twn wu_twn $control, a(a01 dvcode year) vce(r) res
predict double res2_twn, r

eststo: bootstrap: xttobit off_i wm wm_twn $control res1_twn res2_twn i.dvcode i.year if _est_est1==1

reghdfe wm wm_union $control, a(a01 dvcode year) vce(r) res
predict double res1_wlth, r

reghdfe wm_wlth wu_wlth $control, a(a01 dvcode year) vce(r) res
predict double res2_wlth, r

eststo: bootstrap: xttobit off_i wm wm_wlth $control res1_wlth res2_wlth i.dvcode i.year if _est_est1==1

esttab using $table\main_result.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons
drop res1_age res2_age res1_ed res2_ed res1_wlth res2_wlth res1_

*the association between MP and income
global control1  age_w schll_w wrk_wf masst w_crdt hh_size age_hh schll_hh lwlth farmsize town m_age_w m_schll_w m_wrk_wf  m_masst m_w_crdt m_hh_size m_age_hh m_schll_hh m_lwlth m_farmsize m_town

eststo clear

reghdfe m m_union $control1, a(a01 dvcode year) vce(r) res
predict double res1_, r

eststo: reghdfe off_emp_m m  $control1 res1_ , a(a01 dvcode year) vce(r)

xtset a01 year
eststo: bootstrap: xttobit off_i_m m  $control1 res1_ i.dvcode i.year if _est_est1==1
esttab using $table\main_result_men.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons
drop res1_

** Extensive margin: the association between women's mobile phone ownership and off-farm employment 
eststo clear
global extensive csw_nawrk slr_emp slf_emp trdprd_emp

** Panel FE
foreach out of varlist off_emp $extensive {
 	reghdfe `out' wm $control, a(a01 dvcode year) vce(r)
}

** IV-FE
foreach out of varlist off_emp $extensive {
 	reghdfe wm wm_union $control, a(a01 dvcode year) vce(r) res
	predict double res1_`out', r

 	eststo: bootstrap: reghdfe `out' wm  $control res1_`out' , a(a01 dvcode year) vce(r)
	estimates store `out'
}

esttab using $table\main_result_extensive.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons
drop res1_csw_nawrk res1_slr_emp res1_slf_emp  res1_off_emp res1_trdprd_emp

/*Intensive margin: the association between women's mobile phone ownership and off-farm employment 

eststo clear
global intensive csw_nah slr_h slf_h trdprd_h

** Panel FE
foreach out of varlist off_h $intensive {
 	reghdfe `out' wm $control, a(a01 dvcode year) vce(r)
}

foreach out of varlist off_h $intensive {
 	reghdfe wm wm_union $control, a(a01 dvcode year) vce(r) res
	predict double res1_`out', r

 	eststo: bootstrap: reghdfe `out' wm  $control res1_`out' , a(a01 dvcode year) vce(r)
	estimates store `out'
}

esttab using $table\main_result_intensive.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons
drop res1_off_h res1_csw_nah res1_slr_h  res1_slf_h res1_trdprd_h
*/

** Heterogeneous analysis (IV-FE)
** with age of women
eststo clear
eststo: reghdfe off_emp wm  $control res1_ , a(a01 dvcode year) vce(r)

foreach out of varlist off_emp $extensive {
 	reghdfe wm wm_union $control, a(a01 dvcode year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_age wu_age $control, a(a01 dvcode year) vce(r) res
	predict double res2_`out', r

	eststo: probit `out' wm wm_age $control res1_`out' res2_`out' i.dvcode i.year if _est_est1==1, vce(bootstrap)
	estimates store `out'
}

foreach out of varlist off_h $intensive {
 	reghdfe wm wm_union $control, a(a01 dvcode year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_age wu_age $control, a(a01 dvcode year) vce(r) res
	predict double res2_`out', r
	
 	eststo: bootstrap: reghdfe `out' wm wm_age $control res1_`out' res2_`out', a(a01 dvcode year) vce(r)
	estimates store `out'
}
esttab using $table\hetero_age.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons 
drop res1_csw_nawrk res2_csw_nawrk res1_slr_emp res2_slr_emp res1_slf_emp res2_slf_emp res1_trdprd_emp res2_trdprd_emp res1_off_emp res2_off_emp res1_off_h res2_off_h res1_csw_nah res2_csw_nah res1_slr_h res2_slr_h res1_slf_h res2_slf_h res1_trdprd_h res2_trdprd_h

** with education level of women
eststo clear
eststo: reghdfe off_emp wm  $control res1_ , a(a01 year) vce(r)

foreach out of varlist $extensive  off_emp {
 	reghdfe wm wm_union $control, a(a01 year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_ed wu_ed $control, a(a01 year) vce(r) res
	predict double res2_`out', r

	eststo: probit `out' wm wm_ed $control res1_`out' res2_`out' i.dvcode i.year if _est_est1==1, vce(bootstrap)
	estimates store `out'
	margins, dydx(*)
}


foreach out of varlist off_h $intensive {
 	reghdfe wm wm_union $control, a(a01 year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_ed wu_ed $control, a(a01 year) vce(r) res
	predict double res2_`out', r

 	eststo: bootstrap: reghdfe `out' wm wm_ed $control res1_`out' res2_`out', a(a01 dvcode year) vce(r)
	estimates store `out'
}

esttab using $table\hetero_edu.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons 
drop res1_csw_nawrk res2_csw_nawrk res1_slr_emp res2_slr_emp res1_slf_emp res2_slf_emp res1_trdprd_emp res2_trdprd_emp res1_off_emp res2_off_emp //res1_off_h res2_off_h res1_csw_nah res2_csw_nah res1_slr_h res2_slr_h res1_slf_h res2_slf_h res1_trdprd_h res2_trdprd_h


** with distance to town
eststo clear
eststo: reghdfe off_emp wm  $control res1_ , a(a01 dvcode year) vce(r)

foreach out of varlist off_emp $extensive {
 	reghdfe wm wm_union $control, a(a01 year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_tw wu_tw $control, a(a01 year) vce(r) res
	predict double res2_`out', r

	eststo: probit `out' wm wm_tw $control res1_`out' res2_`out' i.dvcode i.year if _est_est1==1, vce(bootstrap)
	estimates store `out'
}


foreach out of varlist off_h $intensive {
 	reghdfe wm wm_union $control, a(a01 dvcode year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_tw wu_tw $control, a(a01 dvcode year) vce(r) res
	predict double res2_`out', r

 	eststo: reghdfe `out' wm wm_tw $control res1_`out' res2_`out', a(a01 dvcode year) vce(r)
	estimates store `out'
}

esttab using $table\hetero_tw.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons 
drop res1_csw_nawrk res2_csw_nawrk res1_slr_emp res2_slr_emp res1_slf_emp res2_slf_emp res1_trdprd_emp res2_trdprd_emp res1_off_emp res2_off_emp res1_off_h res2_off_h res1_csw_nah res2_csw_nah res1_slr_h res2_slr_h res1_slf_h res2_slf_h res1_trdprd_h res2_trdprd_h


** with household wealth
eststo clear
eststo: reghdfe off_emp wm  $control res1_ , a(a01 year) vce(r)

foreach out of varlist off_emp $extensive {
 	reghdfe wm wm_union $control, a(a01 year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_wlth wu_wlth $control, a(a01 year) vce(r) res
	predict double res2_`out', r

	eststo: probit `out' wm wm_wlth $control res1_`out' res2_`out' i.dvcode i.year if _est_est1==1, vce(bootstrap)
 	//eststo: bootstrap: reghdfe `out' wm wm_wlth $control res1_`out' res2_`out', a(a01 dcode year) vce(r)
	estimates store `out'
}


foreach out of varlist off_h $intensive {
 	reghdfe wm wm_union $control, a(a01 dvcode year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_wlth wu_wlth $control, a(a01 dvcode year) vce(r) res
	predict double res2_`out', r

 	eststo: bootstrap: reghdfe `out' wm wm_wlth $control res1_`out' res2_`out', a(a01 year) vce(r)
	estimates store `out'
}

esttab using $table\hetero_wlth.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons 
drop res1_csw_nawrk res2_csw_nawrk res1_slr_emp res2_slr_emp res1_slf_emp res2_slf_emp res1_trdprd_emp res2_trdprd_emp res1_off_emp res2_off_emp res1_off_h res2_off_h res1_csw_nah res2_csw_nah res1_slr_h res2_slr_h res1_slf_h res2_slf_h res1_trdprd_h res2_trdprd_h


** falsification test
eststo clear
eststo: reghdfe off_emp wm  $control , a(a01 dvcode year) vce(r)

eststo: tobit off_i wm_union $control i.dvcode i.year if wm==0 & _est_est1==1
esttab using $table\falsification.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons 

** robustness checks 
** treatment variables: Dynamic panel
use panel_adb, clear
eststo clear

sort a01 year
by a01: gen lagwm=wm[_n-1]
by a01: gen lagwm_union=wm_union[_n-1]

global control  age_w schll_w masst w_crdt hh_size age_hh schll_hh wrk_hs lwlth farmsize town m_age_w m_schll_w m_masst m_w_crdt m_hh_size m_age_hh m_schll_hh m_wrk_hs m_lwlth m_farmsize m_town

xtset a01 year

reghdfe lagwm lagwm_union $control, absorb(a01 dvcode year) vce(robust) residuals(res1_)

eststo: reghdfe off_emp lagwm $control res1_, absorb(a01 dvcode year) vce(robust)

eststo: bootstrap: xttobit off_i lagwm $control res1_ i.dvcode i.year if _est_est1 == 1

esttab using $table\robust_lag.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons 

*** individual level analysis
**** creating a panel dataset
use 2012_i.dta, clear
append using 2015_i.dta, force
append using 2018_i.dta, force

**** household id
sort a01 mid
egen id=group(a01 mid)
label var id "individual ID"

**** create the peer effect variable
sort uncode year
by uncode year: egen mobile_m=sum(mobile)
sort uncode year
by uncode year: egen total_nc=count(id)
gen m_union=(mobile_m-mobile)/(total_nc-1) //creating peer effect
label var m_union "Share of individuals adopting mobile phones in the union"

** CRE household mean
foreach m in  age_i schll_i mrrd_i {
	bysort a01: egen m_`m'= mean(`m')
}

**** estimation fixed effect
eststo clear

eststo: reghdfe off_i mobile age_i schll_i mrrd_i if male==1, absorb(id year) vce(cluster a01)
bysort mobile: su off_i if _est_est1==1
eststo: reghdfe off_i mobile age_i schll_i mrrd_i if male==0, absorb(id year) vce(cluster a01)
bysort mobile: su off_i if _est_est2==1
esttab using $table\robust_i.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons 

global control age_i schll_i mrrd_i m_age_i m_schll_i m_mrrd_i

*the association between WMP and income, w/heterogeneity (IV-Probit)
eststo clear

reghdfe mobile m_union $control if male==0, a(id a01 year) vce(cluster a01) res
predict double res1_, r

eststo: reghdfe off_emp mobile $control res1_ , a(id year) vce(cluster a01)

xtset id year
eststo: bootstrap: xttobit off_i mobile  $control res1_ i.dvcode i.year if _est_est1==1 & male==0

by male mobile: sum off_i
 
gen m_gen=mobile*(1-male)
gen u_gen=m_union*(1-male)
label var m_gen "WMP # Women"

gen m_age=mobile*age_i
gen u_age=m_union*age_w
label var m_age "WMP # Age of women"

gen m_ed=mobile*schll_i
gen u_ed=m_union*schll_w
label var m_ed "WMP # Secondary education"

gen m_mrrd=mobile*mrrd_i
gen u_mrrd=m_union*mrrd_i
label var m_mrrd "WMP # Married"

reghdfe mobile m_union $control, a(id year) vce(cluster a01) res
predict double res1_gen, r

reghdfe m_gen u_gen $control, a(id year) vce(cluster a01) res
predict double res2_gen, r

eststo: bootstrap: xttobit off_i mobile m_gen $control res1_gen res2_gen i.dvcode i.year, ll(0)

reghdfe mobile m_union $control if male==0, a(id year) vce(cluster a01) res
predict double res1_age, r

reghdfe m_age u_age $control if male==0, a(id year) vce(cluster a01) res
predict double res2_age, r

eststo: bootstrap: xttobit off_i mobile m_age $control res1_age res2_age i.dvcode i.year if _est_est1==1 & male==0


reghdfe mobile m_union $control if male==0, a(id year) vce(cluster a01) res
predict double res1_ed, r

reghdfe m_ed u_ed $control if male==0, a(id year) vce(cluster a01) res
predict double res2_ed, r

eststo: bootstrap: xttobit off_i mobile m_ed $control res1_ed res2_ed i.dvcode i.year if _est_est1==1 & male==0


reghdfe mobile m_union $control if male==0, a(id year) vce(cluster a01) res
predict double res1_mrrd, r

reghdfe m_mrrd u_mrrd $control if male==0, a(id year) vce(cluster a01) res
predict double res2_mrrd, r

eststo: bootstrap: xttobit off_i mobile m_mrrd $control res1_mrrd res2_mrrd i.dvcode i.year if _est_est1==1 & male==0

esttab using $table\robust_hetero_result.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons
drop res1_age res2_age res1_ed res2_ed res1_mrrd res2_mrrd res1_gen res2_gen