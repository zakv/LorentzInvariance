/*
Computes the velocity of the earth in the CMB frame
* 
* To compile: mex -O CFLAGS="\$CFLAGS -std=c99" -I/home/zak/Programs/aephem-2:0:0/src/ cmb_velocity.c

Currently does not actually do that.
*/

#include <stdio.h>
#include <stdlib.h>
#include <aephem.h>
#include "mex.h"

/* calculation function */
void get_velocities( double *in_array, size_t number_of_elements,
                     double *out_array )
{
    size_t j;
    for (j=0; j<number_of_elements; j++) {
        out_array[j] = in_array[j];
    }
}

/* gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *in_array;                              /* input array */
    mwSize number_of_dimensions;                   /* number of dimensions of arrays*/
    mwSize *dimensions;                            /* array of dimension sizes */
    size_t number_of_elements;                     /* number of array elements */
    double *out_array;                             /* output array */
    
    /* check for proper number of arguments */
    if(nrhs!=1) {
        mexErrMsgIdAndTxt("MyToolbox:cmb_velocity:nrhs","Only accepts one input array.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("MyToolbox:cmb_velocity:nlhs","Only returns one output array.");
    }
    
    /* make sure the input argument is type double */
    if( !mxIsDouble(prhs[0]) || 
         mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt("MyToolbox:cmb_velocity:notDouble","Input array must be type double.");
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
    plhs[0] = mxCreateNumericArray(number_of_dimensions,dimensions,mxDOUBLE_CLASS,mxREAL);

    /* get a pointer to the real data in the output arrays */
    out_array = mxGetPr(plhs[0]);

    /* call the computational routine */
    get_velocities(in_array,number_of_elements,out_array);
}
