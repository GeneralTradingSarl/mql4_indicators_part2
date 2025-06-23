//+------------------------------------------------------------------+
//|                                   Multi Timeframe Moving Average |
//|                                       Copyright 2016, Il Anokhin |
//|                           http://www.mql5.com/en/users/ilanokhin |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Il Anokhin"
#property link "http://www.mql5.com/en/users/ilanokhin"
#property description ""
#property strict
//-------------------------------------------------------------------------
// Indicator settings
//-------------------------------------------------------------------------
#property  indicator_chart_window
#property  indicator_buffers 1
#property  indicator_color1 Blue
#property  indicator_width1 2
//-------------------------------------------------------------------------
// Inputs
//-------------------------------------------------------------------------
input ENUM_TIMEFRAMES TF = PERIOD_CURRENT;            //Moving Average Timeframe
input int PERIOD = 20;                                //Moving Average Period
input ENUM_MA_METHOD METHOD = MODE_SMA;               //Moving Average Method
input ENUM_APPLIED_PRICE PRICE = PRICE_CLOSE;         //Moving Average Applied Price
input int SHIFT = 0;                                  //Moving Average Shift
//-------------------------------------------------------------------------
// Variables
//-------------------------------------------------------------------------
double ma[];
//-------------------------------------------------------------------------
// 1. Initialization
//-------------------------------------------------------------------------
int OnInit(void)
  {
   IndicatorBuffers(1);
   SetIndexBuffer(0,ma);
   return(INIT_SUCCEEDED);
  }
//-------------------------------------------------------------------------
// 2. Deinitialization
//-------------------------------------------------------------------------
int deinit() {Comment(""); return(0);}
//-------------------------------------------------------------------------
// 3. Main function
//-------------------------------------------------------------------------
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
   int i,j,lim,cb;
   if(Bars<10) return(0);
   cb=IndicatorCounted();
   lim=Bars-cb;
   if(cb==0) lim=lim-11;
   if(cb>0) lim++;

//--- 3.1. Main loop ------------------------------------------------------
   j=0;
   for(i=0;i<lim;i++)
     {
      if(Time[i]<iTime(NULL,TF,j)) j++;
      ma[i]=iMA(NULL,TF,PERIOD,SHIFT,METHOD,PRICE,j);
     }

//--- 3.2. End of main function -------------------------------------------         
   return(rates_total);
  }
//-------------------------------------------------------------------------
