//+------------------------------------------------------------------+
//|                                                 MACDChannels.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot FastEMA
#property indicator_label1  "FastEMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMaroon
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SlowEMA
#property indicator_label2  "SlowEMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot MACDSMA
#property indicator_label3  "MACDSMA"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBrown
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot MACDAVG
#property indicator_label4  "MACDAVG"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrChartreuse
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint      FastEMA=12;
input uint      SlowEMA=26;
input uint      MACDSMA=9;
input ENUM_APPLIED_PRICE      ApplyPrice=PRICE_CLOSE;
//--- indicator buffers
double         FastEMABuffer[];
double         SlowEMABuffer[];
double         MACDSMABuffer[];
double         MACDAVGBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,FastEMABuffer);
   SetIndexBuffer(1,SlowEMABuffer);
   SetIndexBuffer(2,MACDSMABuffer);
   SetIndexBuffer(3,MACDAVGBuffer);

//---
   IndicatorShortName("MACDChannels("+IntegerToString(FastEMA)+","+IntegerToString(SlowEMA)+","+IntegerToString(MACDSMA)+")");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0,DRAW_LINE);

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
   MACDChannels();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
//| MACDChannels function                                              |
//+------------------------------------------------------------------+
void MACDChannels()
  {
//---

   int limit;
   int counted_bars=IndicatorCounted();
//----last counted bar will be pecounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   for(int i=limit -1; i>=0;i--)
     {
      FastEMABuffer[i]=iMA(NULL,NULL,FastEMA,0,MODE_EMA,ApplyPrice,i);
      SlowEMABuffer[i]=iMA(NULL,NULL,SlowEMA,0,MODE_EMA,ApplyPrice,i);
      MACDSMABuffer[i]=iMA(NULL,NULL,MACDSMA,0,MODE_SMA,ApplyPrice,i);
      MACDAVGBuffer[i]=(FastEMABuffer[i]+SlowEMABuffer[i]+MACDSMABuffer[i])/3;
     }
  }
//+------------------------------------------------------------------+
