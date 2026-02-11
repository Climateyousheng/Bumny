.winid "subindep_ExternalCntrl"
.title "External Control"
.wintype entry

.panel
   .gap
   .textw "Do not use the 'Standard Generalised Suite Control' option if you intend to use Rose. See Help text." L
   .gap
   .basrad "Specify the external control type: "  L 2 v GEN_SUITE
            "No external control. UM runs outside a suite." 0
            "Standard Generalised Suite control." 1

  .invisible GEN_SUITE!="0"
    .entry "External name of your UM job (eg. gl_forecast)" L EXNAME
    .entry "Destination directory for your UM job" L EXPATH
    .check "Is this job for operational use?" L LOPUSE Y N
  .invisend

.panend




