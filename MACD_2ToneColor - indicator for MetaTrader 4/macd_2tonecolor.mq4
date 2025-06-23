//+------------------------------------------------------------------+
//|                                              MACD_2ToneColor.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp. ~ Edited By 3rjfx ~ 18/03/2015"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
//--
#include <MovingAverages.mqh>
//--
#property indicator_separate_window
//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  clrNONE
#property  indicator_color2  clrSnow
#property  indicator_color3  clrRed
#property  indicator_color4  clrBlueViolet
//-
#property  indicator_width2  3
#property  indicator_width3  3
#property  indicator_width4  2
//-
//--- indicator parameters
input int InpFastEMA=12;   // Fast EMA Period
input int InpSlowEMA=26;   // Slow EMA Period
input int InpSignalSMA=9;  // Signal SMA Period
//--- indicator buffers
double ExtMacdBuff[];
double ExtSignBuff[];
double ExtMacdBuffUp[];
double ExtMacdBuffDn[];
//-
double now;
double pas;
//--- right input parameters flag
bool ExtParameters=false;
int digit;
//--
void EventSetTimer();
//--
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   //-- Checking the Digits Point
   if(Digits==3||Digits==5)
      {digit=Digits;}
   else {digit=Digits+1;}
   IndicatorDigits(digit);
   //--
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuff);
   SetIndexBuffer(1,ExtMacdBuffUp);   
   SetIndexBuffer(2,ExtMacdBuffDn);
   SetIndexBuffer(3,ExtSignBuff);
   //--
//--- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);  
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_LINE);
   //-
   SetIndexDrawBegin(1,InpSignalSMA);   
   SetIndexDrawBegin(2,InpSignalSMA);
   SetIndexDrawBegin(3,InpSignalSMA);
   //--
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD_2TC ("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"MACD Up");
   SetIndexLabel(2,"MACD Dn");
   SetIndexLabel(3,"Signal");
//--- check for input parameters
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
//--
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   EventKillTimer();
   GlobalVariablesDeleteAll();
//----
   return;
  }
//---
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
   int i,limit;
//---
   if(rates_total<=InpSignalSMA || !ExtParameters)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- counting from rates_total to 0 
   ArraySetAsSeries(ExtMacdBuff,true);
   ArraySetAsSeries(ExtSignBuff,true);
   ArraySetAsSeries(ExtMacdBuffUp,true);
   ArraySetAsSeries(ExtMacdBuffDn,true);
   //--
//--- macd counted in the 1-st buffer
   for(i=limit-1; i>=0; i--)
     {ExtMacdBuff[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
                     iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);}
//--- signal line counted in the 2-nd buffer
   SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuff,ExtSignBuff);
   //--
   for(i=limit-1; i>=0; i--)
     {
       //--
       //now=ExtMacdBuff[i]-ExtSignBuff[i];
       now=ExtMacdBuff[i];
       //--
       if(now>pas)
         {
           ExtMacdBuffUp[i]=ExtMacdBuff[i];
           ExtMacdBuffDn[i]=0.00;
         }
       //--
       if(now<pas)
         {
           ExtMacdBuffUp[i]=0.00;
           ExtMacdBuffDn[i]=ExtMacdBuff[i];
         }
       //--
       pas=now;
       //--
     }
     //--
//--- done
   return(rates_total);   
//--- return value of prev_calculated for next call
  }
//+------------------------------------------------------------------+
