//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "© 2007 RickD"
#property link      "www.e2e-fx.net"

#define major   1
#define minor   0

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  Gold

extern int MA_Period=25;

double MABuf[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init()
  {
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexDrawBegin(0,MA_Period);
   SetIndexBuffer(0,MABuf);

   IndicatorShortName("AMMA ("+MA_Period+")");
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() 
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;

   for(int i=limit; i>=0; i--)
     {
      if(i==Bars-1)
         MABuf[i]=Close[i];
      else
         MABuf[i]=((MA_Period-1)*MABuf[i+1]+Close[i])/MA_Period;
     }
  }
//+------------------------------------------------------------------+
