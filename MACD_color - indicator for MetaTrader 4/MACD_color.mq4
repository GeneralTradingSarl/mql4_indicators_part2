//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

//
//    Отличается от стандартного МАСD 
//    1. раскраской в стиле АС/АО
//    2. запретом на изображение нулевого бара
//
//    Difference from МАСD of standart
//    1. color of style of AC/AO
//    2. unvisible null bar
#property  copyright "Aleksandr Pak,Almaty, 2006"
#property  link  "ekr-ap@mail.ru" 
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_color3  Silver

#property  indicator_width1  2
#property  indicator_width2  2
//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
//---- indicator buffers
double     MacdBuffer[],MacdBufferUp[],MacdBufferDown[];
double     SignalBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   IndicatorBuffers(4);

   SetIndexBuffer(0,MacdBufferUp);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,MacdBufferDown);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,SignalBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexDrawBegin(2,SignalSMA);
   SetIndexBuffer(3,MacdBuffer);
   SetIndexStyle(3,DRAW_NONE);

   SetIndexLabel(0,"Buffer 0");
   SetIndexLabel(1,"Buffer 1");
   SetIndexLabel(2,"Signal");
   IndicatorDigits(Digits+3);
   IndicatorShortName("MACD_color("+FastEMA+","+SlowEMA+","+SignalSMA+")");
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit,i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;
//---- macd counted in the 1-st buffer
   for(i=0; i<limit; i++)
     {
      MacdBuffer[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
     }
   for(i=0; i<limit; i++)
     {
      MacdBufferDown[i]=0.0; MacdBufferUp[i]=0.0;

      if(i>=1) //это зарет на изображение нулевого бара //break the null bar  
        {
         if(MacdBuffer[i+1]-MacdBuffer[i]>=0)MacdBufferDown[i]=MacdBuffer[i]; //условия раскраси //condition of color
         else MacdBufferUp[i]=MacdBuffer[i];
        }
     }
   for(i=0; i<limit; i++) SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
   return(0);
  }
//+------------------------------------------------------------------+
