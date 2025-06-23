//+------------------------------------------------------------------+
//|                                _HPCS_Seventh_MT4_Indi_V01_WE.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double gd_Arr1_Signal[];
double gd_Arr2_Signal[];

int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,gd_Arr1_Signal);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,5,clrRed);
   SetIndexArrow(0,225);
   
   SetIndexBuffer(1,gd_Arr2_Signal);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,5,clrRed);
   SetIndexArrow(1,226);
   
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
   if(High[2]>High[1] && High[2]>High[3])
   {
      gd_Arr1_Signal[0] = High[2]; 
   }
   if(Low[2]<Low[1] && Low[2]<Low[3])
   {
      gd_Arr2_Signal[1] = Low[2]; 
   }


   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
