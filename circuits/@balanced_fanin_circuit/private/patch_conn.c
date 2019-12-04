/*
produduces a patchy connectivity by periodic modulation using sine and cosine
of the synaptic density similar as the clustered network of pyramid cells in
the cortex

Compile with:

mex conn.c randgen.c

*/

#include <stdlib.h>
#include <mex.h>
#include "randgen.h"

/* 32 bit unsigned integers [on Pentium Linux PC] */
typedef unsigned long uint32;

#define PREALLOC 50000

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
          uint32 *destidx, double *destpos, int ndest,
          uint32 *srcidx, double *srcpos, int nsrc,
          double C, double lambda) {

  int i, j;
  int prealloc = 0;
  double dx, dy, dz, dzz;

  double l2 = -1;
  if (!mxIsInf(lambda)) l2 = lambda*lambda;

  *nconn = 0;

  prealloc = PREALLOC;
  *postidx = (uint32 *)mxMalloc(prealloc*sizeof(uint32));
  *preidx = (uint32 *)mxMalloc(prealloc*sizeof(uint32));
  if (*postidx == NULL || *preidx == NULL)
    mexErrMsgTxt("CONN: Failed to malloc memory!\n");

  for (i=0; i<ndest; i++) {
    for (j=0; j<nsrc; j++) {

      if (*nconn >= prealloc) {
        prealloc += PREALLOC;
        *postidx = (uint32 *)mxRealloc(*postidx, prealloc*sizeof(uint32));
        *preidx = (uint32 *)mxRealloc(*preidx,  prealloc*sizeof(uint32));
        if (*postidx == NULL || *preidx == NULL)
          mexErrMsgTxt("CONN: Failed to realloc memory!\n");
      }

      if (mxIsInf(lambda)) {
        if (unirnd() <= C) {
          (*postidx)[*nconn] = destidx[i];
          (*preidx)[*nconn] = srcidx[j];
          (*nconn)++;
        }
      } else {

        dx = destpos[0+i*3] - srcpos[0+j*3];
        dy = destpos[1+i*3] - srcpos[1+j*3];
        dz = destpos[2+i*3] - srcpos[2+j*3];

dzz=(0.5+0.5*cos(3.1428*dx/2.0))*(0.5+0.5*cos(3.1428*dy/2.0));

        if (unirnd() <= C * exp( -0*(dx*dx+dy*dy+dz*dz)/l2 )*dzz )          {
          (*postidx)[*nconn] = destidx[i];
          (*preidx)[*nconn] = srcidx[j];
          (*nconn)++;
        }
      }

    }
  }

}




void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  uint32 *destidx, *srcidx;
  int m, n, ndest, nsrc;
  double *destpos, *srcpos;
  double C, lambda;
  double randSeed = 123456;

  int nconn = 0;
  uint32 *postidx = 0;
  uint32 *preidx = 0;


  if (sizeof(uint32) != 4)
    mexErrMsgTxt("There is something wrong with uint32!!");


  if ((nlhs != 2) || (nrhs != 7)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, C, lambda, randseed);\n\n");
    mexPrintf("Parameters: dest_idx, src_idx: 1xn uint32 vectors\n");
    mexPrintf("            dest_pos, src_pos: 3xn double matrices\n");
    mexPrintf("            C, lambda, randseed: doubles\n");
    mexPrintf("Returns:    post, pre: 1xn uint32 vectors\n");
    return;
  }

  if (getUint32Vector(prhs[0], &destidx, &ndest)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, C, lambda, randseed);\n\n");
    mexPrintf("            dest_idx is not a uint32 vector!\n");
    return;
  }

  if (getUint32Vector(prhs[2], &srcidx, &nsrc)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, C, lambda, randseed);\n\n");
    mexPrintf("            src_idx is not a uint32 vector!\n");
    return;
  }


  if (getDoubleArray(prhs[1], &destpos, &m, &n)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, C, lambda, randseed);\n\n");
    mexPrintf("            dest_pos is not a double array!\n");
    return;
  }

  if ((m!=3) || (n!=ndest)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, C, lambda, randseed);\n\n");
    mexPrintf("            dest_pos is not a 3x%i matrix (but a %ix%i matrix)!\n", ndest, m, n);
    return;
  }

  if (getDoubleArray(prhs[3], &srcpos, &m, &n)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, C, lambda, randseed);\n\n");
    mexPrintf("            src_pos is not a double array!\n");
    return;
  }

  if ((m!=3) || (n!=nsrc)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, C, lambda, randseed);\n\n");
    mexPrintf("            src_pos is not a 3x%i matrix (but a %ix%i matrix)!\n", nsrc, m, n);
    return;
  }

  if (getDouble(prhs[4], &C)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, C, lambda, randseed);\n\n");
    mexPrintf("            C is not a single double!\n");
    return;
  }

  if (getDouble(prhs[5], &lambda)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, C, lambda, randseed);\n\n");
    mexPrintf("            lambda is not a single double!\n");
    return;
  }

	if (getDouble(prhs[6], &randSeed)) {
    mexPrintf("CONN-Usage: [post, pre] = conn(dest_idx, dest_pos, src_idx, src_pos, C, lambda, randseed);\n\n");
    mexPrintf("            randseed is not a single double!\n");
    return;
  }

  rseed((int)randSeed);

  makeconn(&postidx, &preidx, &nconn, destidx, destpos, ndest, srcidx, srcpos, nsrc, C, lambda);

  plhs[0] = mxCreateNumericMatrix(1, nconn, mxUINT32_CLASS, mxREAL);
  plhs[1] = mxCreateNumericMatrix(1, nconn, mxUINT32_CLASS, mxREAL);

  memcpy(mxGetPr(plhs[0]), postidx, nconn*sizeof(uint32));
  memcpy(mxGetPr(plhs[1]), preidx, nconn*sizeof(uint32));

  mxFree(postidx);
  mxFree(preidx);

  /* mexPrintf("-->nconn: %i!\n", nconn); */

}

