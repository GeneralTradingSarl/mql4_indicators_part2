//+------------------------------------------------------------------+
//|                                                  LogTickData.mq4 |
//|                                       Copyright © 2014, matija14 |
//|                                              matija14@gmail.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, matija14"
#property link      "matija14@gmail.com"
#property version   "1.0"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Input Parameters Definition                                      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Local Parameters Definition                                      |
//+------------------------------------------------------------------+
string lbl = "LogTickData.";
int handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
  //------------------------------------------------------------------
  handle = FileOpen("TickData_"+Symbol()+".csv", FILE_CSV|FILE_WRITE|FILE_READ|FILE_SHARE_READ);
  if (handle > 0) FileSeek(handle, 0, SEEK_END);
  Comment("logging tick data...");
  //------------------------------------------------------------------
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  //------------------------------------------------------------------
  if (handle > 0) FileClose(handle);
  Comment("");
  //------------------------------------------------------------------
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // size of input time series
                 const int prev_calculated,  // bars handled in previous call
                 const datetime& time[],     // Time
                 const double& open[],       // Open
                 const double& high[],       // High
                 const double& low[],        // Low
                 const double& close[],      // Close
                 const long& tick_volume[],  // Tick Volume
                 const long& volume[],       // Real Volume
                 const int& spread[]         // Spread
)
{
  //------------------------------------------------------------------
  FileWrite(handle, TimeToStr(TimeCurrent())+";"+DoubleToStr(Bid, _Digits));
  FileFlush(handle);
  //------------------------------------------------------------------
  return (rates_total);
}
//+------------------------------------------------------------------+
