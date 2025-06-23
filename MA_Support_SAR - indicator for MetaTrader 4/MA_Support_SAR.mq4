/*------------------------------------------------------------------+
 |                                               MA_Support_SAR.mq4 |
 |                                                 Copyright © 2010 |
 |                                             basisforex@gmail.com |
 +------------------------------------------------------------------*/
#property copyright "Copyright © 2010, basisforex@gmail.com"
#property link      "basisforex@gmail.com"
//-----
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 White
#property indicator_color2 Yellow
#property indicator_color3 Blue
#property indicator_color4 Black
#property indicator_color5 White
#property indicator_color6 Yellow
#property indicator_color7 Blue
#property indicator_color8 Black
//-----
extern int        M1Period    = 13;
extern int        M5Period    = 13;
extern int        H1Period    = 13;
extern int        D1Period    = 13;
//-----
extern int        MaShift     = 0;
extern int        MODE_Ma     = 3;
extern int        PRICE_Ma    = 6;
//-----
extern double     Step        = 0.02;
extern double     Maximum     = 0.2;
//-----
double M1ma[];
double M5ma[];
double H1ma[];
double D1ma[];
double M1sar[];
double M5sar[];
double H1sar[];
double D1sar[];
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
   //-----
   SetIndexBuffer(0, M1ma);
   SetIndexBuffer(1, M5ma);
   SetIndexBuffer(2, H1ma);
   SetIndexBuffer(3, D1ma);
   SetIndexBuffer(4, M1sar);
   SetIndexBuffer(5, M5sar);
   SetIndexBuffer(6, H1sar);
   SetIndexBuffer(7, D1sar);
   //-----
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4, 159);
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(5, 159);
   SetIndexStyle(6, DRAW_ARROW);
   SetIndexArrow(6, 159);
   SetIndexStyle(7, DRAW_ARROW);
   SetIndexArrow(7, 159);
   //-----
   SetIndexLabel(0, "M1-MA");
   SetIndexLabel(1, "M5-MA");
   SetIndexLabel(2, "H1-MA");
   SetIndexLabel(3, "D1-MA");
   SetIndexLabel(4, "M1-SAR");
   SetIndexLabel(5, "M5-SAR");
   SetIndexLabel(6, "H1-SAR");
   SetIndexLabel(7, "D1-SAR");
   //-----
   return(0);
 }
//+------------------------------------------------------------------+
int start()
 {
   if (Period() != 1)
    {
		Comment("Not a right Period!!! It should be M1");
		return(0);	
	 }
   int limit;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;
   for(int i = 0; i < limit; i++)
    {
      M1ma[i]   = iMA(NULL, PERIOD_M1, M1Period, 0, MODE_Ma, PRICE_Ma, i);
      M5ma[i]   = iMA(NULL, PERIOD_M5, M5Period, 0, MODE_Ma, PRICE_Ma, i / PERIOD_M5);
      H1ma[i]   = iMA(NULL, PERIOD_H1, H1Period, 0, MODE_Ma, PRICE_Ma, i / PERIOD_H1);
      D1ma[i]   = iMA(NULL, PERIOD_D1, D1Period, 0, MODE_Ma, PRICE_Ma, i / PERIOD_D1);
      //-----
      M1sar[i]  = iSAR(NULL, PERIOD_M1, Step, Maximum, i);
      M5sar[i]  = iSAR(NULL, PERIOD_M5, Step, Maximum, i / PERIOD_M5);
      H1sar[i]  = iSAR(NULL, PERIOD_H1, Step, Maximum, i / PERIOD_H1);
      D1sar[i]  = iSAR(NULL, PERIOD_D1, Step, Maximum, i / PERIOD_D1);
    }  
   //-----
   return(0);
 }
//+------------------------------------------------------------------+

