.winid "atmos_Science_Section_DiffFilt_Polar"
.title "Resetting for Original Polar Filter"
.wintype entry

.panel
   .basrad "Choose version" L 2 v ATMOS_SR(13)
            "<0A> Diffusion, Divergence Damping and filtering not included" 0A
            "<2A> Standard schemes" 2A
   .case ATMOS_SR(13)!="0A" && LCOMBI=="N"
     .gap
     .basrad "Filtering of u,v,w and theta" L 2 h FILT121
        "Off"          0
        "1-2-1 filter" 1
     .basrad "Filtering of u,v,w and theta increments" L 2 h FILTINC
        "Off"          0
        "1-2-1 filter" 1
     .gap       
     .case FILT121==1||FILT121==2||FILTINC==1||FILTINC==2
       .block 1
       .entry "Polar filter latitude limit (degrees)" L FILTPOLAR 25
       .entry "Northern latitude limit (+ve degrees)" L FILTNTH 25
       .entry "Southern latitude limit (-ve degrees)" L FILTSTH 25
       .entry "Number of sweeps of filter" L FILTSWEEP 25
       .entry "Filter coefficient" L FILTCOEFF 25
       .entry "Filter step per sweep" L FILTSTEP 25       
       .blockend        
     .caseend
     .gap
     .textw "Push DIFF to go to the Diffusion, Filtering and Moisture window" L
    .caseend  
    .pushnext "DIFF" atmos_Science_Section_DiffFilt
.panend


