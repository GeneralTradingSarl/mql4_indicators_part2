//+------------------------------------------------------------------+
//|                                    Instantaneous Trendline Filter|
//|                         Copyright © 2006, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"
//----
#property indicator_buffers 2
#property indicator_chart_window
#property indicator_color1 clrLime
#property indicator_color2 clrRed
//---- input parameters
extern double  alpha=0.07;
extern int     maxbars=2000;
extern string  Price_Choice="-----  Typical or Median  -----";
extern bool    is_median=true;
//---- buffers
double ind1[];
double ind2[];
//double AuxBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ind1);
//---
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ind2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double pr0,pr1,pr2=0;
   int    counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
   int limit=Bars-counted_bars;
   if(limit>maxbars) limit=maxbars;
   if(maxbars>Bars)  limit=Bars-4;
//if (limit>Bars-1)limit=Bars-1;   
//---- 
   for(int i=limit; i>=0;i--)
     {
      if(is_median)
        {
         pr0=(High[i]+Low[i])/2;
         pr1=(High[i+1]+Low[i+1])/2;
         pr2=(High[i+2]+Low[i+2])/2;
        }
      else
        {
         pr0=(High[i]+Low[i]+Close[i])/3;
         pr1=(High[i+1]+Low[i+1]+Close[i+1])/3;
         pr2=(High[i+2]+Low[i+2]+Close[i+2])/3;
        }
      ind1[i]=(alpha-MathPow(alpha/2,2))*pr0
              +(MathPow(alpha,2)/2)*pr1
              -(alpha-3*MathPow(alpha,2)/4)*pr2
              +2*(1-alpha)*ind1[i+1]
              -MathPow(1-alpha,2)*ind1[i+2];
      ind2[i]=2*ind1[i]-ind1[i+2];
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
