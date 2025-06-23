//+------------------------------------------------------------------+
//|                                       Kolier_SuperTrend_Indi.mq4 |
//|                                       Copyright 2010, KoliEr Li. |
//|                                                 http://kolier.li |
//+------------------------------------------------------------------+
/*
 * I here get paid to program for you. Just $15 for all scripts.
 *
 * I am a bachelor major in Financial-Mathematics.
 * I am good at programming in MQL for Meta Trader 4 platform. Senior Level. Have done hundreds of scripts.
 * No matter what it is, create or modify any indicators, expert advisors and scripts.
 * I will ask these jobs which are not too large, price from $15, surely refundable if you are not appreciate mine.
 * All products will deliver in 3 days.
 * Also, I am providing EA, Indicator and Trade System Improvement Consultant services, contact me for the detail.
 * If you need to have it done, don't hesitate to contact me at: kolier.li@gmail.com
 */

//+------------------------------------------------------------------+
//| Indicator Properties                                             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, KoliEr Li."
#property link      "http://kolier.li"
// Client: 
// Tags: SuperTrend, ATR
// Revision: 1

/* Change Logs */
/*
*/

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

//+------------------------------------------------------------------+
//| Universal Constants                                              |
//+------------------------------------------------------------------+
#define PHASE_NONE 0
#define PHASE_BUY 1
#define PHASE_SELL -1

//+------------------------------------------------------------------+
//| User input variables                                             |
//+------------------------------------------------------------------+
extern string    AdvisorName ="Kolier_SuperTrend_Indi";
extern string AdvisorVersion="1.0.1";            // The version number of this script
extern string    ProjectPage="http://kolier.li/project/kolier-supertrend-indi";            // The project landing page
extern int       BarsToCount = 0;    // Set to 0 to count all bars, if >0, set more to calculate more bars
extern int         TrendMode = 0;    // 0=Show line same as SuperTrend.mq4, 1=New way to show trend line
                                     // iATR
extern string ATR_Indicator = "http://kolier.li/example/mt4-iatr-system-average-true-range";
extern int       ATR_Period = 10;
extern double ATR_Multiplier= 3.0;

//+------------------------------------------------------------------+
//| Universal variables                                              |
//+------------------------------------------------------------------+
double buffer_line_up[],buffer_line_down[];
double atr,band_upper,band_lower;
int phase=PHASE_NONE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName(AdvisorName);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));

   SetIndexBuffer(0,buffer_line_up);
   SetIndexLabel(0,"Up Trend");
   SetIndexBuffer(1,buffer_line_down);
   SetIndexLabel(1,"Down Trend");

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+2;

   for(int i=limit; i>=0; i--) 
     {
      atr=iATR(Symbol(),0,ATR_Period,i);
      band_upper = (High[i]+Low[i])/2 + ATR_Multiplier * atr;
      band_lower = (High[i]+Low[i])/2 - ATR_Multiplier * atr;

      if(phase==PHASE_NONE) 
        {
         buffer_line_up[i]=(High[i+1]+Low[i+1])/2;
         buffer_line_down[i]=(High[i+1]+Low[i+1])/2;
        }

      if(phase!=PHASE_BUY && Close[i]>buffer_line_down[i+1] && buffer_line_down[i+1]!=EMPTY_VALUE) 
        {
         phase = PHASE_BUY;
         buffer_line_up[i]=band_lower;
         buffer_line_up[i+1]=buffer_line_down[i+1];
        }

      if(phase!=PHASE_SELL && Close[i]<buffer_line_up[i+1] && buffer_line_up[i+1]!=EMPTY_VALUE) 
        {
         phase = PHASE_SELL;
         buffer_line_down[i]=band_upper;
         buffer_line_down[i+1]=buffer_line_up[i+1];
        }

      if(phase==PHASE_BUY
         && ((TrendMode==0 && buffer_line_up[i+2]!=EMPTY_VALUE) || TrendMode==1)) 
        {
         if(band_lower>buffer_line_up[i+1]) 
           {
            buffer_line_up[i]=band_lower;
           }
         else 
           {
            buffer_line_up[i]=buffer_line_up[i+1];
           }
        }
      if(phase==PHASE_SELL
         && ((TrendMode==0 && buffer_line_down[i+2]!=EMPTY_VALUE) || TrendMode==1)) 
        {
         if(band_upper<buffer_line_down[i+1]) 
           {
            buffer_line_down[i]=band_upper;
           }
         else 
           {
            buffer_line_down[i]=buffer_line_down[i+1];
           }
        }

     }

   return(0);
  }
//+------------------------------------------------------------------+
