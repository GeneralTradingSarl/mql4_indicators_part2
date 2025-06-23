//+------------------------------------------------------------------+
//|                                                    iAnchMom.mq4  |
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Teal
//---- input parameters
extern int EMA_period=34;
extern int MomPeriod=120;
//---- buffers
double MomBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(1);
   SetIndexBuffer(0, MomBuffer);
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2,Teal);
   SetIndexDrawBegin(0,MomPeriod + MomPeriod + 1);
//---- name for DataWindow and indicator subwindow label
   short_name="iAnchMom("+MomPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| AnchMom                                                          |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
   double a,b;
   int SMA_Period=MomPeriod + MomPeriod + 1;
//----
   if(Bars<=SMA_Period) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=SMA_Period;i++) MomBuffer[Bars-i]=0.0;
//----
   i=Bars-SMA_Period-1;
   if(counted_bars>=SMA_Period) i=Bars-counted_bars-1;
   while(i>=0)
     {
      a=iMA(NULL,0,EMA_period,0, MODE_EMA,PRICE_CLOSE, i);
      b=iMA(NULL,0,SMA_Period,0, MODE_SMA, PRICE_CLOSE, i);
      MomBuffer[i]= 100*((a/b)-1);
      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+