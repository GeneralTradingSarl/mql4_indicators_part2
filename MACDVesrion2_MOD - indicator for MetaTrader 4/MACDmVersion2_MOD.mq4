//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Green
#property  indicator_color2  FireBrick
#property  indicator_color3  White
#property  indicator_color4  Green
#property  indicator_color5  FireBrick

#property  indicator_width1  4
#property  indicator_width2  2
#property  indicator_width3  2
#property  indicator_width4  2
#property  indicator_width5  2
//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
//---- indicator buffers
double     MacdBuffer[];
double     GreenBuffer[];
double     FireBrickBuffer[];

double     SignalBuffer[];
double     Signal2Buffer[];
double     alpha=0;
double     alpha_1=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,SignalSMA);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexDrawBegin(2,SlowEMA+SignalSMA);
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBuffer);
   SetIndexBuffer(1,SignalBuffer);
   SetIndexBuffer(2,Signal2Buffer);

   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,EMPTY,Green);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,EMPTY,FireBrick);
   SetIndexBuffer(0,GreenBuffer);
   SetIndexBuffer(1,FireBrickBuffer);

//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+FastEMA+","+SlowEMA+","+SignalSMA+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   alpha=2.0/(SignalSMA+1.0);
   alpha_1=1.0-alpha;
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1;

   int xsize=ArraySize(Signal2Buffer);
   ArrayResize(MacdBuffer,xsize);
   ArrayResize(SignalBuffer,xsize);
   
//---- macd counted in the 1-st buffer
   for(int i=0; i<limit; i++)
      MacdBuffer[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);

//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
   for(i=0; i<limit; i++)
      Signal2Buffer[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);

   if(MacdBuffer[i]>0.0) GreenBuffer[i]=MacdBuffer[i];
   else if(MacdBuffer[i]<0.0) FireBrickBuffer[i]=MacdBuffer[i];
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
