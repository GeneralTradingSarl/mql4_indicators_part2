//+------------------------------------------------------------------+
//|                                                       MACD+v.mq4 |
//|                                                      IvanMorozov |
//|                            https://www.mql5.com/ru/users/frostow |
//+------------------------------------------------------------------+
#property copyright "IvanMorozov"
#property link      "https://www.mql5.com/ru/users/frostow"
#property version   "1.2"
#property description "MACD with volumes"
#property strict
#property indicator_separate_window
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT
#property indicator_buffers 4    
#property indicator_plots   4    
//--- Гистограмма MACD
#property indicator_label1  "Hist"    //Name, that we can see on chart
#property indicator_type1   DRAW_HISTOGRAM   //Type
#property indicator_color1  clrGray          //Color
#property indicator_style1  STYLE_SOLID      //Style
#property indicator_width1  2                //Width... and the same about following:
//--- Быстрая линия MACD
#property indicator_label2  "Fast" 
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- Медленная линия MACD
#property indicator_label3  "Slow"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- Линия объема
#property indicator_label4  "Volume" 
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- indicator buffers
double         HistogramBuffer[];
double         LBuffer[];
double         SBuffer[];
double         VBuffer[];

//input data
extern bool v = true;//Will volumes be shown?
extern int p1 = 12;  //Period of MACD
extern int p2 = 26;
extern int p3 = 9;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,HistogramBuffer);
   SetIndexBuffer(1,LBuffer);     //Fast         
   SetIndexBuffer(2,SBuffer);     //Slow
   if(v) SetIndexBuffer(3,VBuffer);

   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0);
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD + Volumes");

   return 0;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+


int start()
  {
   int i,
   counted_bars,
   limit;
   string sym=Symbol();

   counted_bars=IndicatorCounted();
   limit=Bars-counted_bars;

// Fast
   for(i=0; i<limit; i++) LBuffer[i]=iMA(sym,0,p1,0,MODE_EMA,PRICE_CLOSE,i) -
      iMA(sym,0,p2,0,MODE_EMA,PRICE_CLOSE,i);

// Slow
   for(i=0; i<limit; i++) SBuffer[i]=iMAOnArray(LBuffer,Bars,p3,0,MODE_EMA,i);

// Hist
   for(i=0; i<limit; i++) HistogramBuffer[i]=LBuffer[i]-SBuffer[i];

// Volume
   for(i=0; i<limit; i++)
     {
      VBuffer[i]=iVolume(sym,0,i) *(MathPow(10,-2-MarketInfo(sym,MODE_DIGITS)));
      //Volumes will be reduced to show it correctly
     }
   return 0;
  }
//+------------------------------------------------------------------+
