//+------------------------------------------------------------------+
//|                                  NatusekoProtrader4HStrategy.mq4 |
//|                                                     FORTRADER.RU |
//|                                              http://FORTRADER.RU |
//+------------------------------------------------------------------+
#property copyright "FORTRADER.RU"
#property link      "http://FORTRADER.RU"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 DarkGray
#property indicator_color2 DodgerBlue
#property indicator_color3 DodgerBlue
#property indicator_color4 DodgerBlue
#property indicator_color5 Red
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double macd[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer5);

   ArraySetAsSeries(macd,true);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit--;

   ArrayResize(macd,ArraySize(ExtMapBuffer1));
   for(i=limit; i>=0; i--)
     {
      macd[i]=iMACD(NULL,0,5,200,1,PRICE_CLOSE,MODE_MAIN,i);
      ExtMapBuffer1[i]=iMACD(NULL,0,5,200,1,PRICE_CLOSE,MODE_MAIN,i);
     }

   for(i=0; i<=limit; i++)
     {
      ExtMapBuffer2[i]=iBandsOnArray(macd,0,20,1,0,MODE_MAIN,i);
      ExtMapBuffer3[i]=iBandsOnArray(macd,0,20,1,0,MODE_UPPER,i);
      ExtMapBuffer4[i]=iBandsOnArray(macd,0,20,1,0,MODE_LOWER,i);
      ExtMapBuffer5[i]=iMAOnArray(macd,0,3,0,MODE_SMA,i);
     }
   return(0);
  }
//+------------------------------------------------------------------+
