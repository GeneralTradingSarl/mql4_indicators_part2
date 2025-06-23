//+------------------------------------------------------------------+
//|                                                       MIndex.mq4 |
//|                                  Copyright © 2005, Yuri Makarov. |
//|                                       http://mak.tradersmind.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Yuri Makarov."
#property link      "http://mak.tradersmind.com"
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 OrangeRed
//----
extern string Currency="USD";
//----
double EurUsd[],UsdChf[],GbpUsd[],UsdJpy[],AudUsd[],UsdCad[];
double Idx[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName(Currency);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Idx);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
//----
   double USD;
//----
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit--;

   ArrayCopySeries(EurUsd,MODE_CLOSE,"EURUSD");
   ArrayCopySeries(GbpUsd,MODE_CLOSE,"GBPUSD");
   ArrayCopySeries(AudUsd,MODE_CLOSE,"AUDUSD");
   ArrayCopySeries(UsdChf,MODE_CLOSE,"USDCHF");
   ArrayCopySeries(UsdJpy,MODE_CLOSE,"USDJPY");
   ArrayCopySeries(UsdCad,MODE_CLOSE,"USDCAD");

   limit=MathMin(limit,ArraySize(EurUsd));
   limit=MathMin(limit,ArraySize(GbpUsd));
   limit=MathMin(limit,ArraySize(AudUsd));
   limit=MathMin(limit,ArraySize(UsdChf));
   limit=MathMin(limit,ArraySize(UsdJpy));
   limit=MathMin(limit,ArraySize(UsdCad));

   for(int i=0; i<limit; i++)
     {
      USD=MathPow(UsdChf[i]*UsdJpy[i]*UsdCad[i]/EurUsd[i]/GbpUsd[i]/AudUsd[i],1./7.);
      if(Currency=="USD") Idx[i]=USD;
      if(Currency=="EUR") Idx[i]=USD*EurUsd[i];
      if(Currency=="GBP") Idx[i]=USD*GbpUsd[i];
      if(Currency=="AUD") Idx[i]=USD*AudUsd[i];
      if(Currency=="CHF") Idx[i]=USD/UsdChf[i];
      if(Currency=="JPY") Idx[i]=USD/UsdJpy[i];
      if(Currency=="CAD") Idx[i]=USD/UsdCad[i];
     }
   return(0);
  }
//+------------------------------------------------------------------+
