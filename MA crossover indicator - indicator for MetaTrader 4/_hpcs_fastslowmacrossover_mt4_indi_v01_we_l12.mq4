//+------------------------------------------------------------------+
//|                    _HPCS_FastSlowMACrossover_MT4_Indi_V01_WE.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property script_show_inputs

input int ii_fastMAPeriod = 14;   // Fast Moving Average Period
input int ii_slowMAPeriod = 21;   // Slow Moving Average Period

double gd_Arr_BuySignal[], gd_Arr_SellSignal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,gd_Arr_BuySignal);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,4,clrBlue);
   SetIndexArrow(0,233);
   SetIndexLabel(0,"Buy Signal");

   SetIndexBuffer(1,gd_Arr_SellSignal);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,4,clrRed);
   SetIndexArrow(1,234);
   SetIndexLabel(1,"Sell Signal");
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
   if(prev_calculated == 0)
     {
      for(int i = Bars-2; i>0; i--)
        {
         if(iMA(_Symbol,PERIOD_CURRENT,ii_fastMAPeriod,0,MODE_SMA,PRICE_CLOSE,i) < iMA(_Symbol,PERIOD_CURRENT,ii_slowMAPeriod,0,MODE_SMA,PRICE_CLOSE,i) && iMA(_Symbol,PERIOD_CURRENT,ii_fastMAPeriod,0,MODE_SMA,PRICE_CLOSE,i+1) >= iMA(_Symbol,PERIOD_CURRENT,ii_slowMAPeriod,0,MODE_SMA,PRICE_CLOSE,i+1))
           {
            gd_Arr_SellSignal[i] = High[i];
           }
         if(iMA(_Symbol,PERIOD_CURRENT,ii_fastMAPeriod,0,MODE_SMA,PRICE_CLOSE,i) > iMA(_Symbol,PERIOD_CURRENT,ii_slowMAPeriod,0,MODE_SMA,PRICE_CLOSE,i) && iMA(_Symbol,PERIOD_CURRENT,ii_fastMAPeriod,0,MODE_SMA,PRICE_CLOSE,i+1) <= iMA(_Symbol,PERIOD_CURRENT,ii_slowMAPeriod,0,MODE_SMA,PRICE_CLOSE,i+1))
           {
            gd_Arr_BuySignal[i] = Low[i];
           }
        }
     }

   if(iMA(_Symbol,PERIOD_CURRENT,ii_fastMAPeriod,0,MODE_SMA,PRICE_CLOSE,0) < iMA(_Symbol,PERIOD_CURRENT,ii_slowMAPeriod,0,MODE_SMA,PRICE_CLOSE,0) && iMA(_Symbol,PERIOD_CURRENT,ii_fastMAPeriod,0,MODE_SMA,PRICE_CLOSE,1) >= iMA(_Symbol,PERIOD_CURRENT,ii_slowMAPeriod,0,MODE_SMA,PRICE_CLOSE,1))
     {
      gd_Arr_SellSignal[0] = High[0];
     }
   if(iMA(_Symbol,PERIOD_CURRENT,ii_fastMAPeriod,0,MODE_SMA,PRICE_CLOSE,0) > iMA(_Symbol,PERIOD_CURRENT,ii_slowMAPeriod,0,MODE_SMA,PRICE_CLOSE,0) && iMA(_Symbol,PERIOD_CURRENT,ii_fastMAPeriod,0,MODE_SMA,PRICE_CLOSE,1) <= iMA(_Symbol,PERIOD_CURRENT,ii_slowMAPeriod,0,MODE_SMA,PRICE_CLOSE,1))
     {
      gd_Arr_BuySignal[0] = Low[0];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
