//+------------------------------------------------------------------+
//|                                                #!MACDonchart.mq4 |
//|                                    Copyright @2011, Rockyhoangdn |
//|                                           rockyhoangdn@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright @2011, Rockyhoangdn"
#property link      "rockyhoangdn@gmail.com"

#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property  indicator_chart_window
#property  indicator_buffers 7
#property indicator_color1 Green
#property indicator_color2 Coral
#property  indicator_color3  Aqua
#property  indicator_color4  Red
#property  indicator_color5  Magenta
#property  indicator_color6  DeepPink
#property  indicator_color7  Aqua

#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 2
#property indicator_width7 2

//---- indicator parameters
extern int FastEMA=8;
extern int SlowEMA=50;
extern int SignalSMA=9;

//---- indicator buffers
double     ind_buffer3a[];
double     ind_buffer3b[];
double     ind_buffer4[];
double     ind_buffer5[];
double     ind_buffer6[];
double     ind_buffer7[];
double     ind_buffer8[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(7);
//---- drawing settings

   SetIndexStyle(0,DRAW_NONE);
   SetIndexDrawBegin(0,SignalSMA);
   SetIndexLabel(0,"Up Trend");
   SetIndexStyle(1,DRAW_NONE);
   SetIndexDrawBegin(1,SignalSMA);
   SetIndexLabel(1,"Down Trend");
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,ind_buffer4);
   
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,ind_buffer6);
   
   SetIndexStyle(4,DRAW_SECTION);
   SetIndexBuffer(4,ind_buffer6);
   SetIndexLabel(4,"Zigzag value");
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexBuffer(5,ind_buffer7);
   SetIndexLabel(5,"Short Entry");
   SetIndexArrow(5, 222);
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexBuffer(6,ind_buffer8);
   SetIndexLabel(6,"Long Entry");
   SetIndexArrow(6, 221);
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
   
//---- 5 indicator buffers mapping
   SetIndexBuffer(0,ind_buffer3a);
   SetIndexBuffer(1,ind_buffer3b);
   SetIndexBuffer(2,ind_buffer4);
   SetIndexBuffer(3,ind_buffer5);
   SetIndexBuffer(4,ind_buffer6);
   
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD  ("+FastEMA+","+SlowEMA+","+SignalSMA+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Average of Oscillator                                     |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1;
//---- macd counted in the 1-st additional buffer
   for(int i=0; i<limit; i++)
      ind_buffer4[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)
                        -iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- signal line counted in the 2-nd additional buffer
   for(i=0; i<limit; i++)
      ind_buffer5[i]=iMAOnArray(ind_buffer4,Bars,SignalSMA,0,MODE_EMA,i);
//---- main loop
   double value=0;
   for(i=0; i<limit; i++)
      {
         ind_buffer3a[i]=0.0;
         ind_buffer3b[i]=0.0;      
         value=ind_buffer4[i]-ind_buffer5[i];
         if (value>0) ind_buffer3a[i]=value;
         if (value<0) ind_buffer3b[i]=value;
         if ( value == 0)ind_buffer6[i]=value;
      }   
   for(i=0; i<limit; i++)
      {
         if ( ind_buffer3a[i+1]!= 0 && ind_buffer3b[i]!=0)
            {
            ind_buffer6[i]=Open[i];
            ind_buffer7[i]=Open[i];
            }
            else
            {
            ind_buffer7[i]=0;
            }
         if ( ind_buffer3b[i+1]!= 0 && ind_buffer3a[i]!=0)
            {
            ind_buffer6[i]=Open[i];
            ind_buffer8[i]=Open[i];
            }
            else
            {
            ind_buffer8[i]=0;
            }
      }   
     
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

