/*
** $Id: cpdelta.c,v 1.2 2003/11/28 14:15:48 joshi Exp $
*/

#include <math.h>
#include "mex.h"

/*
** some helpers
*/

#if !defined(max)
#define	max(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(min)
#define	min(A, B)	((A) < (B) ? (A) : (B))
#endif

/*
** C implementation of one epoch of the p-delta learning algorithm
*/

/*/////////////////////////////////////////////////////////////////////////
// Version History
//
// Prashant Joshi	21-11-2003	Commented the mxGetName to stop
// 					error messages. Search "joshi_21_11_03"
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////*/

#define update_weight(ETA) lr = (ETA); for(j=0;j<d;j++) *(w++) += lr*(*z++);

void p_delta_batch(double *W, double *dW, double *Z, double *Y, double *ORDER, double *out,
		 int n, int d, int m, double rho, double eps, double gamma, double eta, double mu, int maxwu, double *sumwu)
{
  int i,j,k,kk,nwu=0;
  double *net,p,o,c=0.5*n,lr;
  double *w = W;
  double *z = Z;
  double *zk,yk;

  net = (double *)mxMalloc(n*sizeof(double));

  for(k=0;k<m;k++) { /* over all 'm' training examples */
    kk = (int)(ORDER[k])-1;
    zk = Z+(kk*d);
    yk = Y[kk];
    p  = 0.0;
    w  = W;
    for(i=0;i<n;i++) {                 /* over all 'n' units */
      z = zk;
      net[i] = 0.0;
      for(j=0;j<d;j++) {               /* over all 'd' dimension */
	net[i] += ((*(z++)) * (*(w++)));
      }
      p += (net[i] >= 0);
      /* printf("net[%i]=%g\n",i,net[i]); */
    }

    /* printf("p = %g, ",p,o); */

    o = (p-c)/rho;
    o = o <= -1 ? -1 : o;
    o = o >= +1 ? +1 : o;

    out[kk] = o;

    /* printf("%g ",o); */

    w = dW;
    nwu = 0;
    if ( o > yk+eps ) {          /* output to large               */
      for(i=0;i<n;i++) {
	z = zk;
	if ( net[i] >= 0 ) {
	  update_weight(-eta);
	} else if ( net[i] > -gamma ) {
          nwu++;
	  update_weight(-mu*eta);
	} else {
	  w += d;
	}
      }
    } else if ( o >= yk-eps ) {  /* output correct within epsilon */
      for(i=0;i<n;i++) {
	z = zk;
	if ( ( net[i] >= 0 ) && ( net[i] < gamma ) ) {
	  nwu++;
	  update_weight(+mu*eta);
	} else if ( ( net[i] <= 0 ) && ( net[i] > -gamma ) ) {
          nwu++;
	  update_weight(-mu*eta);
	} else {
	  w += d;
	}
      }
    } else {                    /* output to small               */
      for(i=0;i<n;i++) {
	z = zk;
	if ( net[i] < 0 ) {
	  update_weight(+eta);
	} else if ( net[i] < gamma ) {
	  nwu++;
	  update_weight(+mu*eta);
	} else {
	  w += d;
	}
      }
    }
    /* printf("nwu=%i, min(maxwu,nwu)=%i\n",nwu,min(maxwu,nwu)); */
    (*sumwu) += ((double)(min(maxwu,nwu)));    
  }
}


/*
** MATLAB INTERFACE: Mex-Function
**
** function p_delta_inc(W,Z,Y,order,rho,eps,gamma,eta,mu)
*/

/* 
** Input Arguments
*/

#define	W_IN     prhs[0]
#define	Z_IN     prhs[1]
#define	Y_IN     prhs[2]
#define	order_IN prhs[3]
#define	rho_IN   prhs[4]
#define	eps_IN   prhs[5]
#define	gamma_IN prhs[6]
#define	eta_IN   prhs[7]
#define	mu_IN    prhs[8]
#define	maxwu_IN prhs[9]

/*
** Output Arguments 
*/

