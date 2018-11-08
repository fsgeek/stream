CC = gcc
CFLAGS = -O2

FF = g77
FFLAGS = -O2

all: stream_f.exe stream_c.exe

stream_f.exe: stream.f mysecond.o
	$(CC) $(CFLAGS) -c mysecond.c
	$(FF) $(FFLAGS) -c stream.f
	$(FF) $(FFLAGS) stream.o mysecond.o -o stream_f.exe

stream_c.exe: stream.c
	$(CC) $(CFLAGS) stream.c -o stream_c.exe

clean:
	rm -f stream_f.exe stream_c.exe *.o

# an example of a more complex build line for the Intel icc compiler
stream.icc: stream.c
	icc -O3 -xCORE-AVX2 -ffreestanding -qopenmp -DSTREAM_ARRAY_SIZE=80000000 -DNTIMES=20 stream.c -o stream.omp.AVX2.80M.20x.icc

# see https://software.intel.com/en-us/articles/optimizing-memory-bandwidth-on-stream-triad
# –mmic :build an application that runs natively on Intel® Xeon Phi coprocessor
# –O3 :optimize for maximum speed and enable more aggressive optimizations that may not improve performance on some programs
# –openmp: enable the compiler to generate multi-threaded code based on the OpenMP* directives (same as -fopenmp)
# -opt-prefetch-distance=64,8:Software Prefetch 64 cachelines ahead for L2 cache;Software Prefetch 8 cachelines ahead for L1 cache
# -opt-streaming-cache-evict=0:Turn off all cache line evicts
# -opt-streaming-stores always:enables generation of streaming stores under the assumption that the application is memory bound
# -DSTREAM_ARRAY_SIZE=64000000: Increasing the size of the array size to be compliant with the STREAM Rules