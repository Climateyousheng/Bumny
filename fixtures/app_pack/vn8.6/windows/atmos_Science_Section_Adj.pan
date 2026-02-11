.winid "atmos_Science_Section_Adj"
.title "Section 10 : Dynamical Adjustment"
.wintype entry

.panel
   .gap
   .basrad "Choose version" L 3 v ATMOS_SR(10)
            "Dynamical Adjustment Scheme not included" 0A
            "<2A> GCR Solver used to solve Helmholtz Equation" 2A
            "<2B> Recommended solver (essential for variable resolution). May not bit-reproduce 2A option." 2B
   .case ATMOS_SR(10)!="0A"
     .basrad "Select preconditioner" L 7 v PRECON
              "<0>: No Preconditioner"       0
              "<1>: Vertical Preconditioner" 1
              "<2>: 1 iteration of <1> followed by 3D-ADI (global only)" 2
              "<3>: 3D-ADI only (global only)" 3
              "<4>: 1 iteration of <1> followed by XZ ADI (global only)" 4
              "<5>: XZ ADI only (global only)" 5
              "<6>: Dufort-Frankel type preconditioner" 6
     .gap   
     .block 1      
     .case PRECON==2||PRECON==3||PRECON==4||PRECON==5||PRECON==6
         .entry "Size of ADI pseudo timestep" L ADITSTEP 15
     .caseend
     .case PRECON==2||PRECON==3||PRECON==4||PRECON==5
         .check "Add full solution for ADI" L ADIFULL T F
     .caseend
     .blockend
     .gap
     .check "Use last soln as initial guess after 1st cycle" L LGCRCLOP T F
     .entry "Maximum number of iterations" L GCRMAXITER 15
     .gap
     .basrad "Print diagnostics from GCR-solver" L 4 v GCRDIAG
              "<0> None" 0
              "<1> Initial + final residual + number of iterations" 1
              "<2> As <1> + residual on every iteration" 2
              "<3> average iterations over timestep intervals" 3
     .gap
     .case GCRDIAG==3
       .block 1 
         .entry "1st interval ends timestep" L GCRITS1 15
         .entry "2nd interval ends timestep" L GCRITS2 15
         .entry "3rd interval ends timestep and repeats" L GCRITS3 15
       .blockend
     .caseend         
     .gap         
     .basrad "Convergence criterion" L 2 v GCRCONV
              "Residual tolerance" 1
              "Absolute tolerance" 2
     .block 1
     .entry "Tolerance value" L GCR_TOL 15
     .case NUM_CYCLES != "1"
       .entry "Tolerance value after first cycle" L GCR_TOL2 15
     .caseend
     .blockend
   .caseend 
   .gap
.panend


