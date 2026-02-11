proc check_stash {isec item model_number} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash
	# Returns: 0 - Not available, error
	#          1 - Success, passed the test
    #-

    global stmsta st_sec_name st_sections
    global item_temp

    # To test why a particular diagnostic is being rejected, enter its
    # item and section number in the line below
    set print 0
    if {$isec == 0 && $item == 999} {
	set print 1
    }
    if {$print == 1} {
	puts "Check STASH Section $isec item $item"
    }

    set model_letter [modnumber_to_letter $model_number]    
    set model_name [modnumber_to_name $model_number] ; # ATMOS  etc

    # Is this item registered?
    if { ![info exists stmsta($model_number,$isec,$item,item)] } {
	set stmsta($model_number,$isec,$item,avail) N
	if {$print == 1} {
	    puts "fail on registered <$model_number,$isec,$item>. \
		    $stmsta($model_number,$isec,$item,name)"
	    puts "Item is. $stmsta($model_number,$isec,$item,item)"
	}
	return
    } 
    

    # Is this item available for the current submodel?
    set mmm $stmsta($model_number,$isec,$item,mmm)
    if {($mmm != $model_number) } {
        error "Model numbers inconsistent for <$model_number,$isec,$item>.$model_number, $mmm"
	set stmsta($model_number,$isec,$item,avail) N
	if {$print == 1} {
	    puts "fail on model"
	}
	return
    } 

    # check diagnostic is available for chosen version
    set mask $stmsta($model_number,$isec,$item,mask)
    if {$isec != 0} {
	set var [get_variable_value $model_name\_SR($isec)]
	set section_version [string index $var 0]
	if {$section_version == ""} {
	    # this occurs when the section_version variable is unset
	    set stmsta($model_number,$isec,$item,avail) N
	    if {$print == 1} {
		puts "fail on version mask 1"
	    }
	    return
	}
	if {$section_version == 0} {
	    set stmsta($model_number,$isec,$item,avail) N
	    if {$print == 1} {
		puts "fail on version mask 2"
	    }
	    return
	}
	if {[string index $mask [expr [string length $mask] - $section_version]] == 0} {
	    set stmsta($model_number,$isec,$item,avail) N
	    if {$print == 1} {
		puts "fail on version mask 3"
	    }
	    return
	}
    } else {
      # for section zero, must have mask one set.
      if {[string index $mask [expr [string length $mask] - 1]] == 0} {
	  set stmsta($model_number,$isec,$item,avail) N
	  if {$print == 1} {
	      puts "fail on version mask 4"
	  }
	  return
      }
    }

    # Check space code
    set sp $stmsta($model_number,$isec,$item,sp)
    if {($sp == 3)||($sp == 5)||($sp == 10)} {
	set stmsta($model_number,$isec,$item,avail) N
	    if {$print == 1} {
		puts "fail on space code"
	    }
	return
    }

    # check sectional option code
    # must check section 5 even if no option codes set due to inverted check on n4=1
    set op_code $stmsta($model_number,$isec,$item,op_code)  
    if {$op_code != "S000000000000000000000000000000"  || $isec==5} {
        set ret [gen_mask_opts $op_code]
		if {$ret != 0} {
			error "In Option Code Stash Master File\n Model $model_number \
			Section $isec  Item $item Option Code $op_code"
			return 1
		}
        if { [eval "check_section_$model_letter\_$isec $isec" ] == 0 } {
           set stmsta($model_number,$isec,$item,avail) N
	    if {$print == 1} {
		puts "Fail on option code"
	    }
	   return
        }
    }
    set stmsta($model_number,$isec,$item,avail) Y   
}

