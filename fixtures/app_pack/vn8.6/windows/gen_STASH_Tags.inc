.include_begin 1
  .gap
  .textw "Package Include settings take effect on closure of this panel" L
  .gap
  .procs {saveTags %1} {updateTagsAbandon %1} {updateTagsClose %1}
  .table STASHTags_%1 "Diagnostic Packages" top h N_TAGS 10 NONE
    .element "Package" D_TAG N_TAGS 5 out
    .element "Include Y/N" D_TAGF_%1 N_TAGS 10 in
    .element "Description of package" D_TAG_DESC_%1 N_TAGS 72 in
  .tableend
.include_end
