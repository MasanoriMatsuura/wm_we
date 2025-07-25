/*create 2012 dataset for regression: mobile money women empowerment child health*/
/*Author: Masanori Matsuura*/
clear all
set more off
*set the pathes

global BIHS18Community = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Community"
global BIHS18Female = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Female"
global BIHS18Male = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Male"
global BIHS15 = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2015"
global BIHS12 = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2012"

*BIHS2012 data cleaning 
**keep geographical code
use $BIHS12\001_mod_a_male, clear
keep a01 div dcode District_Name uzcode uncode vcode_n
rename (div vcode_n)(dvcode Village)
save 2012, replace

** HH composition, HH with husband and wife
use $BIHS12\003_mod_b1_male.dta, clear
bysort a01: egen size=count(a01) if b1_03==3
bysort a01: egen ch_size=max(size)
replace ch_size=0 if ch_size==.
label var ch_size "Number of children"

keep if mid==1 | mid==2
keep if b1_03==1 | b1_03==2
keep if b1_04==2 
keep if b1_03==2 & b1_01==2
gen couple=1
rename (b1_02 b1_08) (age_w edu_w)
recode edu_w(10/16 33/75=1)(nonm=0), gen(schll_w) // convert  education into schoolling year 
label var age_w "Age of women"
label var schll_w "Secondary school certificate of women"
recode b1_07 (4=1 "yes") (nonm=0 "No" ), gen(lit_w)
label var lit_w "Literacy of women"

keep a01 couple ch_size edu_w schll_w lit_w age_w
save hh12.dta, replace

** individual demography
use $BIHS12\003_mod_b1_male.dta, clear
keep if b1_02 > 16 
keep if b1_02 < 65

rename (b1_01 b1_02 b1_04 b1_08) (male age_i mrrd edu)
replace male=0 if male==2
recode edu (10/16 33/75=1)(nonm=0), gen(schll_i) // convert  education into SSC
label var age_i "Age"
label var schll_i "Secondary school certificate"

recode mrrd (2=1)(nonm=0), gen(mrrd_i)
label var mrrd_i "Married"
keep a01 mid male age_i schll_i mrrd_i
save hh12_i.dta, replace

** individual income
use $BIHS12\005_mod_c_male, clear
recode c05 (81/999=0 "No") (nonm=1 "Yes"), gen(wrk)
label var wrk "Current working status"

*** extensive margin: probability of working
recode c05 (1 6=1 "Yes") (nonm=0 "No"), gen(csw_awrk) //extensive margin
label var csw_awrk "Casual wage employment (agriculture)"
recode c05 (2/5 7/11=1 "Yes")(nonm=0 "No"), gen(csw_nawrk)
label var csw_nawrk "Casual wage employment (non-agriculture)"
recode c05 (12/21=1 "Yes")(nonm=0 "No"), gen(slr_emp)
label var slr_emp "Salaried employment"
recode c05 (22/47 72=1 "Yes")(nonm=0 "No"), gen(slf_emp)
label var slf_emp "Self-employment"
recode c05 (50/57=1 "Yes")(nonm=0 "No"), gen(trdprd_emp)
label var trdprd_emp "Trader/production business"
recode c05 (2/5  7/57 72=1 "Yes")(nonm=0 "No"), gen(off_emp)
label var off_emp "Off-farm employment"

foreach labor in csw_awrk csw_nawrk slr_emp slf_emp trdprd_emp off_emp {
	 bysort a01 mid: egen mx_`labor' = max(`labor')
	 bysort a01 mid: replace `labor' = mx_`labor'
	 bysort a01 mid: replace `labor' = 0 if `labor'==.
	 drop mx_`labor'
}

*** intensive margin: working hour
gen csw_ah=c08 if csw_awrk==1 //intensive margin
replace csw_ah=0 if csw_awrk==0 
label var csw_ah "Casual wage employment (agriculture)"

gen csw_nah=c08 if csw_nawrk==1 //intensive margin
replace csw_nah=0 if csw_nawrk==0 
label var csw_nah "Casual wage employment (non-agriculture)"

gen slr_h=c08 if slr_emp==1 
replace slr_h=0 if slr_emp==0 
label var slr_h "Salaried employment"

gen slf_h=c08 if slf_emp==1 
replace slf_h=0 if slf_emp==0 
label var slf_h "Self-employment"

gen trdprd_h=c08 if trdprd_emp==1 
replace trdprd_h=0 if trdprd_emp==0 
label var trdprd_h "Trader/production business"

gen off_h=c08 if off_emp==1 
replace off_h=0 if off_emp==0 
label var off_h "Off-farm employment"

foreach labor in csw_ah csw_nah slr_h slf_h trdprd_h off_h {
	bysort a01 mid: egen mx_`labor' = total(`labor')
	bysort a01 mid: replace `labor' = mx_`labor'
	drop mx_`labor'
}

*** income of working 
gen csw_ai=c14 if csw_awrk==1 
replace csw_ai=0 if csw_awrk==0 
label var csw_ai "Casual wage employment (agriculture)"

gen csw_nai=c14 if csw_nawrk==1 
replace csw_nai=0 if csw_nawrk==0 
label var csw_nai "Casual wage employment (non-agriculture)"

gen slr_i=c14 if slr_emp==1 
replace slr_i=0 if slr_emp==0 
label var slr_i "Salaried employment"

gen slf_i=c14 if slf_emp==1 
replace slf_i=0 if slf_emp==0 
label var slf_i "Self-employment"

gen trdprd_i=c14 if trdprd_emp==1 
replace trdprd_i=0 if trdprd_emp==0 
label var trdprd_i "Trader/production business"

gen off_i=c14 if off_emp==1 
replace off_i=0 if off_emp==0 
label var off_i "Off-farm employment"

foreach labor in csw_ai csw_nai slr_i slf_i trdprd_i off_i {
	bysort a01 mid: egen mx_`labor' = total(`labor')
	bysort a01 mid: replace `labor' = mx_`labor'
	drop mx_`labor'
}

keep a01 mid csw_awrk csw_nawrk slr_emp slf_emp trdprd_emp off_emp csw_ah csw_nah slr_h slf_h trdprd_h off_h csw_ai csw_nai slr_i slf_i trdprd_i off_i
duplicates drop a01 mid csw_awrk csw_nawrk slr_emp slf_emp trdprd_emp off_emp csw_ah csw_nah slr_h slf_h trdprd_h off_h csw_ai csw_nai slr_i slf_i trdprd_i off_i, force


save inc12_i.dta, replace

**individual mobile phone ownership
use $BIHS12\006_mod_d1_male, clear //individual
keep if d1_02==24 //only mobile phones
rename d1_06_a mid
gen mobile=1 if d1_03==1
replace mobile=1 if d1_03==1
drop if d1_03 == .
replace mobile=0 if mobile==.
label var mobile "Mobile ownership"
keep a01 mid mobile
tempfile m1
save `m1'

