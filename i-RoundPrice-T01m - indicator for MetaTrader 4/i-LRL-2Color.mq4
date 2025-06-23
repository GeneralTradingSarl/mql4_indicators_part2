//+------------------------------------------------------------------+
//|                                            i-RoundPrice-T01m.mq4 |
//|          25.07.2006  Translated on MT4 by Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                    modification by maloma - maloma@datasvit.net  |
//+------------------------------------------------------------------+
/*[[
	Name := RoundPrice
	Author := Copyright © 2006, HomeSoft Tartan Corp.
	Link := spiky@transkeino.ru
	Separate Window := No
	First Color := Lime
	First Draw Type := Line
	First Symbol := 217
	Use Second Data := Yes
	Second Color := Red
	Second Draw Type := Line
	Second Symbol := 218
]]*/
#property copyright "Copyright © 2006, HomeSoft Tartan Corp."
#property link      "spiky@transkeino.ru"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrAqua
#property indicator_color2 clrRed
#property indicator_width1 2
#property indicator_width2 2
//------- Внешние параметры индикатора -------------------------------
extern int LRLPeriod=21;
extern int t3_period=21;
extern double b=0.7;
extern int mBar=300;
//------- Глобальные переменные индикатора ---------------------------
double dBuf0[],dBuf1[];
double LRLBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init()
  {
   IndicatorBuffers(3);
//---
   SetIndexBuffer(0,dBuf0);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(0,DRAW_LINE,EMPTY,2);
//---
   SetIndexBuffer(1,dBuf1);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_LINE,EMPTY,2);
//---
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,LRLBuffer);
//---
   IndicatorDigits(Digits);
   if(LRLPeriod<2) LRLPeriod=2;
   IndicatorShortName("T3 2 Color Linear Regression Line ("+(string)LRLPeriod+")");
   SetIndexDrawBegin(2,LRLPeriod+2);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+4);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start()
  {
   bool   ft=True;
   double e1,e2,e3,e4,e5,e6,c1,c2,c3,c4,n,w1,w2,b2,b3;
   double t3[];
   int    LoopBegin,shift,k;
   double sumx=0,sumy=0,sumxy=0,sumx2=0,sumy2=0;
   double m=0,yint=0,r=0;
//----
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) counted_bars=0;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=LRLPeriod;
   for(shift=limit-1; shift>=0; shift--)
     {
      sumx=0;
      sumy=0;
      sumxy=0;
      sumx2=0;
      sumy2=0;
      for(k=0; k<=LRLPeriod-1; k++)
        {
         sumx=sumx + k;
         sumy=sumy + Close[shift + k];
         sumxy=sumxy + k * Close[shift + k];
         sumx2=sumx2 + k * k;
         sumy2=sumy2 + Close[shift + k] * Close[shift + k];
        }
      m=(LRLPeriod*sumxy-sumx*sumy)/(LRLPeriod*sumx2-sumx*sumx);
      yint=(sumy+m*sumx)/LRLPeriod;
      r=(LRLPeriod*sumxy-sumx*sumy)/MathSqrt((LRLPeriod*sumx2-sumx*sumx)*(LRLPeriod*sumy2-sumy*sumy));
      LRLBuffer[shift]=yint-m*LRLPeriod;
     }
   if(mBar==0) LoopBegin=Bars-t3_period-1;
   else LoopBegin=mBar;
   LoopBegin=MathMin(LoopBegin,Bars-t3_period-1);
//----
   ArrayResize(t3,LoopBegin);
   if(ft)
     {
      b2=b*b;
      b3=b2*b;
      c1=-b3;
      c2=(3*(b2+b3));
      c3=-3*(2*b2+b+b3);
      c4=(1+3*b+b3+3*b2);
      n=t3_period;
      //----
      if(n<1) n=1;
      n=1+0.5*(n-1);
      w1=2/(n+1);
      w2=1-w1;
      ft=False;
     }
   for(shift=LoopBegin-2; shift>=0; shift--)
     {
      e1=w1*Close[shift]+w2*e1;
      e2=w1*e1+w2*e2;
      e3=w1*e2+w2*e3;
      e4=w1*e3+w2*e4;
      e5=w1*e4+w2*e5;
      e6=w1*e5+w2*e6;
      //----
      t3[shift]=c1*e6+c2*e5+c3*e4+c4*e3;
      if(t3[shift+1]<=t3[shift]) dBuf0[shift]=t3[shift]; else dBuf0[shift]=0;
      if(t3[shift+1]>t3[shift]) dBuf1[shift]=t3[shift]; else dBuf1[shift]=0;
     }
  }
//+------------------------------------------------------------------+
