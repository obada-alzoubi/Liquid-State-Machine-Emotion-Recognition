/*
reguierd for the generation of the topology of commisural cells in a spinal
cord model (see Kaske & Bertschinger: "Traveling waves...")
incorporates a rostro-caudal gradient (see gradientconn), but projects to the
contralateral side in a mirror like fashion

Compile with:

mex conn.c randgen.c

*/

#include <stdlib.h>
#include <mex.h>
#include "randgen.h"

/* 32 bit unsigned integers [on Pentium Linux PC] */
typedef unsigned long uint32;

#if !defined(max)
#define max(A, B) ((A) > (B) ? (A) : (B))
#endif
#if !defined(min)
#define min(A, B) ((A) < (B) ? (A) : (B))
#endif


int getDouble(const mxArray *arg, double *x) {
  int m, n;

  if (!arg) return -1;
  m = mxGetM(arg);
  n = mxGetN(arg);
  if (!mxIsNumeric(arg) || mxIsComplex(arg) ||
      mxIsSparse(arg)  || !mxIsDouble(arg) ||
      (m != 1) || (n != 1)) {
    *x = 0.0;
    return -1;
  }
  *x = mxGetScalar(arg);
  return 0;
}


int getDoubleArray(const mxArray *arg, double **x, int *m, int *n) {
  if (!arg) return -1;
  *m = mxGetM(arg);
  *n = mxGetN(arg);
  if (!mxIsNumeric(arg) || mxIsComplex(arg) ||
      mxIsSparse(arg)  || !mxIsDouble(arg) ) {
    *x = NULL;
    return -1;
  }
  *x = mxGetPr(arg);
  return 0;
}


int getUint32Vector(const mxArray *arg, uint32 **x, int *n) {
  int m;

  if (!arg) return -1;
  m = min(mxGetM(arg),mxGetN(arg));
  *n = max(mxGetM(arg),mxGetN(arg));
  if (!mxIsUint32(arg) || m != 1 ) {
    *x = NULL;
    return -1;
  }
  *x = (uint32 *)mxGetData(arg);
  return 0;
}



void makeconn(uint32 **postidx, uint32 **preidx, int *nconn,
          uint32 *destidx, double *destpos, unsigned ndest,
          uint32 *srcidx, double *srcpos, unsigned nsrc,
          unsigned long nSynapses, double lambda) {

  unsigned i, j;  /* index variables: i ... post, j ... pre */
  
  int count, h, l, pre, found; /* for binary search */
  int gSynapse, xmax; /* gradient dependent nSynapse */
  int midline, ymax; /* mirror axis */
  double dx, dy, dz; /* distances */

  double *P,*p,sumP; /* connection probability */
  double *cum,*CUM;    /* cumulative  connection probability */
  double u;          /* uniform (0,1) distributed random number */

  int *usedSrc;

  int finiteLambda = !mxIsInf(lambda);
  double l2 = finiteLambda ? lambda*lambda : 1e30;

  *nconn = 0;

  if ( nSynapses > nsrc ) {
    mexErrMsgTxt("CONN: more connections requested then presynaptic neurons available!\n");
  }

  *postidx = (uint32 *)mxMalloc(nSynapses*ndest*sizeof(uint32));
  *preidx = (uint32 *)mxMalloc(nSynapses*ndest*sizeof(uint32));
  if (*postidx == NULL || *preidx == NULL)
    mexErrMsgTxt("CONN: Failed to malloc memory!\n");

  usedSrc = (int *)mxCalloc(nsrc,sizeof(int));
  if ( usedSrc == NULL )
    mexErrMsgTxt("CONN: Failed to malloc memory!\n");

  p = P = (double *)mxMalloc(nsrc*sizeof(double));
  if ( P == NULL )
    mexErrMsgTxt("CONN: Failed to malloc memory!\n");
  cum = CUM = (double *)mxMalloc((nsrc+1)*sizeof(double));
  if ( CUM == NULL )
    mexErrMsgTxt("CONN: Failed to malloc memory!\n");
  
/* get x-extension of network */
  xmax=0;
  for (i=0; i<ndest; i++) {
  if(destpos[i*3]>xmax)xmax=destpos[i*3];
  }

/* get y-extension of network */
  ymax=0;
  for (i=0; i<ndest; i++) {
  if(destpos[1+i*3]>ymax)ymax=destpos[1+i*3];
  }
  
for (i=0; i<ndest; i++) {
    p = P; 

    /* gradient dependent nSynapse = gSynapse */
    gSynapse = (int)(nSynapses*(0.5+0.5*destpos[i*3]/xmax));
    if(gSynapse>nSynapses)gSynapse = nSynapses;

    /*
    ** Calculate connection probabilities
    */
    if (finiteLambda) {
      for (sumP=0,p=P,j=0; j<nsrc; j++) {
        dx = destpos[0+i*3] - srcpos[0+j*3];
        dy = ymax-destpos[1+i*3] - srcpos[1+j*3];
        dz = destpos[2+i*3] - srcpos[2+j*3];
        
        *p = exp( -(dx*dx+dy*dy+dz*dz)/l2 );
        sumP += (*p);
        p++;
      }
      for (p=P,j=0; j<nsrc; j++) {
        *(p++) /= (sumP);
      }
    } else {
      /* if lambda == infty all connections are equi-probable */
      for (p=P,j=0; j<nsrc; j++) {
        *(p++) = 1.0/nsrc;
      }
    }
    /*
    ** Calculate cummulativ probability: cum[0]=0; cum[nsrc]=1.0;
    */
    cum=CUM; p=P;
    cum[0] = 0;
    for (j=0; j<nsrc; j++) {
      cum[j+1] = p[j]+cum[j];
      usedSrc[j] = 0;
    }
    if ( fabs(cum[nsrc] - 1.0) > 1e-5 ) {
      printf("WARNING: cum[%i] != 1.0 (diff %g)\n",nsrc,cum[nsrc]-1.0);
    }

    /*
    ** Draw nSynapses connection corresponding to the pdf p and the cdf cum.
    */
    j = 0;  count=0;
    do {
      
      /* draw random number between u: 0.0 < u < 1.0 */
      u = unirnd();

      /* Find index pre such that cum[pre] < u <= cum[pre+1]. 
      ** Since 0.0 < u < 1.0 there is always such an index.
      */
      l= 0; h = nsrc; found = 1;
      do {
        found = 1;
        pre = (h+l)/2;
        if ( cum[pre] >= u ) {
          h = pre; found = 0;
        } else if ( cum[pre+1] < u ) {
          l = pre; found = 0;
        }
      } while ( !found  );


      if ( !usedSrc[pre] && srcidx[pre]!=destidx[i] ) {
        (*postidx)[*nconn] = destidx[i];
        (*preidx)[*nconn] = srcidx[pre];
        (*nconn)++;
        usedSrc[pre] = 1;
        j++;
      } 

      count++;

    } while ( j<gSynapse && count < 10*gSynapse) ;
    if ( j<gSynapse ) {
      printf(".");
    }
    /*    if ( j<gSynapse ) {
      printf("WARNING:  Could not create %i Synapses within %i trials!" \
             "(Increase lambda or decrease connection probability)!\n",nSynapses,count);
             }*/
  }
}