proc check_section_A_0 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_0
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_21 check_section_0
    # TREE: experiment_instance navigation create_window stash check_stash check_section_0
    # TREE: experiment_instance navigation create_window stash check_stash check_section_21 check_section_0
    #-

    global st_mask_n2n1 st_mask_n 
       
        if {$st_mask_n2n1!=0} {
            set tca [get_variable_value TCA($st_mask_n2n1)]
            set use_tca [get_variable_value USE_TCA]
            if {($tca==0)||($use_tca!="Y")} {
                # <OPT> A_0(n2n1)=TRACER_NUMBER.  Only if this tracer is included.
		
                return 0
            }
        } elseif {$st_mask_n2n1 !=0 } {
          error "Unexpected STASH option code st_mask_n2n1=$st_mask_n2n1. Model A. Section $isec."
        }

        if {$st_mask_n(3)==0} {
            # nothing to do.
        } elseif {$st_mask_n(3)==2} {
          error "Unexpected STASH option code st_mask_n(3)=$st_mask_n(3). \
                 Model A. Section $isec. This used to be used for multi-layer hydrology"
        } elseif {$st_mask_n(3)==5} {
            set l_top [get_variable_value L_HYDROLOGY]
            if {$l_top == "Y"} {
                # Run without hydrology
                return 0
            }    
        } elseif {$st_mask_n(3) !=0 } {
          error "Unexpected STASH option code st_mask_n(3)=$st_mask_n(3). Model A. Section $isec."
        }

        if {$st_mask_n(4) == 1} {
        # Redundant switch
        } elseif {$st_mask_n(4)==2} {
            set switch_val [get_variable_value LUARCLBIOM]
            if { $switch_val != "Y" } {
                # <OPT> A_0(n4)=2. Only if you are using Biomass-burning.
                return 0
            }
        } elseif {$st_mask_n(4)==3} {
            set switch_val [get_variable_value LUARCLBLCK]
            if { $switch_val != "Y" } {
                # <OPT> A_0(n4)=3. Only if you are using Black Carbon.
                return 0
            }        
        } elseif {$st_mask_n(4)==4} {
            set switch_val [get_variable_value LUARCLSSLT]
            if { $switch_val != "Y" } {
                # <OPT> A_0(n4)=4. Only if you are using Sea-salt.
                return 0
            }        
        } elseif {$st_mask_n(4)==5} {
            set switch_val [get_variable_value LUARCLSULP]
            if { $switch_val != "Y" } {
                # <OPT> A_0(n4)=5. Only if you are using Sulphate.
                return 0
            }              
        } elseif {$st_mask_n(4)==6} {
            set switch_val [get_variable_value LUARCLDUST]
            if { $switch_val != "Y" } {
                # <OPT> A_0(n4)=6. Only if you are using Dust.
                return 0
            }             
        } elseif {$st_mask_n(4)==7} {
            set switch_val [get_variable_value LUARCLOCFF]
            if { $switch_val != "Y" } {
                # <OPT> A_0(n4)=7. Only if you are using Org. Carbon (Fossil Fuel).
                return 0
            }            
        } elseif {$st_mask_n(4)==8} {
            set switch_val [get_variable_value LUARCLDLTA]
            if { $switch_val != "Y" } {
                # <OPT> A_0(n4)=8. Only if you are using Delta aerosol.
                return 0
            }            
        } elseif {$st_mask_n(4) !=0 } {
          error "Unexpected STASH option code st_mask_n(4)=$st_mask_n(4). Model A. Section $isec."
        }

        if {$st_mask_n(5)==1} {
            set orogr [get_variable_value OROGR]
            if { $orogr != "Y" } {
                # <OPT> A_0(n5)=1. Only if you are using orographic rougness.
                return 0
            }
	} elseif {$st_mask_n(5)==2} {
            set atmos_sr6 [string index [get_variable_value ATMOS_SR(6)] 0]
            if {$atmos_sr6!=4} {
                # <OPT> A_0(n5)=2. Only if this model includes anisotropic orography GWD.
                return 0
            }  
	} elseif {$st_mask_n(5)==3} {
	    set atmos_sr1 [get_variable_value ATMOS_SR(1)]
            set orgcorr [get_variable_value LUORGCORR]
            if {$atmos_sr1=="0A" || $orgcorr!="Y"} {
                # <OPT> A_0(n5)=3. Only if this model includes Orographic Correction.
                return 0
            }  	    
	} elseif {$st_mask_n(5)==4} {
	    set atmos_sr1 [get_variable_value ATMOS_SR(1)]
            set orogunfilt [get_variable_value ACON(188)]
            if {$atmos_sr1=="0A" || $orogunfilt!="C"} {
                # <OPT> A_0(n5)=4. Only if this model includes configured unfiltered orography.
                return 0
            }  	  	  
        } elseif {$st_mask_n(5) !=0 } {
          error "Unexpected STASH option code st_mask_n(5)=$st_mask_n(5). Model A. Section $isec."
        }

        if {$st_mask_n(6)==0} {
            # OK
        } elseif {$st_mask_n(6)==1} {
            set ocaaa [get_variable_value OCAAA]
            if {$ocaaa==1} {
                # <OPT> A_0(n6)=1. Only if this is not a global model.
                return 0
            }
        } elseif {$st_mask_n(6)==2} {
            set floor [get_variable_value FLOOR]
            set ocalb 1
            if {($floor=="N")&&($ocalb==1)} {
                # <OPT> A_0(n6)=2. Only if this is a model with a lower boundary condition.
                return 0
            }
        } else {
          error "Unexpected STASH option code st_mask_n(6)=$st_mask_n(6). Model A. Section $isec."
        }

        if {$st_mask_n(7)==0} {
            # OK
        } elseif {$st_mask_n(7)==1} {
            set oasis [get_variable_value OASIS]
            if {$oasis=="F"} {
                # <OPT> A_0(n7)=1. Only if this is a model is coupled to the oasis model.
                return 0
            }
        } elseif {$st_mask_n(7)==2} {
            set ocean "F"
            if {$ocean=="F"} {
                # <OPT> A_0(n7)=2. Only if this is a model is coupled to the ocean model.
                return 0
            }
        } elseif {$st_mask_n(7)==3} {
            set oasis [get_variable_value OASIS]
            set iceberg [get_variable_value LOASIS_ICECLV]
            if {$oasis=="F" || $iceberg=="F"} {
                # <OPT> A_0(n7)=3. Only if iceberg calving and oasis are true
                return 0
            }
        } elseif {$st_mask_n(7)==7} {
            set emiss 0
            if {$emiss!="2"} {
                # <OPT> A_0(n7)=7 Only if Ocean DMS emissions from coupled ocean model ON
                return 0
            }
        } else {
          error "Unexpected STASH option code st_mask_n(7)=$st_mask_n(7). Model A. Section $isec."
        }

        if {$st_mask_n(8)==0} {
            # OK
        } elseif {$st_mask_n(8)==1} {
            set sstan [get_variable_value SSTAN]
            if {$sstan=="N"} {
                # <OPT> A_0(n8)=1. Only if this model includes SST anomolies.
                return 0
            }
        } elseif {$st_mask_n(8)==2} {
            set scrndiag [get_variable_value SCRNTDIAG]
            if {$scrndiag!="2"} {
                # <OPT> A_0(n8)=2. Only if this model includes decoupled screen temperature.
                return 0
            }	    
        } elseif {$st_mask_n(8)==3} {
	    set atmos3 [get_variable_value ATMOS_SR(3)]
            set convgust [get_variable_value CONVGUST]
            if {$atmos3=="0A" || $convgust=="N"} {
                # <OPT> A_0(n8)=1. Only if this model includes Convective Gustiness.
                return 0
            }
        } elseif {$st_mask_n(8)==4} {
            set totae [get_variable_value TOTAE]
            if {$totae!="Y"} {
                # <OPT> A_0(n8)=4. Only if this model includes TOTAL aerosols.
                return 0
            }
        } elseif {$st_mask_n(8)==5} {
            set totae [get_variable_value TOTAE]
            set totem [get_variable_value TOTEM]
            if {($totae!="Y")||($totem!="Y")} {
                # <OPT> A_0(n8)=5. Only if this model includes TOTAL aerosols and emissions.
                return 0
            }
        } elseif {$st_mask_n(8)==6} {
            set es_rad [get_variable_value ES_RAD]
            set snowalb [get_variable_value SNOWALB]
            set jules [get_variable_value JULES]
	    set nsmax [get_variable_value NSMAX]
            if { ($jules == "F" || $nsmax == "0") && ($es_rad != "1" && $es_rad != "3" )||($snowalb != "Y") } {
                # <OPT> A_0(n8)=6. Only if snow albedo option (available if ES SW radiation) chosen, or JULES snow layers are >0.
                return 0
            }
	} elseif {$st_mask_n(8)==7} {
	    set atmos3 [get_variable_value ATMOS_SR(3)]
            if {$atmos3!="1A"} {
                # <OPT> A_0(n8)=7. Only if this model uses the <1A> TKE Closure boundary layer scheme.
                return 0
	    }
	    } elseif {$st_mask_n(8)==8} {
	    set engcor [get_variable_value ATMOS_SR(14)]
	    if {$engcor == "0A"} {
		return 0
	    }
        } elseif {$st_mask_n(8)==9} {
            set atmos4 [get_variable_value ATMOS_SR(4)]
            set mcrgrp [get_variable_value MCRGRPUP]
            set lelectr [get_variable_value LUSE_ELECTR]
            if {$atmos4=="0A"||$mcrgrp!="T"||$lelectr!="T"} {
                # <OPT> A_0(n8)=9. Only with electric scheme.
                return 0
            }
        } else {
          error "Unexpected STASH option code st_mask_n(8)=$st_mask_n(8). Model A. Section $isec."
        }

        # OPTs n9 and n10 are a double digit code representing the CLASSIC aerosols 
        if {$st_mask_n(10)==0} {
            if {$st_mask_n(9)==0} {
               # OK
	    } elseif {$st_mask_n(9)==1} { 
               set chem [get_variable_value ATMOS_SR(17)]
               set sulpc [get_variable_value CHEM_SULPC]
               if {$chem=="0A" || $chem=="" || $sulpc=="N"  } {
                  # <OPT> A_0(n9n10)=1. Only if this model includes the sulphur cycle chemistry.
                  return 0
	       }
	    } elseif {$st_mask_n(9)==2} {
               set chem [get_variable_value ATMOS_SR(17)]
               set sulpc [get_variable_value CHEM_SULPC]
               set emso2 [get_variable_value EMSO2]
               if {$chem=="0A" || $chem=="" || $sulpc=="N" || $emso2=="N"} {
                   # <OPT> A_0(n9n10)=2. Only if this model includes the sulphur cycle chemistry and SO2 emissions.
                   return 0
               }  
	    } elseif {$st_mask_n(9)==3} { 
               set chem [get_variable_value ATMOS_SR(17)]
               set sulpc [get_variable_value CHEM_SULPC]
               set emso2h [get_variable_value EMSO2H]
               if { $chem=="0A" || $chem=="" || $sulpc=="N" || $emso2h=="N"} {
                   # <OPT> A_0(n9n10)=3. Only if this model includes the sulphur cycle chemistry and high-lev SO2 emissions.
                   return 0
               } 
	    } elseif {$st_mask_n(9)==4} {  
               set chem [get_variable_value ATMOS_SR(17)]
               set sulpc [get_variable_value CHEM_SULPC]
               set emso2n [get_variable_value EMSO2N]
               if { $chem=="0A" || $chem=="" || $sulpc=="N" || $emso2n=="N"} {
                   # <OPT> A_0(n9n10)=5. Only if this model includes the sulphur cycle chemistry and natural SO2 emissions.
                   return 0
               }
	    } elseif {$st_mask_n(9)==5} {  
               set chem [get_variable_value ATMOS_SR(17)]
               set sulpc [get_variable_value CHEM_SULPC]
               set dms [get_variable_value DMS  ]
               if { $chem=="0A" || $chem=="" || $sulpc=="N" || $dms=="N"} {
                   # <OPT> A_0(n9n10)=5. Only if this model includes the sulphur cycle chemistry and DMS.
                   return 0
               }
	    } elseif {$st_mask_n(9)==6} {
               set chem [get_variable_value ATMOS_SR(17)]
               set sulpc [get_variable_value CHEM_SULPC]
               set emdms [get_variable_value EMDMS]
               set dms [get_variable_value DMS  ]
               set dms_sch [get_variable_value IDMSE_SCH]
               if { $chem=="0A" || $chem=="" || $sulpc=="N" || $dms=="N"|| $emdms=="N" || $dms_sch=="0"} {
                   # <OPT> A_0(n9n10)=6. Only if this model includes the sulphur cycle chemistry and DMS and DMS emissions.
                   return 0
               }  
	    } elseif {$st_mask_n(9)==7} { 
               set chem [get_variable_value ATMOS_SR(17)]
               set sulpc [get_variable_value CHEM_SULPC]
               set sozo [get_variable_value SULOZONE]
	       set sulpoxi [get_variable_value LSULPOXI]
               set ukca [get_variable_value ATMOS_SR(34)]
	       set scheme [get_variable_value I_UKCA_CHEM]
               if { $chem=="0A" || $chem=="" || $sulpc=="N" || $sozo=="N" || ($ukca!="0A" && $scheme!="1" && $sulpoxi=="Y")} {
                   # <OPT> A_0(n9n10)=7. Only if this model includes the sulphur cycle and chemical ozone and not UKCA online oxidants.
                   return 0
               } 
	    } elseif {$st_mask_n(9)==8} {  
               set chem [get_variable_value ATMOS_SR(17)]
               set sulpc [get_variable_value CHEM_SULPC]
               set sozo [get_variable_value SULOZONE]
               if { $chem=="0A" || $chem=="" || $sulpc=="N" || $sozo=="N"} {
                   # <OPT> A_0(n9n10)=8. Only if this model includes the sulphur cycle and NH3.
                   return 0
               }
	    } elseif {$st_mask_n(9)==9} {
               set chem [get_variable_value ATMOS_SR(17)]
               set sulpc [get_variable_value CHEM_SULPC]
               set sozo [get_variable_value SULOZONE]
	           set oxi2B [get_variable_value OXIOZ2B]
               if { $chem=="0A" || $chem=="" || $sulpc=="N" || $sozo=="N" || ($chem=="2B"&& $oxi2B!="1") } {
                   # <OPT> A_0(n9n10)=9. Only if this model includes the sulphur cycle and NH3 emissions.
                   return 0
               }  
            } else {
               error "Unexpected STASH option code st_mask_n(10)n(9)=$st_mask_n(10)$st_mask_n(9). Model A. Section $isec."
            }

	} elseif {$st_mask_n(10)==1} { 
            if {$st_mask_n(9)==0} {
               set chem [get_variable_value ATMOS_SR(17)]
               set sulpc [get_variable_value CHEM_SULPC]
	       set sulpoxi [get_variable_value LSULPOXI]
               set ukca [get_variable_value ATMOS_SR(34)]
	       set scheme [get_variable_value I_UKCA_CHEM]
               if { $chem=="0A" || $chem=="" || $sulpc=="N" || ($ukca!="0A" && $scheme!="1" && $sulpoxi=="Y") } {
                   # <OPT> A_0(n9n10)=10. Only if this model does not include the UKCA online oxidants.
                   return 0
               } 
            } else {
               error "Unexpected STASH option code st_mask_n(10)n(9)=$st_mask_n(10)$st_mask_n(9). Model A. Section $isec."
            }

	} elseif {$st_mask_n(10)==2} { 
	    if {$st_mask_n(9)==1} { 
               set chem [get_variable_value ATMOS_SR(17)]
               set soot [get_variable_value CHEM_SOOT]
               if {$chem=="0A" || $chem=="" || $soot=="N"  } {
                   # <OPT> A_0(n10n9)=21. Only if Soot.
                   return 0
               }
	    } elseif {$st_mask_n(9)==2} { 
               set chem [get_variable_value ATMOS_SR(17)]
               set soot [get_variable_value CHEM_SOOT]
               set sem [get_variable_value EMSOOT]
               if {$chem=="0A" || $chem=="" || $soot=="N" || $sem=="N"  } {
                   # <OPT> A_0(n10n9)=22. Only if Soot and surface emissions
                   return 0
               } 
	    } elseif {$st_mask_n(9)==3} {  
               set chem [get_variable_value ATMOS_SR(17)]
               set soot [get_variable_value CHEM_SOOT]
               set semh [get_variable_value EMSOOTH]
               if {$chem=="0A" || $chem=="" || $soot=="N"  || $semh=="N"  } {
                   # <OPT> A_0(n10n9)=23. Only if Soot and high lev emissions
                   return 0
               }
	    } elseif {$st_mask_n(9)==4} { 
       	       set chem [get_variable_value ATMOS_SR(17)]
               set biom [get_variable_value CHEM_BIOM]
	       if {$chem=="0A" || $chem=="" || $biom=="N" } {
            	   # <OPT> A_0(n10n9)=24. Only if Biomass modeling included
	    	   return 0
               } 
	    } elseif {$st_mask_n(9)==5} {  
               set chem [get_variable_value ATMOS_SR(17)]
	       set bmass [get_variable_value CHEM_BIOM]
	       set biom [get_variable_value EMBIOM]
	       if {$chem=="0A" || $chem=="" || $bmass=="N" || $biom=="N" } {
            	   # <OPT> A_0(n10n9)=25. Only if Surface emissions included
	    	  return 0
	       }
	    } elseif {$st_mask_n(9)==6} {  
               set chem [get_variable_value ATMOS_SR(17)]
	       set bmass [get_variable_value CHEM_BIOM]
	       set biom [get_variable_value EMBIOMH]
	       if {$chem=="0A" || $chem=="" || $bmass=="N" || $biom=="N" } {
            	   # <OPT> A_0(n10n9)=26. Only if Elevated emissions included
		   return 0
    	       }	
	    } elseif {$st_mask_n(9)==7} {  
	       set chem [get_variable_value ATMOS_SR(17)]
               set dust [get_variable_value I_DUST]
               if {$chem=="0A" || $dust =="0"} {
            	  # <OPT> A_0(n10n9)=27. Only available with 2&6 bin Dust Schemes (S. Woodward)
                  return 0
	      }
	    } elseif {$st_mask_n(9)==8} {  
	       set chem [get_variable_value ATMOS_SR(17)]
               set dust [get_variable_value I_DUST]
               if {$chem=="0A" || ($dust !="2")} {
            	  # <OPT> A_0(n10n9)=28. Only available with Dust Scheme (S. Woodward)
                  return 0
               }
            } else {
               error "Unexpected STASH option code st_mask_n(10)n(9)=$st_mask_n(10)$st_mask_n(9). Model A. Section $isec."
            }
 
	} elseif {$st_mask_n(10)==3} {  
            if {$st_mask_n(9)==1} {  
	       set sulphur [get_variable_value CHEM_SULPC]
	       set nitrate [get_variable_value CHEM_NITR]
	       if { $sulphur=="N" || ($sulphur=="Y" && $nitrate=="N") } {
	          # <OPT> A_0(n10n9)=31. Only if prognostics associated with nitrate aerosol
	          return 0
	       } 
	    } elseif {$st_mask_n(9)==5} {  
	       set chem [get_variable_value ATMOS_SR(17)]
    	       set ocff [get_variable_value CHEM_OCFF]
      	       if { $chem == "0A" || $ocff != "Y" } {
       	           # A_0(n10n9)=35 only if OCFF is true
                   return 0
               }
	    } elseif {$st_mask_n(9)==6} {  
	       set chem [get_variable_value ATMOS_SR(17)]
      	       set ocff [get_variable_value CHEM_OCFF]
               set surem [get_variable_value LOCFFSUREM]
               if { $chem == "0A" || $ocff != "Y" || $surem != "Y"} {
                   # A_0(n10n9)=36 only if Surface OCFF is true
        	   return 0
               }	
	    } elseif {$st_mask_n(9)==7} { 
 	       set chem [get_variable_value ATMOS_SR(17)]
      	       set ocff [get_variable_value CHEM_OCFF]
               set hilem [get_variable_value LOCFFHILEM]
               if { $chem == "0A" || $ocff != "Y" || $hilem != "Y"} {
                  # A_0(n10n9)=37 only if High-level OCFF is true
        	  return 0
               }
	    } elseif {$st_mask_n(9)==8} {  
	       set chem [get_variable_value ATMOS_SR(17)]
               set dust [get_variable_value I_DUST]
	       set bin [get_variable_value SIZEDIST]
               if {$chem=="0A" || $dust =="0" || $bin=="3"} {
            	  # <OPT> A_0(n10n9)=38. Only available with 6 bin Dust Scheme (S. Woodward)
                  return 0
	      }
            } else {
               error "Unexpected STASH option code st_mask_n(10)n(9)=$st_mask_n(10)$st_mask_n(9). Model A. Section $isec."
            }

        } else {
            error "Unexpected STASH option code st_mask_n(10)n(9)=$st_mask_n(10)$st_mask_n(9). Model A. Section $isec."
        }

        if {$st_mask_n(11)==0} {
            # OK
        } elseif {$st_mask_n(11)==1} {
            set veg_type [get_variable_value VEG_TYPE ]
            if { $veg_type != 0 } {
                # <OPT> A_0(n11)=1. Only if this model excludes direct vegetation model.
                return 0
            }
        } elseif {$st_mask_n(11)==2} {
            set veg_type [get_variable_value VEG_TYPE ]
            if { $veg_type == 0 } {
                # <OPT> A_0(n11)=2. Only if this model includes direct vegetation scheme of any type.
                return 0
            }
        } elseif {$st_mask_n(11)==3} {
            set veg_type [get_variable_value VEG_TYPE ]
            if { $veg_type != 2 } {
                # <OPT> A_0(n11)=3. Only if this model includes direct vegetation scheme with competetion.
                return 0
            }
        } elseif {$st_mask_n(11)==4} {
            set albedo_obs  [get_variable_value OBSALB ]
            set albedo_spec [get_variable_value SPECALB]
            if { $albedo_obs=="N" || $albedo_spec=="Y" } {
                # <OPT> A_0(n11)=4. Only if L_ALBEDO_OBS_IO is true and L_SPEC_ALBEDO_IO is false
                return 0
            }
        } elseif {$st_mask_n(11)==5} {
            set albedo_obs  [get_variable_value OBSALB ]
            set albedo_spec [get_variable_value SPECALB]
            if { $albedo_obs=="N" || $albedo_spec=="N" } {
                # <OPT> A_0(n11)=5. Only if L_ALBEDO_OBS_IO is true and L_SPEC_ALBEDO_IO is true
                return 0
            }
        } elseif {$st_mask_n(11)==6} {
            set jl_agg  [get_variable_value JL_AGGREGATE ]
            set ji_optagg [get_variable_value IAGGREGATE]
            if { $jl_agg=="N" || $ji_optagg=="0"} {
                # <OPT> A_0(n11)=6. Only if JL_AGGREGATE is true and IAGGREGATE is 1
                return 0
            }
        } else {
          error "Unexpected STASH option code st_mask_n(11)=$st_mask_n(11). Model A. Section $isec."
        }


        if {$st_mask_n(12)==0 || $st_mask_n(12)==3 } {
            # OK
        } elseif {$st_mask_n(12)==4} {
            set lspice [get_variable_value MCRGRAIN ]
            if { $lspice != "T" } {
                # <OPT> A_0(n12)=4.  Only if MCRGRAIN is true, ie inc prognostic ice.
                return 0
            }		
	} elseif {$st_mask_n(12)==5} {
            set lspice [get_variable_value MCRGRPUP ]
            if { $lspice != "T" } {
                # <OPT> A_0(n12)=5.  Only if MCRGRPUP is true, ie inc prognostic ice.
                return 0
            }	
	} elseif {$st_mask_n(12)==6} {
	    set atmos9 [get_variable_value ATMOS_SR(9)]
            set lpc2 [get_variable_value P_CLD_PC2 ]
            if { $atmos9=="0A" || $lpc2 != "T" } {
                # <OPT> A_0(n12)=5.  Only if PC2 cloud scheme is active.
                return 0
            }			
        } else {
          error "Unexpected STASH option code st_mask_n(12)=$st_mask_n(12). Model A. Section $isec."
        }


        if {$st_mask_n(13)==0} {
            # OK
        } elseif {$st_mask_n(13)==1} {
            set c3dcca [get_variable_value L3DCCA ]
            if { $c3dcca != "N" } {
                # <OPT> A_0(n13)=1. Only if _not_ L_3D_CCA (Anvil) convective cloud.
                return 0
            }
        } elseif {$st_mask_n(13)==2} {
            set c3dcca [get_variable_value L3DCCA ]
            if { $c3dcca != "Y"   } {
                # <OPT> A_0(n13)=2.  Only if L_3D_CCA (Anvil) convective cloud.
                return 0
            }
	} elseif {$st_mask_n(13)==3} {
	    set atmos_sr5 [get_variable_value ATMOS_SR(5)]
            set ccrad [get_variable_value LCCRAD]
            if { $atmos_sr5 == "0A" || $ccrad != "Y" } {
                # <OPT> A_0(n13)=3.  Only if using CCRad
                return 0
            }
	} elseif {$st_mask_n(13)==5} {
	    set atmos_sr5 [get_variable_value ATMOS_SR(5)]
            set convhist [get_variable_value LCONVHIST]
            if { $atmos_sr5 == "0A" || $convhist != "Y" } {
                # <OPT> A_0(n13)=5.  Only if convective history prognostics included
                return 0
            }	    
        } else {
          error "Unexpected STASH option code st_mask_n(13)=$st_mask_n(13). Model A. Section $isec."
        }

        if {$st_mask_n(14)==0} {
            # OK   	    
        } else {
          error "Unexpected STASH option code st_mask_n(14)=$st_mask_n(14). Model A. Section $isec."
        }


        if {$st_mask_n(15)==0} {
	  # OK
        } elseif {$st_mask_n(15)==3} {
            set co2opt [get_variable_value CO2OPT ]
            if { $co2opt != 3  } {
                # <OPT> A_0(n15)=3. Only if Interactive Carbon cycle.
                return 0
            }
	} else {
          error "Unexpected STASH option code st_mask_n(15)=$st_mask_n(15). Model A. Section $isec."
        }
       

        if {$st_mask_n(16)==0} {
            # OK
	} elseif {$st_mask_n(16)==1} {
	   set jules [get_variable_value JULES]
	   if { $jules=="F" } {
	     # <OPT> A_0(n16)=1. Only if JULES sub-model is active
	     return 0
	   }
	} elseif {$st_mask_n(16)==2} {
	   set jules [get_variable_value JULES]
	   set nsmax [get_variable_value NSMAX]
	   if { $jules == "F" || $nsmax == "0" } {
	     # <OPT> A_0(n16)=2. Only if layers in the snowpack is greater than 0
	     return 0
	   }	   
	} elseif {$st_mask_n(16)==3} {
	   set es_rad [get_variable_value ES_RAD]
           set snowalb [get_variable_value SNOWALB]
           if {($es_rad != 1 && $es_rad != 3 )||($snowalb != "Y")} {
	     # <OPT> A_0(n16)=3. Only if ES SW radiation and snow albedo option chosen
	     return 0
	   }	   
	} elseif {$st_mask_n(16)==4} {
	   set jules [get_variable_value JULES]
	   set urban [get_variable_value JULES_SR(2)]
	   if { $jules!="T" || $urban=="1T" } {
	     # <OPT> A_0(n16)=4. Only available with JULES 2T+ urban schemes
	     return 0
	   }
	} elseif {$st_mask_n(16)==5} {
	   set jules [get_variable_value JULES]
	    set flake [get_variable_value JL_FLAKE]
	   if { $jules!="T" || $flake!="T" } {
	     # <OPT> A_0(n16)=5. Only available with the FLake model
	     return 0
	   }
        } else {
          error "Unexpected STASH option code st_mask_n(16)=$st_mask_n(16). Model A. Section $isec."
        }

        if {$st_mask_n(17)==0} {
            set varrcf [get_variable_value VAR_RECON ]
            if { $varrcf == "Y" } {
                 # <OPT> A_0(n17)=1. Only if non-VAR reconfiguration.
                 return 0
            }
        } elseif {$st_mask_n(17)==1} {
            # OK
	} else { 
          error "Unexpected STASH option code st_mask_n(17)=$st_mask_n(17). Model A. Section $isec."
        }

        if {$st_mask_n(18)==1} {
           set ctile [get_variable_value CTILE]
           if { $ctile != "Y" } {
                # <OPT> A_0(n18)=1. Only if using coastal tiling.
                return 0
           }
        } elseif {$st_mask_n(18)==2} {
	    set salb_chl [get_variable_value LSEA_ALBCHL]
            if { $salb_chl!="Y" } {
	        # <OPT> A_0(n18)=2. Only if varying chlotophyll content in open sea albedo is ON
                return 0
            }
        } elseif {$st_mask_n(18)==3} {
	    set rivers [get_variable_value ATMOS_SR(26)]
            if { $rivers!="1A" } {
	        # <OPT> A_0(n18)=3. Only if river routing is ON
                return 0
            }
        } elseif {$st_mask_n(18)==4} {
	    set atmos_sr26 [get_variable_value ATMOS_SR(26)]
            set inland [get_variable_value LINLAND]
            if {$atmos_sr26!="1A" || $inland!="Y"} {
                # <OPT> A_0(n18)=4. Only if inland basin re-routing is ON
                return 0
            }
	} elseif {$st_mask_n(18)==7} {    
            set nice [get_variable_value NCICECAT]
            if { $nice == 1 } {
	       # <OPT> A_0(n18)=7. Only available if NCICECAT > 1
               return 0
	    }
        } elseif {$st_mask_n(18)!=0} {  
          error "Unexpected STASH option code st_mask_n(18)=$st_mask_n(18). Model A. Section $isec."
        }

        if {$st_mask_n(19)==1} {
           # Currently no option to check for in UMUI
           # Eventually it will check if L_USE_TPPS_OZONE is used
        } elseif {$st_mask_n(19)!=0} {  
          error "Unexpected STASH option code st_mask_n(19)=$st_mask_n(19). Model A. Section $isec."
        }


        if {$st_mask_n(20)==1} {
            set canmod [get_variable_value BLCANOPY]
	    set jules [get_variable_value JULES]
	    set nsmax [get_variable_value NSMAX]
            if { ($jules == "F" || $nsmax == "0") && $canmod != "4" } {
                # <OPT> A_0(n20)=1 only if CAN_MODEL!=4 or JULES snow layers are >0
                return 0
            }
        } elseif {$st_mask_n(20)!=0} {
          error "Unexpected STASH option code st_mask_n(20)=$st_mask_n(20). Model A. Section $isec."
        }
		
        if {$st_mask_n(21)==1 || $st_mask_n(21)==2} {
           set i_fsd [get_variable_value I_FSD]
           if {$i_fsd==0 || $i_fsd==1 || $i_fsd==4} {
              # <OPT> A_0(n21)=1. Only available if I_FSD == 2,3,5 or 6
                return 0
           }
        } elseif {$st_mask_n(21)==3} {
           set i_fsd [get_variable_value I_FSD]
           if {$i_fsd!=2 && $i_fsd!=5 } {
              # <OPT> A_0(n21)=1. Only available if I_FSD == 2 or 5
                return 0
           }
        } elseif {$st_mask_n(21)!=0} {  
          error "Unexpected STASH option code st_mask_n(21)=$st_mask_n(21). Model A. Section $isec."
        }


        if {$st_mask_n(22)==0} {
	    # OK
        } else {  
            error "Unexpected STASH option code st_mask_n(22)=$st_mask_n(22). Model A. Section $isec."
        }

        if {$st_mask_n(23)==0} {
           # OK
        } elseif {$st_mask_n(23)!=0} {
          error "Unexpected STASH option code st_mask_n(23)=$st_mask_n(23). Model A. Section $isec."
        }


        if {$st_mask_n(24)==0} {
           # OK
        } elseif {$st_mask_n(24)!=0} {  
          error "Unexpected STASH option code st_mask_n(19)=$st_mask_n(19). Model A. Section $isec."
        }
        
        
	if {$st_mask_n(25)==3} { 
	    set ukca [get_variable_value ATMOS_SR(34)]
            if { $ukca == "0A" } {
                # A_0(n25)=3 only available if UKCA is on
        	    return 0
            }	   
        } elseif {$st_mask_n(25)!=0 } {
    	    error "Unexpected STASH option code st_mask_n(25)=$st_mask_n(25). Model A. Section $isec."
        }
        
        if {$st_mask_n(29)==0} {
            # OK 
        } elseif {$st_mask_n(29)==1} {
           set endgame [get_variable_value L_ENDGAME ]
           if { $endgame != "T" } {
              # <OPT> A_0(n29)=1. Only available for EndGame dynamical core code
              return 0
           }
	} else {
    	    error "Unexpected STASH option code st_mask_n(29)=$st_mask_n(29). Model A. Section $isec."
        }
		
    return 1
}

