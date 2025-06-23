//===================================================================================================================================================//
#property copyright   "Copyright 2016-2017, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.1"
#property description "MACD in MA"
#property strict
//===================================================================================================================================================//
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrPaleTurquoise
#property indicator_color3 clrRed
#property indicator_color4 clrOrange
//===================================================================================================================================================//
input string             MA_Parameters    = "||========== MA Parameters ==========||";
input int                MA_Periods       = 14;
input ENUM_MA_METHOD     MA_Method        = MODE_SMA;
input string             MACD_Parameters  = "||========== MACD Parameters ==========||";
input int                MACD_FastEMA     = 12;
input int                MACD_SlowEMA     = 26;
input int                MACD_SignalSMA   = 9;
input ENUM_APPLIED_PRICE MACD_ApliedPrice = PRICE_CLOSE;
input string             Show_Parameters  = "||========== Show Indicator Parameters ==========||";
extern bool              ReverseSignals   = false;
input int                BarsCount        = 10000;
//===================================================================================================================================================//
double TrendUp1[];
double TrendUp2[];
double TrendDown1[];
double TrendDown2[];
double MALevel[];
double MACD_Main[];
double MACD_Signal[];
//===================================================================================================================================================//
int OnInit(void)
  {
//-----------------------------------------------------------------------------------
   IndicatorShortName(WindowExpertName()+"("+DoubleToStr(MACD_FastEMA,0)+","+DoubleToStr(MACD_SlowEMA,0)+","+DoubleToStr(MACD_SignalSMA,0)+")");
   IndicatorDigits(Digits);
   IndicatorBuffers(7);
//---
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TrendUp1);
   SetIndexLabel(0,"MACD Trend Up 1");
//---
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,TrendUp2);
   SetIndexLabel(1,"MACD Trend Up 2");
//---
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,TrendDown1);
   SetIndexLabel(2,"MACD Trend Down 1");
//---
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,TrendDown2);
   SetIndexLabel(3,"MACD Trend Down 2");
//---
   SetIndexBuffer(4,MACD_Main);
   SetIndexBuffer(5,MACD_Signal);
   SetIndexBuffer(6,MALevel);
//-----------------------------------------------------------------------------------
   return(INIT_SUCCEEDED);
//-----------------------------------------------------------------------------------
  }
//===================================================================================================================================================//
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
//-----------------------------------------------------------------------------------
   int i=0;
   int Limit=0;
   int CountedBars=0;
//-----------------------------------------------------------------------------------
   CountedBars=BarsCount;
   if(CountedBars<0) return(-1);
   if(CountedBars>Bars-1) CountedBars=Bars-1;
   if(CountedBars<0) return(-1);
   if(CountedBars>0) CountedBars--;
   Limit=CountedBars;
