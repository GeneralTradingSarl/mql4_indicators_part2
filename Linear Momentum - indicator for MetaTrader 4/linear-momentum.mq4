//+------------------------------------------------------------------+
//|                                              Linear Momentum.mq4 |
//|                                Copyright 2015, Totom Sukopratomo |
//|                                       https://www.mqlmonster.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Totom Sukopratomo"
#property link      "https://www.mqlmonster.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_level1  0.0
//--- plot MoLin
#property indicator_label1  "Linear Momentum"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

input int            SmoothingPeriod=14;        // Smoothing Period
input ENUM_MA_METHOD SmoothingMethod=MODE_EMA;  // Smoothing Method
//--- indicator buffers
double         LinearMomentumBuffer[];
double         Velocity[];
double         Temporary[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(3);
   SetIndexBuffer(0,LinearMomentumBuffer);
   SetIndexBuffer(1,Velocity);
   SetIndexBuffer(2,Temporary);
   SetIndexDrawBegin(0,SmoothingPeriod);
   IndicatorDigits(1);
   IndicatorShortName("LM ("+IntegerToString(SmoothingPeriod)+")");
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
//--- Set arrays as series for easier calculation
   ArraySetAsSeries(LinearMomentumBuffer,true);
   ArraySetAsSeries(Velocity,true);
   ArraySetAsSeries(Temporary,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Not all candles will be recounted on every incoming tick
   int limit;
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
     {
      limit++;
     }
   else
     {
      limit--;
     }
//--- Calculate Velocity
   for(int x=0; x<limit; x++)
     {
      int _Seconds;
      if(x>0)
        {
         _Seconds=(int)(time[x]-time[x+1]);
        }
      else
        {
         _Seconds=(int)(TimeCurrent()-time[x]);
        }
      double Distance;
      if(NormalizeDouble(close[x]-open[x],8)!=0.00000000) 
        {
         Distance=(close[x]-open[x])/_Point;
        }
      else 
        {
         Distance=0.0;
        }
      if(NormalizeDouble(Distance,8)!=0.00000000 && _Seconds!=0)
        {
         Velocity[x]=Distance/_Seconds;
        }
      else
        {
         Velocity[x]=0.0;
        }
     }
//--- Calculate Momentum Linear
   for(int x=0; x<limit; x++)
     {
      Temporary[x]=tick_volume[x]*Velocity[x];
     }
//--- Do smooth Momentum Linear
   for(int x=0; x<limit; x++)
     {
      LinearMomentumBuffer[x]=iMAOnArray(Temporary,0,SmoothingPeriod,0,SmoothingMethod,x);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
