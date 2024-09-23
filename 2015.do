/*create 2015 dataset for regression: mobile money women empowerment child health*/
/*Author: Masanori Matsuura*/
clear all
set more off
*set the pathes

global BIHS18Community = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Community"
global BIHS18Female = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Female"
global BIHS18Male = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2018\BIHSRound3\Male"
global BIHS15 = "C:\Users\mm_wi\Documents\research\ADB_digital\analysis\BIHS2015"

*BIHS2015 data cleaning 
**keep geographical code
use $BIHS15\001_r2_mod_a_male, clear
keep a01 dvcode dcode District_Name uzcode uncode mzcode Village
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
save 2015, replace

** HH composition, HH with husband and wife
use $BIHS15\003_r2_male_mod_b1.dta, clear
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
save hh15.dta, replace


** individual demography
use $BIHS15\003_r2_male_mod_b1.dta, clear
keep if b1_02 > 17 
keep if b1_02 < 65
rename (b1_01 b1_02 b1_08) (male age_i edu)
replace male=0 if male==2
recode edu (10/16 33/75=1)(nonm=0), gen(schll_i) // convert  education into schoolling year 
label var age_i "Age"
label var schll_i "Secondary school certificate of women"

keep a01 mid age_i schll_i 
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
save hh15_i.dta, replace

** individual income
use $BIHS15\008_r2_mod_c_male.dta, clear
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

keep a01 mid wrk csw_awrk csw_nawrk slr_emp slf_emp trdprd_emp off_emp csw_ah csw_nah slr_h slf_h trdprd_h off_h csw_ai csw_nai slr_i slf_i trdprd_i off_i

duplicates drop a01 mid csw_awrk csw_nawrk slr_emp slf_emp off_emp csw_ah csw_nah slr_h slf_h off_h csw_ai csw_nai slr_i slf_i off_i, force
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
save inc15_i.dta, replace

**Individual mobile phone ownership
use $BIHS15\010_r2_mod_d1_male, clear //individual
keep if d1_02==24 //only mobile phones
rename d1_06_a mid
merge 1:1 a01 mid using $BIHS15\003_r2_male_mod_b1.dta, nogen
gen mobile=1 if  d1_03==1
replace mobile=1 if d1_03==1
drop if d1_03 == .
replace mobile=0 if mobile==.
label var mobile "Men's mobile ownership"
keep a01 mobile
tempfile m1
save `m1'

use $BIHS15\010_r2_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_b mid
merge 1:1 a01 mid using $BIHS15\003_r2_male_mod_b1.dta, nogen
gen mobile=1 if  d1_03==1
replace mobile=1 if d1_03==1
drop if d1_03 == .
replace mobile=0 if mobile==.
label var mobile "Mobile ownership"
keep a01 mobile
append using `m1'

save m215.dta, replace

use $BIHS15\010_r2_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_c mid
merge 1:1 a01 mid using $BIHS15\003_r2_male_mod_b1.dta, nogen
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
duplicates drop a01 mid, force

save m15_i, replace


** female labor force participation
use $BIHS15\008_r2_mod_c_male.dta, clear
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

keep a01 wrk_wf csw_awrk csw_nawrk slr_emp slf_emp trdprd_emp off_emp csw_ah csw_nah slr_h slf_h trdprd_h off_h csw_ai csw_nai slr_i slf_i trdprd_i off_i

duplicates drop a01 csw_awrk csw_nawrk slr_emp slf_emp off_emp csw_ah csw_nah slr_h slf_h off_h csw_ai csw_nai slr_i slf_i off_i, force
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
save fl15.dta, replace

** male labor force participation
use $BIHS15\008_r2_mod_c_male.dta, clear
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
save ml15.dta, replace


** village-level mobile money
use $BIHS15\003_module_cb_community, clear
keep if cb02==7 //
merge 1:1 slno using $BIHS15\109_module_identity_other_community, nogen
rename (cb03 cb04) (magency magency_n)
replace magency_n=0 if magency_n==.
replace magency=0 if magency==2
label var magency "Mobile agency in a community"
label var magency_n "Number of mobile agency in a community"
keep Village magency magency_n
save com15.dta, replace


