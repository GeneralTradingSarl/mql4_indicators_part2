//+------------------------------------------------------------------+
//|                                                         PEMA.mq4 |
//+------------------------------------------------------------------+
#property copyright "Bruno Pio"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
#property  indicator_width1  2
//---- input parameters
extern int       EMA_period=14;
//---- buffers
double PemaBuffer[];
double Ema[];
double EmaOfEma[];
double EmaOfEmaOfEma[];
double EmaOfEmaOfEmaOfEma[];
double EmaOfEmaOfEmaOfEmaOfEma[];
double EmaOfEmaOfEmaOfEmaOfEmaOfEma[];
double Ema7[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,PemaBuffer);
   SetIndexBuffer(1,Ema);
   SetIndexBuffer(2,EmaOfEma);
   SetIndexBuffer(3,EmaOfEmaOfEma);
   SetIndexBuffer(4,EmaOfEmaOfEmaOfEma);
   SetIndexBuffer(5,EmaOfEmaOfEmaOfEmaOfEma);
   SetIndexBuffer(6,EmaOfEmaOfEmaOfEmaOfEmaOfEma);
   SetIndexBuffer(7,Ema7);

   IndicatorShortName("PEMA("+EMA_period+")");
   
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
   int i,limit,limit2,limit3,limit4,limit5,limit6,limit7,limit8,counted_bars=IndicatorCounted();
//----
   if (counted_bars==0)
      {
      limit=Bars-1;
      limit2=limit-EMA_period;
      limit3=limit2-EMA_period;
      limit4=limit3-EMA_period;
      limit5=limit4-EMA_period;
      limit6=limit5-EMA_period;
      limit7=limit6-EMA_period;
      limit8=limit7-EMA_period;
      }
   if (counted_bars>0)
      {
      limit=Bars-counted_bars-1;
      limit2=limit;
      limit3=limit2;
      limit4=limit3;
      limit5=limit4;
      limit6=limit5;
      limit7=limit6;
      limit8=limit7;
      }
   for (i=limit;i>=0;i--) Ema[i]=iMA(NULL,0,EMA_period,0,MODE_EMA,PRICE_CLOSE,i);
   for (i=limit2;i>=0;i--) EmaOfEma[i]=iMAOnArray(Ema,0,EMA_period,0,MODE_EMA,i);
   for (i=limit3;i>=0;i--) EmaOfEmaOfEma[i]=iMAOnArray(EmaOfEma,0,EMA_period,0,MODE_EMA,i);
   for (i=limit4;i>=0;i--) EmaOfEmaOfEmaOfEma[i]=iMAOnArray(EmaOfEmaOfEma,0,EMA_period,0,MODE_EMA,i);
   for (i=limit5;i>=0;i--) EmaOfEmaOfEmaOfEmaOfEma[i]=iMAOnArray(EmaOfEmaOfEmaOfEma,0,EMA_period,0,MODE_EMA,i);
   for (i=limit6;i>=0;i--) EmaOfEmaOfEmaOfEmaOfEmaOfEma[i]=iMAOnArray(EmaOfEmaOfEmaOfEmaOfEma,0,EMA_period,0,MODE_EMA,i);
   for (i=limit7;i>=0;i--) Ema7[i]=iMAOnArray(EmaOfEmaOfEmaOfEmaOfEmaOfEma,0,EMA_period,0,MODE_EMA,i);
   //for (i=limit8;i>=0;i--) EmaOfEmaOfEmaOfEmaOfEmaOfEmaOfEmaOfEma[i]=iMAOnArray(Ema7,0,EMA_period,0,MODE_EMA,i);
   
   for (i=limit8;i>=0;i--) PemaBuffer[i]=8*Ema[i]-28*EmaOfEma[i]+56*EmaOfEmaOfEma[i]-70*EmaOfEmaOfEmaOfEma[i]+56*EmaOfEmaOfEmaOfEmaOfEma[i]-28*EmaOfEmaOfEmaOfEmaOfEmaOfEma[i]+8*Ema7[i]-iMAOnArray(Ema7,0,EMA_period,0,MODE_EMA,i);
//----
   return(0);
  }
//+------------------------------------------------------------------+