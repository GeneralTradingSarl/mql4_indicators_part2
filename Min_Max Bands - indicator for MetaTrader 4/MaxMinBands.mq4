//+------------------------------------------------------------------+
//|                                                  MaxMinBands.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Julien Loutre"
#property link      "http://www.zenhop.com"
//---- indicator settings
#property  indicator_chart_window
#property indicator_buffers  2
#property  indicator_color1  LightSkyBlue
#property  indicator_color2  Plum

//---- input parameters


extern int       Band_Period   = 120;


//---- buffers
double WWBuffer1[];
double WWBuffer2[];

double ATR;

int init() {
   IndicatorBuffers(2);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   IndicatorDigits(Digits+2);

   SetIndexBuffer(0, WWBuffer1);
   SetIndexBuffer(1, WWBuffer2);
   
   IndicatorShortName("Min/Max Bands");
   
   
   return(0);
  }
int start() {
   int    limit,i;
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+Band_Period;      
   
   for(i=limit-1; i>=0; i--) {

      WWBuffer1[i] = getPeriodHigh(Band_Period,i);
      WWBuffer2[i] = getPeriodLow(Band_Period,i);
     
   }
   return(0);
}

double getPeriodHigh(int period, int pos) {
   int i;
   double buffer = 0;
   for (i=pos;i<=pos+period;i++) {
      if (High[i] > buffer) {
         buffer = High[i];
      }
   }
   return (buffer);
}
double getPeriodLow(int period, int pos) {
   int i;
   double buffer = 100000;
   for (i=pos;i<=pos+period;i++) {
      if (Low[i] < buffer) {
         buffer = Low[i];
      }
   }
   return (buffer);
}--------------------------+
//| getPeriodHigh                                                    |
//+------------------------------------------------------------------+
double getPeriodHigh(int period,int pos) 
  {
   int i;
   double buffer=0;
   for(i=pos;i<=pos+period;i++) 
     {
      if(High[i]>buffer) 
        {
         buffer=High[i];
        }
     }
   return (buffer);
  }
//+------------------------------------------------------------------+
//| getPeriodLow                                                     |
//+------------------------------------------------------------------+
double getPeriodLow(int period,int pos) 
  {
   int i;
   double buffer=100000;
   for(i=pos;i<=pos+period;i++) 
     {
      if(Low[i]<buffer) 
        {
         buffer=Low[i];
        }
     }
   return (buffer);
  }
//+------------------------------------------------------------------+
