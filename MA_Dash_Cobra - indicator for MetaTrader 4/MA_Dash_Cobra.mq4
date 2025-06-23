//+------------------------------------------------------------------+
//|                                                  MAÂÏÿòíûøêó.mq4 |
//|                                                                * |
//|Integer                                                         * |
//+------------------------------------------------------------------+
#property copyright "*"
#property link      "*"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 CLR_NONE
#property indicator_color2 Yellow
//---- input parameters
extern int MAPeriod=14;
extern int MAMethod=0; // 0-SMA, 1-EMA, 2-SMMA, 3-LWMA
extern int MAPrice=0; // 0-Close, 1-Open, 2-High, 3-Low, 4-Median, 5-Typical, 6-Weighted
//----
#property indicator_width1 3
#property indicator_width2 3
//---- buffers
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
   SetIndexBuffer(1,ExtMapBuffer2);
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
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+3;

//----
     for(int i=limit-1;i>=0;i--)
     {
      ExtMapBuffer1[i]=iMA(NULL,0,MAPeriod,0,MAMethod,MAPrice,i);
      if(ExtMapBuffer2[i+1]!=EMPTY_VALUE &&
            ExtMapBuffer2[i+2]!=EMPTY_VALUE &&
            ExtMapBuffer2[i+3]!=EMPTY_VALUE   )
        {
         ExtMapBuffer2[i]=EMPTY_VALUE;
        }
        else
        {
         ExtMapBuffer2[i]=ExtMapBuffer1[i];
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+