**Men's mobile phone ownership
use $BIHS15\010_r2_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_a mid
merge 1:1 a01 mid using $BIHS15\003_r2_male_mod_b1.dta, nogen
gen mobile=1 if mid==1 & d1_03==1
replace mobile=1 if mid==71 & d1_03==1
drop if d1_03 == .
replace mobile=0 if mobile==.
label var mobile "Men's mobile ownership"
keep a01 mobile
tempfile m1
save `m1'

use $BIHS15\010_r2_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_b mid
merge 1:1 a01 mid using $BIHS15\003_r2_male_mod_b1.dta, nogen
gen mobile=1 if mid==1 & d1_03==1
replace mobile=1 if mid==71 & d1_03==1
drop if d1_03 == .
replace mobile=0 if mobile==.
label var mobile "Men's mobile ownership"
keep a01 mobile
append using `m1'

save m215.dta, replace

use $BIHS15\010_r2_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_c mid
merge 1:1 a01 mid using $BIHS15\003_r2_male_mod_b1.dta, nogen
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

save mobile15, replace

**Women's mobile phone ownership
use $BIHS15\010_r2_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_a mid
merge 1:1 a01 mid using $BIHS15\003_r2_male_mod_b1.dta, nogen
gen wmobile=1 if mid==2 & d1_03==1
replace wmobile=1 if mid==71 & d1_03==1
drop if d1_03 == .
replace wmobile=0 if wmobile==.
label var wmobile "Women's mobile ownership"
keep a01 wmobile
tempfile wm1
save `wm1'

use $BIHS15\010_r2_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_b mid
merge 1:1 a01 mid using $BIHS15\003_r2_male_mod_b1.dta, nogen
gen wmobile=1 if mid==2 & d1_03==1
replace wmobile=1 if mid==71 & d1_03==1
drop if d1_03 == .
replace wmobile=0 if wmobile==.
label var wmobile "Women's mobile ownership"
keep a01 wmobile
append using `wm1'

save wm215.dta, replace

use $BIHS15\010_r2_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_c mid
merge 1:1 a01 mid using $BIHS15\003_r2_male_mod_b1.dta, nogen
gen wmobile=1 if mid==2 & d1_03==1
replace wmobile=1 if mid==71 & d1_03==1
drop if d1_03 == .
replace wmobile=0 if wmobile==.
label var wmobile "Women's mobile ownership"
keep a01 wmobile

append using wm215

bysort a01: egen wmob=total(wmobile)
recode wmob (0=0 "No")(nonm=1 "Yes" ), gen(wm)
label var wm "Women's mobile ownership"

duplicates drop a01, force
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

save wm15.dta, replace


** Intimate partner violence
use $BIHS15\081_r2_mod_z4_female, clear
drop if z4_01a==.
recode z4_02 (.=0 "No")(nonm=1 "Yes"), gen(vlnc)
label var vlnc "Any violence"
recode z4_01a (1 2=1 "Yes")(nonm=0 "No"), gen(em_vlnc)
replace em_vlnc=1 if z4_01b==1 | z4_01b==2 | z4_01c==1 | z4_01c==2
label var em_vlnc "Emotional violence"
recode z4_01d (1 2=1 "Yes")(nonm=0 "No"), gen(py_vlnc)
label var py_vlnc "Physical violence"
keep a01 vlnc em_vlnc py_vlnc
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
save vlnc15.dta, replace


** Contraceptive use
use $BIHS15\080_r2_mod_z3_female, clear
recode z3_01 (1=1 "Yes")(2=0 "No"), gen(brth_cntrl)
label var brth_cntrl "Use contraceptive"
keep a01 brth_cntrl
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
save cntr15.dta, replace



** asset brought to marriage
use $BIHS15\082_r2_mod_z5_female, clear
rename z5_01 masst
label var masst "Asset brought to marriage"
replace masst=0 if masst==2
keep a01 masst
duplicates drop a01 masst, force
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
save masst15.dta, replace

** credit access
use $BIHS15\096_r2_weai_ind_mod_we4_female.dta, clear
recode we4_08d (1=1 "Yes")(2=0 "No"), gen(w_crdt)
label var w_crdt "Women's access to credit"
replace w_crdt=0 if w_crdt==.
keep a01 w_crdt
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
save wcrdt15.dta, replace


** migrant status
use $BIHS15\053_r2_mod_v1_male, clear //if any members are migrants
recode v1_01 (1=1 "Yes")(2=0 "No"), gen(migrant)
keep a01 migrant
label var migrant "Member migration (1/0)"
duplicates drop a01, force
save migrant15, replace

