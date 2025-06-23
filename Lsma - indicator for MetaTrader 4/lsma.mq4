//+------------------------------------------------------------------+
//|                                                                  |
//|                 Copyright © 2000-2007, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
// LSMA.mq4
// Least Squares Moving Average

#property link "mandorr@gmail.com"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

extern int period=50;
extern int CountBars=10000;   // Количество отображаемых баров

double buffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexBuffer(0,buffer);
   SetIndexLabel(0,"Value");
   SetIndexDrawBegin(0,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   int counted_bars=IndicatorCounted();
   int limit=Bars-counted_bars;
   if(counted_bars==0)
     {
      limit-=(period+1);
      limit=MathMin(CountBars,limit);
     }
   for(int i=0; i<limit; i++)
     {
      buffer[i]=LSMA(period,i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LSMA(int ma_period,int shift)
  {
   double lengthvar;
   double tmp;
   double sum=0;
   for(int i=ma_period; i>=1; i--)
     {
      lengthvar=(ma_period+1)/3;
      tmp=(i-lengthvar)*Close[ma_period-i+shift];
      sum+=tmp;
     }
   double value=sum*6/(ma_period*(ma_period+1));
   return(value);
  }
//+------------------------------------------------------------------+
