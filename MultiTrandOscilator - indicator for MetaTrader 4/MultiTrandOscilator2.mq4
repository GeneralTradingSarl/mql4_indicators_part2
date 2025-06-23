//+------------------------------------------------------------------+
//|                                          MultiTrandOscilator.mq4 |
//|                                  Copyright © 2008, XrustSoftware |
//|                                        http://www.xrust.ucoz.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, XrustSoftware"
#property link      "http://www.xrust.ucoz.net"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 clrLime
#property indicator_color2 clrBlue
#property indicator_color3 clrGreen
#property indicator_color4 clrBlack
#property indicator_color5 clrRed
//---- input parameters
extern int    MaFast=169;
extern int    MaSlow=313;
extern int   LineWidth=2;
extern int    ModeMain=0;
extern int  ModeSignal=0;
extern int   PriseMain=0;
extern int PriseSignal=0;
extern bool  EURUSDJPY=true;
extern bool  EURUSDCHF=true;
extern bool     CHFJPY=true;
extern bool  EURCHFJPY=true;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if(EURUSDJPY){int a=0;}else{a=12;}
   if(EURUSDCHF){int b=0;}else{b=12;}
   if(CHFJPY)   {int c=0;}else{c=12;}
   if(EURCHFJPY){int d=0;}else{d=12;}
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,LineWidth);
   SetIndexBuffer(0,ExtMapBuffer1);
   //---
   SetIndexStyle(1,a,EMPTY,LineWidth);
   SetIndexBuffer(1,ExtMapBuffer2);
   //---
   SetIndexStyle(2,b,EMPTY,LineWidth);
   SetIndexBuffer(2,ExtMapBuffer3);
   //---
   SetIndexStyle(3,c,EMPTY,LineWidth);
   SetIndexBuffer(3,ExtMapBuffer4);
   //---
   SetIndexStyle(4,d,EMPTY,LineWidth);
   SetIndexBuffer(4,ExtMapBuffer5);
   //---
   IndicatorShortName("MultiTrandOscilator "+MaFast+" "+MaSlow+" ");
   //---
   SetIndexLabel(0,"EURUSD");
   SetIndexLabel(1,"EUR\JPY/USD\JPY");
   SetIndexLabel(2,"EUR\CHF/USD\CHF");
   SetIndexLabel(3,"(EUR\JPY/USD\JPY+EUR\CHF/USD\CHF)/2");
   SetIndexLabel(4,"EURUSD+(EUR\JPY/USD\JPY+EUR\CHF/USD\CHF)/3");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   int limit = Bars-counted_bars;
   if(counted_bars==0) limit--;
   if(limit>1000) limit=1000;
   for(int i=0;i<limit;i++)//Загоняем текущие значения МАшек в массив
     {
      double a = iMA("EURUSD",0,MaFast,0,ModeMain,PriseMain,i)-iMA("EURUSD",0,MaSlow,0,ModeMain,PriseMain,i);
      double b = iMA("EURJPY",0,MaFast,0,ModeSignal,PriseSignal,i)-iMA("EURJPY",0,MaSlow,0,ModeSignal,PriseSignal,i);
      double c = iMA("USDJPY",0,MaFast,0,ModeSignal,PriseSignal,i)-iMA("USDJPY",0,MaSlow,0,ModeSignal,PriseSignal,i);
      double d = iMA("EURCHF",0,MaFast,0,ModeSignal,PriseSignal,i)-iMA("EURCHF",0,MaSlow,0,ModeSignal,PriseSignal,i);
      double e = iMA("USDCHF",0,MaFast,0,ModeSignal,PriseSignal,i)-iMA("USDCHF",0,MaSlow,0,ModeSignal,PriseSignal,i);
      ExtMapBuffer1[i]=a;
      ExtMapBuffer2[i]=(b-c)/100;
      ExtMapBuffer3[i]=d-e;
      ExtMapBuffer4[i]=(d-e)+((b-c)/100)/2;
      ExtMapBuffer5[i]= (a+((b-c)/100)+(d-e))/3;
      Comment(a+"\n"+b+"\n"+c+"\n"+d+"\n"+e);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
