//+------------------------------------------------------------------+
//|                                                 GainLossInfo.mq4 |
//|                                  Copyright © 2013, Andriy Moraru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Andriy Moraru"
#property link      "http://www.earnforex.com"
/*
   Shows percentage and pip gain/loss for a candle.
   Can calculate gain/loss compared either to the previous Close or to the current Open.
*/
//--- The indicator uses only objects for display, but the line below is required for it to work.
#property indicator_chart_window
//---
extern double PercentageLimit=1.0; // Will not display number if percentage gain/loss is below limit.
extern int PipsLimit=1000; // Will not display number if pips gain/loss is below limit.
//--- If true, will compare Close of the current candle to Close of the previous one. Otherwise compares current Close to current Open.
extern bool CloseToClose=true;
extern color DisplayLossColor = Red;
extern color DisplayGainColor = LimeGreen;
extern int DisplayDistance=100; // Distance in pips from High/Low to percentage display.
extern int MaxBars=100; // More bars - more objects - more lag and memory usage.
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i=0; i<Bars; i++)
     {
      ObjectDelete("RedPercent-"+TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));
      ObjectDelete("GreenPercent-"+TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));
      ObjectDelete("RedPips-"+TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));
      ObjectDelete("GreenPips-"+TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   string perc,pips,name;
   double start;
//---
   int counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(limit>MaxBars) limit=MaxBars-1;
//---
   for(int i=0; i<=limit; i++)
     {
      if((CloseToClose) && (i+1<Bars)) start=Close[i+1];
      else start=Open[i];
      //---
      if(((Close[i]-start)/start)*100>=PercentageLimit) // Gain percent display
        {
         name = "GreenPercent-" + TimeToStr(Time[i], TIME_DATE|TIME_MINUTES);
         perc = DoubleToStr(((Close[i] - start) / start) * 100, 1) + "%";
         if(ObjectFind(name)!=-1) ObjectDelete(name);
         ObjectCreate(name,OBJ_TEXT,0,Time[i],High[i]+DisplayDistance*Point);
         ObjectSetText(name,perc,10,"Verdana",DisplayGainColor);
        }
      else if(((start-Close[i])/start)*100>=PercentageLimit) // Loss percent display
        {
         name = "RedPercent-" + TimeToStr(Time[i], TIME_DATE|TIME_MINUTES);
         perc = DoubleToStr(((start - Close[i]) / start) * 100, 1) + "%";
         if(ObjectFind(name)!=-1) ObjectDelete(name);
         ObjectCreate(name,OBJ_TEXT,0,Time[i],High[i]+DisplayDistance*Point);
         ObjectSetText(name,perc,10,"Verdana",DisplayLossColor);
        }
      //---
      if((Close[i]-start)/Point>=PipsLimit) // Gain pips display
        {
         name = "GreenPips-" + TimeToStr(Time[i], TIME_DATE|TIME_MINUTES);
         pips = DoubleToStr((Close[i] - start) / Point, 0);
         if(ObjectFind(name)!=-1) ObjectDelete(name);
         ObjectCreate(name,OBJ_TEXT,0,Time[i],Low[i]);
         ObjectSetText(name,pips,10,"Verdana",DisplayGainColor);
        }
      else if((start-Close[i])/Point>=PipsLimit) // Loss pips display
        {
         name = "RedPips-" + TimeToStr(Time[i], TIME_DATE|TIME_MINUTES);
         pips = DoubleToStr((start - Close[i]) / Point, 0);
         if(ObjectFind(name)!=-1) ObjectDelete(name);
         ObjectCreate(name,OBJ_TEXT,0,Time[i],Low[i]);
         ObjectSetText(name,pips,10,"Verdana",DisplayLossColor);
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
