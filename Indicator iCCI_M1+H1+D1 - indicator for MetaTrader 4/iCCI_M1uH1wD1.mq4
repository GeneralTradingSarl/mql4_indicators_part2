//+------------------------------------------------------------------+
//|                                                iCCI_M1+H1+D1.mq4 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Blue
//---- input parameters
extern int       barsToProcess=30;
extern int       period=14;
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
   SetIndexBuffer(0,ExtMapBuffer1); SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
	SetIndexBuffer(1,ExtMapBuffer2); SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);
	SetIndexBuffer(2,ExtMapBuffer3); SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);
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
   int    counted_bars=IndicatorCounted(),
//----
 limit;

   if(counted_bars>0)
      counted_bars--;
   
   limit=Bars-counted_bars;
   
   if(limit>barsToProcess)
      limit=barsToProcess;
  
   for(int i=0;i<limit;i++)
   {
      ExtMapBuffer1[i]=iCCI(NULL,PERIOD_M1,period,PRICE_OPEN,i);
      ExtMapBuffer2[i]=iCCI(NULL,PERIOD_H1,period,PRICE_OPEN,i);
      ExtMapBuffer3[i]=iCCI(NULL,PERIOD_D1,period,PRICE_OPEN,i);
   }  
//----
   return(0);
  }
//+------------------------------------------------------------------+