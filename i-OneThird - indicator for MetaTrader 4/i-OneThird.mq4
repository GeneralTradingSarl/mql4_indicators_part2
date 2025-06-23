//+------------------------------------------------------------------+
//|                                                   i-OneThird.mq4 |
//|                                          Copyright © 2007, RickD |
//|                                                   www.e2e-fx.net |
//+------------------------------------------------------------------+
#property copyright "© 2007 RickD"
#property link      "www.e2e-fx.net"
//----
#define major   1
#define minor   0
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 OrangeRed
#property indicator_color2 DodgerBlue
#property indicator_color3 OrangeRed
#property indicator_color4 DodgerBlue
//----
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexBuffer(3, ExtMapBuffer4);
//----        
   SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0, 1);
   SetIndexStyle(2, DRAW_HISTOGRAM, 0, 3);
   SetIndexStyle(3, DRAW_HISTOGRAM, 0, 3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   int counted = IndicatorCounted();
   if(counted < 0) 
     return (-1);
//----  
   if (counted > 0) 
     counted--;
   int limit = Bars-counted;
//----  
   for(int i = 0; i < limit; i++) 
     {
       double third = (High[i] - Low[i]) / 3;
       //----
       if(Close[i] > High[i] - third)
         {
           ExtMapBuffer1[i] = Low[i];
           ExtMapBuffer2[i] = High[i];
           ExtMapBuffer3[i] = MathMin(Open[i], Close[i]);
           ExtMapBuffer4[i] = MathMax(Open[i], Close[i]);
         } 
       //----
       if(Close[i] < Low[i] + third)
         {
           ExtMapBuffer1[i] = High[i];
           ExtMapBuffer2[i] = Low[i];
           ExtMapBuffer3[i] = MathMax(Open[i], Close[i]);
           ExtMapBuffer4[i] = MathMin(Open[i], Close[i]);
         }
     }
  }  
//+------------------------------------------------------------------+

