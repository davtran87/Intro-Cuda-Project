/****
Author: David Tran
File: minDistSOAGPU.cu
Compilation: nvcc minDistSOAGPU.cu -Wno-deprecated-gpu-targets -o  minDistSOAGPU
Execution: dtran7.csc656@tiger:~$ ./minDistSOAGPU
***/

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <cuda.h>

// You may edit NUMPARTICLES and THREADSPERBLOCK for measurements
#define NUMPARTICLES 32768
#define THREADSPERBLOCK 4

void initPos(float *);
void findMinsG(float *pos, int *minIndex, float *minDistance);
void dumpResults(int index[], float d[]);
__global__ void findMinsGPU(float *p, int *minI, float *minD);
__device__ float findDistanceGPU(float *p, int i, int j);
// You are not allowed to change main()!
int main() {
  cudaEvent_t start, stop;
  float time;

  float *pos;
  int *minIndex;
  float *minDistance;

  pos = (float *) malloc(NUMPARTICLES * 3 * sizeof(float));
  minIndex = (int *) malloc(NUMPARTICLES * sizeof(int));
  minDistance = (float *) malloc(NUMPARTICLES * sizeof(float));

  initPos(pos);

  // create timer events
  cudaEventCreate(&start);
  cudaEventCreate(&stop);

  cudaEventRecord(start, 0);

  findMinsG(pos, minIndex, minDistance);

  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&time, start, stop);

  printf("%d particles, %d threads per block\n", NUMPARTICLES, THREADSPERBLOCK);
  printf("Elapsed time = %f\n", time);

  dumpResults(minIndex, minDistance);

}

void initPos(float *p) {
  // this should be identical to initPos() for minDistSOA.c
  // your code goes here
  for(int i=0; i<NUMPARTICLES; i++){
    p[i] = rand() / (float) RAND_MAX;
    p[NUMPARTICLES+i] = rand() / (float) RAND_MAX;
    p[NUMPARTICLES*2+i] = rand() / (float) RAND_MAX;
   }
}

void findMinsG(float *pos, int *minIndex, float *minDistance) {
 // wrapper function for CUDA code
 // CUDA memory management and kernel calls go here
 float *dPos, *mDistance;
 int *mIndex;
 cudaMalloc((void **) &dPos, NUMPARTICLES * 3 * sizeof(float));
 cudaMalloc((void **) &mDistance, NUMPARTICLES * sizeof(float));
 cudaMalloc((void **) &mIndex, NUMPARTICLES * sizeof(int));
 cudaMemcpy(dPos, pos, NUMPARTICLES * 3 * sizeof(float), cudaMemcpyHostToDevice);
 cudaMemcpy(mDistance, minDistance, NUMPARTICLES * sizeof(float), cudaMemcpyHostToDevice);
 cudaMemcpy(mIndex, minIndex, NUMPARTICLES * sizeof(int), cudaMemcpyHostToDevice);

 // Invoke kernal finMinsGPU()
 findMinsGPU<<<NUMPARTICLES/THREADSPERBLOCK, THREADSPERBLOCK>>>(dPos, mIndex, mDistance);
 cudaThreadSynchronize();
 cudaMemcpy(minIndex, mIndex, NUMPARTICLES * sizeof(int), cudaMemcpyDeviceToHost);
 cudaMemcpy(minDistance, mDistance, NUMPARTICLES * sizeof(float), cudaMemcpyDeviceToHost);
 /****** Did not want to change main so left this here to show that i remembered
 // clean up
 free(hm);
 cudaFree(dm);
 free(hcs);
 cudaFree(dcs);
 *****/
}
/* device function to find distances */
__device__ float findDistanceGPU(float *p, int i, int j) {
 float dx, dy, dz;

 dx = p[i] - p[j];
 dy = p[NUMPARTICLES + i] - p[NUMPARTICLES + j];
 dz = p[NUMPARTICLES*2 + i] - p[NUMPARTICLES*2 + j];

 return(dx*dx + dy*dy + dz*dz);
}

/* kernal function that calculates min distance */
__global__ void findMinsGPU(float *p, int *minI, float *minD) {
 // your kernel code goes here
  int i, j;
  float distance, mD;
  int mI;
  mD = 0;
  i = blockDim.x * blockIdx.x + threadIdx.x;
  if(i!=0){
  mI = 0;
     mD = findDistanceGPU(p, i, 0);
  }else{
     mI=1;
     mD = findDistanceGPU(p, 0, 1);
  }

  for(j=0; j<NUMPARTICLES; j++){
     if(i!=j) {
     // calculate distance between particles i and j
         distance = findDistanceGPU(p, i, j);
     // if distance < mD
         if(distance < mD){
            mD = distance;
            mI = j;
          }
      }
   }
minI[i] = mI;
minD[i] = mD;
}

void dumpResults(int index[], float d[]) {
int i;
FILE *fp;

fp = fopen("./dump.out", "w");

for (i=0; i<NUMPARTICLES; i++) {
fprintf(fp, "%d %d %f\n", i, index[i], d[i]);
}

fclose(fp);
}
