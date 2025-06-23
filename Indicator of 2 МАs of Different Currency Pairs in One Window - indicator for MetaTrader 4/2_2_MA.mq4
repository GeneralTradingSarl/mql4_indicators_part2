//+------------------------------------------------------------------+
//|                                                       2*2_MA.mq4 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int period_1 = 13 ;
extern int period_2 = 55 ;
extern int ma_method = 0;
extern int applied_price = 0;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
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
   
   IndicatorShortName("2*2_MA("+period_1+","+period_2+")");
   
   SetIndexLabel(0,"EURUSD");
   SetIndexLabel(1,"GBPUSD");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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
  int limit;
   int counted_bars=IndicatorCounted();
   
   //---- check for possible errors
   if(counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   //---- main loop
   for(int i=0; i<limit; i++)
   {
     double p1 = MarketInfo("EURUSD",MODE_POINT);
     double MA1 = iMA("EURUSD",0,period_1,0,ma_method,applied_price,i);
     double MA2 = iMA("EURUSD",0,period_2,0,ma_method,applied_price,i);
     ExtMapBuffer1[i]=(MA1-MA2)/p1;
     
     double p2 = MarketInfo("GBPUSD",MODE_POINT);
     double MA11 = iMA("GBPUSD",0,period_1,0,ma_method,applied_price,i);
     double MA22 = iMA("GBPUSD",0,period_2,0,ma_method,applied_price,i);
     ExtMapBuffer2[i]=(MA11-MA22)/p2;     
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+


