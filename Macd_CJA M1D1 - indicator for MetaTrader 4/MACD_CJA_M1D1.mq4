//+------------------------------------------------------------------+
//|                                                 MACD# MTF CJA.mq4|
//|                       Copyright © 2006, MetaQuotes Software Corp.|
//|                                         by CJA www.forex-tsd.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property link      "cja"
//----
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 DeepSkyBlue
#property indicator_color4 DeepSkyBlue
#property indicator_color5 Orange
#property indicator_color6 Maroon
#property indicator_color7 Green
#property indicator_color8 LawnGreen
#property indicator_width1 2
#property indicator_style2 2
#property indicator_width3 1
#property indicator_style4 2
#property indicator_width5 1
#property indicator_style6 0
#property indicator_width7 1
#property indicator_style8 0
#property indicator_level1 0
#property indicator_width6 2
//---- input parameters
extern int       FastEMA=12;  //8  Faster settings
extern int       SlowEMA=26;  //17
extern int       SignalSMA=9; //9 
// Different Currencies may need different Factors to help
// separate the different MACD lines - raise the Factor # on the 
// largest moving MACD lines to enlarge the view of the other 3 MACD Timeframes.
extern double    MACD_FactorD1=48;
extern double    MACD_FactorH4=24;
extern double    MACD_FactorH1 =12;
extern double    MACD_FactorM15=6;
extern double    MACD_FactorM5=2;
extern double    MACD_FactorM1=1;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {  IndicatorShortName("MACD MTF");
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,ExtMapBuffer8);
//----
   SetIndexLabel(0,"MACD_H4");
   SetIndexLabel(1,"MACD_H4");
   SetIndexLabel(2,"MACD_H1");
   SetIndexLabel(3,"MACD_H1");
   SetIndexLabel(4,"MACD_m15");
   SetIndexLabel(5,"MACD_D1");
   SetIndexLabel(6,"MACD_M5");
   SetIndexLabel(7,"MACD_M1");
//---- MACD CJA
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   IndicatorShortName("MACD MTF");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   // Start of LABELS
   double MyFValue=Period();
   ObjectCreate("MACDMTF4", OBJ_LABEL, WindowFind("MACD MTF"), 0, 0);
   ObjectSetText("MACDMTF4",DoubleToStr(MyFValue,Digits-4), 15, "Arial", DarkTurquoise);
   ObjectSet("MACDMTF4", OBJPROP_CORNER, 0);
   ObjectSet("MACDMTF4", OBJPROP_XDISTANCE, 430);
   ObjectSet("MACDMTF4", OBJPROP_YDISTANCE, 0);
   ObjectCreate("MACDMTF5", OBJ_LABEL, WindowFind("MACD MTF"), 0, 0);//1hr
   ObjectSetText("MACDMTF5","Curr Period", 12, "Arial",DarkTurquoise);
   ObjectSet("MACDMTF5", OBJPROP_CORNER, 0);
   ObjectSet("MACDMTF5", OBJPROP_XDISTANCE, 340);
   ObjectSet("MACDMTF5", OBJPROP_YDISTANCE, 0);
//----
   ObjectCreate("MACDMTF0", OBJ_LABEL, WindowFind("MACD MTF"), 0, 0);//4hr
   ObjectSetText("MACDMTF0","D1", 15, "Arial",Maroon );
   ObjectSet("MACDMTF0", OBJPROP_CORNER, 0);
   ObjectSet("MACDMTF0", OBJPROP_XDISTANCE, 500);
   ObjectSet("MACDMTF0", OBJPROP_YDISTANCE, 0);
//----
   ObjectCreate("MACDMTF", OBJ_LABEL, WindowFind("MACD MTF"), 0, 0);//1hr
   ObjectSetText("MACDMTF","H4", 15, "Arial",Red );
   ObjectSet("MACDMTF", OBJPROP_CORNER, 0);
   ObjectSet("MACDMTF", OBJPROP_XDISTANCE, 540);
   ObjectSet("MACDMTF", OBJPROP_YDISTANCE, 0);
   ObjectCreate("MACDMTF1", OBJ_LABEL, WindowFind("MACD MTF"), 0, 0);//15min
   ObjectSetText("MACDMTF1","H1", 15, "Arial", DodgerBlue);
   ObjectSet("MACDMTF1", OBJPROP_CORNER, 0);
   ObjectSet("MACDMTF1", OBJPROP_XDISTANCE, 580);
   ObjectSet("MACDMTF1", OBJPROP_YDISTANCE, 0);
   ObjectCreate("MACDMTF2", OBJ_LABEL, WindowFind("MACD MTF"), 0, 0);//5min
   ObjectSetText("MACDMTF2","M15", 15, "Arial", Orange);
   ObjectSet("MACDMTF2", OBJPROP_CORNER, 0);
   ObjectSet("MACDMTF2", OBJPROP_XDISTANCE, 640);
   ObjectSet("MACDMTF2", OBJPROP_YDISTANCE, 0);
   ObjectCreate("MACDMTF3", OBJ_LABEL, WindowFind("MACD MTF"), 0, 0);//1min
   ObjectSetText("MACDMTF3","M5", 15, "Arial",Green );
   ObjectSet("MACDMTF3", OBJPROP_CORNER, 0);
   ObjectSet("MACDMTF3", OBJPROP_XDISTANCE, 690);
   ObjectSet("MACDMTF3", OBJPROP_YDISTANCE, 0);
//----
   ObjectCreate("MACDMTF6", OBJ_LABEL, WindowFind("MACD MTF"), 0, 0);//1min
   ObjectSetText("MACDMTF6","M1", 15, "Arial",LawnGreen);
   ObjectSet("MACDMTF6", OBJPROP_CORNER, 0);
   ObjectSet("MACDMTF6", OBJPROP_XDISTANCE, 730);
   ObjectSet("MACDMTF6", OBJPROP_YDISTANCE, 0);
   // End of LABELS
//----
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
   
     for(int i=limit;i>=0;i--)
     {
      ExtMapBuffer1[i]=(iMACD(NULL,PERIOD_H4,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/MACD_FactorH4);
      ExtMapBuffer2[i]=(iMACD(NULL,PERIOD_H4,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i)/MACD_FactorH4);
      ExtMapBuffer3[i]=(iMACD(NULL,PERIOD_H1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/MACD_FactorH1);
      ExtMapBuffer4[i]=(iMACD(NULL,PERIOD_H1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i)/MACD_FactorH1);
      ExtMapBuffer5[i]=(iMACD(NULL,PERIOD_M15,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/MACD_FactorM15);
      ExtMapBuffer6[i]=(iMACD(NULL,PERIOD_D1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/MACD_FactorD1);
      ExtMapBuffer7[i]=(iMACD(NULL,PERIOD_M5,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/MACD_FactorM5);
      ExtMapBuffer8[i]=(iMACD(NULL,PERIOD_M1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/MACD_FactorM1);
     }
   return(0);
  }
//----
//+------------------------------------------------------------------+