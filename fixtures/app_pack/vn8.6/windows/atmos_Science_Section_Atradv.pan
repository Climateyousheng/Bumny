.winid "atmos_Science_Section_Atradv"
.title "Section 11 : Atmospheric Tracer Advection"
.wintype entry

.panel
  .gap
  .basrad "Choose version" L 2 v ATMOS_SR(11)
          "Atmospheric tracer advection not included" 0A
          "<2A> Atmospheric tracer advection included" 2A
  .gap
  .case ATMOS_SR(11)!="0A"
    .check "Apply a correction after advection to conserve tracer mass (not to be used in standard LAMs)" L LCNSRVTRS T F
  .caseend
.panend



