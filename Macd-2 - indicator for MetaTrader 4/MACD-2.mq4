//+------------------------------------------------------------------+
//| macd-2.mq4                                                       |
//| Copyright ?2004, MetaQuotes Software Corp.                       |
//| http://www.metaquotes.net/                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2004, MetaQuotes Software Corp."
#property link "http://www.metaquotes.net/"
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 LimeGreen
#property indicator_color2 Red
#property indicator_color3 Black
#property indicator_color4 Black
//---- indicator parameters
extern int FastEMA=13;
extern int SlowEMA=17;
extern int SignalEMA=9;
//---- indicator buffers
double ind_buffer1[];
double ind_buffer2[];
double ind_buffer3[];
double ind_buffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(5);
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,1);
   IndicatorDigits(int(MarketInfo(Symbol(),MODE_DIGITS)+2));
   SetIndexDrawBegin(0,SignalEMA);
   SetIndexDrawBegin(1,SignalEMA);
//---- 4 indicator buffers mapping
   SetIndexBuffer(0,ind_buffer1);
   SetIndexBuffer(1,ind_buffer2);
   SetIndexBuffer(2,ind_buffer3);
   SetIndexBuffer(3,ind_buffer4);

//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD-2 ("+string(FastEMA)+","+string(SlowEMA)+","+string(SignalEMA)+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Oscillator                                                       |
//+------------------------------------------------------------------+
int start()
  {
   double prev,current;

   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1;
   
//---- macd counted in the 1-st additional buffer
   for(int i=0; i<limit; i++)
      ind_buffer3[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- signal line counted in the 2-nd additional buffer
   for(i=0; i<limit; i++)
      ind_buffer4[i]=iMAOnArray(ind_buffer3,Bars,SignalEMA,0,MODE_EMA, i);
//---- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=ind_buffer3[i]-ind_buffer4[i];
      prev=ind_buffer3[i+1]-ind_buffer4[i+1];
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up)
        {
         ind_buffer2[i]=3*current;
         ind_buffer1[i]=0.0;
        }
      else
        {
         ind_buffer1[i]=3*current;
         ind_buffer2[i]=0.0;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+