*mobile money
use $BIHS15\047_r2_mod_q_male, clear
recode q_20d_1 (1/5=1)(nonm=0), gen(mm_1)
recode q_20d_2 (1/5=1)(nonm=0), gen(mm_2)
recode q_20d_3 (1/5=1)(nonm=0), gen(mm_3)
keep if mm_1==1 | mm_2==1 | mm_3==1
gen mm_o=1
label var mm_o "Mobile money user"
duplicates drop a01, force
keep a01 mm_o
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
save mm_o15.dta, replace

**mobile money
use $BIHS15\108_r2_weai_ind_mod_we7_female, clear
keep if we7b_13_1==2 | we7b_13_1==3 | we7b_13_1==4 | we7b_13_2==2 | we7b_13_2==3 | we7b_13_2==4 | we7b_13_3==2 | we7b_13_3==3 | we7b_13_3==4
gen mm_p=1
label var mm_p "Mobile money user"
keep a01 mm_p
keep a01 mm
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
save mm15.dta, replace

** energy poverty
use $BIHS15\045_r2_mod_p1_male, clear
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
keep a01 elcex enex gasex nonex dum_el dum_gas
save ene15, replace

**cooking fuel
use $BIHS15\047_r2_mod_q_male, clear
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
use $BIHS15\hhexpenditure_R2, clear // poverty status and depth (gap)
merge 1:1 a01 using $BIHS15\mpi_R2, nogen //multidimentional poverty index
keep a01 pcexp_da p190hcgcpi p190hcfcpi p320hcgcpi p320hcfcpi pov190gapgcpi deppov190gcpi pov190gapfcpi deppov190fcpi pov320gapgcpi pov320gapfcpi deppov320fcpi deppov320gcpi hc_mpi mpiscore
save poverty15.dta, replace

**social network
use  $BIHS15\077_r2_mod_y8_female, clear
recode y8_06 (1=1 "Yes")(2=0 "No")(.=0 "No"),gen(network)
keep a01 network
label var network "Social network (discussion)"
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
save network15.dta, replace

** keep age gender education occupation of HH
use $BIHS15\003_r2_male_mod_b1.dta, clear
bysort a01: egen hh_size=count(a01)
label var hh_size "Household size"
bysort a01: egen ch_size_i=count(a01) if b1_02 < 19
bysort a01: egen ch_size=max(ch_size_i)
label var ch_size "Number of children" 
bysort a01: egen ad_size=count(a01) if b1_02 > 18
label var ad_size "Number of adults"
keep if b1_03==1 
keep a01 mid b1_01 b1_02 b1_04 b1_04a b1_08 b1_10 b1_13a b1_13b hh_size ad_size
rename (b1_01 b1_02 b1_04 b1_04a b1_08 b1_13a b1_13b)(gender_hh age_hh marital_hh age_marital_hh edu_hh main_earning_1 main_earning_2)
recode edu_hh (10/16 33/75=1)(nonm=0), gen(schll_hh) // convert  education into schoolling year 
label var age_hh "Age of HH"
label var schll_hh "Secondary school certificate of HH"
recode gender_hh (1=1 "Man")(2=0 "Woman"), gen(Male)
label var Male "Male(=1)"
recode b1_10 (1/72=1 "Yes")(nonm=0 "No"), gen(wrk_hs)
label var wrk_hs "Current working status of husband"

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
save sciec15.dta, replace