#define dW_OUT     plhs[0]
#define out_OUT    plhs[1]
#define sumwu_OUT  plhs[2]


double GetScalar(const mxArray *SCALAR_IN)
{
  char str[400];
  int m = mxGetM(SCALAR_IN); 
  int n = mxGetN(SCALAR_IN); 
  if (!mxIsNumeric(SCALAR_IN) || mxIsComplex(SCALAR_IN) || 
      mxIsSparse(SCALAR_IN)  || !mxIsDouble(SCALAR_IN) || 
      (m != 1) || (n != 1)) {
	  /* Start - joshi_21_11_03
	   Code block commented.*/
    /*sprintf(str,"CSIMSNN requires that %s is a scalar!\n",mxGetName(SCALAR_IN));*/
    sprintf(str,"CSIM error");
    /* End - joshi_21_11_03*/
    mexErrMsgTxt(str); 
  }
  return mxGetScalar(SCALAR_IN); 
}

double *GetRealArray(const mxArray *ARRAY_IN, int *m, int *n)
{
  char str[400];
  *m = mxGetM(ARRAY_IN);
  *n = mxGetN(ARRAY_IN);
  if (!mxIsNumeric(ARRAY_IN) || mxIsComplex(ARRAY_IN) ||  
      mxIsSparse(ARRAY_IN)  || !mxIsDouble(ARRAY_IN) ) {
	  /* Start - joshi_21_11_03
	    Code block commented.*/
    /*sprintf(str,"p_delta_inc requires that %s is a double array!\n",mxGetName(ARRAY_IN));*/
    sprintf(str,"CSIM error");
    /* End - joshi_21_11_03*/
    mexErrMsgTxt(str); 
  }
  return mxGetPr(ARRAY_IN);
}
  

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int n,m,d,h1,h2;
  double *W,*dW,*Z,*Y,*order,rho,eps,gamma,eta,mu,*out,maxwu,*sumwu;

  /* 
  ** Check  arguments 
  */
  if (nrhs < 10)
    mexErrMsgTxt("p_delta_inc requires 10 arguments: W,Z,Y,order,rho,eps,gamma,eta,mu,maxwu");

  if (nlhs != 3) 
    mexErrMsgTxt("p_delta_inc req. three output arguments: dW,O,sumwu");

  W = GetRealArray(W_IN,&d,&n);

  Z = GetRealArray(Z_IN,&h1,&m);
  if ( h1 != d )
    mexErrMsgTxt("p_delta_inc requires that Z has equal number of rows as W has!");

  Y = GetRealArray(Y_IN,&h1,&h2);
  if ( h2 != m )
    mexErrMsgTxt("p_delta_inc requires that Y has equal number of columns as Z!");

  order = GetRealArray(order_IN,&h1,&h2);
  if ( h2 != m )
    mexErrMsgTxt("p_delta_inc requires that order has equal number of columns as Z and Y!");

  rho   = GetScalar(rho_IN);
  eps   = GetScalar(eps_IN);
  gamma = GetScalar(gamma_IN);
  eta   = GetScalar(eta_IN);
  mu    = GetScalar(mu_IN);
  maxwu = GetScalar(maxwu_IN);

  /*
  ** alloc mem for out
  */
  out_OUT = mxCreateDoubleMatrix( 1, m, mxREAL);
  out = mxGetPr(out_OUT);

  /*
  ** alloc mem for dW
  */
  dW_OUT = mxCreateDoubleMatrix( d, n, mxREAL);
  dW = mxGetPr(dW_OUT);

  /*
  ** alloc mem for out
  */
  sumwu_OUT = mxCreateDoubleMatrix( 1, 1, mxREAL);
  sumwu = mxGetPr(sumwu_OUT);
  *sumwu = 0.0;

  /* 
  ** do the actual learning ...
  */ 
  p_delta_batch(W,dW,Z,Y,order,out,n,d,m,rho,eps,gamma,eta,mu,maxwu,sumwu);

  return;
}


