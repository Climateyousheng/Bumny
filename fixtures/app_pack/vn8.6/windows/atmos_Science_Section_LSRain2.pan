.winid "atmos_Science_Section_LSRain2"
.title "Large Scale Precipitation continued: Ice Particles"
.wintype entry
.comment .procs {} {} {}
.panel
   .block 0
     .case ATMOS_SR(4)!="0A"
         .check "Use generic ice particle size distribution" L L_PSD T F
         .block 1
         .case L_PSD=="T"
           .basrad "Choose generic ice p.s.d version" L 2 v PSDGLOBAL
             "Mid-latitude version" 0
	     "Global version" 1 
           .check "Use two ice fallspeeds" L LDIF_ICEVT Y N
           .case LDIF_ICEVT=="Y"
             .block 2
             .entry "Crystal fallspeed scaling, CIC" L CIC_INPUT 15
             .entry "Crystal fallspeed exponent, DIC" L DIC_INPUT 15
             .entry "Aggregate fallspeed scaling, CI" L CI_INPUT 15
             .entry "Aggregate fallspeed exponent, DI" L DI_INPUT 15
             .blockend
           .caseend
         .caseend
       .gap
       .case L_PSD=="F"
         .basrad "Choose ice particle size distribution parameters" L 2 v IPSDP
           "Standard ice size distributions" 1
           "Use HadGEM tunings (for HadGEM family)" 2 
       .blockend    
     .caseend
   .blockend
   .gap
   .check "Include Hallett-Mossop Process" L L_HLTMOSS T F   
   .case ATMOS_SR(4)=="3D"
     .check "Share supersaturation between crystals and aggregates" L LCRYAGGDEP T F
     .case MCRGRPUP=="T"
       .check "Allow snow-rain collisions to produce graupel" L LSR2GRAUP Y N
     .caseend
   .caseend
   .gap
   .basrad "Specify ice particle mass-diameter relationship" L 2 v IPMSDR
     "Standard parameters" 1
     "Explicitly define parameters (see Help)" 2 
   .case IPMSDR=="2"
     .textw "Specify mass diameter relationships for aggregates (m(D) = ai D**bi) and crystals (m(D) = aic D**bic)" L
     .block 2
       .entry "Aggregate mass scaling, AI" L AI 15
       .entry "Aggregate mass exponent, BI" L BI 15
       .entry "Crystal mass scaling, AIC" L AIC 15
       .entry "Crystal mass exponent, BIC" L BIC 15
     .blockend
   .caseend  
   .gap 
   .basrad "Specify ice particle Best-Reynolds relationship" L 2 v IPBRE
     "Standard parameters" 1 
     "Explicitly define parameters (see Help)" 2 
   .case IPBRE=="2"
     .textw "and crystals (Re(D) = lsp_eic Be**lsp_fic)" L
     .block 2
     .entry "Crystal Best scaling, LSP_EIC" L LSP_EIC 15
     .entry "Crystal Best exponent, LSP_FIC" L LSP_FIC 15
     .blockend
   .caseend  
   .gap
   .block 0
   .entry "Maximum ice nucleation temperature" L TNUC 15 
   .entry "Axial ratio for aggregates" L AXIALR 15
   .entry "Axial ratio for crystals" L AXIALC 15
   .blockend
   .gap  
   .textw "Push BACK to return to the precipitation panel" L 
   .pushnext "Back" atmos_Science_Section_LSRain  
.panend
