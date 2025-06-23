//+------------------------------------------------------------------+
//|                                       ind - Profitunity Bars.mq4 |
//|                                 Copyright © 2006, Andrew Suvorov |
//|                                                    trade@sibp.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Andrew Suvorov"
#property link      "trade@sibp.ru"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2
//----
double buf1[];
double buf2[];
//----
extern int       nAccountedBars=300;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,buf1);
   SetIndexDrawBegin(0,0);
   // 
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,buf2);
   SetIndexDrawBegin(1,0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   for(int CurrentBar=0;CurrentBar<=nAccountedBars;CurrentBar++)
     {

      if(iAO(Symbol(),0,CurrentBar) > iAO(Symbol(),0,CurrentBar+1) &&
         iAC(Symbol(),0,CurrentBar) > iAC(Symbol(),0,CurrentBar+1))
        {
         buf1[CurrentBar]=High[CurrentBar];
         buf2[CurrentBar]=Low[CurrentBar];
        }
      if(iAO(Symbol(),0,CurrentBar) < iAO(Symbol(),0,CurrentBar+1) &&
         iAC(Symbol(),0,CurrentBar) < iAC(Symbol(),0,CurrentBar+1))
        {
         buf1[CurrentBar]=Low[CurrentBar];
         buf2[CurrentBar]=High[CurrentBar];
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+