proc check_section_A_1 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_1
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_1
    #-

    global st_mask_n2n1 st_mask_n
    
    if {$st_mask_n(1)==1} {
	set ocaaa [get_variable_value OCAAA]
	if {$ocaaa!=1} {
	    return 0
	}
    }  elseif {$st_mask_n(1) !=0 } {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }

    if {$st_mask_n(2)==1} {
	set swmcr [get_variable_value SWMCR]
	set sr1 [get_variable_value ATMOS_SR(1)]
	set es_rad [get_variable_value ES_RAD]
	if { ! ($swmcr=="Y" && ( $es_rad == 1 || $es_rad == 3 ) ) } {
	    return 0
	}
    }  elseif {$st_mask_n(2) !=0 } {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }       


    if {$st_mask_n(3) !=0 } {
       error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }

    if {$st_mask_n(4)==1} {
        set chem [get_variable_value ATMOS_SR(17)]
        set sulpc [get_variable_value CHEM_SULPC]
        set sulpind [get_variable_value SULP_SW_IND]
        if {$chem=="0A" || $chem=="" || $sulpc=="N" || $sulpind!="Y"} {
            # <OPT> A_1(n4)=1. Only if indirect effect of sulphate for SW rad
            return 0
        }
    }  elseif {$st_mask_n(4) !=0 } {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }

    if {$st_mask_n(5)==1} {
	set chem [get_variable_value ATMOS_SR(17)]
	set sulpc [get_variable_value CHEM_SULPC]
	set sulpind_sw [get_variable_value SULP_SW_IND]
	set sulpind_lw [get_variable_value SULP_LW_IND]
	set sea_ind [get_variable_value SEA_IND]
	set sea_dir [get_variable_value SEA_RAD_DIR]
	if {($chem=="0A" || $sulpc=="N" || ($sulpind_sw=="N" && $sulpind_lw=="N") || $sea_ind=="N") && $sea_dir=="N"} {
	    # <OPT> A_1(n5)=1. Only if direct or indirect seasalt aerosols
	    return 0
	}
    }  elseif {$st_mask_n(5) !=0 } {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }

    if {$st_mask_n(6)==1} {
        set pc2 [get_variable_value P_CLD_PC2]
        set sr9 [get_variable_value ATMOS_SR(9)]
        if {($sr9 == "0A" || $pc2 == "N" )} {
            return 0
        }
        
    } elseif {$st_mask_n(6) !=0 } {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }

    return 1
}
proc check_section_A_2 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_2
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-
    global st_mask_n2n1 st_mask_n

    if {$st_mask_n(2)==1} {
        set luseaod [get_variable_value LUSEAOD]
#        set sr17 [get_variable_value ATMOS_SR(17)]
        if {($luseaod == "N" )} {
            # Only available if switch "Enable aerosol optical depths diagnostics" selected
            return 0
        }
    } elseif {$st_mask_n(6)==1} {
        set pc2 [get_variable_value P_CLD_PC2]
        set sr9 [get_variable_value ATMOS_SR(9)]
        if {($sr9 == "0A" || $pc2 == "N" )} {
            return 0
        }
    } elseif {$st_mask_n(6) !=0 } {
          error "Unexpected STASH option code st_mask_n(6)=$st_mask_n(6). Model A. Section $isec."
    } elseif {$st_mask_n(7)==1} {
         set sr2 [get_variable_value ATMOS_SR(2)]
         set l_cosp [get_variable_value LCOSP]
         if {($sr2 == "0A" || $l_cosp == "N")} {
             return 0
         }
    } elseif {$st_mask_n(7) !=0} {
          error "Unexpected STASH option code st_mask_n(7)=$st_mask_n(7). Model A. Section $isec."
    }

    return 1
}

