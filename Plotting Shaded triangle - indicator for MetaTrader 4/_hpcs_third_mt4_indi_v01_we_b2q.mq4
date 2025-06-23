//+------------------------------------------------------------------+
//|                                  _HPCS_Third_MT4_Indi_V01_WE.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   if(ObjectCreate(0,"Triangle",OBJ_TRIANGLE,0,Time[0],Open[0],Time[2],Close[2],Time[3],Close[3]))
   {
      Print("Object Not Created");
   }
   ObjectSetInteger(0,"Triangle",OBJPROP_COLOR,clrOrange);
   ObjectSetInteger(0,"Triangle",OBJPROP_STYLE,DRAW_ZIGZAG);
   ObjectSetInteger(0,"Triangle",OBJPROP_WIDTH,5);
   ObjectSetInteger(0,"Triangle",OBJPROP_BACK,true);
   ObjectSetInteger(0,"Triangle",OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,"Triangle",OBJPROP_SELECTABLE,true);
   
      
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