**Asset index
use $BIHS15\010_r2_mod_d1_male, clear  
keep a01 d1_02 d1_03
drop if d1_02==24
tab d1_02, gen(a)
local varlist "a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23  a25 a26 a27 a28 a29 a30 a31 a32 a33 a34 a35 a36 a37 a38 a39 a40 a41 a42 a43 a44 a45 a46 a47 a48 a49 a50 a51 a52 a53 a54 a55 a56" //a24 mobile phone
sort a01 d1_02
foreach x in `varlist'{
	bysort a01: egen s_`x'=sum(`x')
}
local varlist "s_a1 s_a2 s_a3 s_a4 s_a5 s_a6 s_a7 s_a8 s_a9 s_a10 s_a11 s_a12 s_a13 s_a14 s_a15 s_a16 s_a17 s_a18 s_a19 s_a20 s_a21 s_a22 s_a23  s_a25 s_a26 s_a27 s_a28 s_a29 s_a30 s_a31 s_a32 s_a33 s_a34 s_a35 s_a36 s_a37 s_a38 s_a39 s_a40 s_a41 s_a42 s_a43 s_a44 s_a45 s_a46 s_a47 s_a48 s_a50 s_a49 s_a51 s_a52 s_a53 s_a54 s_a55 s_a56" //s_a24 mobile phone
pca `varlist'
predict asset
keep a01 asset
recode asset (min/-2.331655=1)(nonm=0), gen(lwlth)
label var lwlth "Poor asset"
duplicates drop a01, force

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
save asset15.dta, replace

**keep agronomic variables
use $BIHS15\014_r2_mod_g_male, clear
keep if g01==2
bysort a01: egen farmsize=total(g02) 
label var farmsize "Farm Size(decimal)"
gen ln_farm=log(farmsize)
label var ln_farm "Farm size(log)"
duplicates drop a01 farmsize, force
keep a01 farmsize ln_farm
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
save agrnmic15.dta, replace

**saving
use $BIHS15\012_r2_mod_e_male.dta, clear
replace e06=0 if e06==.
bysort a01: egen saving=sum(e06)
keep a01 saving 
duplicates drop a01, force
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
save save15.dta, replace

**non-earned income
use $BIHS15\056_r2_mod_v4_male, clear
drop hh_type
bysort a01: gen nnearn=v4_01+v4_02+v4_03+v4_04+v4_05+v4_06+v4_07+v4_08+v4_09+v4_10+v4_11+v4_12
label var nnearn "Non-earned income"
keep a01 nnearn
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
save nnrn15.dta, replace //non-earned  income

**remittance
use $BIHS15\054_r2_mod_v2_male, clear
replace v2_06=0 if v2_06==.
bysort a01: egen remi=sum(v2_06) //if v2_07==10 //total
bysort a01: egen remi_dom=sum(v2_06) if v2_03!=. //v2_07==10 & Domestic
bysort a01: egen remi_for=sum(v2_06) if v2_04!=. //v2_07==10 &Foereign remittance

bysort a01: egen remi_n=sum(v2_05) //if v2_07==10
label var remi_n "Frequency of remittance"
duplicates drop a01, force
label var remi "Value of remittance"
label var remi_dom "Value of domestic remittance"
label var remi_for "Value of foreign remittance"

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
keep a01 remi remi_n remi_dom remi_for
save rem15.dta, replace

**agricultural production cost
use $BIHS15\015_r2_mod_h1_male, clear //seed cost
egen sc_i=rowtotal(h1_07 h1_08), missing
bysort a01: egen sc=sum(sc_i)
duplicates drop a01, force
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
keep a01 sc
tempfile sc15
save `sc15'
use $BIHS15\016_r2_mod_h2_male, clear //irrigation cost
bysort a01: egen ic=sum(h2_05)
duplicates drop a01, force
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
keep a01 ic
tempfile ic15
save `ic15'

use $BIHS15\018_r2_mod_h4_male, clear //machinery cost
egen mc_i=rowtotal(h4_04 h4_05 h4_06 h4_07 h4_08 h4_09 h4_10), missing
bysort a01: egen mc=sum(mc_i)
duplicates drop a01, force
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
keep a01 mc
tempfile mc15
save `mc15'
use $BIHS15\019_r2_mod_h5_male, clear //labor cost
egen lc_i=rowtotal(h5_10 h5_40 h5_34 h5_28 h5_22 h5_16 h5_04 h5_46 h5_06 h5_18 h5_12 h5_24 h5_42 h5_36 h5_30 h5_48), missing
bysort a01: egen lc=sum(lc_i)
duplicates drop a01, force
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
keep a01 lc
tempfile lc15
save `lc15'
use $BIHS15\020_r2_mod_h6_male, clear //post-labor cost
egen plc_i=rowtotal(h6_04 h6_06 h6_08 h6_13 h6_15 h6_19 h6_21 h6_25 h6_27 h6_31 h6_33), missing
bysort a01: egen plc=sum(plc_i)
duplicates drop a01, force
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
keep a01 plc
tempfile plc15
save `plc15'

use $BIHS15\036_r2_mod_k3_male, clear //livestock cost
egen lvc_i=rowtotal(k3_03 k3_07 k3_09), missing
bysort a01: egen lvc=sum(lvc_i)
duplicates drop a01, force
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
keep a01 lvc
tempfile lvc15
save `lvc15'
use $BIHS15\037_r2_mod_l1_male, clear //fishery cost
bysort a01: egen fc=sum(l1_09)
duplicates drop a01, force
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
keep a01 fc
tempfile fc15
save `fc15'

