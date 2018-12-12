#include <stdio.h>


const int N = 10000 ;

__global__ void Vector_Addition (  int *dev_a ,  int *dev_b , int *dev_c)
{ 
      //Lay ra id cua thread trong 1 block.
      int tid = blockIdx.x ; // blockDim.x*blockIdx.x+threadIdx.x
     
      if ( tid < N )
            *(dev_c+tid) = *(dev_a+tid) + *(dev_b+tid) ;

}


int main (void)
{

      //Cap phat bo nho 3 mang A B C tren CPU
      int *Host_a, *Host_b, *Host_c;
      Host_a  = (int *) malloc (N*sizeof(int));
      Host_b   = (int *) malloc (N*sizeof(int));
      Host_c   = (int *) malloc (N*sizeof(int));
      //Khởi tao bên CPU
      for ( int i = 0; i <N ; i++ )
      {
            *(Host_a+i) = i ;
            *(Host_b+i) = i+1 ; 
      }

	  //Cap phat bo nho 3 mang A B C tren GPU
      int *dev_a , *dev_b, *dev_c ;
      cudaMalloc(&dev_a , N*sizeof(int) ) ;
      cudaMalloc(&dev_b , N*sizeof(int) ) ;
      cudaMalloc(&dev_c , N*sizeof(int) ) ;

     
      //Copy mang host_a, host_b tu CPU cho mang dev_a,dev_b tren GPU
      cudaMemcpy (dev_a , Host_a , N*sizeof(int) , cudaMemcpyHostToDevice);
      cudaMemcpy (dev_b , Host_b , N*sizeof(int) , cudaMemcpyHostToDevice);

      //Tính toán trên GPU
	  //N block/gird ,1 thread/1 block
      Vector_Addition <<< N, 1  >>> (dev_a , dev_b , dev_c ) ;

      //Copy lại CPU
      cudaMemcpy(Host_c , dev_c , N*sizeof(int) , cudaMemcpyDeviceToHost);

      //Ket qua
      for ( int i = 0; i<N; i++ )
                  printf ("%d + %d = %d\n", *(Host_a+i) , *(Host_b+i)  , *(Host_c+i)  ) ;

      //Gia phong bo nhe
      cudaFree (dev_a) ;
      cudaFree (dev_b) ;
      cudaFree (dev_c) ;

      system("pause");
      return 0 ;

}