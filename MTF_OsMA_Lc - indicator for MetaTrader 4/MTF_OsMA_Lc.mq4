//+-----------------------------------------------------------------------+
//|                                                           MTF_OsMA_Lc |
//|                                                 Copyright © 2007, SOK |
//|                                              http://SOK.LiteForex.net |
//|                         www.metaquotes.net/mtf / www.forex-tsd.com ik |
//+-----------------------------------------------------------------------+
#property copyright "Copyright © 2007, SOK"
#property link      "http://sok.liteforex.net"
//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 Magenta
#property indicator_width1 2
#property indicator_width2 2
//----
extern int TimeFrame=0;
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
extern int AplyingPrice=0;
//----
double ExtMapBuffer0[];
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0, DRAW_LINE, 0, 2);
   SetIndexBuffer(0, ExtMapBuffer0);
   SetIndexStyle(1, DRAW_LINE, 0, 2);
   SetIndexBuffer(1, ExtMapBuffer1);
   IndicatorShortName("MTF_OsMA_Lc[" + FastEMA + ", " + SlowEMA + ", " + SignalSMA + "]TF ("+TimeFrame+")");
   SetIndexLabel(0,"MTF_OsMA_Lc,[" + FastEMA + ", " + SlowEMA + ", " + SignalSMA + "]TF ("+TimeFrame+")");
   SetIndexLabel(1,"MTF_OsMA_Lc,[" + FastEMA + ", " + SlowEMA + ", " + SignalSMA + "] TF ("+TimeFrame+")");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator start function                                  |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,shift,limit,y=0,counted_bars=IndicatorCounted();
//----
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
//----   
   limit=Bars-counted_bars+TimeFrame/Period();
     for(i=0,y=0;i<limit;i++) 
     {
      if (Time[i]<TimeArray[y]) {y++;}
      ExtMapBuffer0[i]=iCustom(NULL, TimeFrame, "OsMA_Lc",FastEMA, SlowEMA, SignalSMA,AplyingPrice,  0,y);
      ExtMapBuffer1[i]=iCustom(NULL, TimeFrame, "OsMA_Lc",FastEMA, SlowEMA, SignalSMA,AplyingPrice,  1,y);
     }
   return(0);
  }
//+------------------------------------------------------------------+

