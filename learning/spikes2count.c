#include "mex.h"
#include "math.h"

/*
**
** Here comes the MATLAB INTERFACE: 
**
** X=SPIKES2COUNT(C,t,tau1,tau2)
**
*/

/* Input Arguments */

#define	C_IN	 prhs[0]
#define	t_IN	 prhs[1]
#define	tau1_IN   prhs[2]
#define	tau2_IN   	 prhs[3]

/* Output Arguments */

#define X_OUT  plhs[0]

/*
** some helpers do parse the MatLab given input
*/
#if !defined(max)
#define	max(A, B)	((A) > (B) ? (A) : (B))
#endif
#if !defined(min)
#define	min(A, B)	((A) < (B) ? (A) : (B))
#endif

int getDouble(const mxArray *arg, double *x)
{
  int m = mxGetM(arg); 
  int n = mxGetN(arg); 
  if (!mxIsNumeric(arg) || mxIsComplex(arg) || 
      mxIsSparse(arg)  || !mxIsDouble(arg) || 
      (m != 1) || (n != 1)) {
    *x = 0.0;
    return -1;
  }
  *x = mxGetScalar(arg);
  return 0;
}

int getDoubleVector(const mxArray *arg, double **x, int *n)
{
  int m = min(mxGetM(arg),mxGetN(arg));
  *n = max(mxGetM(arg),mxGetN(arg));
  if (!mxIsNumeric(arg) ||  mxIsComplex(arg) ||  
       mxIsSparse(arg)  || !mxIsDouble(arg)  || m > 1 || m < 0) {
    *x = NULL;
    return -1;
  }
  *x = mxGetPr(arg); 
  return 0;
}

