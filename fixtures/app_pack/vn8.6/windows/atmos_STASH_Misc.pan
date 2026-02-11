.winid "atmos_STASH_Misc"
.title "STASH related choices"
.wintype entry
.panel
  .gap
  .basrad "Diagnosis of screen temperature" L 3 v SCRNTDIAG
    "Using pure surface similarity theory" 0
    "Using surface similarity theory with decoupling in strongly stable conditions" 1
    "Including radiative cooling and transient decoupling during the evening transition" 2
  .gap
  .entry "Enter the cumulative probability value at which visibility is estimated" L VISPROB 5
  .gap
  .case ATMOS_SR(15)!="0A"
    .text "Section 15 is included" L
  .caseend
  .gap
  .entry "Height threshold for PMSL geostrophic wind calculation" L NPMSLHGH 15
  .basrad "PMSL smoothing" L 2 v LPMSL
     "Use SOR algorithm (default prior to UM7.8)"                  1
     "Use Jacobi algorithm (more scalable at high node counts)" 2
  .gap
.panend



