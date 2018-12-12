#include <stdio.h>
#include<cuda.h>


const int N = 100 ;//256

__global__ void MatrixAdd_CUDA(int *A, int *B, int *C) { 
      int i= blockIdx.y*blockDim.y+ threadIdx.y; 
      int j = blockIdx.x*blockDim.x+ threadIdx.x; 
    *(C + i*N + j) =  *(A + i*N + j)+ *(B + i*N + j); 
      
}      
void DisplayMatrix(int *A, int row,  int col)
{
    int i,j;
    for(i=0;i<row;i++){
        for(j=0;j<col;j++) printf("  %d",*(A+i*col+j));
        printf("\n");
    }
}
   
int main (void)
{
      int *Host_a, *Host_b, *Host_c;
      Host_a  = (int *) malloc ((N*N)*sizeof(int));
      Host_b   = (int *) malloc ((N*N)*sizeof(int));
      Host_c   = (int *) malloc ((N*N)*sizeof(int));
     

      int *dev_a , *dev_b, *dev_c ;
       cudaMalloc(&dev_a , (N*N)*sizeof(int));
      cudaMalloc(&dev_b , (N*N)*sizeof(int));
      cudaMalloc(&dev_c , (N*N)*sizeof(int));

      for ( int i = 0; i <N ; i++ )
          for(int j=0;j<N;j++){
              *(Host_a+i*N+j)=i*2+1;
              *(Host_b+i*N+j)=i+j;
               
          }
      cudaMemcpy (dev_a , Host_a , (N*N)*sizeof(int) , cudaMemcpyHostToDevice);
      cudaMemcpy (dev_b , Host_b , (N*N)*sizeof(int) , cudaMemcpyHostToDevice);

      //int threadsPerBlock = 256;    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock
   
      dim3 threadsPerBlock(10, 10);    //16 16 
      dim3 numBlocks(N / threadsPerBlock.x, N / threadsPerBlock.y); 

      MatrixAdd_CUDA <<< numBlocks, threadsPerBlock  >>> (dev_a , dev_b , dev_c ) ;

     cudaMemcpy(Host_c , dev_c , (N*N)*sizeof(int) , cudaMemcpyDeviceToHost);

      DisplayMatrix(Host_c,10,10);
                 

      cudaFree (dev_a) ;
      cudaFree (dev_b) ;
      cudaFree (dev_c) ;
      
      return 0 ;

}