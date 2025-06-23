//+------------------------------------------------------------------+
//|                                       OneSideGaussianLibrary.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property library

#define MaxLength 34

//
//
//
//
//

int    levels[] = {1,2,3,5,8,13,21,34};
double GaussianBuffer[][8];

//+------------------------------------------------------------------+
//| Gaussian function                                                |
//+------------------------------------------------------------------+
// Counts function Exp((x - x0)^2/s^2)
// x0 - higher point of function
// x  - point function is counted at
// s  - width of function // don't forget about 3-sigma rule

double Gaussian(int Size, int X)
{
   return (MathExp(-X*X*9/((Size + 1)*(Size + 1))));
}

//
//
//
//
//

void BuffersInit()
{
   int i;
   
   ArrayResize(GaussianBuffer,MaxLength);
   for (int k = 0; k < 8; k++)
   {
      double sum = 0.0;
         for (i = 0; i < MaxLength; i++) { if (i>=levels[k]) break; GaussianBuffer[i][k]  = Gaussian(levels[k],i); sum += GaussianBuffer[i][k];}
         for (i = 0; i < MaxLength; i++) { if (i>=levels[k]) break; GaussianBuffer[i][k] /= sum; }
   }                              
}

//
//
//
//
//

double Smooth(int level,int appliedPrice, int shift)
{
   double sum   = 0;
   int    limit = levels[level];
   
   if (shift >= (Bars - limit)) return(iMA(NULL,0,1,0,MODE_SMA,appliedPrice,shift));
   
   //
   //
   //
   //
   //
   
   for (int i = 0; i < limit; i++)
           sum += GaussianBuffer[i][level]*iMA(NULL,0,1,0,MODE_SMA,appliedPrice,shift+i);
   return (sum);
}

double SmoothArray(int level, double& array[], int shift)
{
   double sum   = 0;
   int    limit = levels[level];
   
   if (shift >= (Bars - limit)) return(array[shift]);
   
   for (int i = 0; i < limit; i++)
           sum += GaussianBuffer[i][level]*array[shift + i];
   return (sum);
}