proc check_section_A_3 {isec} {
    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_3
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-
    global st_mask_n2n1 st_mask_n

    if {$st_mask_n(1)==1} {
	set orogr [get_variable_value OROGR]
	if {$orogr!="Y"} {
            # <OPT> A_3(n1)=1. Only if this model is with ororgraphic roughness.
	    return 0
        }
    } elseif {$st_mask_n(1) !=0 } {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }

    if {$st_mask_n(2)==1} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set sulpc [get_variable_value CHEM_SULPC]
	    if {$chem=="0A" || $chem=="" || $sulpc=="N" } {
            # <OPT> A_3(n2)=1. Only if this model includes sulphur cycle.
	        return 0
        }
    } elseif {$st_mask_n(2)==2} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set sulpc [get_variable_value CHEM_SULPC]
        set oznh3 [get_variable_value SULOZONE ]
	    if {$chem=="0A" || $chem=="" || $sulpc=="N" || $oznh3=="N"} {
            # <OPT> A_3(n2)=2. Only if this model includes sulphur cycle with Ozone and NH3
	        return 0
        }
      
    } elseif {$st_mask_n(2)==3} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set soot [get_variable_value CHEM_SOOT]
	    if {$chem=="0A" || $chem=="" || $soot=="N" } {
            # <OPT> A_3(n2)=3. Only if this model includes soot chemistry model
	        return 0
        }
		
	} elseif {$st_mask_n(2)==4} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set biom [get_variable_value CHEM_BIOM]
	    if {$chem=="0A" || $chem=="" || $biom=="N" } {
            # <OPT> A_3(n2)=4. Only if this model includes biomass chemistry model
	        return 0
        }		
      
	} elseif {$st_mask_n(2)==5} { 
        set dust [get_variable_value I_DUST]
	    if {$dust=="0" } {
            # <OPT> A_3(n2)=5. Only if this model includes dust scheme
	        return 0
        }	
        	
    } elseif {$st_mask_n(2)==6} { 
        set ocff [get_variable_value CHEM_OCFF]
	    if {$ocff!="Y" } {
            # <OPT> A_4(n2)=6. Only if this model includes ocff scheme
	        return 0
        }
	   
    } elseif {$st_mask_n(2)==7} { 
        set sulphur [get_variable_value CHEM_SULPC]
	set nitrate [get_variable_value CHEM_NITR]
	    if { $sulphur=="N" || ($sulphur=="Y" && $nitrate=="N") } {
            # <OPT> A_3(n2)=7. Only if this model includes nitrate aerosol
	        return 0
        }

    } elseif {$st_mask_n(2)==8} {
        set atmos17 [get_variable_value ATMOS_SR(17)] 
        set idust [get_variable_value I_DUST]
	    if { $atmos17=="0A" || $idust=="0" } {
            # <OPT> A_3(n2)=8. Only if this model includes a Dust Scheme
	        return 0
        }		
		
    } elseif {$st_mask_n(2) !=0 } {
          error "Unexpected STASH option code st_mask_n(2)=$st_mask_n(2). Model A. Section $isec."
    }


    if {$st_mask_n(3)==0} {
            # OK
    } elseif {$st_mask_n(3)==1} {
        set co2opt [get_variable_value CO2OPT ]
        if { $co2opt != 3  } {
            # <OPT> A_3(n3)=1. Only if interactive carbon cycle.
            return 0
        }
    } elseif {$st_mask_n(3) !=0 } {
          error "Unexpected STASH option code st_mask_n(3)=$st_mask_n(3). Model A. Section $isec."
    }

    if {$st_mask_n(4)==1} {
    	   set nice [get_variable_value NCICECAT]
           if { $nice == 1 } {
               # <OPT> A_0(n4)=1 only available if NCICECAT > 1
               return 0
           }
    } elseif {$st_mask_n(4)!=0} {  
        error "Unexpected STASH option code st_mask_n(4)=$st_mask_n(4). Model A. Section $isec."
    }
   
    if {$st_mask_n(5) !=0 } {
        error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
    }

    if {$st_mask_n(6)==1} {
        set pc2 [get_variable_value P_CLD_PC2]
        set sr9 [get_variable_value ATMOS_SR(9)]
        if {($sr9 == "0A" || $pc2 == "N" )} {
            return 0
        }
    }  elseif {$st_mask_n(6) !=0 } {
          error "Unexpected STASH option code st_mask_n(6)=$st_mask_n(6). Model A. Section $isec."
    }

    if {$st_mask_n(7)==0} {
        # OK
    } elseif {$st_mask_n(7)==1} {
       set chem [get_variable_value ATMOS_SR(17)]
       set dust [get_variable_value I_DUST]
       if {$chem=="0A" || $dust =="0"} {
          # <OPT> A_0(n7)=1. Only available with 2 & 6 bin Dust Schemes (S. Woodward)
          return 0
       }
    } elseif {$st_mask_n(7)==2} {
       set chem [get_variable_value ATMOS_SR(17)]
       set dust [get_variable_value I_DUST]
       set bin [get_variable_value SIZEDIST]
       if {$chem=="0A" || $dust =="0" || $bin=="3"} {
          # <OPT> A_0(n7)=1. Only available with 6 bin Dust Scheme (S. Woodward)
          return 0
       }
    }

    for { set i 8 } { $i <= 20 } { incr i } {
      if {$st_mask_n($i) !=0 } {
          error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
      }
    } 

    return 1
}

