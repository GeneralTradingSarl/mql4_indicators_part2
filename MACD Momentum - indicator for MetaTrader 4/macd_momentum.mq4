//+------------------------------------------------------------------+
//|                                                MACD_Momentum.mq4 |
//|                                                 GGG Mâcon France |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Moving Averages Convergence/Divergence"
#property strict

//#include <MovingAverages.mqh>

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Gray// Silver
#property  indicator_color2  Yellow
#property  indicator_color3  White// Silver
#property  indicator_color4 Red // Magenta



#property  indicator_width1  2
//--- indicator parameters
input int InpFastEMA=12;   
input int InpSlowEMA=26;   
input int InpSignalSMA=9;  
input int smooth = 3;
//--- indicator buffers
double    ExtMacdBuffer[];
double    ExtSignalBuffer[];
double    Mom[];
double    Mom_smooth[];
//--- right input parameters flag
bool      ExtParameters=false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorDigits(Digits+1);
//--- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,InpSignalSMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer);
   SetIndexBuffer(1,ExtSignalBuffer);
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
//--- check for input parameters
 
    SetIndexBuffer(2,Mom );
    SetIndexStyle(2,DRAW_LINE,0,1);

     SetIndexBuffer(3,Mom_smooth );
    SetIndexStyle(3,DRAW_LINE,0,3);

   if(InpFastEMA<=1 || InpSlowEMA<=1 || InpSignalSMA<=1 || InpFastEMA>=InpSlowEMA)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
  {
   int i,limit;
//---
   if(rates_total<=InpSignalSMA || !ExtParameters)    return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated==0)     limit = rates_total- 3000;
   if(prev_calculated>0)     limit--;
//--- macd counted in the 1-st buffer
   for(i=limit; i>=0; i--)     ExtMacdBuffer[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
                               iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//--- signal line counted in the 2-nd buffer
  // SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
    for(i=limit; i>=0; i--) ExtSignalBuffer[i] =  iMAOnArray(ExtMacdBuffer,0,InpSignalSMA,0,0,i);


  for(i=limit; i>=0; i--) Mom[i] = ExtMacdBuffer[i] - ExtMacdBuffer[i+10];
  for(i=limit; i>=0; i--) Mom_smooth[i] = iMAOnArray(Mom,0,smooth,0,0,i);


//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+