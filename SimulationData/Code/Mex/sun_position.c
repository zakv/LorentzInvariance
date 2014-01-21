/*
* Computes the position of the sun.  This returns three arrays, one for
* each of the following: altitude, azimuth, distance (in that order)
* 
* To compile: mex -O CFLAGS="\$CFLAGS -std=c99" -I../../../aephem-2.0.0/src/ sun_position.c ../../../aephem-2.0.0/src/.libs/libaephem.so
* 
* Input Times should be Unix Time, which is seconds since
* January 1 1970 00:00:00 UTC
*/

#include <stdio.h>
#include <stdlib.h>
#include <aephem.h>
#include "mex.h"

//Location of Alpha
#define LATITUDE     46.234063888888    // Degrees north of the equator.
#define LONGITUDE    6.04616111111111   // Degrees east of the meridean.
#define ALTITUDE     448.0              // Metres above sea level.

/*
//Shattuck and Dwight
#define LATITUDE     37.8639679         // Degrees north of the equator.
#define LONGITUDE    -122.2674246       // Degrees east of the meridean.
#define ALTITUDE     53.0               // Metres above sea level.
*/

/* calculation function */
void sun_position( double *in_array, size_t number_of_elements,
                     double *out_array0, double *out_array1,
                     double *out_array2 )
{
    double jd_utc, jd_ut1, jd_tt, last, right_ascension, declination;
    double distance, altitude, azimuth;
    double rectangular[3];
    double polar[3];
    size_t j;
    int j1;
      
    for (j=0; j<number_of_elements; j++) {
        //Convert to TT
        jd_utc=ae_ctime_to_jd(in_array[j]);         //Julian date in UTC
        jd_ut1=jd_utc+ae_dut1(jd_utc)*AE_D_PER_S;   //Julian date in UT1
        jd_tt=jd_ut1+ae_delta_t(jd_ut1)*AE_D_PER_S; //Julian date in TT
        
        //Get position of sun in coordinates centered in the center
        //of the Earth
        ae_geocentric_sun_from_orbit(jd_tt, &ae_orb_earth,
                                     &right_ascension, &declination,
                                     &distance);
        
        //Account for fact that ALPHA is on the surface of the Earth
        aes_topocentric(jd_ut1, LATITUDE, LONGITUDE, distance,
                        &right_ascension, &declination);
        
        //Convert to altitude/azimuth
        last = aes_last(jd_ut1, LONGITUDE);
        ae_radec_to_altaz(last, LATITUDE, right_ascension, declination,
                          &altitude, &azimuth);
        
        //Assign to output arrays
        out_array0[j] = altitude;
        out_array1[j] = azimuth;
        out_array2[j] = distance;
    }
}

/* gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *in_array;                              /* input array */
    mwSize number_of_dimensions;                   /* number of dimensions of arrays*/
    const mwSize *dimensions;                      /* array of dimension sizes */
    size_t number_of_elements;                     /* number of array elements */
    double *out_array0, *out_array1, *out_array2;  /* output arrays */
    
    /* check for proper number of arguments */
    if(nrhs!=1) {
        mexErrMsgIdAndTxt("MyToolbox:cmb_velocity:nrhs",
                          "Only accepts one input array.");
    }
    if(nlhs!=3) {
        mexErrMsgIdAndTxt("MyToolbox:cmb_velocity:nlhs",
                          "Returns three output arrays.");
    }
    
    /* make sure the input argument is type double */
    if( !mxIsDouble(prhs[0]) || 
         mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt("MyToolbox:cmb_velocity:notDouble",
                          "Input array must be type double.");
    }
    
    /* create a pointer to the real data in the input array  */
    in_array = mxGetPr(prhs[0]);
    
    /* get number of dimensions of the input array */
    number_of_dimensions = mxGetNumberOfDimensions(prhs[0]);
    
    /* get dimensions of the input array */
    dimensions = mxGetDimensions(prhs[0]);
    
    /* get number of elements in input array */
    number_of_elements = mxGetNumberOfElements(prhs[0]);
    
    /* create the output arrays */
    plhs[0] = mxCreateNumericArray(number_of_dimensions,dimensions,
                                   mxDOUBLE_CLASS,mxREAL);
    plhs[1] = mxCreateNumericArray(number_of_dimensions,dimensions,
                                   mxDOUBLE_CLASS,mxREAL);
    plhs[2] = mxCreateNumericArray(number_of_dimensions,dimensions,
                                   mxDOUBLE_CLASS,mxREAL);

    /* get a pointer to the real data in the output arrays */
    out_array0 = mxGetPr(plhs[0]);
    out_array1 = mxGetPr(plhs[1]);
    out_array2 = mxGetPr(plhs[2]);

    /* call the computational routine */
    sun_position(in_array,number_of_elements,
                 out_array0,out_array1,out_array2);
}
