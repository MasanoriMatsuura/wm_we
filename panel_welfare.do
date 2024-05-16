**Women's mobile phone and women empowerment**
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
label var saving "Saving" 
foreach m in mm_p mm_o remi_d saving_d mhlth_d fhlth_d hlth_d edu_d fedu_d medu_d shock e_shock ad_size ch_size leisure_d enex_d elcex_d gasex_d nonex_d dum_el dum_gas magency {
	replace `m'=0 if `m'==.
}
recode remi (0=0)(nonm=1), gen(rem_d)


*mobile phone
label var mobile "Mobile phone"

*create peer effect variables
sort uncode year
by uncode year: egen mobile_nc=sum(wm) 
by uncode year: egen total_nc=count(a01)
gen wm_union=(mobile_nc-wm)/(total_nc-1) //creating peer effect
label var wm_union "Share of households adopting mobile money in the union"

*gender of household head
recode Male (1=0 "no")(0=1 "yes"), gen(female)
label var female "Female household head"

*create village-level average household characteristics
foreach m in female age_hh hh_size schll_hh farmsize asset road {
	bysort a01: egen mn_`m'=mean(`m')
}

** CRE household mean
foreach m in female age_hh schll_hh ad_size ch_size asset {
	bysort a01: egen m_`m'=mean(`m')
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

save panel.dta, replace

*Descriptive statistics

graph bar wm, over(year) ytitle("Women's Mobile phone ownership")  note("Source: Bangladesh Integrated Household Survey 2011, 2015 and 2019") scheme(s1mono)
graph export $graph/phone_overtime.jpg, replace

graph bar emp, over(year) ytitle("Women's disempowerment status")  note("Source: Bangladesh Integrated Household Survey 2011, 2015 and 2019") scheme(s1mono)

graph bar brth_cntrl, over(year) ytitle("Birth control")  note("Source: Bangladesh Integrated Household Survey 2011, 2015 and 2019") scheme(s1mono)

graph bar vlnc, over(year) ytitle("Any violence")  note("Source: Bangladesh Integrated Household Survey 2011, 2015 and 2019") scheme(s1mono)

*the association between women's mobile phone ownership and women empowerment
use panel, clear

global control age_w c.age_w#c.age_w schll_w wrk_wf masst w_crdt ch_size age_hh schll_hh wrk_hs farmsize asset //covariates
eststo clear
** Panel FE
foreach out of varlist FiveDE emp{
 	eststo: reghdfe `out' wm $control, a(a01 dcode year) vce(r)
}
** IV-FE
foreach out of varlist FiveDE emp{
 	eststo: ivreghdfe `out' $control (wm = wm_union), a(a01 dcode year) robust
}
esttab using $table\main_result_we.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons

*the association between women's mobile phone ownership and women empowerment
eststo clear

** Panel FE
foreach out of varlist brth_cntrl vlnc em_vlnc py_vlnc{
 	eststo: reghdfe `out' wm $control, a(a01 dcode year) vce(r)
}

** IV-FE
foreach out of varlist brth_cntrl vlnc em_vlnc py_vlnc{
 	eststo: ivreghdfe `out' $control (wm = wm_union), a(a01 dcode year) robust
}

esttab using $table\main_result_vlbc.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons

** Heterogeneous analysis (IV-FE)
** with women's credit access
eststo clear
gen wm_cr=wm*w_crdt
gen wu_cr=wm_union*w_crdt
label var wm "WMP"
label var wm_cr "WMP # Credit access"
foreach out of varlist FiveDE emp{
 	reghdfe wm wm_union $control, a(a01 dcode year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_cr wu_cr $control, a(a01 dcode year) vce(r) res
	predict double res2_`out', r

 	eststo: reghdfe `out' wm wm_cr $control res1_`out' res2_`out', a(a01 dcode year) vce(r)
	estimates store `out'
 }


foreach out of varlist brth_cntrl vlnc em_vlnc py_vlnc{
 	reghdfe wm wm_union $control, a(a01 dcode year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_cr wu_cr $control, a(a01 dcode year) vce(r) res
	predict double res2_`out', r

 	eststo: reghdfe `out' wm wm_cr $control res1_`out' res2_`out', a(a01 dcode year) vce(r)
	estimates store `out'
}
coefplot (FiveDE, label(5DE score)) (emp, label(Empowerment)) (brth_cntrl, label(Contraception)) (vlnc, label(Any violence)) (em_vlnc, label(Emotional violence)) (py_vlnc, label(Physical violence)) , keep(wm wm_cr) xline(0)
graph export $graph\we_cr.png, replace

esttab using $table\hetero_crd.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons 
drop res1_FiveDE res2_FiveDE res1_emp res2_emp res1_brth_cntrl res2_brth_cntrl res1_vlnc res2_vlnc res1_em_vlnc res2_em_vlnc res1_py_vlnc res2_py_vlnc

** with age of women
eststo clear
gen wm_age=wm*age_w
gen wu_age=wm_union*age_w
label var wm_age "WMP # Age of women"

foreach out of varlist FiveDE emp{
 	reghdfe wm wm_union $control, a(a01 dcode year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_age wu_age $control, a(a01 dcode year) vce(r) res
	predict double res2_`out', r

 	eststo: reghdfe `out' wm wm_age $control res1_`out' res2_`out', a(a01 dcode year) vce(r)
 	estimates store `out'
}

foreach out of varlist brth_cntrl vlnc em_vlnc py_vlnc{
 	reghdfe wm wm_union $control, a(a01 dcode year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_age wu_age $control, a(a01 dcode year) vce(r) res
	predict double res2_`out', r

 	eststo: reghdfe `out' wm wm_age $control res1_`out' res2_`out', a(a01 dcode year) vce(r)
	estimates store `out'
}
coefplot (FiveDE, label(5DE score)) (emp, label(Empowerment)) (brth_cntrl, label(Contraception)) (vlnc, label(Any violence)) (em_vlnc, label(Emotional violence)) (py_vlnc, label(Physical violence)) , keep(wm wm_age) xline(0)
graph export $graph\we_age.png, replace

esttab using $table\hetero_age.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons 
drop res1_FiveDE res2_FiveDE res1_emp res2_emp res1_brth_cntrl res2_brth_cntrl res1_vlnc res2_vlnc res1_em_vlnc res2_em_vlnc res1_py_vlnc res2_py_vlnc
** with education level of women
eststo clear
gen wm_ed=wm*schll_w
gen wu_ed=wm_union*schll_w
label var wm_ed "WMP # Education level of women"

foreach out of varlist FiveDE emp{
 	reghdfe wm wm_union $control, a(a01 dcode year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_ed wu_ed $control, a(a01 dcode year) vce(r) res
	predict double res2_`out', r

 	eststo: reghdfe `out' wm wm_ed $control res1_`out' res2_`out', a(a01 dcode year) vce(r)
 	estimates store `out'
}

foreach out of varlist brth_cntrl vlnc em_vlnc py_vlnc{
 	reghdfe wm wm_union $control, a(a01 dcode year) vce(r) res
	predict double res1_`out', r

	reghdfe wm_ed wu_ed $control, a(a01 dcode year) vce(r) res
	predict double res2_`out', r

 	eststo: reghdfe `out' wm wm_ed $control res1_`out' res2_`out', a(a01 dcode year) vce(r)
	estimates store `out'
}
coefplot (FiveDE, label(5DE score)) (emp, label(Empowerment)) (brth_cntrl, label(Contraception)) (vlnc, label(Any violence)) (em_vlnc, label(Emotional violence)) (py_vlnc, label(Physical violence)) , keep(wm wm_ed) xline(0)
graph export $graph\we_ed.png, replace

esttab using $table\hetero_edu.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons 
drop res1_FiveDE res2_FiveDE res1_emp res2_emp res1_brth_cntrl res2_brth_cntrl res1_vlnc res2_vlnc res1_em_vlnc res2_em_vlnc res1_py_vlnc res2_py_vlnc

** falsification test

esttab using $table\falsification.rtf, keep(mobile_union) b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons s(hh division control N, label("Household FE" "Division Year" "Control variables" "Observations"))
