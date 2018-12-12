#include <stdio.h>

#define HANDLE_ERROR( err ) ( HandleError( err, __FILE__, __LINE__ ))

static void HandleError( cudaError_t err, const char *file, int line )
{
    if (err != cudaSuccess)
      {
        printf( "%s in %s at line %d\n", cudaGetErrorString( err ),file, line );
        exit( EXIT_FAILURE );
    }
}


const int N = 10000 ;

// CUDA Kernel
__global__ void Vector_Plus ( int *AG ,  int *BG , int *CG)
{
      int id = blockDim.x*blockIdx.x+threadIdx.x ;
      if ( id < N )
            *(CG+id)=*(AG+id)+ *(BG+id);

}


int main (void)
{

      //Khoi tao 3 mang A B C tren CPU
      int *A, *B, *C;
      A   = (int *) malloc (N*sizeof(int));
      B   = (int *) malloc (N*sizeof(int));
      C   = (int *) malloc (N*sizeof(int));

   

      //Khoi tao 3 mang A B C tren GPU
      int *AG , *BG, *CG ;
      HANDLE_ERROR ( cudaMalloc(&AG , N*sizeof(int) ) );
      HANDLE_ERROR ( cudaMalloc(&BG , N*sizeof(int) ) );
      HANDLE_ERROR ( cudaMalloc(&CG , N*sizeof(int) ) );

      //Khoi tao gia tri mang A B tren CPU
      for ( int i = 0; i <N ; i++ )
      {
            *(A+i) = i ;
            *(B+i) = i+1 ; 
      }

      //Copy mang A B  sang GPU
      HANDLE_ERROR (cudaMemcpy (AG , A , N*sizeof(int) , cudaMemcpyHostToDevice));
      HANDLE_ERROR (cudaMemcpy (BG , B , N*sizeof(int) , cudaMemcpyHostToDevice));

      
      int threadsPerBlock = 1000;    
      int blocksPerGrid = N / threadsPerBlock;
      //Vector_Plus <<< 1, N  >>> (AG , BG , CG ) ;
      Vector_Plus <<<blocksPerGrid, threadsPerBlock >>> (AG , BG , CG ) ;

      //Copy lai CPU
      HANDLE_ERROR (cudaMemcpy(C , CG , N*sizeof(int) , cudaMemcpyDeviceToHost));

      //Hien thi ket qua
      for ( int i = 0; i<N; i++ )
            printf ("%d + %d = %d\n", *(A+i) , *(B+i) , *(C+i)) ;

      //Gia phong bo nho
      cudaFree (AG) ;
      cudaFree (BG) ;
      cudaFree (CG) ;

      system("pause");
      return 0 ;

}