use $BIHS12\006_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_b mid
gen mobile=1 if d1_03==1
replace mobile=1 if d1_03==1
drop if d1_03 == .
replace mobile=0 if mobile==.
label var mobile "Mobile ownership"
keep a01 mid mobile
append using `m1'

save m215.dta, replace

use $BIHS12\006_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_c mid
gen mobile=1 if d1_03==1
replace mobile=1 if d1_03==1
drop if d1_03 == .
replace mobile=0 if mobile==.
label var mobile "Mobile ownership"
keep a01 mid mobile

append using m215

bysort a01: egen mob=total(mobile)
recode mob (0=0 "No")(nonm=1 "Yes" ), gen(m)
label var m "Mobile ownership"

duplicates drop a01 mid m, force
save m12_i, replace

** female labor force participation
use $BIHS12\005_mod_c_male, clear
keep if mid==2
recode c05 (81/999=0 "No") (nonm=1 "Yes"), gen(wrk_wf)
label var wrk_wf "Current working status of wife"

*** extensive margin: probability of working
recode c05 (1 6=1 "Yes") (nonm=0 "No"), gen(csw_awrk) //extensive margin
label var csw_awrk "Casual wage employment (agriculture)"
recode c05 (2/5 7/11=1 "Yes")(nonm=0 "No"), gen(csw_nawrk)
label var csw_nawrk "Casual wage employment (non-agriculture)"
recode c05 (12/21=1 "Yes")(nonm=0 "No"), gen(slr_emp)
label var slr_emp "Salaried employment"
recode c05 (22/47 72=1 "Yes")(nonm=0 "No"), gen(slf_emp)
label var slf_emp "Self-employment"
recode c05 (50/57=1 "Yes")(nonm=0 "No"), gen(trdprd_emp)
label var trdprd_emp "Trader/production business"
recode c05 (2/5  7/57 72=1 "Yes")(nonm=0 "No"), gen(off_emp)
label var off_emp "Off-farm employment"

foreach labor in csw_awrk csw_nawrk slr_emp slf_emp trdprd_emp off_emp {
	 bysort a01: egen mx_`labor' = max(`labor')
	 bysort a01: replace `labor' = mx_`labor'
	 bysort a01: replace `labor' = 0 if `labor'==.
	 drop mx_`labor'
}

*** intensive margin: working hour
gen csw_ah=c08 if csw_awrk==1 //intensive margin
replace csw_ah=0 if csw_awrk==0 
label var csw_ah "Casual wage employment (agriculture)"

gen csw_nah=c08 if csw_nawrk==1 //intensive margin
replace csw_nah=0 if csw_nawrk==0 
label var csw_nah "Casual wage employment (non-agriculture)"

gen slr_h=c08 if slr_emp==1 
replace slr_h=0 if slr_emp==0 
label var slr_h "Salaried employment"

gen slf_h=c08 if slf_emp==1 
replace slf_h=0 if slf_emp==0 
label var slf_h "Self-employment"

gen trdprd_h=c08 if trdprd_emp==1 
replace trdprd_h=0 if trdprd_emp==0 
label var trdprd_h "Trader/production business"

gen off_h=c08 if off_emp==1 
replace off_h=0 if off_emp==0 
label var off_h "Off-farm employment"

foreach labor in csw_ah csw_nah slr_h slf_h trdprd_h off_h {
	bysort a01: egen mx_`labor' = total(`labor')
	bysort a01: replace `labor' = mx_`labor'
	drop mx_`labor'
}

*** income of working 
gen csw_ai=c14 if csw_awrk==1 
replace csw_ai=0 if csw_awrk==0 
label var csw_ai "Casual wage employment (agriculture)"

gen csw_nai=c14 if csw_nawrk==1 
replace csw_nai=0 if csw_nawrk==0 
label var csw_nai "Casual wage employment (non-agriculture)"

gen slr_i=c14 if slr_emp==1 
replace slr_i=0 if slr_emp==0 
label var slr_i "Salaried employment"

gen slf_i=c14 if slf_emp==1 
replace slf_i=0 if slf_emp==0 
label var slf_i "Self-employment"

gen trdprd_i=c14 if trdprd_emp==1 
replace trdprd_i=0 if trdprd_emp==0 
label var trdprd_i "Trader/production business"

gen off_i=c14 if off_emp==1 
replace off_i=0 if off_emp==0 
label var off_i "Off-farm employment"

foreach labor in csw_ai csw_nai slr_i slf_i trdprd_i off_i {
	bysort a01: egen mx_`labor' = total(`labor')
	bysort a01: replace `labor' = mx_`labor'
	drop mx_`labor'
}

keep a01 csw_awrk csw_nawrk slr_emp slf_emp trdprd_emp off_emp csw_ah csw_nah slr_h slf_h trdprd_h off_h csw_ai csw_nai slr_i slf_i trdprd_i off_i

duplicates drop a01 csw_awrk csw_nawrk slr_emp slf_emp trdprd_emp off_emp csw_ah csw_nah slr_h slf_h trdprd_h off_h csw_ai csw_nai slr_i slf_i trdprd_i off_i, force
save fl12.dta, replace

** male labor force participation
use $BIHS12\005_mod_c_male, clear
keep if mid==1

*** extensive margin: probability of working
recode c05 (1 6=1 "Yes") (nonm=0 "No"), gen(csw_awrk_m) //extensive margin
label var csw_awrk "Casual wage employment (agriculture)"
recode c05 (2/5 7/11=1 "Yes")(nonm=0 "No"), gen(csw_nawrk_m)
label var csw_nawrk "Casual wage employment (non-agriculture)"
recode c05 (12/21=1 "Yes")(nonm=0 "No"), gen(slr_emp_m)
label var slr_emp "Salaried employment"
recode c05 (22/47 72=1 "Yes")(nonm=0 "No"), gen(slf_emp_m)
label var slf_emp "Self-employment"
recode c05 (50/57=1 "Yes")(nonm=0 "No"), gen(trdprd_emp_m)
label var trdprd_emp "Trader/production business"
recode c05 (2/5  7/57 72=1 "Yes")(nonm=0 "No"), gen(off_emp_m)
label var off_emp "Off-farm employment"

foreach labor in csw_awrk_m csw_nawrk_m slr_emp_m slf_emp_m trdprd_emp_m off_emp_m {
	 bysort a01: egen mx_`labor' = max(`labor')
	 bysort a01: replace `labor' = mx_`labor'
	 bysort a01: replace `labor' = 0 if `labor'==.
	 drop mx_`labor'
}

*** intensive margin: working hour
gen csw_ah_m=c08 if csw_awrk_m==1 //intensive margin
replace csw_ah_m=0 if csw_awrk_m==0 
label var csw_ah_m "Casual wage employment (agriculture)"

gen csw_nah_m=c08 if csw_nawrk_m==1 //intensive margin
replace csw_nah_m=0 if csw_nawrk_m==0 
label var csw_nah_m "Casual wage employment (non-agriculture)"

gen slr_h_m=c08 if slr_emp_m==1 
replace slr_h_m=0 if slr_emp_m==0 
label var slr_h_m "Salaried employment"

gen slf_h_m=c08 if slf_emp_m==1 
replace slf_h_m=0 if slf_emp_m==0 
label var slf_h_m "Self-employment"

gen trdprd_h_m=c08 if trdprd_emp_m==1 
replace trdprd_h_m=0 if trdprd_emp_m==0 
label var trdprd_h_m "Trader/production business"

gen off_h_m=c08 if off_emp_m==1 
replace off_h_m=0 if off_emp_m==0 
label var off_h_m "Off-farm employment"

foreach labor in csw_ah_m csw_nah_m slr_h_m slf_h_m trdprd_h_m off_h_m {
	bysort a01: egen mx_`labor' = total(`labor')
	bysort a01: replace `labor' = mx_`labor'
	drop mx_`labor'
}

*** income of working 
gen csw_ai_m=c14 if csw_awrk_m==1 
replace csw_ai_m=0 if csw_awrk_m==0 
label var csw_ai "Casual wage employment (agriculture)"

gen csw_nai_m=c14 if csw_nawrk_m==1 
replace csw_nai_m=0 if csw_nawrk_m==0 
label var csw_nai_m "Casual wage employment (non-agriculture)"

gen slr_i_m=c14 if slr_emp_m==1 
replace slr_i_m=0 if slr_emp_m==0 
label var slr_i_m "Salaried employment"

gen slf_i_m=c14 if slf_emp_m==1 
replace slf_i_m=0 if slf_emp_m==0 
label var slf_i_m "Self-employment"

gen trdprd_i_m=c14 if trdprd_emp_m==1 
replace trdprd_i_m=0 if trdprd_emp_m==0 
label var trdprd_i_m "Trader/production business"

gen off_i_m=c14 if off_emp_m==1 
replace off_i_m=0 if off_emp_m==0 
label var off_i_m "Off-farm employment"

foreach labor in csw_ai_m csw_nai_m slr_i_m slf_i_m trdprd_i_m off_i_m {
	bysort a01: egen mx_`labor' = total(`labor')
	bysort a01: replace `labor' = mx_`labor'
	drop mx_`labor'
}

keep a01 csw_awrk_m csw_nawrk_m slr_emp_m slf_emp_m trdprd_emp_m off_emp_m csw_ah_m csw_nah_m slr_h_m slf_h_m trdprd_h_m off_h_m csw_ai_m csw_nai_m slr_i_m slf_i_m trdprd_i_m off_i_m

duplicates drop a01 csw_awrk_m csw_nawrk_m slr_emp_m slf_emp_m trdprd_emp_m off_emp_m csw_ah_m csw_nah_m slr_h_m slf_h_m trdprd_h_m off_h_m csw_ai_m csw_nai_m slr_i_m slf_i_m trdprd_i_m off_i_m, force


save ml12.dta, replace

**mobile phone ownership
use $BIHS12\006_mod_d1_male, clear //household ownership
keep if d1_02==24 //only mobile phones
rename d1_06_a mid
merge 1:1 a01 mid using $BIHS12\003_mod_b1_male, nogen
gen mobile=1 if mid==1 & d1_03==1
replace mobile=1 if mid==71 & d1_03==1
drop if d1_03 == .
replace mobile=0 if mobile==.
label var mobile "Men's mobile ownership"
keep a01 mobile
tempfile m1
save `m1'

