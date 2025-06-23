//+------------------------------------------------------------------+
//|                                                 trendxplorer.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Peeter Paan"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot first
#property indicator_label1  "first"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrWhite
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot second
#property indicator_label2  "second"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- indicator buffers
double         firstBuffer[];
double         secondBuffer[];
input int closePeriod   =5;   //Close period
input int lowPeriod     =13;  //Low period
input int highPeriod    =34;  //High period
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,firstBuffer);
   SetIndexBuffer(1,secondBuffer);

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
   for(int i=0; i<Bars; i++)
     {

      double emac=iMA(NULL,0,closePeriod,0,1,0,i);  //Takes EMA with Close Price
      double emal=iMA(NULL,0,lowPeriod,0,1,3,i);  //Takes EMA with Low Price
      double emah=iMA(NULL,0,highPeriod,0,1,2,i);  //Takes EMA with High Price

      firstBuffer[i]=emac-emah;
      secondBuffer[i]=emal-emac;

     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