**Social safety net program
use $BIHS15/052_r2_mod_u_male.dta, clear
bysort a01: gen trsfr=sum(u02)
label var trsfr "Social safety net program transfer"
keep a01 trsfr
duplicates drop a01, force
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
save ssnp15.dta, replace

**number of crop type
use $BIHS15\015_r2_mod_h1_male, clear // crop type
keep a01 crop_a crop_b h1_02 h1_03
rename (h1_02 h1_03)(crp_typ plntd)
bysort a01 crop_a: egen typ_plntd=sum(plntd)
duplicates drop a01 crop_a, force
bysort a01: egen crpdivnm=count(crop_a) //crop diversification (Number of crop species including vegetables and fruits produced by the household in the last year (number))
label var crpdivnm "Crop diversity"
keep a01 crpdivnm
duplicates drop a01, force
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
save crp15.dta, replace

**market access 
use $BIHS15\039_r2_mod_m1_male, clear //Marketing of Paddy, Rice, Banana, Mango, and Potato
keep a01 m1_16 m1_18
recode m1_16 (2/6=1 "yes")(nonm=0 "no"), gen(market)
bysort a01: egen market_participation=sum(market) 
recode market_participation (1/max=1 "Yes")(nonm=0 "No"), gen(marketp1)
duplicates drop a01, force 
keep a01 marketp1
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
save marketstaple15.dta, replace

**Marketing of ag products
use $BIHS15\040_r2_mod_m2_male, clear //Marketing of Livestock, Jute, Wheat, Pulses, Fish, Fruits, Vegetable
keep a01 m2_16 m2_18
recode m2_16 (2/6=1 "yes")(nonm=0 "no"), gen(market)
bysort a01: egen market_participation=sum(market) 
recode market_participation (1/max=1 "Yes")(nonm=0 "No"), gen(marketp2)
duplicates drop a01, force 
keep a01 marketp2
merge 1:1 a01 using marketstaple15, nogen
gen mrkt=marketp1+marketp2
recode mrkt (1/max=1 "yes")(nonm=0 "no"), gen(marketp)
keep a01 marketp
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
save mrkt15, replace

/*** community mobile agency
use $BIHS15\111_module_cb_community.dta, clear
keep if ca01==6
rename (ca03 ca04) (magency magency_n)
replace magency_n=0 if magency_n==.
label var magency "Mobile agency in a community"
label var magency_n "Number of mobile agency in a community"
save com15.dta, replace*/

**access to facility
use $BIHS15\049_r2_mod_s_male.dta, clear
keep a01 s_01 s_04 s_06
keep if s_01==3 
drop s_01
rename s_06 road
rename s_04 road_d
label var road "Road access (minute)"
tempfile cal
save `cal'
use $BIHS15\049_r2_mod_s_male.dta, clear
keep a01 s_01 s_04 s_06
keep if s_01==9 
drop s_01
rename s_06 agri
rename s_04 agri_d
label var agri "Agricultural office (minute)"
tempfile aes
save `aes'
use $BIHS15\049_r2_mod_s_male.dta, clear
keep a01 s_01 s_04 s_06
keep if s_01==7 
drop s_01
rename s_06 town
rename s_04 town_d
label var town "Distance to near town (minute)"
tempfile town
save `town'
use $BIHS15\049_r2_mod_s_male.dta, clear
keep a01 s_01 s_04 s_06
keep if s_01==6
drop s_01
rename s_04 bazaar_d
rename s_06 bazaar
label var bazaar "Periodic bazaar access (minute)"
tempfile bazaar
save `bazaar'
use $BIHS15\049_r2_mod_s_male.dta, clear
keep a01 s_01 s_04 s_06
keep if s_01==5
drop s_01
rename s_06 shop
rename s_04 shop_d
label var shop "Local shop access (minute)"
tempfile shop
save `shop'
use $BIHS15\049_r2_mod_s_male.dta, clear
keep a01 s_01 s_04 s_06
keep if s_01==6 
drop s_01
rename s_06 market
rename s_04 market_d
label var market "Market access (minute)"

merge 1:1 a01 using `cal', nogen
merge 1:1 a01 using `aes', nogen
merge 1:1 a01 using `town', nogen
merge 1:1 a01 using `bazaar', nogen
merge 1:1 a01 using `shop', nogen

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
save facility15, replace


