.winid "atmos_Science_Section_Cloud"
.title "Section 9 : Cloud Scheme"
.wintype entry
.procs {} {} {check_cloud-rain}
.procs {} {} {check_cloud-conv}

.panel
   .basrad "Choose version" L 2 v ATMOS_SR(9)
            "Cloud Scheme not included" 0A
            "<2A> Standard scheme with triangular probability density function" 2A
   .case ATMOS_SR(9)!="0A"
     .check "Using RHCrit parametrization" L RHCRIT_PARM Y N
.comment     .check "Increase RHCrit when resolved vertical velocity is large" L LWBSDRHC Y N
   .caseend  
   .check "Include convective cloud in cloud generator" L LCCA_MCICA Y N
   .check "Use mixing ratio formulation for the parallel physics" L LMRPHYSICS1 Y N 
   .case (LSPICECOMP==1)&&(ES_RAD==3)
      .check "Including cloud area parametrization (Gen2 Rad only)" L  CLD_AREA Y N
   .caseend
   .case CLD_AREA=="Y"
      .check "Use the Cusack method based on temperature and moisture profiles" L CLDAREAPRM Y N
   .caseend
   .case ATMOS_SR(9)!="0A"
     .check "Use prognostic cloud scheme PC2?" L P_CLD_PC2 Y N
     .block 2
       .textw "If using PC2 scheme the 3D large-scale precipitation scheme (ATMOS_SR(4)) must " L
       .textw "be selected as well" L
     .blockend
     .case P_CLD_PC2=="Y"
       .block 1
         .check "Ensure a minimum in-cloud ice water content" L LEMINCLQCF Y N
         .check "Use consistent formulation of mixed phase cloud fraction" L LFIXPC2BL Y N
         .check "Ensure consistent sinks of qcl and CFL" L LFIXPC2QCL Y N
         .case ATMOS_SR(5)!="4A"
             .check "Include forced convective clouds" L FORCED_CU Y N
         .caseend
       .blockend
       .block 1
         .entry "Method for creating liquid cloud fraction when supersaturated in pc2_checks (0,1,2)" L FIXPC2CHK 5
       .blockend
       .block 1
         .basrad "Select how shear affects falling ice cloud fraction:" L 3 v PC2FLCESH
            "Ignore the effects of shear" 0
            "Use shear derived from model winds" 2            
            "Assume a globally constant shear" 1
       .gap     
       .case PC2FLCESH=="0"||PC2FLCESH=="2"     
         .entry "Ice cloud fraction spreading rate" L CFFSPR_RATE 15
       .caseend
         .check "Include Erosion prior to Microphysics" L LMICROEROS Y N  
       .blockend
       .block 1
       .entry "Method for doing PC2 cloud erosion" L IPC2ERSN 15       
       .entry "Enter value of cloud erosion / s-1" L DTBSTURB 15
       .entry "Method for coupling PC2 to convection scheme" L IPC2_CNVCPL 15 
       .case IPC2_CNVCPL=="3"||IPC2_CNVCPL=="4"||IPC2_CNVCPL=="5"
         .entry "Start detraining condensate as ice at (Kelvin)" L STKELVIN 15
         .entry "All condensate is detrained as ice by (deg C)" L ALTDEGC 15 
       .caseend   
       .entry "Ice_Width" L ICE_WIDTH 15
       .blockend
     .caseend
     .gap 
     .case P_CLD_PC2!="Y"  
       .check "Use empirically adjusted cloud fraction parametrization" L LEACF Y N
       .check "Explicitly set overlap between liquid and ice phases" L CLDFRACM 2 1
     .caseend  
   .caseend
   .gap
   .check "Filter optically-thin ice clouds from diagnostics" L LFLT_CLOUD Y N
   .case LFLT_CLOUD=="Y"
     .block 1
     .entry "Optical-depth threshold" L TAU_THRSH 15
     .blockend
   .caseend

  .textw "Push LSP for large scale precipitation section." L
  .pushnext "LSP" atmos_Science_Section_LSRain 
.panend

