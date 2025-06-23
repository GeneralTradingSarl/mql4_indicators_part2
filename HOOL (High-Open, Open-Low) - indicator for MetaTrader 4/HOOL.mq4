//+------------------------------------------------------------------+
//|                                                         HOOL.mq4 |
//|                                         Copyright © 2009, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2009, LeMan."
#property  link      "b-market@mail.ru"
//----
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_width1  2
#property  indicator_width2  2
//----
double     ExtBuffer1[];
double     ExtBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() 
  {
//----
   IndicatorBuffers(2);
   IndicatorDigits(Digits);
//----
   SetIndexBuffer(0,ExtBuffer1);
   SetIndexBuffer(1,ExtBuffer2);
//----
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
//----
   IndicatorShortName("HOOL");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| HOOL Indicator                                                   |
//+------------------------------------------------------------------+
int start() 
  {
   int    limit,i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit--;
//----
   for(i=limit; i>=0; i--) 
     {
      ExtBuffer1[i] = NormalizeDouble((High[i]-Open[i])*MathPow(10,Digits),0);
      ExtBuffer2[i] = NormalizeDouble((Low[i]-Open[i])*MathPow(10,Digits),0);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
