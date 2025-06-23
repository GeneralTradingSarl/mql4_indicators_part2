//+------------------------------------------------------------------+
//|                         Hotkeys_CycleMarketWatchSymbols_v1.0.mq4 |
//|                                         Copyright 2021, NickBixy |
//|             https://www.forexfactory.com/showthread.php?t=904734 |
//+------------------------------------------------------------------+
#property copyright "NickBixy"
#property link      "https://www.forexfactory.com/showthread.php?t=904734"
//#property version   "1.00"
#property strict
#property description "Hotkeys Comma, Period To Cycle Through Market Watch Symbols."
#property indicator_chart_window
int NumSymbols=0;
string StringSymbolList[];
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
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
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_KEYDOWN)
     {
      //if want to change default hotkeys for next and previous symbol in market watch
      //use this website to find keycode https://keycode.info
      //https://keycode.info
      switch(int(lparam))
        {
         case 188://keycode for previous market watch symbol
            PrevSymbol();
            break;
         case 190://keycode for next market watch symbol
            NextSymbol();
            break;
        }
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
void NextSymbol()
  {
   int currentIndex;
   GetSymbols();
   currentIndex=GetIndex();
   currentIndex++;

   if(currentIndex>=NumSymbols)
     {
      ChartSetSymbolPeriod(0,StringSymbolList[0],0);
     }
   else
     {
      ChartSetSymbolPeriod(0,StringSymbolList[currentIndex],0);
     }
  }
//+------------------------------------------------------------------+
void PrevSymbol()
  {
   int currentIndex;
   GetSymbols();
   currentIndex=GetIndex();
   currentIndex--;

   if(currentIndex<0)
     {
      currentIndex=NumSymbols-1;
      ChartSetSymbolPeriod(0,StringSymbolList[currentIndex],0);
     }
   else
     {
      ChartSetSymbolPeriod(0,StringSymbolList[currentIndex],0);
     }
  }
//+------------------------------------------------------------------+
void GetSymbols()
  {
   int numSymbolsMarketWatch=SymbolsTotal(true);
   NumSymbols=numSymbolsMarketWatch;
   ArrayResize(StringSymbolList,numSymbolsMarketWatch);
   for(int i=0; i<numSymbolsMarketWatch; i++)
     {
      StringSymbolList[i]=SymbolName(i,true);
     }
  }
//+------------------------------------------------------------------+
int GetIndex()
  {
   int index=0;
   for(int i=0; i<NumSymbols; i++)
     {
      if(_Symbol==StringSymbolList[i])
        {
         index=i;
         break;
        }
     }
   return index;
  }
//+------------------------------------------------------------------+
