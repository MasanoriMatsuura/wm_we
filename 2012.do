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
recode edu_w(99=0 "Non-schooling") (22=5)(33=9)(66=0 "Non-schooling")(67=0 "Non-schooling")(74=16)(76=.)(99=0 "Non-schooling"), gen(schll_w) // convert  education into schoolling year 
label var age_w "Age of women"
label var schll_w "Schooling year of women"
recode b1_07 (4=1 "yes") (nonm=0 "No" ), gen(lit_w)
label var lit_w "Literacy of women"
recode b1_10 (1=72 "Yes")(nonm=0 "No"), gen(wrk_wf)
label var wrk_wf "Current working status of wife"

keep a01 couple ch_size edu_w schll_w lit_w age_w wrk_wf
save hh12.dta, replace

**mobile phone ownership
use $BIHS12\006_mod_d1_male, clear //household ownership
keep if d1_02==24
recode d1_03 (1=1 "yes")(nonm=0 "no"), gen(mobile)
rename d1_04 mobile_q
label var mobile_q "Mobile phone ownership (quantity)"
keep a01 mobile mobile_q
save mobile12, replace

**Women's mobile phone ownership
use $BIHS12\006_mod_d1_male, clear 
keep if d1_02==24 //only mobile phones
rename d1_06_a mid
merge 1:1 a01 mid using $BIHS12\003_mod_b1_male, nogen
gen wmobile=1 if b1_01==2 & d1_03==1
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
gen wmobile=1 if b1_01==2 & d1_03==1
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
gen wmobile=1 if b1_01==2 & d1_03==1
drop if d1_03 == .
replace wmobile=0 if wmobile==.
label var wmobile "Women's mobile ownership"
keep a01 wmobile

append using wm212

bysort a01: egen wmob=total(wmobile)
recode wmob (0=0 "No")(nonm=1 "Yes" ), gen(wm)
label var wm "Women's mobile ownership"

duplicates drop a01, force

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

** income for women


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
recode edu_hh(99=0 "Non-schooling") (22=5)(33=9)(66=0 "Non-schooling")(67=0 "Non-schooling")(74=16)(76=.)(99=0 "Non-schooling"), gen(schll_hh) // convert  education into schoolling year 
label var age_hh "Age of HH"
label var schll_hh "Schooling year of HH"
recode gender_hh (1=1 "Man")(2=0 "Woman"), gen(Male)
label var Male "Male(=1)"
recode b1_10 (1=72 "Yes")(nonm=0 "No"), gen(wrk_hs)
label var wrk_hs "Current working status of husband"
save sciec12.dta, replace


**Asset index
use $BIHS12\006_mod_d1_male.dta, clear  
keep a01 d1_02 d1_03
reshape wide d1_03,i(a01) j(d1_02)
local varlist "d1_031 d1_032 d1_033 d1_034 d1_035 d1_036 d1_037 d1_038 d1_039 d1_0310 d1_0311 d1_0312 d1_0313 d1_0314 d1_0315 d1_0316 d1_0317 d1_0318 d1_0319 d1_0320 d1_0321 d1_0322 d1_0323 d1_0326 d1_0327 d1_0328 d1_0329 d1_0330 d1_0331 d1_0332 d1_0333 d1_0334 d1_0335 d1_0336 d1_0337 d1_0338 d1_0339 d1_0340 d1_0341 d1_0342 d1_0343 d1_0344 d1_0345 d1_0346 d1_0347"
foreach x in `varlist'{
	replace `x'=0 if `x'==2
	replace `x'=0 if `x'==.
}
pca `varlist'
predict asset
keep a01 asset
save asset12.dta, replace

**keep agronomic variables
use $BIHS12\010_mod_g_male, clear
collapse (sum) farmsize=g02 ,by(a01)
label var farmsize "Farm Size(decimal)"
gen ln_farm=log(farmsize)
label var ln_farm "Farm size(log)"
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

label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
//gen lnoff=log(offrmagr)
gen year=2012
replace crpdivnm=0 if crpdivnm==.
drop if couple==.
save 2012.dta, replace
