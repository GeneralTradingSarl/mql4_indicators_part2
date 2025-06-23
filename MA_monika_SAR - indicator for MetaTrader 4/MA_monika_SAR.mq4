/*------------------------------------------------------------------+
 |                                            MA_monika_SAR.mq4.mq4 |
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
extern int        n0Period    = 13;
extern int        n1Period    = 13;
extern int        n2Period    = 13;
extern int        n3Period    = 13;
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
   return(0);
 }
//+------------------------------------------------------------------+
void GetNextTF(int curTF, int &tf1, int &tf2, int &tf3)
  {
   switch(curTF)
     {
      case 1:
         tf1=5; tf2=15; tf3=30;
         break;
      case 5:
         tf1=15; tf2=30; tf3=60;
         break;
      case 15:
         tf1=30; tf2=60; tf3=240;
         break;
      case 30:
         tf1=60; tf2=240; tf3=1440;
         break;
      case 60:
         tf1=240; tf2=1440; tf3=10080;
         break;
      case 240:
         tf1=1440; tf2=10080; tf3=43200;
         break;
     }
  }
//+------------------------------------------------------------------+
int start()
 {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
   //-----
   int tf1 = 0;
   int tf2 = 0;
   int tf3 = 0;
   GetNextTF(Period(),tf1,tf2,tf3);
   Comment(tf1, " Yellow  ", "\n", tf2, " Blue ", "\n", tf3, " Black");
   //-----
   for(int i = 0; i < limit; i++)
    {
      M1ma[i]   = iMA(NULL, Period(), n0Period, 0, MODE_Ma, PRICE_Ma, i);
      if (tf1!=0) M5ma[i]   = iMA(NULL, tf1, n1Period, 0, MODE_Ma, PRICE_Ma, i / (tf1 / Period()));
      if (tf2!=0) H1ma[i]   = iMA(NULL, tf2, n2Period, 0, MODE_Ma, PRICE_Ma, i / (tf2 / Period()));
      if (tf3!=0) D1ma[i]   = iMA(NULL, tf3, n3Period, 0, MODE_Ma, PRICE_Ma, i / (tf3 / Period()));
      //-----
      M1sar[i]  = iSAR(NULL, Period(), Step, Maximum, i);
      if (tf1!=0) M5sar[i]  = iSAR(NULL, tf1, Step, Maximum, i / (tf1 / Period()));
      if (tf2!=0) H1sar[i]  = iSAR(NULL, tf2, Step, Maximum, i / (tf2 / Period()));
      if (tf3!=0) D1sar[i]  = iSAR(NULL, tf3, Step, Maximum, i / (tf3 / Period()));
    }  
   //-----
   return(0);
 }
//+------------------------------------------------------------------+

