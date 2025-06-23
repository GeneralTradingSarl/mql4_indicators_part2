//+------------------------------------------------------------------+
//|                                                         KC.mq4   |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- Matsu
//---- indicator settings
#property indicator_chart_window
#property  indicator_buffers 2
#property  indicator_color1  clrRed
#property  indicator_color2  clrRed
//---- indicator parameters
extern int EMA=20;
extern int ATR=20;
extern double    Factor=1.5;
//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexDrawBegin(0,EMA);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,ind_buffer1);
   SetIndexBuffer(1,ind_buffer2);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("KC("+EMA+","+ATR+","+Factor+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Average of Oscillator                                     |
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
   if(counted_bars==0) limit--;
//---- KC counted in the 1-st additional buffer
   for(int i=0; i<limit; i++)
      ind_buffer1[i]=iMA(NULL,0,EMA,0,MODE_EMA,PRICE_CLOSE,i)+iATR(NULL,0,ATR,0)*Factor;
//---- signal line counted in the 2-nd additional buffer
   for(i=0; i<limit; i++)
      ind_buffer2[i]=iMA(NULL,0,EMA,0,MODE_EMA,PRICE_CLOSE,i)-iATR(NULL,0,ATR,0)*Factor;
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