//-----------------------------------------------------------------------------------
   for(i=Limit; i>=0; i--)
     {
      MACD_Main[i]=iMACD(NULL,0,MACD_FastEMA,MACD_SlowEMA,MACD_SignalSMA,PRICE_CLOSE,MODE_MAIN,i);
      MACD_Signal[i]=iMACD(NULL,0,MACD_FastEMA,MACD_SlowEMA,MACD_SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i);
      MALevel[i]=iMA(NULL,0,MA_Periods,0,MA_Method,0,i);
      //-----------------------------------------------------------------------------------
      TrendUp1[i]=EMPTY_VALUE;
      TrendUp2[i]=EMPTY_VALUE;
      TrendDown1[i]=EMPTY_VALUE;
      TrendDown2[i]=EMPTY_VALUE;
      //-----------------------------------------------------------------------------------
      //Normal signals
      if(ReverseSignals==false)
        {
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]>0)&&(MACD_Main[i]>MACD_Signal[i])) TrendUp1[i]=NormalizeDouble(MALevel[i],Digits);
         if((MACD_Main[i]>0)&&(MACD_Main[i]<MACD_Signal[i])) TrendUp2[i]=NormalizeDouble(MALevel[i],Digits);
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]<0)&&(MACD_Main[i]<MACD_Signal[i])) TrendDown1[i]=NormalizeDouble(MALevel[i],Digits);
         if((MACD_Main[i]<0)&&(MACD_Main[i]>MACD_Signal[i])) TrendDown2[i]=NormalizeDouble(MALevel[i],Digits);
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]>0) && (MACD_Main[i+1]<0)) TrendUp1[i+1]=NormalizeDouble(MALevel[i+1],Digits);
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]<0) && (MACD_Main[i+1]>0)) TrendDown1[i+1]=NormalizeDouble(MALevel[i+1],Digits);
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]>0)&&(MACD_Main[i]<MACD_Signal[i])&&(MACD_Main[i+1]>MACD_Signal[i+1])) TrendUp1[i]=NormalizeDouble(MALevel[i],Digits);
         if((MACD_Main[i]>0)&&(MACD_Main[i]>MACD_Signal[i])&&(MACD_Main[i+1]<MACD_Signal[i+1])) TrendUp2[i]=NormalizeDouble(MALevel[i],Digits);
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]<0)&&(MACD_Main[i]>MACD_Signal[i])&&(MACD_Main[i+1]<MACD_Signal[i+1])) TrendDown1[i]=NormalizeDouble(MALevel[i],Digits);
         if((MACD_Main[i]<0)&&(MACD_Main[i]<MACD_Signal[i])&&(MACD_Main[i+1]>MACD_Signal[i+1])) TrendDown2[i]=NormalizeDouble(MALevel[i],Digits);
        }
      //-----------------------------------------------------------------------------------
      //Reverse signals
      if(ReverseSignals==true)
        {
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]>0)&&(MACD_Main[i]>MACD_Signal[i])) TrendDown1[i]=NormalizeDouble(MALevel[i],Digits);
         if((MACD_Main[i]>0)&&(MACD_Main[i]<MACD_Signal[i])) TrendDown2[i]=NormalizeDouble(MALevel[i],Digits);
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]<0)&&(MACD_Main[i]<MACD_Signal[i])) TrendUp1[i]=NormalizeDouble(MALevel[i],Digits);
         if((MACD_Main[i]<0)&&(MACD_Main[i]>MACD_Signal[i])) TrendUp2[i]=NormalizeDouble(MALevel[i],Digits);
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]>0) && (MACD_Main[i+1]<0)) TrendDown1[i+1]=NormalizeDouble(MALevel[i+1],Digits);
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]<0) && (MACD_Main[i+1]>0)) TrendUp1[i+1]=NormalizeDouble(MALevel[i+1],Digits);
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]>0)&&(MACD_Main[i]<MACD_Signal[i])&&(MACD_Main[i+1]>MACD_Signal[i+1])) TrendDown1[i]=NormalizeDouble(MALevel[i],Digits);
         if((MACD_Main[i]>0)&&(MACD_Main[i]>MACD_Signal[i])&&(MACD_Main[i+1]<MACD_Signal[i+1])) TrendDown2[i]=NormalizeDouble(MALevel[i],Digits);
         //-----------------------------------------------------------------------------------
         if((MACD_Main[i]<0)&&(MACD_Main[i]>MACD_Signal[i])&&(MACD_Main[i+1]<MACD_Signal[i+1])) TrendUp1[i]=NormalizeDouble(MALevel[i],Digits);
         if((MACD_Main[i]<0)&&(MACD_Main[i]<MACD_Signal[i])&&(MACD_Main[i+1]>MACD_Signal[i+1])) TrendUp2[i]=NormalizeDouble(MALevel[i],Digits);
        }
      //-----------------------------------------------------------------------------------
     }
//-----------------------------------------------------------------------------------
   return(rates_total);
//-----------------------------------------------------------------------------------
  }
//===================================================================================================================================================//