**keep livestock variables
use $BIHS15\034_r2_mod_k1_male.dta, clear //animal
bysort a01: gen livstck=sum(k1_04)
recode livstck (1/max=1 "yes")(0=0 "no"),gen(lvstck)
label var lvstck "Livestock ownership(=1)"
keep a01 livestock k1_18 lvstck
save lvstck15.dta, replace
keep a01 lvstck
duplicates drop a01, force
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
save lvstckown15.dta, replace //ownership

/*Livestock product*/
use $BIHS15\035_r2_mod_k2_male.dta, clear //milk and egg
keep a01 k2_12 bprod
label var k2_12 "Total value of livestock product"
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
save lvstckpr15.dta, replace //livestock product

/*create livestock income*/
use lvstck15, clear 
rename k1_18 k2_12 //rename livestock income
keep a01 k2_12 livestock
append using lvstckpr15.dta
drop diff ext a01R2 
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
save eli15, replace //save a file for farm diversification index

bysort a01: egen ttllvstck=sum(k2_12) // livestock product income
label var ttllvstck "Livestock income"
drop k2_12
duplicates drop a01, force
save lvinc15.dta, replace
use lvstckown15.dta, clear //merge currently ownership and livestock income
merge 1:1 a01 using lvinc15, nogen

save lvstckinc15.dta, replace

**livestock diversification
use $BIHS15\034_r2_mod_k1_male.dta, clear 
drop if k1_04==0
bysort a01: egen livdiv=count(livestock)
keep a01 livdiv
duplicates drop a01, force
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

save livdiv15.dta, replace

/*fishery income*/
use $BIHS15\038_r2_mod_l2_male.dta, clear
bysort a01:egen fshinc=sum(l2_12)
bysort a01:egen fshdiv=count(l2_01)
keep a01 fshdiv fshinc
label var fshdiv "fish diversification"
label var fshinc "fishery income"
duplicates drop a01, force
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
save fsh15.dta, replace 

**keep Non-farm self employment
use $BIHS15\008_r2_mod_c_male.dta, clear
keep a01 c05 c09 c14
keep if c09 == 3 //keep self employed
bysort a01: egen offsel=sum(c14)
gen offself=12*offsel
keep a01 offself
label var offself "Non-farm self employment"
duplicates drop a01, force
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
save nnfrminc15.dta, replace

**Non-farm employment 
use $BIHS15\008_r2_mod_c_male.dta, clear
keep a01 c05 c09 c14
keep if c09 != 3 //keep salary and wage
drop if c05== 1 //drop farm wage
gen yc14=12*c14
bysort a01: egen offrminc=sum(yc14)
label var offrminc "Non-farm wage and salary"
keep a01 offrminc
duplicates drop a01, force
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

save offfrm15.dta, replace

**farm wage
use $BIHS15\008_r2_mod_c_male.dta, clear
keep if c05== 1
keep a01 c14
replace c14=0 if c14==.
bysort a01: egen frmwag=sum(c14) 
gen frmwage=12*frmwag
keep a01 frmwage
label var frmwage "Farm wage"
duplicates drop a01, force
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

save frmwage15.dta, replace

*Non-agricultural enterprise
use $BIHS15\041_r2_mod_n_male.dta, clear
bysort a01: egen nnagent=sum(n05)
label var nnagent "non-agricultural enterprise"
keep a01 nnagent
duplicates drop a01, force
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

save nnagent15.dta, replace

*HDDS
use $BIHS15\042_r2_mod_o1_female.dta, clear //create Household dietary diversity score (HDDS)

recode o1_01 (1/16 277/290 297 901 296 302 =1 "Cereals")(61 621 622 295 301 3231=2 "White tubers and roots")(41/60 63/82 86/115 904 905 291 292 298 441=3 "Vegetables")(141/170 317 319 907=4 "Fruits")(121/129 906 322 =5 "Meat")(130/135 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 902 299=8 "Legumes, nuts and seeds")(132/135 1321/1323 2941/2943 294=9 "Milk and milk products")(31/36 903 312 =10 "Oils and fats")(266/271 293 303/311=11 "Sweets")(246/251 253/264 272/276 318 323 910 300 314/321 2521 2522 313= 12 "Spices, condiments and beverages"), gen(hdds_i)

duplicates drop a01 hdds_i, force
bysort a01: egen hdds=count(a01)
drop hdds_i
label var hdds "Household Dietary Diversity"
duplicates drop a01, force
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

