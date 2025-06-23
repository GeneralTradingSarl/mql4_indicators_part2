//+------------------------------------------------------------------+
//|                                                     iMA_Fibs.mq4 |
//|                                Copyright © 2006, Robert L Hill   |
//|                                     mailto:robydoby314@yahoo.com |
//+------------------------------------------------------------------+
// This indicator allows selection of MA type and sets levels based on Fib values
// Added MAType 4 to use LSMA
#property copyright "Copyright © 2005, Metaquotes"
#property link      "mailto:metaquotes@metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Red
#property indicator_width1  2
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1
//---- input parameters
extern int       MAPeriod=14;
extern int       MAType=1;
extern int fibo1=23;
extern int fibo2=38;
extern int fibo3=50;
extern int fibo4=62;
extern int fibo5=76;
extern int fibo6=100;
extern int fibo7=127;
//---- buffers
double LineBuffer[];
double Fib1[];
double Fib2[];
double Fib3[];
double Fib4[];
double Fib5[];
double Fib6[];
double Fib7[];
//---- variables
int    MAMode;
string strMAType;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,LineBuffer);
   SetIndexDrawBegin(0,MAPeriod);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Fib1);
   SetIndexDrawBegin(1,MAPeriod);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Fib2);
   SetIndexDrawBegin(2,MAPeriod);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Fib3);
   SetIndexDrawBegin(3,MAPeriod);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Fib4);
   SetIndexDrawBegin(4,MAPeriod);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Fib5);
   SetIndexDrawBegin(5,MAPeriod);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,Fib6);
   SetIndexDrawBegin(6,MAPeriod);
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,Fib7);
   SetIndexDrawBegin(7,MAPeriod);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName( strMAType+ " (" +MAPeriod + ") ");
//----
   switch(MAType)
     {
      case 1: strMAType="EMA"; MAMode=MODE_EMA; break;
      case 2: strMAType="SMMA"; MAMode=MODE_SMMA; break;
      case 3: strMAType="LWMA"; MAMode=MODE_LWMA; break;
      case 4: strMAType="LSMA"; break;
      default: strMAType="SMA"; MAMode=MODE_SMA; break;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LSMA(int Rperiod, int shift)
  {
   int i;
   double sum;
   int length;
   double lengthvar;
   double tmp;
   double wt;
//---
   length=Rperiod;
   sum=0;
   for(i=length; i>=1 ;i--)
     {
      lengthvar=length + 1;
      lengthvar/=3;
      tmp=0;
      tmp =(i - lengthvar)*Close[length-i+shift];
      sum+=tmp;
     }
   wt=sum*6/(length*(length+1));
   return(wt);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double MA;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+MAPeriod;
//----
   for(int i=limit; i>=0; i--)
     {
      if (MAType==4)
        {
         MA=LSMA(MAPeriod,i);
        }
      else
        {
         MA=iMA(NULL,0,MAPeriod,0,MAMode,PRICE_CLOSE,i);
        }
      LineBuffer[i]=MA;
      Fib1[i]=MA + fibo1*Point;
      Fib2[i]=MA + fibo2*Point;
      Fib3[i]=MA + fibo3*Point;
      Fib4[i]=MA + fibo4*Point;
      Fib5[i]=MA + fibo5*Point;
      Fib6[i]=MA + fibo6*Point;
      Fib7[i]=MA + fibo7*Point;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+