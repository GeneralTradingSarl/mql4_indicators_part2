//+------------------------------------------------------------------+
//|                                                    Mom Cross.mq4 |
//|                               Copyright © 2005, Taylor Stockwell |
//|                                        mailto:stockwet@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Taylor Stockwell"
#property link      "mailto:stockwet@yahoo.com"
//----
#property  indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int FastMom=5;
extern int SlowMom=14;
//---- buffers
double FastMomBuffer[];
double SlowMomBuffer[];
//---- variables
int indexbegin=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, FastMomBuffer);
   SetIndexLabel(0, "Fast Momemtum");
   SetIndexEmptyValue(0, 0.0);
   //
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, SlowMomBuffer);
   SetIndexLabel(1, "Slow Momentum");
   SetIndexEmptyValue(1, 0.0);
//----
   indexbegin=Bars - 20;
   if (indexbegin < 0)
      indexbegin=0;
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if (counted_bars < 0) counted_bars=0;
//---- last counted bar will be recounted
   if (counted_bars > 0) counted_bars--;
   if (counted_bars > indexbegin) counted_bars=indexbegin;
   for(i=indexbegin-counted_bars; i>=0; i--)
     {
      FastMomBuffer[i]=iMomentum(NULL,0,FastMom,PRICE_CLOSE,i);
      SlowMomBuffer[i]=iMomentum(NULL,0,SlowMom,PRICE_CLOSE,i);
     }
   return(0);
  }
//+------------------------------------------------------------------+