save fd15.dta, replace


use $BIHS15\065_r2_mod_x1_2_female.dta //create Woman Dietary Diversity Score (WDDS)


**Consumption expenditure
use BIHS_hh_variables_r123, clear
keep if round==2
keep a01 pc_expm_d pc_foodxm_d pc_nonfxm_d
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
save expend15.dta, replace

**human capital
use $BIHS15\046_r2_mod_p2_male, clear
keep if p2_01>139
keep if p2_01<156
bysort a01: gen med=sum(p2_03) if p2_01<148
bysort a01: gen fed=sum(p2_03) if p2_01>147
bysort a01: gen ed=sum(p2_03)
bysort a01: egen medu=max(med)
bysort a01: egen fedu=max(fed)
bysort a01: egen edu=max(ed)
label var medu "Male educational expenses"
label var fedu "Female educational expenses"
label variable edu "Educational expenses"
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
save edu15, replace

**health expenditure
use $BIHS15\046_r2_mod_p2_male, clear
keep if p2_01>116
keep if p2_01<140
bysort a01: gen mhl=sum(p2_03) if p2_01<128
bysort a01: gen fhl=sum(p2_03) if p2_01>127
bysort a01: gen hl=sum(p2_03)
bysort a01: egen mhlth=max(mhl)
bysort a01: egen fhlth=max(fhl)
bysort a01: egen hlth=max(hl)
label var mhlth "Male educational expenses"
label var fhlth "Female educational expenses"
label variable hlth "Educational expenses"
keep a01 mhlth fhlth hlth
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
save hlth15, replace

**leisure expenditure
use $BIHS15\046_r2_mod_p2_male, clear
keep if p2_01>167
keep if p2_01<178
bysort a01: gen leisur=sum(p2_03)
bysort a01: egen leisure=max(leisur)
label variable leisure "Leisure expenditure"
keep a01 leisure
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
save leisure15, replace

/*Idiosyncratic shocks*/
use $BIHS15\050_r2_mod_t1_male.dta, clear
keep if t1_05==2014
keep if t1_02==09 
rename t1_02a cropflood
tempfile crpfld
save `crpfld'
use $BIHS15\050_r2_mod_t1_male.dta, clear
keep if t1_05==2014
keep if t1_02==11 
rename t1_02a lvstckflood
merge 1:1 a01 using `crpfld', nogen
tempfile lvsfld
save `lvsfld'
use $BIHS15\050_r2_mod_t1_male.dta, clear
keep if t1_05==2014
keep if t1_02==14 
rename t1_02a  prdflood
merge 1:1 a01 using `lvsfld', nogen
tempfile prdfld
save `prdfld'
use $BIHS15\050_r2_mod_t1_male.dta, clear
keep if t1_05==2014
keep if t1_02==16 
rename t1_02a  cnsmpflood
merge 1:1 a01 using `prdfld', nogen
tempfile cnsfld
save `cnsfld'

use $BIHS15\050_r2_mod_t1_male.dta, clear
keep if t1_05==2014
keep if t1_02==101
rename t1_02a  crpcyc
merge 1:1 a01 using `cnsfld', nogen
tempfile crpcyc
save `crpcyc'

use $BIHS15\050_r2_mod_t1_male.dta, clear
keep if t1_05==2014
keep if t1_02==111
rename t1_02a  lvcyc
merge 1:1 a01 using `crpcyc', nogen
gen shock=1
tempfile shock
save `shock'
use $BIHS15\050_r2_mod_t1_male.dta, clear
duplicates drop a01, force
keep if t1_05==2014
keep if t1_02a==1
rename t1_02a e_shock
label var e_shock "Negative economic shock"
merge 1:1 a01 using `shock', nogen
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
keep a01 shock e_shock
label var shock "Shock"
save shock15.dta, replace

