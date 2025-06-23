//+------------------------------------------------------------------+
//|                                                    NonLagRSI.mq4 |
//|                           Copyright 2020, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright   "2005-2020, MetaQuotes Software Corp. ~ By 3rjfx ~ Created: 03/04/2020"
#property link        "http://www.mql4.com"
#property link        "http://www.mql5.com"
#property link        "https://www.mql5.com/en/users/3rjfx"
#property version     "1.00"
#property description "Non Lag Relative Strength Index."
#property description "Eliminates unnecessary preliminary calculations on the built-in RSI"
#property strict
//---
#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_buffers    3
#property indicator_color1     clrRed
#property indicator_level1     30.0
#property indicator_level2     50.0
#property indicator_level3     70.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_SOLID
//---
//--
enum priceuse
 {
   price_close,     // CLOSE
   price_open,      // OPEN
   price_high,      // HIGH
   price_low,       // LOW
   price_median,    // MEDIAN (H+L)/2
   price_typical,   // TYPICAL (H+L+C)/3
   price_weighted,  // WEIGHETED (H+L+C+C)/4
   price_all        // ALL (O+H+L+C)/4
 };
//--
//--- input parameters
input int          InpPeriod = 14;             // RSI Period
input priceuse        eprice = price_weighted; // Calculation Price
//--
double ExtRSI[];
double ExtPos[];
double ExtNeg[];
double diffup[];
double diffdn[];
#define DATA_LIMIT  120
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   string short_name;
//--- 2 additional buffers are used for counting.
   IndicatorBuffers(3);
   SetIndexBuffer(0,ExtRSI);
   SetIndexBuffer(1,ExtPos);
   SetIndexBuffer(2,ExtNeg);
//--- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtRSI);
//--- name for DataWindow and indicator subwindow label
   short_name="NonLagRSI("+string(InpPeriod)+"-"+string(eprice)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
//--- check for input
   if(InpPeriod<2)
     {
      Print("Incorrect value for input variable InpPeriod = ",InpPeriod);
      return(INIT_FAILED);
     }
//---
   IndicatorDigits(2);
   SetIndexDrawBegin(0,InpPeriod);
//---
   return(INIT_SUCCEEDED);
  }
//---------//
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
   //--
   PrintFormat("%s: Deinitialization reason code=%d",__FUNCTION__,reason);
//----
   return;
//---
  } //-end OnDeinit()
//-------//
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
    int limit,barc;
    double diff=0;
//--- check for rates total
   if(rates_total<DATA_LIMIT)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(limit==0) limit=InpPeriod*2+2;
   if(prev_calculated>0) limit--;
   if(limit>Bars) limit=Bars;
   barc=limit-InpPeriod+1;
   //--
   ArrayResize(ExtRSI,limit);
   ArrayResize(ExtPos,limit);
   ArrayResize(ExtNeg,limit);
   ArrayResize(diffup,limit);
   ArrayResize(diffdn,limit);
   ArraySetAsSeries(ExtRSI,true);
   ArraySetAsSeries(ExtPos,true);
   ArraySetAsSeries(ExtNeg,true);
   ArraySetAsSeries(diffup,true);
   ArraySetAsSeries(diffdn,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   //---
   for(int i=barc-1; i>=0; i--)
     {
       diff=FillPrice(i)-FillPrice(i+1);
       if(diff>0)
          diffup[i]=diff;
       else
          diffdn[i]=-diff;
       //--
       ExtPos[i]=((ExtPos[i+1]*(InpPeriod-1))+(diffup[i]))/InpPeriod;
       ExtNeg[i]=((ExtNeg[i+1]*(InpPeriod-1))+(diffdn[i]))/InpPeriod;
       if(ExtNeg[i]!=0.0)
          ExtRSI[i]=100.0-(100.0/(1+(ExtPos[i]/ExtNeg[i])));
       else
        {
         if(ExtPos[i]!=0.0)
            ExtRSI[i]=100.0;
         else
            ExtRSI[i]=50.0;
        }
     }
   //---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---------//

double FillPrice(int shift)
  {
//---
    double prc=0;
    ArraySetAsSeries(Open,true);
    ArraySetAsSeries(High,true);
    ArraySetAsSeries(Low,true);
    ArraySetAsSeries(Close,true);
    //--
    switch(eprice)
      {
        case 0: prc=Close[shift]; break;
        case 1: prc=Open[shift];  break;
        case 2: prc=High[shift];  break;
        case 3: prc=Low[shift];   break;
        case 4: prc=(High[shift]+Low[shift])/2;  break;
        case 5: prc=(High[shift]+Low[shift]+Close[shift])/3;  break;
        case 6: prc=(High[shift]+Low[shift]+Close[shift]+Close[shift])/4;  break;
        case 7: prc=(Open[shift]+High[shift]+Low[shift]+Close[shift])/4;   break;
      }
    //--
    return(prc);
//---
  }
//---------//
//+------------------------------------------------------------------+