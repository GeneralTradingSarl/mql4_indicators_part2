//+------------------------------------------------------------------+
//|                                                  J_TPO_Clean.mq4 |
//|                      Copyright © 2005,                           |
//|                                                                  |
//+------------------------------------------------------------------+

// J_TPO_Clean is a cleanup of the original J_TPO code, which
// was incomprehensible, and obviously translated poorly from some 
// other implementation.   Some bugs have been eliminated.
// It now does J_TPO on Close[] and High[] and Low[], in
// white, green and red respectively.   If you want classic J_TPO,
// then just turn the colors of the green and red to 'none'.
// Matt (mbkennel@gmail.com)
// This code is released under the terms of the GNU General Public License V2

#property copyright "Copyright © 2005"
#property link      "www.metatrader.org"
//----
#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 1
#property indicator_buffers 3
#property indicator_color1 White
#property indicator_color2 Green
#property indicator_color3 Red
//---- input parameters
extern int       Len=14;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| J_TPO indicatop                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+Len;

   if(Len<3)
     {
      Print("J_TPO_B:  length must be at least 3");
      return(0); //  
     }
   for(int i=limit; i>=0; i--)
     {
      ExtMapBuffer1[i]=J_TPO_value(Close,Len,i);
      ExtMapBuffer2[i]=J_TPO_value(High,Len,i);
      ExtMapBuffer3[i]=J_TPO_value(Low,Len,i);
     }
//---- done
   return(0);
  }
//----
double J_TPO_value(double inputp[],int Len,int shift)
  {
// compute the J_TPO function on input[shift], looking back up to Len data previous
   double value,normalization,Lenp1half;
   double accum,tmp,maxval;
   int j,maxloc,m;
   double arr1[],arr2[],arr3[];
   bool flag;
   accum=0;
//----
   ArrayResize(arr1,Len+2);
   ArrayResize(arr2,Len+2);
   ArrayResize(arr3,Len+2);
//----   
   for(m=1; m<=Len; m++)
     {
      arr2[m]=m;
      arr3[m]=m;
      arr1[m]=inputp[shift+Len-m];
     }
// sort arr1[] in ascending order, arr2[] is the permutation index 
// Note, this is a poor quadratic search, and will not scale well with Len
   for(m=1; m<=(Len-1); m++)
     {
      // find max value & its location in arr1 [m..m+Len]
      maxval=arr1[m];
      maxloc=m;
      for(j=m+1; j<=Len; j++)
        {
         if(arr1[j]<maxval)
           {
            maxval=arr1[j];
            maxloc=j;
           }
        }
      // Swap arr1[m] with its max value
      // amd similarly for arr2.
      tmp=arr1[m];
      arr1[m]=arr1[maxloc];
      arr1[maxloc]=tmp;
      tmp=arr2[m];
      arr2[m]=arr2[maxloc];
      arr2[maxloc]=tmp;
     }
// arr3[1..Len] is nominally 1..m, but this here adjusts for
// ties.
   m=1;
   while(m<Len)
     {
      // Search for repeated values. 
      j=m+1;
      flag=true;
      accum=arr3[m];
      while(flag)
        {
         if(arr1[m]!=arr1[j])
           {
            if((j-m)>1)
              {
               // a streak of repeated values was found
               // and so replace arr3[] for those with 
               // its average
               accum=accum/(j-m);
               for(int n=m; n<=(j-1); n++)
                  arr3[n]=accum;
              }
            flag=false;
           }
         else
           {
            accum+=arr3[j];
            j++;
           }  // if
        } // while flag 
      m=j;
     } // while (Len > m) 
// This is the real guts of the J_TPO
// it is a simple statistic to see if the ranks, when applied in sorted order are
// "correlated" with 1..Len, a simple cross correlation of ranks.
// so if they are sorted then this gives 1, and if they are anti-sorted they give -1
// and similarly for intermediate values. 
   normalization=12.0/(Len*(Len-1)*(Len+1));
   Lenp1half=(Len+1)*0.5;
//----
   for(accum=0,m=1; m<=Len; m++)
     {
      // Print("m="+m+"Arr2[m] ="+arr2[m]+" arr3[m]="+arr3[m]); 
      accum+=(arr3[m]-Lenp1half) *(arr2[m]-Lenp1half);
     }
   value=normalization*accum;
// Print("JTPO_B:  accum = "+accum+" norm = "+normalization); 
   return(value);
  }
//+------------------------------------------------------------------+
half) *(arr2[m]-Lenp1half);
     }
   value=normalization*accum;
// Print("JTPO_B:  accum = "+accum+" norm = "+normalization); 
   return(value);
  }
//+------------------------------------------------------------------+
