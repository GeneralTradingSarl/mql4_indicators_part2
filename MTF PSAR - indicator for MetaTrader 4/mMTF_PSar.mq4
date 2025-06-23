//+------------------------------------------------------------------+
//|                                                     MTF_PSAR.mq4 |
//|                                      Copyright © 2006, Keris2112 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Keris2112"
#property link      "http://www.forex-tsd.com"
//----
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Magenta
//---- input parameters
extern int TimeFrame=0;
extern double Step=0.02;
extern double Maximum=0.2;
//----
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
     {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
     }
   IndicatorShortName("MTF_PSAR ("+TimeFrameStr+")");
   return(0);
  }
//----
//+------------------------------------------------------------------+
//| MTF Parabolic Sar                                                |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,y=0;
   // Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);

   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
   
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
      ExtMapBuffer1[i]=iSAR(NULL,TimeFrame,Step,Maximum,y);
     }
   //----
   return(0);
  }
//+------------------------------------------------------------------+