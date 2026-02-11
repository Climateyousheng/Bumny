The following example is based on specification for CO2, but also 
illustrates the method for defining trace gases and sulphate loading:

Number of designated years for linear interpolation      [5                ]
Comment: You must have at least one year to define a starting value.
         Set this to 1 if you just want exponential growth in years
         subsequent to the start year.

Years and CO2 MMRs for linear Interpolation.
No	Years in 		CO2 MMRs at         Comment
	ascending order	        those years
1	1994			4.9E-4 		    The first year must be at
2	1998			5.2E-4		    at or before the run start.	
3	2010			5.8E-4		    Linear interpolation will
4	2020			6.3E-4		    be used between defined 
5	2030			6.8E-4		    years based on 1st Jan. 

Comment: The last value will be used from 2030 onwards unless you have
         also defined rates for the following period in the table below.
         The interpolation is done in all years on a timestep-by-timestep 
         basis assuming the values to be point values at 00:00 on the 
         1st January of the defined year.

Number of designated year for exponential increase      [3                ]
Comment: Set this to zero if you just want linear interpolation
         between years optionally followed by a constant value.
         This exponential growth regime must come after a linear growth
         period.

Years and % compound growth PA (per annum) in subsequent years.
No	Years in 		CO2 % Compound      Comment
	ascending order		growth PA from 
				year
1	2031			5      		    The first year must be the year
2	2040			8     		    after the last linear year.
3	2050			-2      	    The growth is compounded each
                   				    year using the rate defined   
  						    until a new rate is defined.

Comment: In 2031, a growth of 5% of CO2 MMR will apply to the value of 6.8 
         defined in 2030, to 7.14.
         In 2032 this will increase, in a compound way, by another 5% to 7.497.
         This will continue until 2040, when 8% will be used.
         In 2050, and in subsequent years, a compounded decrease of 2%
         will be applied.
         Values are held constant within each year.
         


