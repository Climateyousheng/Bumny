This window allows users to specify the use of the soil parameters ancillary
file. It is part of a window sequence.

Note there are different ancillary files if you are using single-layer
hydrology (hydrology option 1A) and MOSES hydrology (options 5A or 7A).
The action required for each field depends on the options chosen.


SINGLE-LAYER HYDROLOGY (option 1A)

The following fields should be considered:

VSMC at wilting point
VSMC at critical point
VSMC at field capacity
VSMC at saturation
Saturated hydraulic conductivity
Eagleson's exponent
Thermal capacity
Thermal conductivity
   
All other fields should be set to "not used".

Standard files hold time-fixed fields and so configuration is the only required
action with these files.



MOSES-I HYDROLOGY (option 5A)

The following fields should be considered:

VSMC at wilting point
VSMC at critical point
VSMC at field capacity (dummy field)
VSMC at saturation
Saturated hydraulic conductivity
Clapp-Hornberger 'B' parameter
Thermal capacity
Thermal conductivity
Saturated soil water suction

All other fields should be set to "not used".
 
Standard files hold time-fixed fields and so configuration is the only required
action with these files.



MOSES-II HYDROLOGY (option 7A)

VSMC at wilting point
VSMC at critical point
VSMC at field capacity (dummy field)
VSMC at saturation
Saturated hydraulic conductivity
Clapp-Hornberger 'B' parameter
Thermal capacity
Thermal conductivity
Saturated soil water suction
Snow-free soil albedo
Soil carbon content

All other fields should be set to "not used".
 
In standard files, all the above fields EXCEPT SOIL CARBON CONTENT are 
time-fixed and so configuration is the only required action with these 
fields.  Soil carbon content is updated within the model, so 
configuration will only normally be required when the soil carbon state 
needs to be set to a prescribed state (eg: at the beginning of a 
simulation).  Configuration of the soil carbon part-way through a 
simulation will cause the previous evolution of soil carbon to be lost, 
resulting in discontinuity of the land surface state and 
non-conservation of global carbon.


GENERAL INFO

See the UMPDs on soil hydrology and vegetation for scientific explanation 
of the fields.

Fields should be configured when changing resolution or moving to a new
land-sea mask.

%I ancill_gen

