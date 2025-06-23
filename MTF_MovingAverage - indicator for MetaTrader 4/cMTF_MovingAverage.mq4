//+------------------------------------------------------------------+
//|                                            MTF_MovingAverage.mq4 |
//|                                      Copyright © 2006, Keris2112 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Keris2112"
#property link      "http://www.forex-tsd.com"
//----
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue
//---- input parameters
extern int TimeFrame=0;
extern int MAPeriod=13;
extern int ma_shift=0;
extern int ma_method=MODE_SMA;
extern int applied_price=PRICE_CLOSE;
//----
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
//---- name for DataWindow and indicator subwindow label   
   switch(ma_method)
     {
      case 1 : short_name="MTF_EMA("; break;
      case 2 : short_name="MTF_SMMA("; break;
      case 3 : short_name="MTF_LWMA("; break;
      default : short_name="MTF_SMA(";
     }
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
   IndicatorShortName(short_name+MAPeriod+") "+TimeFrameStr);
   return(0);
  }
//----
//+------------------------------------------------------------------+
//| MTF Moving Average                                               |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,y=0;
   // Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
//----
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
   
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
      //----
      ExtMapBuffer1[i]=iMA(NULL,TimeFrame,MAPeriod,ma_shift,ma_method,applied_price,y);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+