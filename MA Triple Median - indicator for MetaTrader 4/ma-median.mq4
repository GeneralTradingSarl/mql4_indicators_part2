//+------------------------------------------------------------------+
//|                                                    MA-Median.mq4 |
//|                                         ATS TURBO by Andy Ismail |
//|                                                    fbsbroker.com |
//+------------------------------------------------------------------+
#property copyright "Andy Ismail"
#property link      "http://www.fbsbroker.com/"
#property description "MA Median Indicator by Andy Ismail"
#property strict
//---
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red
//---- input parameters
extern int maPeriod1=5; //MA Period
//---
int maPeriod_2   = maPeriod1;
int maPeriod_3   = maPeriod1;
int maMethod_1   = 0;
int maAppPrice_1 = 0;
int maMethod_2   = 0;
int maMethod_3   = 0;
//---- indicator buffers
double a[];
double b[];
double c[];
//+------------------------------------------------------------------+
int init()
  {
   SetIndexDrawBegin(0,maPeriod1+maPeriod_2+maPeriod_3);
   SetIndexDrawBegin(1,maPeriod1+maPeriod_2+maPeriod_3);
   SetIndexDrawBegin(2,maPeriod1+maPeriod_2+maPeriod_3);
//---
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
//---
   SetIndexBuffer(0,a);
   SetIndexBuffer(1,b);
   SetIndexBuffer(2,c);
//---
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
//---
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   int limit,i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---
   for(i=0; i<limit; i++)
     {
      a[i]=iMA(NULL,0,maPeriod1,0,MODE_EMA,PRICE_MEDIAN,i+1);
     }
   for(i=0; i<limit; i++)
     {
      b[i]=iMAOnArray(a,Bars,maPeriod_2,0,MODE_EMA,i+1);
     }
   for(i=0; i<limit; i++)
     {
      c[i]=iMAOnArray(b,Bars,maPeriod_3,0,MODE_EMA,i+1);
     }
   return(0);
  }
//+------------------------------------------------------------------+
