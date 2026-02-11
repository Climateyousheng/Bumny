.winid "atmos_Assim_IAU"
.title "Assimilation IAU"
.wintype entry

.panel

  .invisible (ATMOS_SR(18)!="0A")&&(AAS_IAU=="Y")
   .text "\"Incremental Analysis Update\" scheme is activated." L
  .invisend
  .invisible (ATMOS_SR(18)=="0A")||(AAS_IAU=="N")
   .text "\"Incremental Analysis Update\"  scheme is not activated." L
  .invisend
  .gap
   
  .case (ATMOS_SR(18)!="0A")&&(AAS_IAU=="Y")
    .block 0
    .entry "Number of increment files?" L IAU_NUMINCS 10
    .colour red GEN_SUITE==1
      .entry "Full path of first increment file" L ASM_IAUINC 50
    .colourend
    .blockend
    .check "Specify filter for first increment file" L LIAU_SPCFILT Y N
    .case LIAU_SPCFILT=="Y"
      .block 1
        .entry "Start of IAU insertion in minutes from run start" L ASM_IAUSTR 10
        .entry "End of IAU insertion in minutes from run start" L ASM_IAUEND 10
      .blockend
      .block 1
        .gap
        .basrad "Filter type:"  L 4 h ASM_IAUFILT
            "Uniform"          1
            "Triangular"       2
            "Lanczos windowed" 3
            "Dolph"            4
      .blockend
      .block 2
        .invisible ASM_IAUFILT=="2"
          .entry "Apex minute for triangular filter" L ASM_IAUTAM 10
          .gap
	.invisend 
        .invisible ASM_IAUFILT=="3"
          .entry "Cutoff period (hrs) for Lanczos windowed filter" L ASM_IAULCP 10
          .gap
	.invisend 
        .invisible ASM_IAUFILT=="4"
          .entry "Stop-band edge period (hrs) for Dolph filter" L ASM_IAUDSB 10
          .gap 
        .invisend 
      .blockend
    .caseend  
    .basrad "QLimits call frequency:" L 4 v IAU_QLIMCF
        "Never"                                     0
        "Every call on which there are incs to add" 1
        "End of Inc1 time window"                   2
        "Last IAU call"                             3    
    .case IAU_QLIMCF!="0"
      .block 1
      .check "Write QLimits diagnostics" L LIAU_QLDIAGS Y N
      .check "Remove q incs above tropopause" L LIAU_NTQINCS Y N
      .textw "Qlimits parameters" L
      .textw "Parameters for diagnosis of tropospheric points:" L
      .block 2
      .entry "Minimum tropospheric pressure (Pa)" L IAU_TRMINP 10
      .entry "Maximum tropospheric ABS(PV) (K m2 kg-1 s-1)" L IAU_TRMAXPV 10
      .entry "Maximum non-tropospheric pressure (Pa)" L IAU_NTRMAXP 10
      .blockend 
      .textw "Limits to apply to humidities:" L
      .case LIAU_NTQINCS=="N"
        .block 3
        .entry "Maximum non-tropospheric q" L IAU_NTRMAXQ 10
	.entry "Minimum non-tropospheric q" L IAU_NTRMINQ 10
	.entry "Maximum non-tropospheric RH" L IAU_NTRMAXRH 10
        .blockend
      .caseend
      .entry "Minimum tropospheric RH" L IAU_TRMINRH 10
      .blockend
    .caseend
    .gap
    .check "Write increment diagnostics" L LIAU_INCDIAG Y N 
    .check "Write out timestep zero model state" L LIAUZEROMST Y N
    .check "Calculating exner increments from p increments" L ASM_IAUEXP Y N
    .check "Calculating theta increments from exner and q increments" L ASM_IAUTHEQ Y N
    .check "Calculating rho   increments from exner, theta and q increments" L ASM_IAURHETQ Y N
    .check "Add T1 incs to surface temp and top-level soil temp" L LIAUSOILTMP Y N
    .check "Diagnose qCF as well as q and qCL incs if providing qT incs" L LIAU_INCICE Y N
    .check "Scale cloud incs diagnosed from qT incs to be within physical limits" L LIAU_SCLCLD Y N
    .gap
  .caseend
  .textw "Push Next to go to the follow up window" L
  .pushsequence  "Next" atmos_Assim_IAU_2
.panend
 


