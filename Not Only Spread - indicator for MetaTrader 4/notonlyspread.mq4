//+------------------------------------------------------------------+
//|                                                NotOnlySpread.mq4 |
//|        Spread, its moving average (ema), its maximum and minimum,|
//|                   and ticks per second (market speed) on comment.|
//+------------------------------------------------------------------+
#property copyright "Fabrizio"
#property link      "fajuzi@yahoo.it"
#property version   "1.00"
#property indicator_chart_window
input int     digi=1;//digits format
input int     sec=30;//seconds to refresh
input bool    clear=false;//if true clears comment after closing indicator
double newspread,emaspread,cost,maxpread,minspread;
int tickscount;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   EventSetTimer(sec);
   emaspread=MarketInfo(Symbol(),MODE_SPREAD);
   cost=(sec+1.0)/2.0;
   newspread=emaspread; maxpread=emaspread; minspread=emaspread;
   tickscount=0;
   Comment("INSTANT SPREAD = ",DoubleToString(emaspread,digi),
           "; PLEASE WAIT ",IntegerToString(sec)," SECONDS...");
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+  
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(clear==true) Comment("");
  }
//+------------------------------------------------------------------+
//| On timer function                                                |
//+------------------------------------------------------------------+ 
void OnTimer()
  {
   Comment("INSTANT SPREAD = ",DoubleToString(newspread,digi),
           ";  EMA AVERAGE = ",DoubleToString(emaspread,digi),
           ";  MAX = ",DoubleToString(maxpread,digi),
           ";  MIN = ",DoubleToString(minspread,digi),
           ";  TICKS/MINUTE SPEED = ",IntegerToString(60*tickscount/sec),
           "; ",IntegerToString(sec)," SECONDS TO REFRESH...");
   newspread=emaspread; maxpread=emaspread; minspread=emaspread;
   tickscount=0;
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
   tickscount++;
   newspread=MarketInfo(Symbol(),MODE_SPREAD);
   maxpread=MathMax(maxpread,newspread);
   minspread=MathMin(minspread,newspread);
   emaspread=emaspread+(newspread-emaspread)/cost;
   return(rates_total);
  }
//+------------------------------------------------------------------+