use $BIHS12\006_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_b mid
merge 1:1 a01 mid using $BIHS12\003_mod_b1_male, nogen
gen mobile=1 if mid==1 & d1_03==1
replace mobile=1 if mid==71 & d1_03==1
drop if d1_03 == .
replace mobile=0 if mobile==.
label var mobile "Men's mobile ownership"
keep a01 mobile
append using `m1'

save m215.dta, replace

use $BIHS12\006_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_c mid
merge 1:1 a01 mid using $BIHS12\003_mod_b1_male, nogen
gen mobile=1 if mid==1 & d1_03==1
replace mobile=1 if mid==71 & d1_03==1
drop if d1_03 == .
replace mobile=0 if mobile==.
label var mobile "Men's mobile ownership"
keep a01 mobile

append using m215

bysort a01: egen mob=total(mobile)
recode mob (0=0 "No")(nonm=1 "Yes" ), gen(m)
label var m "Men's mobile ownership"

duplicates drop a01, force
save mobile12, replace


/**Women's mobile phone ownership
use $BIHS12\006_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_a mid
merge 1:1 a01 mid using $BIHS12\003_mod_b1_male, nogen
gen wmobile=1 if mid==2
drop if d1_03 == .
replace wmobile=0 if wmobile==.
label var wmobile "Women's mobile ownership"
keep a01 wmobile
tempfile wm1
save `wm1'

