//+------------------------------------------------------------------+
//| MALock.mq4                                                       |
//| Copyright © tembox, 27 March 2015                                |
//| ------------                                                     |
//|                                                                  |
//| Moving Average bound to spesific Time Frame                      |
//| example: Locked MA(8) on H1  --> MA(32) on M15 --> MA(16) on M30 |
//|          Locked MA(32) on M15 --> MA(8) on H1 --> MA(16) on M30  |
//+------------------------------------------------------------------+
#property copyright "Copyright © tembox"
#property link      ""
//---
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_width1 1
//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
extern string noteMATF       = "5=M5; 15=M15; 30=M30; 60=H1; 240=H4; 1440=D1; 10080=W1; 43200=MN";
extern int MATF              = 60;
extern int MAPeriod          = 8;
extern string noteMAMethod   = "0=MODE_SMA; 1=MODE_EMA; 2=MODE_SMMA; 3=MODE_LWMA";
extern int MAMethod          = 0;
extern string noteMAPrice    = "0=CLOSE; 1=OPEN; 2=HIGH; 3=LOW; 4=MEDIAN; 5=TYPICAL; 6=WIGHTED";
extern int MAPrice           = 0;
extern int MAShift           = 0;
//+------------------------------------------------------------------+
//| Buffers                                                          |
//+------------------------------------------------------------------+
double Buff1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buff1);
   SetIndexLabel(0,"MALock("+MAPeriod+"->"+(MATF*MAPeriod/Period())+")");
   SetIndexDrawBegin(0,(MATF*MAPeriod)/Period());
// Data window
   IndicatorShortName("MALock("+MAPeriod+")");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars = IndicatorCounted();
   double NewPeriod = (MATF*MAPeriod/Period());
//---
   if(counted_bars < 0) return(-1);
   limit=Bars-1 -counted_bars;
//---
   for(int i=limit; i>=0; i--)
     {
      Buff1[i]=iMA(NULL,0,NewPeriod,MAShift,MAMethod,MAPrice,i);
     }
   return(0);
  }
//+------------------------------------------------------------------+
