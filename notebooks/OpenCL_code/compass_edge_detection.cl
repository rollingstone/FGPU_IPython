#include "FGPUlib.c"

__kernel void compass_edge_detection(__global unsigned *in, __global unsigned *out)
{
  unsigned x = get_global_id(1);
  unsigned y = get_global_id(0);
  unsigned rowLen = get_global_size(0);


  // return on boarder pixels
  bool border =  x < 1 | y < 1 | (x>rowLen-2) | (y>rowLen-2);
  if(border) 
    return;
  //read pixels
  unsigned p[3][3];
  unsigned p00 = in[(x-1)*rowLen+y-1];
  unsigned p01 = in[(x-1)*rowLen+y];
  unsigned p02 = in[(x-1)*rowLen+y+1];
  unsigned p10 = in[x*rowLen+y-1];
  unsigned p11 = in[x*rowLen+y];
  unsigned p12 = in[x*rowLen+y+1];
  unsigned p20 = in[(x+1)*rowLen+y-1];
  unsigned p21 = in[(x+1)*rowLen+y];
  unsigned p22 = in[(x+1)*rowLen+y+1];
  int G[8] = {0};
  //find edges in 4 directions
  G[0] =  -1*p00 +0*p01 +1*p02 +
          -2*p10 +0*p11 +2*p12 +
          -1*p20 +0*p21 +1*p22;
  G[1] =  -2*p00 -1*p01 +0*p02 +
          -1*p10 +0*p11 +1*p12 +
          -0*p20 +1*p21 +2*p22;
  G[2] =  -1*p00 -2*p01 -1*p02 +
          -0*p10 +0*p11 +0*p12 +
          +1*p20 +2*p21 +1*p22;
  G[3] =  -0*p00 -1*p01 -2*p02 +
          +1*p10 +0*p11 -1*p12 +
          +2*p20 +1*p21 +0*p22;
  //compute the edges in the remaining 4 directions by inversion
  G[4] = -G[0];
  G[5] = -G[1];
  G[6] = -G[2];
  G[7] = -G[3];
  //taking the maximum value on all directions
  int max_val = G[0], i;
  for(i = 1; i < 8; i++)
    max_val = G[i] < max_val ? max_val:G[i];
  //write the result to output
  out[x*rowLen+y] = max_val;
}