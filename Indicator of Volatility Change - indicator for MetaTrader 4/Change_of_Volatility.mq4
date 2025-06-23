//+------------------------------------------------------------------+
//|                                         Change of Volatility.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- input parameters
extern int       Short=6;
extern int       Long=100;
//---- buffers
double HVBuffer[];
double Moment[];
double LongLog[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,HVBuffer);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,Moment);

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
   int  i,limit=0,limit2=0, counted_bars=IndicatorCounted();
//----
   if (counted_bars==0)
      {
      limit=Bars-2;
      limit2=Bars-Long-1;
      }
   if (counted_bars>0)
      {
      limit=Bars-counted_bars;
      limit2=limit;
      }
      
   for (i=limit;i>=0;i--) Moment[i]=iMomentum(NULL,0,1,PRICE_CLOSE,i)/100;         
   for (i=limit2;i>=0;i--) HVBuffer[i]=iStdDevOnArray(Moment,0,Short,0,MODE_SMA,i)/iStdDevOnArray(Moment,0,Long,0,MODE_SMA,i);
//----
   return(0);
  }
//+------------------------------------------------------------------+