**Income diversification
use crpincm15.dta, clear
merge 1:1 a01 using nnrn15.dta, nogen
merge 1:1 a01 using ssnp15.dta, nogen
merge 1:1 a01 using lvstckinc15.dta, nogen
merge 1:1 a01 using offfrm15.dta, nogen
merge 1:1 a01 using fsh15.dta, nogen
merge 1:1 a01 using nnagent15.dta, nogen
merge 1:1 a01 using rem15.dta, nogen
merge 1:1 a01 using frmwage15.dta, nogen
merge 1:1 a01 using nnfrminc15.dta, nogen
drop dstnc_sll_ trnsctn lvstck fshdiv 
replace crp_vl=0 if crp_vl==.
replace offrminc=0 if offrminc==.
replace nnearn=0 if nnearn==.
replace fshinc=0 if fshinc==.
replace ttllvstck=0 if ttllvstck==.
replace remi=0 if remi==.
replace nnagent=0 if nnagent==.
replace frmwage=0 if frmwage==.
replace offself=0 if offself==.
replace trsfr=0 if trsfr==.
gen ttinc= crp_vl+nnearn+trsfr+ttllvstck+offrminc+fshinc+nnagent+remi+frmwage+offself //total income
gen aginc=ttllvstck+crp_vl+fshinc
gen nonself=offself+nnagent //off-farm self
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
keep a01 aginc frmwage nonself nonwage nonearn inc_div shni ttinc 
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
save incdiv15.dta, replace



**merge all 2015 dataset
use 2015.dta,clear
merge 1:1 a01 using hh15, nogen
merge 1:1 a01 using sciec15, nogen
merge 1:1 a01 using agrnmic15, nogen
merge 1:1 a01 using nnrn15, nogen
merge 1:1 a01 using shock15.dta, nogen
merge 1:1 a01 using lvstckinc15.dta,nogen
merge 1:1 a01 using crpincm15,nogen
merge 1:1 a01 using offfrm15.dta,nogen
merge 1:1 a01 using ssnp15,nogen
merge 1:1 a01 using nnfrminc15,nogen
merge 1:1 a01 using crp15,nogen
merge 1:1 a01 using irri15, nogen
merge 1:1 a01 using incdiv15, nogen
merge 1:1 a01 using fd15.dta, nogen
merge 1:1 a01 using expend15, nogen
merge 1:1 a01 using frm_div15, nogen
merge 1:1 a01 using mrkt15, nogen
merge 1:1 a01 using facility15, nogen
merge 1:1 a01 using extension15, nogen
merge 1:1 a01 using mobile15, nogen
merge 1:1 a01 using poverty15, nogen
merge 1:1 a01 using migrant15, nogen
merge 1:1 a01 using asset15, nogen
merge 1:1 a01 using network15,nogen
merge 1:1 a01 using rem15, nogen
merge 1:1 a01 using mm15, nogen
merge 1:1 a01 using save15, nogen
merge 1:1 a01 using network15, nogen
merge 1:1 a01 using edu15, nogen
merge 1:1 a01 using hlth15, nogen
merge 1:1 a01 using leisure15, nogen
merge 1:1 a01 using mm_o15, nogen
merge 1:1 a01 using ckng15, nogen
merge 1:1 a01 using ene15, nogen
merge 1:1 a01 using wei_r2, nogen
merge 1:1 a01 using `sc15', nogen
merge 1:1 a01 using `ic15', nogen
merge 1:1 a01 using `mc15', nogen
merge 1:1 a01 using `lc15', nogen
merge 1:1 a01 using `plc15', nogen
merge 1:1 a01 using `lvc15', nogen
merge 1:1 a01 using `fc15', nogen
merge 1:1 a01 using wm15, nogen
merge 1:1 a01 using wcrdt15.dta, nogen
merge 1:1 a01 using vlnc15.dta, nogen
merge 1:1 a01 using cntr15.dta, nogen
merge 1:1 a01 using masst15.dta, nogen
merge 1:1 a01 using fl15.dta, nogen
merge 1:1 a01 using ml15.dta, nogen
merge m:m Village using com15, nogen force
label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
gen year=2015

foreach m in remi saving mhlth fhlth hlth edu fedu medu leisure ttinc enex elcex gasex nonex sc ic mc lc plc lvc remi_dom remi_for fc{
	gen `m'_d=(74.15*`m')/77.95
}

drop if dvcode==.
egen agcost=rowtotal(sc ic mc lc plc lvc fc), missing
label var agcost "Agricultural cost"

drop if couple==.
save 2015.dta, replace

//gen lnoff=log(offrmagr)

*** individual level data for mobile phones
use hh15_i, clear
merge 1:1 a01 mid using inc15_i, nogen
merge 1:1 a01 mid using m15_i, nogen
drop if age_i==.
replace mobile=0 if mobile==.
merge m:1 a01 using 2015, nogen

label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
//gen lnoff=log(offrmagr)

save 2015_i.dta, replace