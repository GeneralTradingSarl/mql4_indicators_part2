//+------------------------------------------------------------------+
//|                                                                  |
//|                 Copyright © 1999-2007, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property copyright "Metatrader4 Code by jjk2. Based on MBA Thesis from Simon Fraser University written by C.E. ALDEA."
#property link      ""
#property indicator_separate_window
#property indicator_buffers 3
//----
#property indicator_color1 Green
#property indicator_color2 Yellow
#property indicator_color3 White
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 1
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(4);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
//
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexLabel(2,NULL);
//
   string short_name="ZigZag BETA Current value:";
   IndicatorShortName(short_name);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;
//----
   for(int i=limit; i>=0; i--)
     {
      double MACD  =iMACD(NULL,0,12,26,9,PRICE_CLOSE,0,i);
      double Stoch =iStochastic(NULL,0,9,6,2,MODE_SMA,1,0,i);
      double RSI   =iRSI(NULL,0,9,PRICE_CLOSE,i);
      double moment=iMomentum(NULL,0,9,PRICE_CLOSE,i);
      //----
      if(moment!=0)
         ExtMapBuffer4[i]=Stoch*(MACD+RSI)/moment;
      else  ExtMapBuffer4[i]=0.00;
     }
   for(i=limit; i>=0; i--)
     {
      ExtMapBuffer3[i]=iMAOnArray(ExtMapBuffer4,0,2,0,MODE_SMA,i);
      if(ExtMapBuffer3[i]>ExtMapBuffer3[i+1])
        {
         ExtMapBuffer1[i]=ExtMapBuffer3[i];
         ExtMapBuffer2[i]=EMPTY_VALUE;
        }
      else
        {
         ExtMapBuffer2[i]=ExtMapBuffer3[i];
         ExtMapBuffer1[i]=EMPTY_VALUE;
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