proc check_section_A_4 {isec} {
    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_3
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-
    global st_mask_n2n1 st_mask_n

    if {$st_mask_n(1) !=0 } {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }

    if {$st_mask_n(2)==1} {
        set chem [get_variable_value ATMOS_SR(17)]
        set sulpc [get_variable_value CHEM_SULPC]
	if {$chem=="0A" || $chem=="" || $sulpc=="N" } {
            # <OPT> A_4(n2)=1. Only if this model includes sulphur cycle.
	    return 0
        }
    } elseif {$st_mask_n(2)==2} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set sulpc [get_variable_value CHEM_SULPC]
        set oznh3 [get_variable_value SULOZONE ]
	if {$chem=="0A" || $chem=="" || $sulpc=="N" || $oznh3=="N"} {
            # <OPT> A_4(n2)=2. Only if this model includes sulphur cycle with Ozone and NH3
	    return 0
        }
      
    } elseif {$st_mask_n(2)==3} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set soot [get_variable_value CHEM_SOOT]
		if {$chem=="0A" || $chem=="" || $soot=="N" } {
            # <OPT> A_4(n2)=3. Only if this model includes soot chemistry model
	    return 0
        }
		
	} elseif {$st_mask_n(2)==4} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set biom [get_variable_value CHEM_BIOM]
		if {$chem=="0A" || $chem=="" || $biom=="N" } {
            # <OPT> A_3(n2)=4. Only if this model includes biomass chemistry model
	    return 0
        }			
      
	} elseif {$st_mask_n(2)==5} { 
        set chem [get_variable_value I_DUST]
	    if {$chem=="0" } {
            # <OPT> A_4(n2)=5. Only if this model includes dust scheme
	        return 0
        }		
		
    } elseif {$st_mask_n(2)==6} { 
        set ocff [get_variable_value CHEM_OCFF]
	    if {$ocff!="Y" } {
            # <OPT> A_4(n2)=6. Only if this model includes ocff scheme
	        return 0
        }	
		
    } elseif {$st_mask_n(2)==7} { 
        set sulphur [get_variable_value CHEM_SULPC]
	set nitrate [get_variable_value CHEM_NITR]
	    if { $sulphur=="N" || ($sulphur=="Y" && $nitrate=="N") } {
            # <OPT> A_4(n2)=7. Only if this model includes nitrate aerosol
	        return 0
        }
				
    } elseif {$st_mask_n(2) !=0 } {
          error "Unexpected STASH option code st_mask_n(2)=$st_mask_n(2). Model A. Section $isec."
    }

    for { set i 3 } { $i <= 5 } { incr i } {
      if {$st_mask_n($i) !=0 } {
          error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
      }
    } 

    if {$st_mask_n(6)==1} {
        set pc2 [get_variable_value P_CLD_PC2]
        set sr9 [get_variable_value ATMOS_SR(9)]
        if {($sr9 == "0A" || $pc2 == "N" )} {
            # <OPT> A_4(n6)=1. Only available with PC2 Cloud Scheme
            return 0
        }
    }  elseif {$st_mask_n(6) !=0 } {
          error "Unexpected STASH option code st_mask_n(6)=$st_mask_n(6). Model A. Section $isec."
    }

    if {$st_mask_n(7)==0} {
        # OK
    } elseif {$st_mask_n(7)==1} {
       set chem [get_variable_value ATMOS_SR(17)]
       set dust [get_variable_value I_DUST]
       if {$chem=="0A" || $dust =="0"} {
          # <OPT> A_0(n7)=1. Only available with 2 & 6 bin Dust Schemes (S. Woodward)
          return 0
       }
    } elseif {$st_mask_n(7)==2} {
       set chem [get_variable_value ATMOS_SR(17)]
       set dust [get_variable_value I_DUST]
       set bin [get_variable_value SIZEDIST]
       if {$chem=="0A" || $dust =="0" || $bin=="3"} {
          # <OPT> A_0(n7)=1. Only available with 6 bin Dust Scheme (S. Woodward)
          return 0
       }
    }

    for { set i 8 } { $i <= 20 } { incr i } {
      if {$st_mask_n($i) !=0 } {
          error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
      }
    } 


    return 1
}

