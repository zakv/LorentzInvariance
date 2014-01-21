/*
* Computes the velocity of the earth in the CMB frame
* 
* To compile: mex -O CFLAGS="\$CFLAGS -std=c99" -I../../../aephem-2.0.0/src/ cmb_velocity.c ../../../aephem-2.0.0/src/.libs/libaephem.so
* 
* Input Times should be Unix Time, which is seconds since
* January 1 1970 00:00:00 UTC
*/

#include <stdio.h>
#include <stdlib.h>
#include <aephem.h>
#include "mex.h"

//Define CMB parameters from Fixsen (Movement of Solar system barycenter
//with respect to the CMB)
//(http://iopscience.iop.org/0004-637X/707/2/916/pdf/0004-637X_707_2_916.pdf)
#define CMB_SPEED    (0.0012338*299792458.0) // meters/sec
#define CMB_L        263.87                  // degrees
#define CMB_B        48.24                   // degrees

//Other Constants
#define VELOCITY_CONVERSION (149597870700.0/(24.0*60.0*60.0))
    //Multiply by this to convert from AU/day to m/s

/* calculation function */
void get_velocities( double *in_array, size_t number_of_elements,
                     double *out_array0, double *out_array1,
                     double *out_array2 )
{
    //Variables
    double jd_utc, jd_ut1, jd_tt;
    double velocity[3];
    size_t j;
    int j1;
    //CMB velocity variables (really constants)
    double CMB_RIGHT_ASCENSION;
    double CMB_DECLINATION;
    double CMB_VELOCITY[3];
    ae_gal_to_radec(CMB_L,CMB_B,&CMB_RIGHT_ASCENSION,
                    &CMB_DECLINATION,1);
    ae_polar_to_rect(CMB_RIGHT_ASCENSION,CMB_DECLINATION,CMB_SPEED,
                     CMB_VELOCITY);
    
    
    //Stuff used for JPL Ephemerides (currently not used)
    //const char *EPHEMERIDE_FILE_NAME="earth_ephemeride.txt";
    //struct ae_jpl_handle_t jpl_handle;
    //double position[3]; 
    
    //Ephemeride code gives a segfault
    //Open ephemerides
    //ae_jpl_init(EPHEMERIDE_FILE_NAME,&jpl_handle);
      
    for (j=0; j<number_of_elements; j++) {
        //Convert to TT
        jd_utc = ae_ctime_to_jd(in_array[j]); //Julian date in UTC
        jd_ut1=jd_utc+ae_dut1(jd_utc)*AE_D_PER_S; //Julian date in UT1
        jd_tt=jd_ut1+ae_delta_t(jd_ut1)*AE_D_PER_S; //Julian date in TT
        
        //Get the velocity from JPL ephemerides
        //ae_jpl_get_coords(jpl_handle,jd_tt,AE_SS_EARTH,position,velocity,0);
        
        //Just use heliocentric velocity since JPL ephemerides aren't working
        ae_v_orbit(jd_tt,&ae_orb_earth,velocity); //velocity in AU/day
        
        //For testing, set Earth's velocity to 0 to get CMB velocity in
        //J200 coordinates
        /*for (j1=0; j1<3; j1++) {
            velocity[j1]=0.0;
        }*/
        
        //To get velocity of Earth relative to CMB, add the velocity of
        //Earth relative to the sun to the velocity of the sun relative
        //to the CMB        
        for (j1=0; j1<3; j1++) {
            velocity[j1]=velocity[j1]*VELOCITY_CONVERSION+CMB_VELOCITY[j1];
                //Convert velocity to m/s and add CMB velocity
        }
        
        //Assign to output arrays
        out_array0[j] = velocity[0];
        out_array1[j] = velocity[1];
        out_array2[j] = velocity[2];
        

    }
    
    //Close ephemerides (probably not necessary since the function
    //ends after this)
    //ae_jpl_close(jpl_handle);
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
    get_velocities(in_array,number_of_elements,
                   out_array0,out_array1,out_array2);
}