void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  uint32 *destidx, *srcidx;
  int m, n, ndest, nsrc;
  double *destpos, *srcpos;
  double Ndummy, lambda;
  double randSeed = 123456;
  unsigned long N;

  int nconn = 0;
  uint32 *postidx = 0;
  uint32 *preidx = 0;


  if (sizeof(uint32) != 4)
    mexErrMsgTxt("There is something wrong with uint32!!");


  if ((nlhs != 2) || (nrhs != 7)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, N, lambda, randseed);\n\n");
    mexPrintf("Parameters: dest_idx, src_idx: 1xn uint32 vectors\n");
    mexPrintf("            dest_pos, src_pos: 3xn double matrices\n");
    mexPrintf("            N, lambda, randseed: doubles\n");
    mexPrintf("Returns:    post, pre: 1xn uint32 vectors\n");
    return;
  }

  if (getUint32Vector(prhs[0], &destidx, &ndest)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, N, lambda, randseed);\n\n");
    mexPrintf("            dest_idx is not a uint32 vector!\n");
    return;
  }

  if (getUint32Vector(prhs[2], &srcidx, &nsrc)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, N, lambda, randseed);\n\n");
    mexPrintf("            src_idx is not a uint32 vector!\n");
    return;
  }


  if (getDoubleArray(prhs[1], &destpos, &m, &n)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, N, lambda, randseed);\n\n");
    mexPrintf("            dest_pos is not a double array!\n");
    return;
  }

  if ((m!=3) || (n!=ndest)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, N, lambda, randseed);\n\n");
    mexPrintf("            dest_pos is not a 3x%i matrix (but a %ix%i matrix)!\n", ndest, m, n);
    return;
  }

  if (getDoubleArray(prhs[3], &srcpos, &m, &n)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, N, lambda, randseed);\n\n");
    mexPrintf("            src_pos is not a double array!\n");
    return;
  }

  if ((m!=3) || (n!=nsrc)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, N, lambda, randseed);\n\n");
    mexPrintf("            src_pos is not a 3x%i matrix (but a %ix%i matrix)!\n", nsrc, m, n);
    return;
  }

  if (getDouble(prhs[4], &Ndummy)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, N, lambda, randseed);\n\n");
    mexPrintf("            C is not a single double!\n");
    return;
  }
  N = (unsigned long)Ndummy;

  if (getDouble(prhs[5], &lambda)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, N, lambda, randseed);\n\n");
    mexPrintf("            lambda is not a single double!\n");
    return;
  }

	if (getDouble(prhs[6], &randSeed)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, N, lambda, randseed);\n\n");
    mexPrintf("            randseed is not a single double!\n");
    return;
  }

  rseed((int)randSeed);

  makeconn(&postidx, &preidx, &nconn, destidx, destpos, ndest, srcidx, srcpos, nsrc, N, lambda);

  /*  printf("nconn=%i\n",nconn); */

  plhs[0] = mxCreateNumericMatrix(1, nconn, mxUINT32_CLASS, mxREAL);
  plhs[1] = mxCreateNumericMatrix(1, nconn, mxUINT32_CLASS, mxREAL);

  memcpy(mxGetPr(plhs[0]), postidx, nconn*sizeof(uint32));
  memcpy(mxGetPr(plhs[1]), preidx, nconn*sizeof(uint32));

  mxFree(postidx);
  mxFree(preidx);

}