proc check_section_A_5 {isec} {
    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_3
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-
    global st_mask_n2n1 st_mask_n

    if {$st_mask_n(1) !=0 } {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }

    if {$st_mask_n(2)==1} {
        set chem [get_variable_value ATMOS_SR(17)]
        set sulpc [get_variable_value CHEM_SULPC]
	if {$chem=="0A" || $chem=="" || $sulpc=="N" } {
            # <OPT> A_5(n2)=1. Only if this model includes sulphur cycle.
	    return 0
        }

    } elseif {$st_mask_n(2)==2} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set sulpc [get_variable_value CHEM_SULPC]
        set oznh3 [get_variable_value SULOZONE ]
	if {$chem=="0A" || $chem=="" || $sulpc=="N" || $oznh3=="N"} {
            # <OPT> A_5(n2)=2. Only if this model includes sulphur cycle with Ozone and NH3
	    return 0
        }
      
    } elseif {$st_mask_n(2)==3} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set soot [get_variable_value CHEM_SOOT]
	if {$chem=="0A" || $chem=="" || $soot=="N" } {
            # <OPT> A_5(n2)=3. Only if this model includes soot chemistry model
	    return 0
        }
		
    } elseif {$st_mask_n(2)==4} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set biom [get_variable_value CHEM_BIOM]
	if {$chem=="0A" || $chem=="" || $biom=="N" } {
            # <OPT> A_3(n2)=4. Only if this model includes biomass chemistry model
	    return 0
        }				
      
    } elseif {$st_mask_n(2)==5} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set dust [get_variable_value I_DUST]
	if {$chem=="0A" || $dust=="0" } {
            # <OPT> A_3(n2)=5. Only if this model includes dust scheme
	    return 0
        }
		
    } elseif {$st_mask_n(2)==6} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set ocff [get_variable_value CHEM_OCFF]
	if {$chem=="0A" || $ocff!="Y" } {
            # <OPT> A_4(n2)=6. Only if this model includes ocff scheme
	    return 0
        }
	
    } elseif {$st_mask_n(2)==7} { 
        set chem [get_variable_value ATMOS_SR(17)]
        set sulphur [get_variable_value CHEM_SULPC]
	set nitrate [get_variable_value CHEM_NITR]
	if { $chem=="0A" || $sulphur=="N" || ($sulphur=="Y" && $nitrate=="N") } {
            # <OPT> A_5(n2)=7. Only if this model includes nitrate aerosol
	    return 0
        }			
		
    } elseif {$st_mask_n(2) !=0 } {
          error "Unexpected STASH option code st_mask_n(2)=$st_mask_n(2). Model A. Section $isec."
    }


    if {$st_mask_n(3)==0} {
        # OK
    } elseif {$st_mask_n(3)==1} {
        set c3dcca [get_variable_value L3DCCA ]
        if { $c3dcca != "N" } {
            # <OPT> A_5(n3)=1. Only if _not_ L_3D_CCA (Anvil) convective cloud.
            return 0
        }
    } elseif {$st_mask_n(3)==2} {
        set c3dcca [get_variable_value L3DCCA ]
        if { $c3dcca != "Y"   } {
            # <OPT> A_0(n3)=2.  Only if L_3D_CCA (Anvil) convective cloud.
            return 0
        }
    } else {
          error "Unexpected STASH option code st_mask_n(3)=$st_mask_n(3). Model A. Section $isec."
    }

    if {$st_mask_n(4)==0} { 
        set convopt [get_variable_value CONVOPT] 
        if { $convopt == "0" } { 
            # <OPT> A_5(n4)=1. Only available if convection option is turned ON 
            return 0  
        } 
    } elseif {$st_mask_n(4)==1} { 
	# OK 
    } else { 
        error "Unexpected STASH option code st_mask_n(4)=$st_mask_n(4). Model A. Section $isec." 
    } 
 
    if {$st_mask_n(5) !=0 } {
        error "Unexpected STASH option code st_mask_n($i)=$st_mask_n(5). Model A. Section $isec."
    }


    if {$st_mask_n(6)==1} {
        set pc2 [get_variable_value P_CLD_PC2]
        set sr9 [get_variable_value ATMOS_SR(9)]
        if {($sr9 == "0A" || $pc2 == "N" )} {
            # <OPT> A_4(n6)=1. Only available with PC2 Cloud Scheme
            return 0
        }
    }  elseif {$st_mask_n(6) !=0 } {
          error "Unexpected STASH option code st_mask_n(6)=$st_mask_n(6). Model A. Section $isec."
    }

    if {$st_mask_n(7)==0} {
        # OK
    } elseif {$st_mask_n(7)==1} {
       set chem [get_variable_value ATMOS_SR(17)]
       set dust [get_variable_value I_DUST]
       if {$chem=="0A" || $dust =="0"} {
          # <OPT> A_0(n7)=1. Only available with 2 & 6 bin Dust Schemes (S. Woodward)
          return 0
       }
    } elseif {$st_mask_n(7)==2} {
       set chem [get_variable_value ATMOS_SR(17)]
       set dust [get_variable_value I_DUST]
       set bin [get_variable_value SIZEDIST]
       if {$chem=="0A" || $dust =="0" || $bin=="3"} {
          # <OPT> A_0(n7)=1. Only available with 6 bin Dust Scheme (S. Woodward)
          return 0
       }
    }

    for { set i 8 } { $i <= 20 } { incr i } {
      if {$st_mask_n($i) !=0 } {
          error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
      }
    } 

    return 1
}

