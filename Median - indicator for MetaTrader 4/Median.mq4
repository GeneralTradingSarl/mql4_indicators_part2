//+------------------------------------------------------------------+
//|                                                       Median.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Rosh"
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Aqua
#property indicator_color2 Aqua
#property indicator_color3 Yellow
#property indicator_color4 Red
//----
extern int per=3;
extern int Dep=300;
extern double K_ATR=2.0;
extern int Period_ATR=13;
//---- indicator buffers
double UpBuffer[];
double DownBuffer[];
double MidlleBuffer[];
double SmoothMedian[];
//----
int ExtCountedBars=0;
int LastCalcTime=0;
int LastPeriod=0;
int shift=0;
double mmin=0;
double mmax=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,0);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   SetIndexStyle(1,DRAW_LINE);
   SetIndexShift(1,0);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexShift(2,0);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexShift(3,0);
//----
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DownBuffer);
   SetIndexBuffer(2,MidlleBuffer);
   SetIndexBuffer(3,SmoothMedian);
//----
   SetIndexLabel(0,"Hi");
   SetIndexLabel(1,"Low");
   SetIndexLabel(2,"Midlle");
   SetIndexLabel(3,"Signal");
//---- indicators
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double ATR;
   int counter;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(per,Period_ATR);

   for(shift=limit;shift>=1;shift--)
     {
      mmin=Low[Lowest(NULL,0,MODE_LOW,per,shift)];
      mmax=High[Highest(NULL,0,MODE_HIGH,per,shift)];
      ATR=0;
      for(counter=Period_ATR;counter>=1;counter--)
        {
         ATR=ATR+MathAbs(High[shift+counter]-Low[shift+counter]);
        }
      ATR=ATR/Period_ATR;
      MidlleBuffer[shift-1]=(mmax+mmin)/2;
      UpBuffer[shift-1]=MidlleBuffer[shift-1]+ATR*K_ATR;
      DownBuffer[shift-1]=MidlleBuffer[shift-1]-ATR*K_ATR;
     }
   for(shift=limit;shift>=1;shift--)
     {
      SmoothMedian[shift-1]=iMAOnArray(MidlleBuffer,0,5,0,MODE_EMA,shift-1);
     }
//----
//return;
  }
//+------------------------------------------------------------------+
