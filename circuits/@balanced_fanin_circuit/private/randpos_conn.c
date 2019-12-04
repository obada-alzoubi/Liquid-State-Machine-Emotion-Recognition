/*
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
          unsigned long nSynapses, double lambda) {

  int i, j, found, found2, nS, h, l;
  int Xmin, Xmax, Ymin, Ymax;
  int prealloc = 0;
  double dx, dy, dz;
  int DX, DY, DXh, DYh;

  double *P,*p,sumP; /* connection probability */
  double *cum,*CUM;    /* cumulative  connection probability */
  double u;          /* uniform (0,1) distributed random number */
  double pmax;       /* highest probability */


  int finiteLambda = !mxIsInf(lambda);
  double l2 = finiteLambda ? lambda*lambda : 1e30;


  *nconn = 0;

  prealloc = PREALLOC;
  *postidx = (uint32 *)mxMalloc(prealloc*sizeof(uint32));
  *preidx = (uint32 *)mxMalloc(prealloc*sizeof(uint32));
  if (*postidx == NULL || *preidx == NULL)
    mexErrMsgTxt("CONN: Failed to malloc memory!\n");

  p = P = (double *)mxMalloc(nsrc*sizeof(double));
  if ( P == NULL )
    mexErrMsgTxt("CONN: Failed to malloc memory!\n");
  cum = CUM = (double *)mxMalloc((nsrc+1)*sizeof(double));
  if ( CUM == NULL )
    mexErrMsgTxt("CONN: Failed to malloc memory!\n");


  Xmin = 2^16;
  Xmax = 0;
  Ymin = 2^16;
  Ymax = 0;

  for (j=0; j<nsrc; j++) {
    if (srcpos[0+j*3] < Xmin) 
        Xmin = srcpos[0+j*3];
    if (srcpos[0+j*3] > Xmax) 
        Xmax = srcpos[0+j*3];
    if (srcpos[1+j*3] < Ymin) 
        Ymin = srcpos[1+j*3];
    if (srcpos[1+j*3] > Ymax) 
        Ymax = srcpos[1+j*3];
  }
  for (j=0; j<ndest; j++) {
    if (destpos[0+j*3] < Xmin) 
        Xmin = destpos[0+j*3];
    if (destpos[0+j*3] > Xmax) 
        Xmax = destpos[0+j*3];
    if (destpos[1+j*3] < Ymin) 
        Ymin = destpos[1+j*3];
    if (destpos[1+j*3] > Ymax) 
        Ymax = destpos[1+j*3];
  }

  DX = Xmax - Xmin + 1;
  DY = Ymax - Ymin + 1;
  DXh = (int) DX/2;
  DYh = (int) DY/2;

  do {
      do {
         found = 1;
         if (finiteLambda) {
            /* choose destination neuron randomly */
            do { i = (int) ndest* unirnd();} while (i==ndest);

            /* calculate all source neuron connection probability */
            for (sumP=0,p=P,j=0; j<nsrc; j++) {
              dx = ((int)(destpos[0+i*3] - srcpos[0+j*3] + DXh + DX) % DX) - DXh;
              dy = ((int)(destpos[1+i*3] - srcpos[1+j*3] + DYh + DY) % DY) - DYh;
              /* dz = destpos[2+i*3] - srcpos[2+j*3]; */
/*              printf("x1: %g x2: %g y1: %g y2: %g dx: %g dy: %g\n",destpos[0+i*3],srcpos[0+j*3],destpos[1+i*3],srcpos[1+j*3],dx,dy); */

              /* *p = exp( -(dx*dx+dy*dy+dz*dz)/l2 ); */
              *p = exp( -(dx*dx+dy*dy)/l2 );
              sumP += (*p);
              p++;
            }
 
            if (sumP) {
               for (p=P,j=0; j<nsrc; j++) {
                 *(p++) /= (sumP);
    	       }
            } else {
               printf("WARNING: all connection probabilities are zero and reset to equi-probable!\n");
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
          }
          if ( fabs(cum[nsrc] - 1.0) > 1e-5 ) {
            printf("WARNING: cum[%i] != 1.0 (diff %g)\n",nsrc,cum[nsrc]-1.0);
          }

          /* draw random number between u: 0.0 < u < 1.0 */
          u = unirnd();

          /* Find index pre such that cum[pre] < u <= cum[pre+1].
          ** Since 0.0 < u < 1.0 there is always such an index.
          */
          l= 0; h = nsrc; found2 = 1;
          do {
            found2 = 1;
            j = (h+l)/2;
            if ( cum[j] >= u ) {
              h = j; found2 = 0;
            } else if ( cum[j+1] < u ) {
              l = j; found2 = 0;
            }
          } while ( !found2  );
         } else {
            do { i = (int) ndest* unirnd();} while (i==ndest);
            do { j = (int) nsrc * unirnd();} while (j==nsrc);
         }

         /* check if it is a self loop */
         if (i==j) found = 0;

         /* check if this synapse exists already */
         for (nS=0; nS<(*nconn); nS++) {
            if ((*postidx)[nS] == destidx[i]) {
               if ((*preidx)[nS] == srcidx[j]) {
                  found = 0;
                  nS = (*nconn);   
               }
            }
         }
      } while (!found);

      if (*nconn >= prealloc) {
        prealloc += PREALLOC;
        *postidx = (uint32 *)mxRealloc(*postidx, prealloc*sizeof(uint32));
        *preidx = (uint32 *)mxRealloc(*preidx,  prealloc*sizeof(uint32));
        if (*postidx == NULL || *preidx == NULL)
          mexErrMsgTxt("CONN: Failed to realloc memory!\n");
      }

      (*postidx)[*nconn] = destidx[i];
      (*preidx)[*nconn] = srcidx[j];
      (*nconn)++;

   } while ((*nconn) < nSynapses);
}




void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  uint32 *destidx, *srcidx;
  int m, n, ndest, nsrc;
  double *destpos, *srcpos;
  double lambda;
  double randSeed = 123456;
  double Ndummy;
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
    mexPrintf("            N is not a single double!\n");
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

  plhs[0] = mxCreateNumericMatrix(1, nconn, mxUINT32_CLASS, mxREAL);
  plhs[1] = mxCreateNumericMatrix(1, nconn, mxUINT32_CLASS, mxREAL);

  memcpy(mxGetPr(plhs[0]), postidx, nconn*sizeof(uint32));
  memcpy(mxGetPr(plhs[1]), preidx, nconn*sizeof(uint32));

  mxFree(postidx);
  mxFree(preidx);

  /* mexPrintf("-->nconn: %i!\n", nconn); */

}

