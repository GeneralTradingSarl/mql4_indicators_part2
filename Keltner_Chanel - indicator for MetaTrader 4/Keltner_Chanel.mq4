//+------------------------------------------------------------------+
//|                                                Keltner Chanel.mq4 |
//|                                                            Korey |
//|                                                   ekr-ap@mail.ru |
//+------------------------------------------------------------------+
#property copyright "AP"
#property link      "ekr-ap@mail.ru"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red

extern int periodMA=20; //Basic EMA
extern int periodATR=10;//Average True Range period
extern double kshift=2; //shift Lines Upper & Lower

double b0[],b1[],b2[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,b0);
   SetIndexLabel(0,"Upper"+periodATR+","+DoubleToStr(kshift,1));

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,b1);
   SetIndexLabel(1,"Lower"+periodATR+","+DoubleToStr(kshift,1));

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,b2);
   SetIndexLabel(2,"EMA"+periodMA);
   IndicatorShortName("Keltner_Chanel("+periodMA+","+periodATR+","+DoubleToStr(kshift,1)+")");

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
   double r;

   for(int i=0;i<=limit;i++)
     {
      b2[i]=iMA(NULL,0,periodMA,0,MODE_EMA,PRICE_CLOSE,i);
      r=kshift*iATR(NULL,0,periodATR,i);
      b0[i]=b2[i]+r;
      b1[i]=b2[i]-r;
     }

   return(0);
  }
//+------------------------------------------------------------------+
