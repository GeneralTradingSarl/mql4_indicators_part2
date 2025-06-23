//+------------------------------------------------------------------+
//|                                                    i-HighLow.mq4 |
//|                                          Copyright © 2007, RickD |    
//|                                       Александър Пламенов Рядков |
//|                                            http://www.e2e-fx.net |
//+------------------------------------------------------------------+
#property copyright "© 2007 RickD"
#property link      "www.e2e-fx.net"
//----
#define major 1
#define minor 0
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  Gold
#property indicator_color2  DodgerBlue
//----
extern int N = 20;
extern int N2 = 5;
//----
double UpperBuf[];
double LowerBuf[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {       
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1);
//----   
   SetIndexDrawBegin(0, N);
   SetIndexDrawBegin(1, N);
//----
   SetIndexBuffer(0, UpperBuf);
   SetIndexBuffer(1, LowerBuf);
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
//----
   if(counted < 0) 
       return (-1);
//----  
   if(counted > 0) 
       counted--;
   int limit = Bars - counted;
//----  
   for(int i = 0; i < limit; i++) 
     {
       UpperBuf[i] = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, N, 
                           i)) + N2*Point;
       LowerBuf[i] = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, N, i)) - 
                          N2*Point;
     }
  }
//+------------------------------------------------------------------+