use  $BIHS12\006_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_b mid
merge 1:1 a01 mid using $BIHS12\003_mod_b1_male, nogen
gen wmobile=1 if mid==2
drop if d1_03 == .
replace wmobile=0 if wmobile==.
label var wmobile "Women's mobile ownership"
keep a01 wmobile
append using `wm1'

save wm212.dta, replace

use  $BIHS12\006_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_c mid
merge 1:1 a01 mid using $BIHS12\003_mod_b1_male, nogen
gen wmobile=1 if mid==2
drop if d1_03 == .
replace wmobile=0 if wmobile==.
label var wmobile "Women's mobile ownership"
keep a01 wmobile

append using wm212

bysort a01: egen wmob=total(wmobile)
recode wmob (0=0 "No")(nonm=1 "Yes" ), gen(wm)
label var wm "Women's mobile ownership"

duplicates drop a01, force*/

*Women's mobile phone ownership
use $BIHS12\006_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
keep if d1_06_a==2 | d1_06_b==2 | d1_06_c==2
gen wm=1
label var wm "Women's mobile ownership"
keep a01 wm
save wm12.dta, replace

** Intimate partner violence
use $BIHS12\063_mod_z4_female, clear
drop if z4_01a==.
recode z4_02 (.=0 "No")(nonm=1 "Yes"), gen(vlnc)
label var vlnc "Any violence"
recode z4_01a (1 2=1 "Yes")(nonm=0 "No"), gen(em_vlnc)
replace em_vlnc=1 if z4_01b==1 | z4_01b==2 | z4_01c==1 | z4_01c==2
label var em_vlnc "Emotional violence"
recode z4_01d (1 2=1 "Yes")(nonm=0 "No"), gen(py_vlnc)
label var py_vlnc "Physical violence"
keep a01 vlnc em_vlnc py_vlnc
save vlnc12.dta, replace


** Contraceptive use
use $BIHS12\062_mod_z3_female, clear
recode z3_01 (1=1 "Yes")(2=0 "No"), gen(brth_cntrl)
label var brth_cntrl "Use contraceptive"
keep a01 brth_cntrl
duplicates drop a01 brth_cntrl, force
save cntr12.dta, replace


** asset brought to marriage
use $BIHS12\064_mod_z5_female, clear
rename z5_01 masst
label var masst "Asset brought to marriage"
replace masst=0 if masst==2
keep a01 masst
duplicates drop a01, force
save masst12.dta, replace

** credit access
use $BIHS12\074_mod_weai_we_female.dta, clear
recode e07_d (1=1 "Yes")(2=0 "No"), gen(w_crdt)
label var w_crdt "Women's access to credit"
rename wa01 a01
keep a01 w_crdt
duplicates drop a01 w_crdt, force
save wcrdt12.dta, replace

** migrant status
use $BIHS12\041_mod_v1_male, clear //if any members are migrants
recode v1_01 (1=1 "Yes")(2=0 "No"), gen(migrant)
keep a01 migrant
label var migrant "Member migration (1/0)"
duplicates drop a01, force
save migrant12, replace

** energy poverty
use $BIHS12\033_mod_p1_male, clear
keep if p1_01==1 | p1_01==2 | p1_01==3 | p1_01==4 | p1_01==5 | p1_01==6 |p1_01==7 | p1_01==8 | p1_01==9 | p1_01==36 | p1_01==37 | p1_01==38 | p1_01==46 | p1_01==47
egen enex_i=rowtotal(p1_02 p1_04)
bysort a01: egen enex=sum(enex_i)
egen elcex_i=rowtotal(p1_02 p1_04) if p1_01==7
bysort a01:egen elcex=sum(elcex_i)
egen gasex_i=rowtotal(p1_02 p1_04) if p1_01==6
bysort a01: egen gasex=sum(gasex_i)
egen nonex_i=rowtotal(p1_02 p1_04) if p1_01==1 | p1_01==2 | p1_01==3 | p1_01==4 | p1_01==8 | p1_01==9 | p1_01==36 | p1_01==37 | p1_01==38 | p1_01==46 | p1_01==47
bysort a01: egen nonex=sum(nonex_i)
recode elcex (0=0) (nonm=1), gen(dum_el)
recode gasex (0=0) (nonm=1), gen(dum_gas)

duplicates drop a01, force
keep a01 elcex enex gasex nonex dum_el dum_gas
save ene15, replace

**cooking fuel
use $BIHS12\035_mod_q_male, clear
recode q_16 (1/3=1)(nonm=0),gen(clean)
label var clean "Clean fuels"
keep a01 clean
gen diff=a01-int(a01)
gen a01_int=a01-diff
tab diff
gen ext=0 if diff==0
replace ext=1 if diff>0 & diff<.18
replace ext=2 if diff>.18 & diff<.21
replace ext=3 if diff>.21 & diff<.31
replace ext=4 if diff>.31 & diff<.41
drop if ext>1
ren a01 a01R2
ren a01_int a01
order a01
sort a01
duplicates report a01
sum a01
duplicates drop a01, force
save ckng15, replace

**poverty indicators
use $BIHS12\hhexpenditure_R1, clear // poverty status and depth (gap)
merge 1:1 a01 using $BIHS12\mpi_R1, nogen //multidimentional poverty index
keep a01 pcexp_da p190hcgcpi p190hcfcpi p320hcgcpi p320hcfcpi pov190gapgcpi deppov190gcpi pov190gapfcpi deppov190fcpi pov320gapgcpi pov320gapfcpi deppov320fcpi deppov320gcpi hc_mpi mpiscore
save poverty12.dta, replace

**social network
use $BIHS15\024_r2_mod_h9_male.dta, clear
recode h9_02_1 (1=1 "Yes")(2=0 "No")(.=0 "No"),gen(network_urea)
keep a01 network_urea
merge 1:1 a01 using $BIHS15\077_r2_mod_y8_female, nogene
recode y8_06 (1=1 "Yes")(2=0 "No")(.=0 "No"),gen(network_health)
gen network_discussion=network_health+network_urea
recode network_discussion (0=0 "No")(nonm=1 "Yes"), gen(network)
keep a01 network
label var network "Social network (discussion)"
save network15.dta, replace

** keep age gender education occupation of HH
use $BIHS12\003_mod_b1_male.dta, clear
bysort a01: egen hh_size=count(a01)
label var hh_size "Household size"
keep if b1_03==1 
keep a01 mid b1_01 b1_02 b1_04 b1_08 b1_10 hh_size
rename (b1_01 b1_02 b1_04 b1_08)(gender_hh age_hh marital_hh edu_hh)
recode edu_hh (10/16 33/75=1)(nonm=0), gen(schll_hh) // convert  education into schoolling year 
label var age_hh "Age of HH"
label var schll_hh "Secondary school certificate of HH"
recode gender_hh (1=1 "Man")(2=0 "Woman"), gen(Male)
label var Male "Male(=1)"
recode b1_10 (1/72=1 "Yes")(nonm=0 "No"), gen(wrk_hs)
label var wrk_hs "Current working status of husband"
save sciec12.dta, replace


**Asset index
use $BIHS12\006_mod_d1_male.dta, clear  
keep a01 d1_02 d1_03
reshape wide d1_03,i(a01) j(d1_02)
local varlist "d1_031 d1_032 d1_033 d1_034 d1_035 d1_036 d1_037 d1_038 d1_039 d1_0310 d1_0311 d1_0312 d1_0313 d1_0314 d1_0315 d1_0316 d1_0317 d1_0318 d1_0319 d1_0320 d1_0321 d1_0322 d1_0323 d1_0325 d1_0326 d1_0327 d1_0328 d1_0329 d1_0330 d1_0331 d1_0332 d1_0333 d1_0334 d1_0335 d1_0336 d1_0337 d1_0338 d1_0339 d1_0340 d1_0341 d1_0342 d1_0343 d1_0344 d1_0345 d1_0346 d1_0347" //d1_0324 mobile phone set
foreach x in `varlist'{
	replace `x'=0 if `x'==2
	replace `x'=0 if `x'==.
}
pca `varlist'
predict asset
keep a01 asset
recode asset (min/-2.411879=1)(nonm=0), gen(lwlth)
label var lwlth "Poor asset"
save asset12.dta, replace

**keep agronomic variables
use $BIHS12\010_mod_g_male, clear
keep if g01==2
bysort a01: egen farmsize=total(g02) 
label var farmsize "Farm Size(decimal)"
gen ln_farm=log(farmsize)
label var ln_farm "Farm size(log)"
duplicates drop a01 farmsize, force
keep a01 farmsize ln_farm
save agrnmic12.dta, replace

/*Irrigation*/
use $BIHS12\012_mod_h2_male.dta, clear
recode h2_02 (1=0 "No") (nonm=1 "Yes"), gen(irri)
label var irri "Irrigation(=1)"
collapse (sum) i1=irri, by(a01)
recode i1 (0=0 "No")(nonm=1 "Yes"), gen(irrigation)
label var irrigation "Irrigation(=1)"
keep a01 irrigation
save irri12.dta, replace

**non-earned income
use $BIHS12\044_mod_v4_male, clear
drop sample_type
bysort a01: gen nnearn=v4_01+v4_02+v4_03+v4_04+v4_05+v4_06+v4_07+v4_08+v4_09+v4_10+v4_11+v4_12+v4_13
label var nnearn "Non-earned income"
keep a01 nnearn
save nnrn12.dta, replace //non-earned  income

**remittance
use $BIHS12\042_mod_v2_male, clear
keep a01 v2_06
bysort a01: egen remi=sum(v2_06)
duplicates drop a01, force
label var remi "remittance"
save rem12.dta, replace

**social safety net program
use $BIHS12\040_mod_u_male.dta, replace
bysort a01: gen trsfr=sum(u02)
label var trsfr "Social safety net program transfer"
keep a01 trsfr
duplicates drop a01, force
save ssnp12.dta, replace

**crop type, farm income and diversification
use $BIHS12\011_mod_h1_male.dta , clear // crop type
keep a01 crop_a crop_b h1_02 h1_03
rename (h1_02 h1_03)(crp_typ plntd)
bysort a01 crop_a: egen typ_plntd=sum(plntd)
duplicates drop a01 crop_a, force
bysort a01: egen crpdivnm=count(crop_a) //crop diversification (Number of crop species including vegetables and fruits produced by the household in the last year (number))
label var crpdivnm "Crop diversity"
keep a01 crpdivnm
duplicates drop a01, force
save crp12.dta, replace

use $BIHS12\011_mod_h1_male, clear //crop diversification 
keep a01 crop_a crop_b h1_03
rename  h1_03 plntd
collapse (sum) typ_plntd=plntd, by(a01 crop_a)
/*bysort a01 crop_a: egen typ_plntd=sum(plntd) //area of each crop */
label var typ_plntd "Area of each crop"
bysort a01: egen ttl_frm=sum(typ_plntd)  //total planted area
label var ttl_frm "total farm area"

gen es=(typ_plntd/ttl_frm)^2
label var es "enterprise share (planted area)"
bysort a01: egen es_crp=sum(es) 
label var es_crp "Herfindahl-Hirschman index (crop)"
drop if crop_a==.
gen crp_div=1-es_crp
label var crp_div "Crop Diversification Index"
gen es_sh=(typ_plntd/ttl_frm)
gen lnc=log(es_sh)
bysort a01: egen _shnc=sum(lnc*es_sh)
gen shnc=-1*_shnc
keep a01 crp_div shnc
label var shnc "Crop diversification index (shannon)"
keep a01 crp_div shnc
duplicates drop a01, force
save crp_div12.dta, replace

use $BIHS12\028_mod_m1_male, clear //crop income
keep a01 m1_02 m1_10 m1_18 m1_20
collapse (sum) crp_vl=m1_10 (mean) dstnc_sll_=m1_18 trnsctn=m1_20,by(a01)
label var crp_vl "farm income"
label var dstnc_sll_ "distance to selling place" 
label var trnsctn "transaction time"
save crpincm12.dta, replace

/*use $BIHS15\039_r2_mod_m1_male, clear //crop income diversification 
keep a01 m1_10
bysort a01: egen ttl_frminc=sum(m1_10) 
label var ttl_frminc "total farm income"
gen es=(m1_10/ttl_frminc)^2
label var es "enterprise share (farm income)"
bysort a01: egen es1=sum(es)
drop if m1_10==.
hist es1 */

**market access 
use $BIHS12\028_mod_m1_male.dta, clear //Marketing of Paddy, Rice, Banana, Mango, and Potato
keep a01 m1_16 m1_18
recode m1_16 (2/5=1 "yes")(nonm=0 "no"), gen(market)
bysort a01: egen market_participation=sum(market) 
recode market_participation (1/max=1 "Yes")(nonm=0 "No"), gen(marketp1)
duplicates drop a01, force 
keep a01 marketp1
save marketstaple12.dta, replace
use $BIHS12\029_mod_m2_male.dta, clear //Marketing of Livestock, Jute, Wheat, Pulses, Fish, Fruits, Vegetable
keep a01 m2_16 m2_18
recode m2_16 (2/5=1 "yes")(nonm=0 "no"), gen(market)
bysort a01: egen market_participation=sum(market) 
recode market_participation (1/max=1 "Yes")(nonm=0 "No"), gen(marketp2)
duplicates drop a01, force 
keep a01 marketp2
merge 1:1 a01 using marketstaple15, nogen
gen mrkt=marketp1+marketp2
recode mrkt (1/max=1 "yes")(nonm=0 "no"), gen(marketp)
keep a01 marketp
save mrkt12, replace

*access to facility
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==3 
drop s_01
rename s_06 road
label var road "Road access (minute)"
tempfile cal
save `cal'
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==6 
drop s_01
rename s_06 market
label var market "Market access (minute)"
merge 1:1 a01 using `cal', nogen
save facility12, replace
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==7 
drop s_01
rename s_06 town
label var town "Distance to near town (minute)"
tempfile town
save `town'
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==9 
drop s_01
rename s_06 agri
label var agri "Agricultural office (minute)"
merge 1:1 a01 using facility12, nogen
merge 1:1 a01 using `town', nogen
save facility12, replace
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==6
drop s_01
rename s_06 bazaar
label var bazaar "Periodic bazaar access (minute)"
merge 1:1 a01 using facility12, nogen
save facility12, replace
use $BIHS12\037_mod_s_male, clear
keep a01 s_01 s_06
keep if s_01==5
drop s_01
rename s_06 shop
label var shop "Local shop access (minute)"
merge 1:1 a01 using facility12, nogen
save facility12, replace


**Agricultural extension
use $BIHS12\021_mod_j1_male, clear 
keep a01 j1_01 j1_04
recode j1_01 (1=1 "yes")(nonm=0 "no"), gen(agent)
recode j1_04 (1=1 "yes")(nonm=0 "no"), gen(phone)
gen aes=agent+phone
recode aes (1/max=1 "yes")(nonm=0 "no"), gen(extension)
label var extension "Access to agricultural extension service (=1 if yes)"
keep a01 extension
save extension12, replace

**keep livestock variables
use $BIHS12\023_mod_k1_male.dta, clear //animal
bysort a01: gen livstck=sum(k1_04)
recode livstck (1/max=1 "yes")(0=0 "no"),gen(lvstck)
label var lvstck "Livestock ownership(=1)"
keep a01 livestock k1_18 lvstck
save lvstck12.dta, replace
keep a01 lvstck
duplicates drop a01, force
save lvstckown12.dta, replace //ownership

/*Livestock product*/
use $BIHS12\024_mod_k2_male.dta , clear //milk and egg but no data
keep a01 k2_12 bprod
rename bprod livestock
save lvstckpr12.dta, replace

/*create livestock income*/
use lvstck12, clear //create livestock income
rename k1_18 k2_12 //rename livestock income
keep a01 k2_12 livestock
append using lvstckpr12.dta //append using lvstckpr_12.dta
save eli12, replace //save a file for farm diversification index

bysort a01: egen ttllvstck=sum(k2_12) // livestock product income
label var ttllvstck "Livestock income"
drop k2_12
duplicates drop a01, force
save lvinc12.dta, replace
use lvstckown12.dta, clear //merge currently ownership and livestock income
merge 1:1 a01 using lvinc12, nogen
save lvstckinc12.dta, replace

**livestock diversificatioin
use $BIHS12\023_mod_k1_male.dta, clear 
drop if k1_04==0
bysort a01: egen livdiv=count(livestock)
keep a01 livdiv
duplicates drop a01, force
save livdiv12.dta, replace

/*fishery income*/
use $BIHS12\027_mod_l2_male.dta, clear
bysort a01:egen fshinc=sum(l2_12)
bysort a01:egen fshdiv=count(l2_01)
keep a01 fshdiv fshinc
label var fshdiv "fish diversification"
label var fshinc "fishery income"
duplicates drop a01, force
save fsh12.dta, replace

**keep Non-farm self employment
use $BIHS12\005_mod_c_male.dta, clear
keep a01 c05 c09 c14
keep if c09 == 3 //keep self employed
drop if c09==1 // drop farm wage
bysort a01: egen offsel=sum(c14)
gen offself=12*offsel
keep a01 offself
label var offself "Non-farm self employment"
duplicates drop a01, force
save nnfrminc12.dta, replace

**Non-farm employment 
use $BIHS12\005_mod_c_male.dta, clear
keep a01 c05 c09 c14
keep if c09 != 3 //keep salary and wage
drop if c05== 1 //drop farm wage
gen yc14=12*c14
bysort a01: egen offrminc=sum(yc14)
label var offrminc "Non-farm wage and salary"
keep a01 offrminc
duplicates drop a01, force
save offfrm12.dta, replace

**farm wage
use $BIHS12\005_mod_c_male.dta, clear
keep if c05== 1
keep a01 c14
replace c14=0 if c14==.
bysort a01: egen frmwag=sum(c14)
gen frmwage=frmwag*12
keep a01 frmwage
label var frmwage "Farm wage"
duplicates drop a01, force
save frmwage12.dta, replace

*Non-agricultural enterprise
use $BIHS12\030_mod_n_male.dta, clear
bysort a01: egen nnagent=sum(n05)
label var nnagent "non-agricultural enterprise"
keep a01 nnagent
duplicates drop a01, force
save nnagent12.dta, replace

/*food consumption*/
use $BIHS12/031_mod_o1_female, clear

recode o1_01 (1/16 277/290 297 901 296 302 =1 "Cereals")(61 62 621 622 295 301 3231=2 "White tubers and roots")(41/60 63/82 86/115 904 905 291 292 298 441=3 "Vegetables")(141/170 317 319 907=4 "Fruits")(121/129 906 322 =5 "Meat")(130/135 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 902 299=8 "Legumes, nuts and seeds")(132/135 1321/1323 2941/2943 294=9 "Milk and milk products")(31/36 903 312 =10 "Oils and fats")(266/271 293 303/311=11 "Sweets")(246/251 253/264 272/276 318 323 910 300 314/321 2521 2522 252 313= 12 "Spices, condiments and beverages"), gen(hdds_i)

duplicates drop a01 hdds_i, force
bysort a01: egen hdds=count(a01)
drop hdds_i
label var hdds "Household Dietary Diversity"
duplicates drop a01, force
save fd12.dta, replace

**Consumption expenditure
use BIHS_hh_variables_r123, clear
keep if round==1
keep a01 pc_expm_d pc_foodxm_d pc_nonfxm_d
save expend12.dta, replace

**Idiosyncratic shocks
use $BIHS12\038_mod_t1_male.dta, clear
recode t1_02 (9 10= 1 "Yes") (nonm=0 "No"), gen(c)
recode t1_02 (11 12 13=1 "Yes")(nonm=0 "No"), gen(l)
bysort a01: egen idi_crp=sum(c) 
bysort a01: egen idi_lvstck=sum(l)
keep a01 idi_crp idi_lvstck
recode idi_crp (1/max=1 "Yes") (0=0 "No"), gen(idcrp)
label var idcrp "Crop shock(=1 if yes)"
recode idi_lvstck (1/max=1 "Yes") (0=0 "No"), gen(idliv)
label var idliv "Livestock shock(=1 if yes)"
keep a01 idcrp idliv
duplicates drop a01, force
gen idi_crp_liv=idcrp*idliv
label var idi_crp_liv "Crop shock*Livestock shock "
save idisyn12.dta, replace

**farm diversification index
use $BIHS12\028_mod_m1_male, clear //crop income
keep a01 m1_02 m1_10 m1_18 m1_20
bysort a01 m1_02: egen eis=sum(m1_10)
keep a01 m1_02 eis
duplicates drop a01 m1_02, force
save eci12, replace
use $BIHS12\027_mod_l2_male.dta, clear // fishery income
keep a01 l2_12 l2_01
bysort a01 l2_01: egen eis=sum(l2_12)
keep a01 eis l2_01
duplicates drop a01 l2_01, force
tempfile efi12
save efi12, replace
use eli12, clear //livestock income
bysort a01 livestock: egen eis=sum(k2_12)
keep a01 eis livestock 
duplicates drop a01 livestock, force
append using efi12
append using eci12
bysort a01: egen frminc=sum(eis) //total farm income
gen seir=(eis/frminc)^2 //squared each farm income ratio 
bysort a01: egen frm_div1=sum(seir)
bysort a01: gen frm_div=1-frm_div1
gen p=eis/frminc 
gen lnp=log(p)
gen shnn1=p*lnp
bysort a01: egen shn1=sum(shnn1)
gen shnf=-1*(shn1)
duplicates drop a01, force
keep a01 frm_div shnf
save frm_div12, replace

**Farm diversification
use crp12.dta, clear
merge 1:1 a01 using livdiv12, nogen
merge 1:1 a01 using fsh12, nogen
replace livdiv=0 if livdiv==.
replace crpdivnm=0 if crpdivnm==.
replace fshdiv=0 if fshdiv==.
gen frmdiv=crpdivnm+livdiv+fshdiv
save frmdiv12.dta, replace

**Income diversification
use crpincm12.dta, clear
merge 1:1 a01 using nnrn12.dta, nogen
merge 1:1 a01 using ssnp12.dta, nogen
merge 1:1 a01 using lvstckinc12.dta, nogen
merge 1:1 a01 using offfrm12.dta, nogen
merge 1:1 a01 using fsh12.dta, nogen
merge 1:1 a01 using nnagent12.dta, nogen
merge 1:1 a01 using rem12.dta, nogen
merge 1:1 a01 using frmwage12.dta, nogen
merge 1:1 a01 using nnfrminc12.dta, nogen
drop dstnc_sll_ trnsctn lvstck fshdiv v2_06
replace crp_vl=0 if crp_vl==.
replace offrminc=0 if offrminc==.
replace nnearn=0 if nnearn==.
replace fshinc=0 if fshinc==.
replace ttllvstck=0 if ttllvstck==.
replace remi=0 if remi==.
replace nnagent=0 if nnagent==.
replace frmwage=0 if frmwage==.
replace offself=0 if offself==.
gen ttinc= crp_vl+nnearn+trsfr+ttllvstck+offrminc+fshinc+nnagent+remi+frmwage+offself //total income
gen aginc=ttllvstck+crp_vl+fshinc
gen nonself=offself //off-farm self
gen nonwage=offrminc //off-farm wage
gen nonearn=remi+trsfr+nnearn //non-earned 
gen i1=(aginc/ttinc)^2
gen i2=(frmwage/ttinc)^2
gen i3=(nonself/ttinc)^2
gen i4=(nonwage/ttinc)^2
gen i5=(nonearn/ttinc)^2
gen es=i1+i2+i3+i4+i5
gen inc_div=1-es
label var inc_div "Income diversification index" //simpson
gen p1=(aginc/ttinc)
gen p2=(frmwage/ttinc)
gen p3=(nonself/ttinc)
gen p4=(nonwage/ttinc)
gen p5=(nonearn/ttinc)
gen lnp1=log(p1)
gen lnp2=log(p2)
gen lnp3=log(p3)
gen lnp4=log(p4)
gen lnp5=log(p5)
gen shn1=p1*lnp1
gen shn2=p2*lnp2
gen shn3=p3*lnp3
gen shn4=p4*lnp4
gen shn5=p5*lnp5
egen shnni = rowtotal(shn1 shn2 shn3 shn4 shn5)
gen shni=-1*(shnni) //shannon
keep a01 aginc frmwage nonself nonwage nonearn inc_div shni ttinc // ttinc crp_vl nnearn trsfr ttllvstck offrminc fshinc nnagent
save incdiv12.dta, replace


**merge all 2012 dataset
use 2012.dta,clear
merge 1:1 a01 using hh12, nogen
merge 1:1 a01 using sciec12, nogen
merge 1:1 a01 using agrnmic12, nogen
merge 1:1 a01 using nnrn12, nogen
merge 1:1 a01 using crp_div12, nogen
merge 1:1 a01 using idisyn12.dta, nogen
merge 1:1 a01 using lvstckinc12.dta,nogen
merge 1:1 a01 using crpincm12,nogen
merge 1:1 a01 using offfrm12.dta,nogen
merge 1:1 a01 using ssnp12,nogen
merge 1:1 a01 using nnfrminc12,nogen
merge 1:1 a01 using crp12,nogen
merge 1:1 a01 using irri12, nogen
merge 1:1 a01 using incdiv12, nogen
merge 1:1 a01 using frmdiv12.dta, nogen
merge 1:1 a01 using fd12.dta, nogen
merge 1:1 a01 using expend12, nogen
merge 1:1 a01 using frm_div12, nogen
merge 1:1 a01 using mrkt12, nogen
merge 1:1 a01 using facility12, nogen
merge 1:1 a01 using extension12, nogen
merge 1:1 a01 using mobile12, nogen
merge 1:1 a01 using poverty12, nogen
merge 1:1 a01 using migrant12, nogen
merge 1:1 a01 using asset12, nogen
merge 1:1 a01 using wm12, nogen
merge 1:1 a01 using wei_r1, nogen
merge 1:1 a01 using wcrdt12.dta, nogen
merge 1:1 a01 using vlnc12.dta, nogen
merge 1:1 a01 using cntr12.dta, nogen
merge 1:1 a01 using masst12.dta, nogen
merge 1:1 a01 using fl12.dta, nogen
merge 1:1 a01 using ml12.dta, nogen
label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
//gen lnoff=log(offrmagr)
gen year=2012
replace crpdivnm=0 if crpdivnm==.
drop if couple==.
replace wm=0 if wm==.


** Instrumental variable 
* データセットの読み込み、またはサンプルデータの作成
* 実際のデータに合わせて、以下の部分は調整してください。

*-------------------------------------------------------------------------------
* ステップ1: 年齢と世帯サイズを5つのカテゴリーに分類
*-------------------------------------------------------------------------------

* 年齢のカテゴリ化 (age_cat)
* 適切なカテゴリの閾値はデータ分布に応じて調整してください
xtile age_cat = age_w, nq(5) // 年齢を5つの等しいグループに分割

* 世帯サイズのカテゴリ化 (hh_size_cat)
* 世帯サイズがすでに離散的なカテゴリ変数であれば、`xtile`の代わりに`egen group()`などを使うか、そのまま利用することも検討できます。
* 例えば、`recode hh_size (1=1) (2-3=2) (4-5=3) (6-7=4) (8/max=5), gen(hh_size_cat)` のように具体的な区切りでカテゴリ化することも可能です。
xtile hh_size_cat = hh_size, nq(5) // 世帯サイズを5つの等しいグループに分割

* 結果を確認
tabulate age_cat
tabulate hh_size_cat

*-------------------------------------------------------------------------------
*ステップ2: 25の複合カテゴリーの作成
*-------------------------------------------------------------------------------

* 年齢カテゴリと世帯サイズカテゴリの組み合わせで新しいカテゴリ変数 (age_hh_size_cat) を作成
* この変数には1から25までの値が割り振られます。
egen age_hh_size_cat = group(age_cat hh_size_cat)

* 結果を確認
tabulate age_hh_size_cat, missing // 25のカテゴリが生成されたことを確認

*-------------------------------------------------------------------------------
*ステップ3: IV (Peer Mobile Phone Ownership Rate) の計算
*-------------------------------------------------------------------------------

* 各 survey_id, age_hh_size_cat グループ内で、village_id が異なる個体の mobile_owner の平均を計算します。
* 処理を高速化するため、事前にデータをソートすることを推奨します。
sort a01 age_hh_size_cat uncode

* 各観察値に対して、対応するピアグループの携帯電話所有率を計算するループ処理
* 大規模データの場合、このループは時間がかかる可能性があります。

gen iv_peer_mobile_ownership = .

preserve // 既存のデータを一時的に保存

* 各調査、各年齢・世帯サイズカテゴリー、各村ごとの携帯電話所有率を計算
bysort a01 age_hh_size_cat uncode: egen un_mobile_avg = mean(wm) //所有率
bysort a01 age_hh_size_cat uncode: egen un_mobile_sum = sum(wm) //所有人数
bysort a01 age_hh_size_cat uncode: egen un_total_members = count(wm) //union人数

* 各個人のIVを計算 (自身の村を除外した平均)
* (カテゴリ全体の合計 - 自身の村の合計) / (カテゴリ全体の人数 - 自身の村の人数)
gen mob_sum_excl_own_vil = category_mobile_owner_sum - (union_mobile_owner_avg * _N) // _Nはbysort group内の要素数
gen sum_mob_excl_vil = category_total_members - _N // _Nはbysort group内の要素数

* IVの計算 (ゼロ除算を防ぐため、分母が0でないことを確認)
replace iv_peer_mobile_ownership = ///
    sum_mob_excl_vil / sum_mob_excl_vil ///
    if sum_mob_excl_vil > 0


* 結果の確認
summarize iv_peer_mobile_ownership
list survey_id age_cat hh_size_cat age_hh_size_cat village_id mobile_owner iv_peer_mobile_ownership in 1/20

save
** Save the dataset
save 2012.dta, replace


*** Individual level data for mobile phones
use hh12_i, clear
merge 1:1 a01 mid using inc12_i, nogen
merge 1:1 a01 mid using m12_i, nogen
drop if age_i==.
replace mobile=0 if mobile==.
merge m:1 a01 using 2012, nogen

label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
//gen lnoff=log(offrmagr)

save 2012_i.dta, replace