proc check_section_A_6 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_16
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-

    global st_mask_n2n1 st_mask_n   
    if {$st_mask_n(1) !=0 } {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }
    
    if {$st_mask_n(2)==1} {
       set atmos_sr6 [ get_variable_value ATMOS_SR(6) ] 
       set tmp_lorods [ get_variable_value LORODS ] 
       if {($atmos_sr6 == "0A")} {
          # exclude diagnostic option code n(2)=1 when l_gwd = false
         return 0
       }
       if {($atmos_sr6 != "0A" && $tmp_lorods == "F")} {
          # exclude diagnostic option code n(2)=1 when l_gwd = false
          return 0 
       }
    } elseif {$st_mask_n(2)==6} { 
        set ocff [get_variable_value CHEM_OCFF]
	    if {$ocff!="Y" } {
            # <OPT> A_4(n2)=6. Only if this model includes ocff scheme
	        return 0
        }		
		
    } elseif {$st_mask_n(2) !=0 } {
          error "Unexpected STASH option code st_mask_n(2)=$st_mask_n(2). Model A. Section $isec."
    }
    
    if {$st_mask_n(3)==1} {
  
       set atmos_sr6 [ get_variable_value ATMOS_SR(6) ] 
       set tmp_ussp [ get_variable_value LFBLOK ] 
       if {($atmos_sr6 == "4A" && $tmp_ussp == "F")} {
          # exclude diagnostic n(3)=1 when l_use_ussp is false
          return 0
       }
       if {($atmos_sr6 == "0A")} {
         # exclude diagnostic option code n(3)=1 when l_use_ussp = false
         return 0
       }
 
    }
    for { set i 4 } { $i <= 20 } { incr i } {
      if {$st_mask_n($i) !=0 } {
          error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
      }
    } 
    return 1
}

proc check_section_A_8 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_2
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-
    global st_mask_n2n1 st_mask_n

    if {$st_mask_n(3)==5} {
        set l_top [get_variable_value L_HYDROLOGY]
        if {$l_top == "Y"} {
            # Run without hydrology
            return 0
        }    
    } elseif {$st_mask_n(5) !=0 } {
      error "Unexpected STASH option code st_mask_n(3)=$st_mask_n(3). Model A. Section $isec."
    }
    
    if {$st_mask_n(6) !=0 } {
      error "Unexpected STASH option code st_mask_n(6)=$st_mask_n(6). Model A. Section $isec."
    }
    
    if {$st_mask_n(22)==1} {
        set l_riv [get_variable_value ATMOS_SR(26)]
        if {$l_riv != "1A"} {
            return 0
        }
    } elseif {$st_mask_n(22)==2} {
        set inland [get_variable_value LINLAND]
        if {$inland!="Y"} {
            # <OPT> A_0(n22)=2. Only if inland basin re-routing is ON
            return 0
        }
    } elseif {$st_mask_n(22) !=0 } {
          error "Unexpected STASH option code st_mask_n(22)=$st_mask_n(22). Model A. Section $isec."
    }
    
    return 1
}

proc check_section_A_9 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_16
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-

    global st_mask_n2n1 st_mask_n   

    if {$st_mask_n(1) !=0 } {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }

    if {$st_mask_n(2)==0} {
      # OK
    } elseif {$st_mask_n(2)==1} {
        set inactive [inactive_var CLD_AREA ]
        set clda [get_variable_value CLD_AREA ]
        if { $inactive || ($clda != "Y") } {
          # <OPT> A_9(n2)=1. Only if Cloud area Parametrisation used
          return 0
        }
    } else {
      error "Unexpected STASH option code st_mask_n(2)=$st_mask_n(2). Model A. Section $isec."
    }   

    if {$st_mask_n(3)==0} {
      # OK
    } elseif {$st_mask_n(3)==1} {
        set rhcrit [get_variable_value RHCRIT_PARM ]
        if { $rhcrit != "Y"  } {
          # <OPT> A_9(n3)=1. Only if using RHCrit parametrization.   
          return 0
        }
    } else {
      error "Unexpected STASH option code st_mask_n(3)=$st_mask_n(3). Model A. Section $isec."
    }


    for { set i 4 } { $i <= 5 } { incr i } {
      if {$st_mask_n($i) !=0 } {
          error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
      }
    } 
 
    if {$st_mask_n(6)==1} {
        set pc2 [get_variable_value P_CLD_PC2]
        set sr9 [get_variable_value ATMOS_SR(9)]
        if {($sr9 == "0A" || $pc2 == "N" )} {
            return 0
        }
    }  elseif {$st_mask_n(6) !=0 } {
          error "Unexpected STASH option code st_mask_n(6)=$st_mask_n(6). Model A. Section $isec."
    }


    for { set i 7 } { $i <= 20 } { incr i } {
      if {$st_mask_n($i) !=0 } {
          error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
      }
    } 
    return 1
}

proc check_section_A_12 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_12
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-
    global st_mask_n2n1 st_mask_n

    for { set i 1 } { $i <= 5 } { incr i } {
      if {$st_mask_n($i) !=0 } {
          error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
      }
    } 
    if {$st_mask_n(6)==1} {
        set pc2 [get_variable_value P_CLD_PC2]
        set sr9 [get_variable_value ATMOS_SR(9)]
        if {($sr9 == "0A" || $pc2 == "N" )} {
            return 0
        }
        
    } elseif {$st_mask_n(6) !=0 } {
          error "Unexpected STASH option code st_mask_n(6)=$st_mask_n(6). Model A. Section $isec."
    }

    for { set i 7 } { $i <= 20 } { incr i } {
      if {$st_mask_n($i) !=0 } {
          error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
      }
    } 

    return 1
}


proc check_section_A_13 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_13
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-

    global st_mask_n2n1 st_mask_n
       
    for { set i 1 } { $i <= 20 } { incr i } {
      if {$st_mask_n($i) !=0 } {
          error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
      }
    } 

    return 1

}

proc check_section_A_16 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_16
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-

    global st_mask_n2n1 st_mask_n
       
    if {$st_mask_n2n1!=0} {
            set tca [get_variable_value TCA($st_mask_n2n1)]
            set use_tca [get_variable_value USE_TCA]
            if {($tca==0)||($use_tca!="Y")} {
                return 0
            }
    } elseif {$st_mask_n2n1 !=0 } {
         error "Unexpected STASH option code st_mask_n2n1=$st_mask_n2n1. Model A. Section $isec."
    }
   
    if {$st_mask_n(6)==1} {
        set pc2 [get_variable_value P_CLD_PC2]
        set sr9 [get_variable_value ATMOS_SR(9)]
        if {($sr9 == "0A" || $pc2 == "N" )} {
            # <OPT> A_4(n6)=1. Only available with PC2 Cloud Scheme
            return 0
        }
        
    } elseif {$st_mask_n(6) !=0 } {
          error "Unexpected STASH option code st_mask_n(6)=$st_mask_n(6). Model A. Section $isec."
    }

    return 1
}

proc check_section_A_17 {isec} {

    global st_mask_n2n1 st_mask_n

        if {$st_mask_n(1)==1} {
            set sulpc [get_variable_value CHEM_SULPC]
            if { $sulpc=="N" } {
                # <OPT> A_17(n1)=1. Only if this model includes sulphur cycle.
                return 0
            }
        } elseif {$st_mask_n(1)==2} { 
            set soot [get_variable_value CHEM_SOOT]
            if { $soot=="N" } {
                # <OPT> A_17(n1)=2. Only if this model includes soot model.
                return 0
            }
        } elseif {$st_mask_n(1)==3} { 
            set atmos17 [get_variable_value ATMOS_SR(17)]
            set biom [get_variable_value CHEM_BIOM]
            if { $atmos17=="0A" || $biom=="N" } {
                # <OPT> A_17(n1)=3. Only if this model includes Biomass model.
                return 0
            }
        } elseif {$st_mask_n(1)==4} { 
            set atmos17 [get_variable_value ATMOS_SR(17)]
            set dust [get_variable_value I_DUST]
            if { $atmos17=="0A" || $dust=="0" } {
                # <OPT> A_17(n1)=4. Only if this model includes Dust model.
                return 0
            }
        } elseif {$st_mask_n(1)==5} { 
            set atmos17 [get_variable_value ATMOS_SR(17)]
            set ocff [get_variable_value CHEM_OCFF]
            if { $atmos17=="0A" || $ocff=="N" } {
                # <OPT> A_17(n1)=5. Only if this model includes OCFF model.
                return 0
            }
        } elseif {$st_mask_n(1)==6} { 
            set esrad [get_variable_value ES_RAD]
            set biogen [get_variable_value LUSEBIOGEN]
            if { $esrad=="0" || $biogen=="N" } {
                # <OPT> A_17(n1)=6. Only if this model includes Biogenic model.
                return 0
            }
        } elseif {$st_mask_n(1)==7} { 
            set atmos17 [get_variable_value ATMOS_SR(17)]
            set seapm [get_variable_value SEA_PMDIAGS]
            if { $atmos17=="0A" || $seapm=="N" } {
                # <OPT> A_17(n1)=7. Only if this model includes Sea Salt model.
                return 0
            }
        } elseif {$st_mask_n(1)==8} { 
            set atmos17 [get_variable_value ATMOS_SR(17)]
            set sulpc [get_variable_value CHEM_SULPC]
            set nitr [get_variable_value CHEM_NITR]
            if { $atmos17!="2B" || $sulpc=="N" || $nitr=="N" } {
                # <OPT> A_17(n1)=8. Only if this model includes Nitrate model.
                return 0
            }
        } elseif {$st_mask_n(1)==9} { 
            set atmos17 [get_variable_value ATMOS_SR(17)]
            set esrad [get_variable_value ES_RAD]
            set biogen [get_variable_value LUSEBIOGEN]
            if { $atmos17=="0A" && ($esrad=="N" || $biogen=="N")} {
                # <OPT> A_17(n1)=9. Only if this model includes an Aerosol model.
                return 0
            }
        } elseif {$st_mask_n(1)!=0} {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
        }

        if {$st_mask_n(2)==1} {
            set sulpc [get_variable_value CHEM_SULPC]
            set dms [get_variable_value DMS]
            if { $sulpc=="N" || $dms=="N"} {
                # <OPT> A_17(n2)=1. Only if this model includes sulphur cycle with DMS.
                return 0
            }
        } elseif {$st_mask_n(2)==2} { 
            set sulpc [get_variable_value CHEM_SULPC]
            set ozone [get_variable_value  SULOZONE]
            if { $sulpc=="N" || $ozone=="N" } {
                # <OPT> A_17(n2)=2. Only if this model includes sulphur cycle with ozone oxidant
                return 0
            }
        } elseif {$st_mask_n(2)!=0} {
          error "Unexpected STASH option code st_mask_n(2)=$st_mask_n(2). Model A. Section $isec."
        }


        for { set i 3 } { $i <= 20 } { incr i } {
           if {$st_mask_n($i) !=0 } {
               error "Unexpected STASH option code st_mask_n($i)=$st_mask_n($i). Model A. Section $isec."
           }
        } 
}


