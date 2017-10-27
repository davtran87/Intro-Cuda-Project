Configuration for compiling and running MaxCol.cu

Compilation:
dtran7.csc656@tiger:~$ nvcc MaxCol.cu -o MaxCol

Execution:
dtran7.csc656@tiger:~$ ./MaxCol [Matrix Size] [Threads per Block]

Example:
dtran7.csc656@tiger:~$ ./MaxCol 4096 128




Configuration for compiling and running minDist.c

Compilation:
dtran7.csc656@tiger:~$ gcc minDist.c -O3 -o minDist

Execution:
dtran7.csc656@tiger:~$ ./minDist





Configuration for compiling and running minDistSOA.c

Compilation:
dtran7.csc656@tiger:~$ gcc minDistSOA.c -O3 -o minDistSOA

Execution:
dtran7.csc656@tiger:~$ ./minDistSOA




Configuration for compiling and running minDistSOAGPU.cu

Source: source ~whsu/lees.bash_profile

Compilation:
dtran7.csc656@tiger:~$  nvcc minDistSOAGPU.cu -Wno-deprecated-gpu-targets -o  minDistSOAGPU

Execution:
dtran7.csc656@tiger:~$ ./minDistSOAGPU