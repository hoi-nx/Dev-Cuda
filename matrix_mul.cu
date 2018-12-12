#include <stdio.h>

const int m=20;
const int n=20;
const int p=5;

//m*n *n*p=m*p

__global__ void MatrixAdd_CUDA(int *A, int *B, int *C) { 
      int row = blockIdx.y * blockDim.y + threadIdx.y;    
      int col = blockIdx.x * blockDim.x + threadIdx.x;
      int s ;
      if(row<m && col<p){
            s=  0; 
            for (int k = 0 ; k < n ; k++ ) {
                  s +=*(A + row*n + k)*(*(B + k*p + col));
            }
            *(C+row*p+col) = s;
      }
     
          

      
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
      int *A, *B, *C;
      A  = (int *) malloc ((m*n)*sizeof(int));
      B   = (int *) malloc ((n*p)*sizeof(int));
      C   = (int *) malloc ((m*p)*sizeof(int));
     

      int *AG , *BG, *CG ;
      
      cudaMalloc(&AG , (m*n)*sizeof(int) ) ;
      cudaMalloc(&BG , (m*n)*sizeof(int) ) ;
      cudaMalloc(&CG , (m*p)*sizeof(int) ) ;

      for ( int i = 0; i <m ; i++ )
          for(int j=0;j<n;j++){
                if(i==j){
                  *(A+i*n+j)=1;
                }else{
                  *(A+i*n+j)=0;
                } 
          }
      for ( int i = 0; i <n ; i++ )
          for(int j=0;j<p;j++){
              *(B+i*p+j)=i+j;    
          }

      cudaMemcpy (AG , A , (m*n)*sizeof(int) , cudaMemcpyHostToDevice);
      cudaMemcpy (BG , B , (n*p)*sizeof(int) , cudaMemcpyHostToDevice);

      dim3 threadsPerBlock(5, 5);    
      dim3 numBlocks(m / threadsPerBlock.x, m / threadsPerBlock.y); 
      MatrixAdd_CUDA <<< numBlocks, threadsPerBlock  >>> (AG , BG , CG ) ;

      cudaMemcpy(C , CG , (m*p)*sizeof(int) , cudaMemcpyDeviceToHost);

      DisplayMatrix(A,m,n);
      printf("======================================================================================\n");
      DisplayMatrix(B,n,p);

      printf("=======================================================================================\n");
      DisplayMatrix(C,m,p);

                 

      cudaFree (AG) ;
      cudaFree (BG) ;
      cudaFree (CG) ;
      free(A);
      free(B);
      free(C);

    
      return 0 ;

}