proc check_section_A_18 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_18
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_18
    #-

    global st_mask_n2n1 st_mask_n

    if {$st_mask_n(1)!=0} {
	error "STASH OBS checking not working since removal of OBS windows at 5.1"
    }
    if {$st_mask_n(2)==1} {
	set totae [get_variable_value TOTAE]
	if {$totae!="Y"} {
	    return 0
	}
    } 
    return 1
}

proc check_section_A_20 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_18
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_18
    #-

    global st_mask_n
	
	if {$st_mask_n(22)==1} {
    	# Only available if river routing is on (Cyndy Bunton)
    	set river [get_variable_value ATMOS_SR(20)]
    	if {$river=="0A"} {
        	return 0
        }
    } elseif {$st_mask_n(22)!=0} {  
    	error "Unexpected STASH option code st_mask_n(22)=$st_mask_n(22). Model A. Section $isec."
    }
	return 1
}

#proc check_section_A_21 {isec} {

#    #+
#    # TREE: experiment_instance navigation create_window stash check_stash check_section_21
#    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_21
#    #-

#    set phi [expr $isec - 20]
#    set a_mean_number [ x_mean_number 1]
#    if {$a_mean_number<$phi} {
#	return 0
#    }
#    if {[check_section_A_0 $isec]==0} {
#	return 0
#    }
#    return 1
#} 

proc check_section_A_21 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_21
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_18
    #-

    global st_mask_n2n1 st_mask_n

    if {$st_mask_n(2)==1} {

        set atmos4 [get_variable_value ATMOS_SR(4)]
        set mcrgrp [get_variable_value MCRGRPUP]
        set lelectr [get_variable_value LUSE_ELECTR]
        set elmethod [get_variable_value ELMETHOD]

        if { $atmos4=="0A"||$mcrgrp!="T"||$lelectr!="T"||$elmethod!=2} {
            # <OPT> A_21(n2)=1. Only to be used with McCaul et al (2009) scheme
            return 0
        }
    }  elseif {$st_mask_n(1)!=0} {
          error "Unexpected STASH option code st_mask_n(1)=$st_mask_n(1). Model A. Section $isec."
    }
    return 1
}


proc check_section_A_22 {isec} {
    if {[check_section_A_22 $isec]==0} {return 0} else {return 1}
}

proc check_section_A_23 {isec} {
    if {[check_section_A_23 $isec]==0} {return 0} else {return 1}
}

proc check_section_A_24 {isec} {
    if {[check_section_A_24 $isec]==0} {return 0} else {return 1}
}

proc check_section_A_26 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_A_2
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_3
    #-
    global st_mask_n2n1 st_mask_n

    if {$st_mask_n(22)==1} {
        set l_riv [get_variable_value ATMOS_SR(26)]
        if {$l_riv != "1A"} {
            return 0
        }
    } elseif {$st_mask_n(22)==2} {
        set inland [get_variable_value LINLAND]
        if {$inland!="Y"} {
            # <OPT> A_0(n22)=2. Only if inland basin re-routing is ON
            return 0
        }
    } elseif {$st_mask_n(22) !=0 } {
          error "Unexpected STASH option code st_mask_n(22)=$st_mask_n(22). Model A. Section $isec."
    }

    return 1
}

proc check_section_A_31 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_31
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_31
    #-

    global st_mask_n2n1 st_mask_n

    if {$st_mask_n(6)==0} {
            # OK
    } elseif {$st_mask_n(6)==1} {
	    set ocaaa [get_variable_value OCAAA]
	    if {$ocaaa==1} {
	     # <OPT> A_0(n6)=1. Only if this is not a global model.
	     return 0
	    }
    } elseif {$st_mask_n(6)==2} {
	    set floor [get_variable_value FLOOR]
	    set ocalb 1
	    if {($floor=="N")&&($ocalb==1)} {
	        # <OPT> A_0(n6)=2. Only if this is a model with a lower boundary condition.
	        return 0
	    }
    } elseif {$st_mask_n(6) > 2} {
	    error "Unexpected STASH option code st_mask_n(6)=$st_mask_n(6). Model A. Section $isec."
    }
    
    if {$st_mask_n(12)==6} {
        set l_pc2 [get_variable_value P_CLD_PC2]
        if { $l_pc2 == "N" } {
            return 0
        }
    }    
    
    return 1
}

proc check_section_A_32 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_31
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_31
    #-

    global st_mask_n2n1 st_mask_n

    if {$st_mask_n(12)==0} {
        #OK
    } elseif {$st_mask_n(12)==6} {
        set l_pc2 [get_variable_value P_CLD_PC2]
        if { $l_pc2 == "N" } {
            return 0
        }
    } 
    
    return 1
}

proc check_section_A_33 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_31
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_31
    #-

    global st_mask_n2n1 st_mask_n

    set tca_mask_321 [ expr 100 * $st_mask_n(3) + $st_mask_n2n1 ]
 
    if {$tca_mask_321 != 0 && $tca_mask_321 <= 150} {
        set tca [get_variable_value TCA($tca_mask_321)]
    
        set use_tca [get_variable_value USE_TCA]
        if {($tca==0)||($use_tca!="Y")} {
            # <OPT> A_33(n3n2n1)=TRACER_NUMBER.  Only if this tracer is included.
            return 0
        }
    } elseif {$tca_mask_321 > 150 } {
        error "Unexpected STASH option code st_mask_n3n2n1=$tca_mask_321. Model A. Section $isec."
    }
    
    return 1
}

proc check_section_A_34 {isec} {

    #+
    # TREE: experiment_instance navigation create_window stash check_stash check_section_31
    # TREE: experiment_instance navigation create_window stash load_diag load_new_diag get_section check_stash check_section_31
    #-

    global st_mask_n2n1 st_mask_n

    set tca_mask_321 [ expr 100 * $st_mask_n(3) + $st_mask_n2n1 ]
 
    if {$tca_mask_321 != 0} {
        set ukca_tca [get_variable_value UKCA_TCA($tca_mask_321)]
    
        set use_ukca_tr [get_variable_value ATMOS_SR(34)]
        if {($ukca_tca==0)||($use_ukca_tr!="1A")} {
            # <OPT> A_34(n3n2n1)=TRACER_NUMBER.  Only if this tracer is included.
            return 0
        }
    } elseif {$tca_mask_321 > 179 } {
        error "Unexpected STASH option code st_mask_n3n2n1=$tca_mask_321. Model A. Section $isec."
    }
    
    return 1
}

proc check_section_A_36 {isec} {
    return 1
}

proc check_section_A_37 {isec} {
    return 1
}

proc check_section_A_38 {isec} {
    return 1
}

proc check_section_A_50 {isec} {
    return 1
}

proc gen_mask_opts {op_code} {

    global st_mask_n st_mask_n2n1
	
	set oplen [string length $op_code]
	if {$oplen != 31} {
		return 1
	}	
	
    for { set i 1 } { $i <= 30 } { incr i } {
      # note the extra index as this is preceded by S eg "S000000000000.."
      set  st_mask_n($i) [string index $op_code [expr 31 - $i] ]
    }
    set st_mask_n2n1 [ expr $st_mask_n(1) + 10 * $st_mask_n(2) ] 
	return 0
}

