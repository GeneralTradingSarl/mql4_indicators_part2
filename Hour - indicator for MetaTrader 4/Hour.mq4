//+------------------------------------------------------------------+
//|                                                         Hour.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Yellow
#property indicator_color3 Red
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
//---- последний посчитанный бар будет пересчитан
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- основной цикл
   for(int i=0; i<limit; i++)
     {
      ExtMapBuffer1[i]=iMA(NULL,60,5,0,0,0,i/12);
      ExtMapBuffer2[i]=iMA(NULL,15,5,0,0,0,i/3);
      ExtMapBuffer3[i]=iMA(NULL,5,5,0,0,0,i);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+