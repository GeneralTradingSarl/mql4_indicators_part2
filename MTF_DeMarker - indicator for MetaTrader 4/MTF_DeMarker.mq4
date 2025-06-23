//+------------------------------------------------------------------+
//|PARAMS:                                                           |
//|      - TimeFramePeriod: #of minutes in TF.                       |
//|NOTE:                                                             |
//|      - I did not test non-standard TFs or a TimeFramePeriod      |
//|        value less than that of current chart. So they probably   |
//|        won't work.                                               |
//|      - DeMarkerPeriod: self explanatory                          |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006 ycomp"
#property link      "ycomp"
//----
#define MIN_BARS_REQUIRED 200 // Just a safe amount here. Probably needs much less.
//--- Indicator Settings
#property indicator_separate_window
#property indicator_level1 0.3
#property indicator_level2 0.7
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
#property indicator_width1 2
#property indicator_maximum 1
#property indicator_minimum 0
//---- input parameters
extern int TimeFramePeriod;
extern int DeMarkerPeriod=14;
//---- buffers
double buff[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0,buff);
   string paramDesc=
                    "("+
                    getPeriodDesc(TimeFramePeriod)+", "+
                    DeMarkerPeriod+
                    ")";
   IndicatorShortName("MTF_DeMarker"+paramDesc);
// Set Index Labels
   SetIndexLabel(0,"MTF_DeM"+paramDesc);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getPeriodDesc(int aNumMinutes)
  {
   switch(aNumMinutes)
     {
      case PERIOD_M1 : return("M1");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1 : return("H1");
      case PERIOD_H4 : return("H4");
      case PERIOD_D1 : return("D1");
      case PERIOD_W1 : return("W1");
      case PERIOD_MN1: return("MN1");
      case 0: return("Chart");
      default: return("M"+aNumMinutes);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getDeMarker(int aShift)
  {
   return(iDeMarker(NULL,TimeFramePeriod,13,iBarShift(NULL,TimeFramePeriod,Time[aShift])));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
     
   for(int shift=limit;shift>=0;shift--)
     {
      buff[shift]=getDeMarker(shift);
     }
   return(0);
  }
//+------------------------------------------------------------------+
