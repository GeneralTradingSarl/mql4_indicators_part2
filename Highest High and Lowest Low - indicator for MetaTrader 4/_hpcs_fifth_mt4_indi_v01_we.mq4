//+------------------------------------------------------------------+
//|                                  _HPCS_Fifth_MT4_Indi_V01_WE.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property script_show_inputs
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
input int igi_StartBar = 0;
input int igi_EndBar = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   int li_Highest = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,igi_EndBar,igi_StartBar);
   int li_Lowest = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,igi_EndBar,igi_StartBar);

   double li_High = iHigh(Symbol(),PERIOD_CURRENT,li_Highest);
   double li_Low = iLow(Symbol(),PERIOD_CURRENT,li_Lowest);
   string li_String = "Highest Value: "+DoubleToString(li_High,Digits())+" Lowest Valve:"+DoubleToString(li_Low,Digits());

   if(ObjectCreate(0,"Display",OBJ_LABEL,0,0,0))
     {
      Print("Object NOT Created");
     }
   ObjectSetInteger(0,"Display",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"Display",OBJPROP_WIDTH,5);
   ObjectSetInteger(0,"Display",OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,"Display",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"Display",OBJPROP_YDISTANCE,10);
   ObjectSetString(0,"Display",OBJPROP_TEXT,li_String);



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
