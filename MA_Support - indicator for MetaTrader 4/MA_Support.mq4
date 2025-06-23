/*------------------------------------------------------------------+
 |                                                   MA_Support.mq4 |
 |                                                 Copyright © 2010 |
 |                                             basisforex@gmail.com |
 +------------------------------------------------------------------*/
#property copyright "Copyright © 2010, basisforex@gmail.com"
#property link      "basisforex@gmail.com"
//----
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 White
#property indicator_color2 Yellow
#property indicator_color3 Orange
#property indicator_color4 Red
#property indicator_color5 Brown
#property indicator_color6 Green
#property indicator_color7 Blue
#property indicator_color8 Black
//----
extern int M1Period  = 13;
extern int M5Period  = 13;
extern int M15Period = 13;
extern int M30Period  = 13;
extern int H1Period  = 13;
extern int H4Period  = 13;
extern int D1Period  = 13;
extern int MnPeriod  = 13;
extern int MaShift   = 0;
extern int MODE_Ma   = 3;
extern int PRICE_Ma  = 6;
//----
double M1Buffer[];
double M5Buffer[];
double M15Buffer[];
double M30Buffer[];
double H1Buffer[];
double H4Buffer[];
double D1Buffer[];
double MnBuffer[];
//+------------------------------------------------------------------+
int init()
 {
   SetIndexShift(0, MaShift);
   SetIndexShift(1, MaShift);
   SetIndexShift(2, MaShift);
   SetIndexShift(3, MaShift);
   SetIndexShift(4, MaShift);
   SetIndexShift(5, MaShift);
   SetIndexShift(6, MaShift);
   SetIndexShift(7, MaShift);
//----
   SetIndexBuffer(0, M1Buffer);
   SetIndexBuffer(1, M5Buffer);
   SetIndexBuffer(2, M15Buffer);
   SetIndexBuffer(3, M30Buffer);
   SetIndexBuffer(4, H1Buffer);
   SetIndexBuffer(5, H4Buffer);
   SetIndexBuffer(6, D1Buffer);
   SetIndexBuffer(7, MnBuffer);
//----
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexStyle(5, DRAW_LINE);
   SetIndexStyle(6, DRAW_LINE);
   SetIndexStyle(7, DRAW_LINE);
//----
   SetIndexLabel(0, "M1");
   SetIndexLabel(1, "M5");
   SetIndexLabel(2, "M15");
   SetIndexLabel(3, "M30");
   SetIndexLabel(4, "H1");
   SetIndexLabel(5, "H4");
   SetIndexLabel(6, "D1");
   SetIndexLabel(7, "Mn");
//----
   return(0);
 }
//+------------------------------------------------------------------+
int start()
 {
   int limit;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;
   for(int i = 0; i < limit; i++)
    {
      M1Buffer[i]  = iMA(NULL, PERIOD_M1, M1Period, 0, MODE_Ma, PRICE_Ma, i);
      M5Buffer[i]  = iMA(NULL, PERIOD_M5, M5Period, 0, MODE_Ma, PRICE_Ma, i / PERIOD_M5);
      M15Buffer[i] = iMA(NULL, PERIOD_M15, M15Period, 0, MODE_Ma, PRICE_Ma, i / PERIOD_M15);
      M30Buffer[i] = iMA(NULL, PERIOD_M30, M30Period, 0, MODE_Ma, PRICE_Ma, i / PERIOD_M30);
      H1Buffer[i]  = iMA(NULL, PERIOD_H1, M30Period, 0, MODE_Ma, PRICE_Ma, i / PERIOD_H1);
      H4Buffer[i]  = iMA(NULL, PERIOD_H4, H1Period, 0, MODE_Ma, PRICE_Ma, i / PERIOD_H4);
      D1Buffer[i]  = iMA(NULL, PERIOD_D1, D1Period, 0, MODE_Ma, PRICE_Ma, i / PERIOD_D1);
      MnBuffer[i]  = iMA(NULL, PERIOD_MN1, MnPeriod, 0, MODE_Ma, PRICE_Ma, i / PERIOD_MN1);
    }  
   //-----
   return(0);
 }
//+------------------------------------------------------------------+