/*
** the mexFunction the the gateway to and from matlab
*/  
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double tau1, tau2, *sample_time; /* arguments */
  int  nSampleTimePoints,nDIM; /* arguments */

  double *spike_time,*x,delta,tmp,*analog_data; /* helper variables and pointer */

  int	m,n,nSpikes,nDataPoints,c,i,j; /* helper and loop variables */

  mxArray *mx_data; int i_data = 0;            /* for field data */
  mxArray *mx_dt;   int i_dt   = 0; double dt; /* for dt field */
  mxArray *mx_spk;  int i_spk  = 0;            /* for spiking field */

  mxArray *mx_spiketimes=0; int i_spiketimes = 0;           
  mxArray *mx_channel=0;    int i_channel    = 0;
  mxArray *mx_index=0;      int i_index      = 0;           

  int *us_spike_times,*us;
  short *channel,*ch;
  double s;
  /* 
  ** check arguments 
  */
  if (nrhs < 2)
    mexErrMsgTxt("SPIKES2COUNT requires at least 2 input arguments!\n");

  if (nlhs != 1) 
    mexErrMsgTxt("SPIKES2COUNT requires 1 output argument!\n");

  /* C should be something like a struct or an empty matrix */
  n = mxGetN(C_IN);
  m = mxGetM(C_IN);
  nDIM = max(n,m);

  if ( nDIM > 0 && !mxIsStruct(C_IN) )
    mexErrMsgTxt("SPIKES2COUNT requires that C is a struct\n");

  if ( nDIM == 0 )
    mexErrMsgTxt("SPIKES2COUNT: nothing to do since there are 0 channels!\n");

  if ( nDIM> 0 && min(m,n) != 1 )
    mexErrMsgTxt("SPIKES2COUNT: C is not a struct vector.\n");
  
  if ( nDIM > 0 ) {
    if ( (i_data = mxGetFieldNumber(C_IN,"data")) >= 0 ) {
      i_dt  = mxGetFieldNumber(C_IN,"dt");
      i_spk = mxGetFieldNumber(C_IN,"spiking");
    } else if ( (i_spiketimes=mxGetFieldNumber(C_IN,"spiketimes")) >= 0 ) {
/*        printf("spiketimes found (%i)!\n",i_spiketimes); */
      if ( (i_channel = mxGetFieldNumber(C_IN,"channel")) < 0 )
        mexErrMsgTxt("C has no field 'channel' while having 'spiketimes'\n");
      if ( (i_index = mxGetFieldNumber(C_IN,"index")) < 0 )
        mexErrMsgTxt("C has no field 'index' while having 'spiketimes'\n");
      if ( nDIM > 1 ) 
        mexErrMsgTxt("Can only handle single spikemat!\n");

      mx_spiketimes = mxGetFieldByNumber(C_IN,0,i_spiketimes);
      if ( !mxIsInt32(mx_spiketimes) )
        mexErrMsgTxt("spiketimes not a uint32 vector!\n");

      mx_index      = mxGetFieldByNumber(C_IN,0,i_index);
      if ( !mxIsInt16(mx_index) )
        mexErrMsgTxt("'index' not a uint16 vector!\n");

      mx_channel    = mxGetFieldByNumber(C_IN,0,i_channel);
      if ( !mxIsInt16(mx_channel) )
        mexErrMsgTxt("'channel' not a uint16 vector!\n");

    } else {
      mexErrMsgTxt("C has no field 'data' or 'spiketimes'\n");
    }
  }
    
  /*
  ** check t
  */
  if ( getDoubleVector(t_IN,&sample_time,&nSampleTimePoints) < 0 )
    mexErrMsgTxt("SPIKES2COUNT requires that 't' is a sortet vector!\n");

  tau1=30e-3;
  if ( nrhs > 2 ) {
    if ( getDouble(tau1_IN,&tau1) < 0 )
      mexErrMsgTxt("SPIKES2COUNT requires that 'tau1' is a double scalar!\n");
    if ( tau1 <=0 ) mexErrMsgTxt("SPIKES2COUNT requires that tau1 > 0!");
  }

  /*
  ** check tau2
  */
  tau2=3e-3;
  if ( nrhs > 3 ) {
    if ( getDouble(tau2_IN,&tau2) < 0 )
      mexErrMsgTxt("SPIKES2COUNT requires that 'tau2' is a double scalar!\n");
    if ( tau2 <=0 ) mexErrMsgTxt("SPIKES2COUNT requires that tau2 > 0!");
  }

  /* make sure that tau1 >= tau */
  if ( tau1 < tau2 ) {
    tmp = tau2; tau2 = tau1; tau1 = tmp;
  }

  if ( i_data > 0 ) {
    /*
    ** RESPONSE FORMAT
    */
    /* create outputmatrix */
    X_OUT = mxCreateDoubleMatrix( nSampleTimePoints, nDIM, mxREAL);
    x=mxGetPr(X_OUT);
    
    for(c=0;c<nDIM;c++) {
      mx_data = mxGetFieldByNumber(C_IN,c,i_data);
      
      dt = -1.0;
      if ( i_spk >= 0 ) {
        /* there is a field spiking so we check its value */
        mx_spk = mxGetFieldByNumber(C_IN,c,i_spk);
        if ( *(mxGetPr(mx_spk)) < 1 ) {
          /* it should be analog so we get the dt */
          if ( i_dt >= 0 ) {
            mx_dt   = mxGetFieldByNumber(C_IN,c,i_dt);
            dt=*(mxGetPr(mx_dt));
            if ( dt <= 0.0 ) {
              mexErrMsgTxt("C has field 'dt <= 0' while spiking=0\n");
            }
          } else
            mexErrMsgTxt("C has no field 'dt' while spiking=0\n");
        } else {
          /* data are spikes */
          dt = -1.0;
        }
      } else {
        /* there is no field spiking so we look at the value of dt */
        if ( i_dt >= 0 ) {
          mx_dt   = mxGetFieldByNumber(C_IN,c,i_dt);
          dt=*(mxGetPr(mx_dt));
        } else
          mexErrMsgTxt("C has no field 'dt' and no field 'spiking' \n");
      }
      if ( dt == -1.0 ) {
        /* here we deal with spikes */
        spike_time=mxGetPr(mx_data);
        nSpikes=mxGetN(mx_data)*mxGetM(mx_data);
        for(j=0;j<nSampleTimePoints;j++) {
          *x=0.0;
          for(i=0; ( i<nSpikes ) && (spike_time[i]<=sample_time[j]); i++) {
/*              printf("%g ",spike_time[i]); */
            delta=spike_time[i]-sample_time[j];
            *x += (int)(delta>-tau1); 
          }
          x++;
        }
      } else if ( dt > 0 ) {
        /* here we deal with analog values */
        analog_data=mxGetPr(mx_data);
        nDataPoints=max(mxGetN(mx_data),mxGetM(mx_data));
        
        for(j=0;j<nSampleTimePoints;j++) {
          i=(int)(sample_time[j]/dt);
          if ( i < 0 ) {
            *x = analog_data[0];
          } else if ( i >= nDataPoints-1  ) {
            *x = analog_data[nDataPoints-1];
          } else {
            *x = (analog_data[i]+analog_data[i+1])/2.0;
          }
          x++;
        }
      } else {
        mexErrMsgTxt("SPIKES2COUNT: invalid value for dt!\n");
      }
    }
  } else if ( i_spiketimes >= 0 ) {
    /*
    ** SPIKETIMES FORMAT
    */
    n = mxGetN(mx_index);
    m = mxGetM(mx_index);
    nDIM = max(n,m);
/*      printf("nDIM=%i, nSTP=%i\n",nDIM,nSampleTimePoints); */

    X_OUT = mxCreateDoubleMatrix( nSampleTimePoints, nDIM, mxREAL);
    x=mxGetPr(X_OUT);
    
    us_spike_times = (int *)mxGetData(mx_spiketimes);
    channel        = (short *)mxGetData(mx_channel);
/*      printf("lst=%i lch=%i sizeof(short)=%i\n",mxGetN(mx_spiketimes),mxGetN(mx_channel),sizeof(short)); */
    for(c=1;c<=nDIM;c++) {
      for(j=0;j<nSampleTimePoints;j++) {
        *x = 0.0;
        us = us_spike_times;
        ch = channel;
        while( ((*ch) == c) && ((s=((double)(*us))*1e-6) <= sample_time[j]) ) {
/*            printf("%g ",s); */
          delta=s-sample_time[j];
          *x += (int)(delta>-tau1); 
          us++;
          ch++;
        }
        x++;
      }
      while( (*channel) == c ) {
        us_spike_times++;
        channel++;
      }
    }
  } else {
    mexErrMsgTxt("Unknown input format\n");
  }
}
