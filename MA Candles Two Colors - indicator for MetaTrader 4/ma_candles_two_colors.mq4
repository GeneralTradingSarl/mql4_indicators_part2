//+------------------------------------------------------------------+
//|                                        MA_Candles_Two_Colors.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, File45."
#property link      "https://www.mql5.com/en/users/file45/publications"
#property version   "2.00"
#property description "Supported MA Methods >>" 
#property description "Simple" 
#property description "Exponential" 
#property description "Smoothed" 
#property description "Weighted" 
#property description "Triangular" 
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum mam
  {
   a=0, // Simple
   b=1, // Exponential
   c=2, // Smoothed
   d=3, // Weighted
   e=4  // Triangular
  };
//+------------------------------------------------------------------+
#property indicator_buffers 4
#property indicator_color1 RoyalBlue//wicks
#property indicator_color2 Red//wicks
#property indicator_color3 RoyalBlue // Candle Bodies
#property indicator_color4 Red // Candle Bodies
//---
input int Candle_MA_Period=34; // Candle MA Period
input int Candle_MA_Shift=0; // Candle MA Shift
input mam Candle_Typex=b; // Candle MA Method
input ENUM_APPLIED_PRICE Candle_MA_Price=0; // Candle Price
input int Candle_Shadow_Width=1;
input int Candle_Body_Width=3;
//---
int MA1=1;
int MA1_MODE=0;
int MA1_PRICE = 0;
int MA1_SHIFT = 0;
//--- indicator buffers
double Bar1[],Bar2[],Candle1[],Candle2[];
//---
int Candle_Type=Candle_Typex;
//---
double MA_1 (int i = 0){return(iMA(NULL,0,MA1,MA1_SHIFT,MA1_MODE, MA1_PRICE,i));}
double MA_2 (int i = 0){return(iMA(NULL,0,Candle_MA_Period,Candle_MA_Shift,Candle_Type, Candle_MA_Price,i));}
double MA_3 (int i = 0){return(iTma(iMA(NULL,0,1,Candle_MA_Shift,MODE_SMA,Candle_MA_Price,i),Candle_MA_Period,i));}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//Candle_Type = Candle_Typex;
   ChartSetInteger(0,CHART_MODE,CHART_LINE);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrNONE);
//---
   IndicatorShortName("MA Candles");
   IndicatorBuffers(4);
//---
   SetIndexBuffer(0,Bar1);
   SetIndexBuffer(1,Bar2);
   SetIndexBuffer(2,Candle1);
   SetIndexBuffer(3,Candle2);
//---
   SetIndexStyle(0,DRAW_HISTOGRAM,0,Candle_Shadow_Width);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,Candle_Shadow_Width);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,Candle_Body_Width);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,Candle_Body_Width);
//--- Data Window Truth Table: R up L is Red Candle up Low; R dn L is Red Candle down Low, etc,.
   SetIndexLabel(0,"R up L, R dn L, B up H, B dn H");
   SetIndexLabel(1,"R up H, R dn H, B up L, B dn L");
   SetIndexLabel(2,"R up O, R dn C, B up C, B dn O");
   SetIndexLabel(3,"R up C, R dn O, B up O, B dn C");
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
   for(int i=MathMax(Bars-1-IndicatorCounted(),1); i>=0; i--)
     {
      double   Ma1 = MA_1(i);
      double   Ma2 = MA_2(i);
      double   Ma3 = MA_3(i);
      //---
      if(Candle_Typex<4)
        {
         if(Ma1>Ma2)
           {
            SetCandleColor(1,i);
           }
         else
           {
            if(Ma1<Ma2) SetCandleColor(2,i);
           }
        }
      else if(Candle_Typex>3)
        {
         if(Ma1>Ma3)
           {
            SetCandleColor(1,i);
           }
         else
           {
            if(Ma1<Ma3) SetCandleColor(2,i);
           }
        }
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetCandleColor(int col,int i)
  {
   double high,low,bodyHigh,bodyLow;
//---
   bodyHigh= MathMax(Open[i],Close[i]);
   bodyLow = MathMin(Open[i],Close[i]);
   high= High[i];
   low = Low[i];
//---
   Bar1[i]    = EMPTY_VALUE;
   Bar2[i]    = EMPTY_VALUE;
   Candle1[i] = EMPTY_VALUE;
   Candle2[i] = EMPTY_VALUE;
//---
   switch(col)
     {
      case 1: Bar1[i] = high; Bar2[i] = low; Candle1[i] = bodyHigh; Candle2[i] = bodyLow; break;
      case 2: Bar2[i] = high; Bar1[i] = low; Candle2[i] = bodyHigh; Candle1[i] = bodyLow; break;
     }
  }
//---
double workTma[][1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iTma(double price,double period,int r,int instanceNo=0)
  {
   if(ArrayRange(workTma,0)!=Bars) ArrayResize(workTma,Bars); r=Bars-r-1;
//---
   workTma[r][instanceNo]=price;
//---
   double half = (period+1.0)/2.0;
   double sum  = price;
   double sumw = 1;
//---
   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=k+1; if(weight>half) weight=period-k;
      sumw  += weight;
      sum   += weight*workTma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//+------------------------------------------------------------------+
