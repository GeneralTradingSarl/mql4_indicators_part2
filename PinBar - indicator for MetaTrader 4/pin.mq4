//+------------------------------------------------------------------+
//|                                                          Pin.mq4 |
//|                                         Copyright 2015, mrak297. |
//|                            https://www.mql5.com/ru/users/mrak297 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, mrak297."
#property link      "https://www.mql5.com/ru/users/mrak297"
#property version   "15.08"
#property strict
#property indicator_chart_window
//--- input parameters
input int    Depth    = 40;   //Depth of pinbars in percents
input int    MaxRange = 100;  //Maximum range
input int    MinRange = 20;   //Minimum range
input bool   Extremum = true; //Only extremum

double Pp;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if (Point() == 0.0001 || Point() == 0.00001) Pp = 0.0001;
   if (Point() == 0.01 || Point() == 0.001) Pp = 0.01;
   
   return(INIT_SUCCEEDED);
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
//---
   string name = " ";
   
   for (int i = 1; i < Bars-1; i++)
    {
     if (PinUp(time[i], open[i], high[i], low[i], close[i], Depth))
      {
       name = "PinUp"+TimeToString(time[i], TIME_DATE|TIME_MINUTES); 
       ArrowSellCreate(name, time[i], high[i]);
      }
     if (PinDown(time[i], open[i], high[i], low[i], close[i], Depth))
      {
       name = "PinDown"+TimeToString(time[i], TIME_DATE|TIME_MINUTES); 
       ArrowBuyCreate(name, time[i], low[i]);
      }
    }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
  ObjectsDeleteAll(0, -1, OBJ_ARROW);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PinUp(datetime time, double open, double high, double low, double close, int depth)
 {
  int  range = (int)MathRound((high - low)/Pp);
  int  zone  = (int)MathRound(range * depth * 0.01);                      //////////////////////////////////////
  int  shift = iBarShift(_Symbol, PERIOD_D1, time, true);                 //                                  //
  double dayHidh = iHigh(_Symbol, PERIOD_D1, shift);                      //       |               --|        //
  double level = NormalizeDouble(low + zone * Pp, _Digits);               //       |                 |        //
  bool check = false;                                                     //       |                 |        //
                                                                          //       |                 |        //
  if (range > MinRange && range < MaxRange)                               //       |                 |        //
   {                                                                      //       |                 |- range //
    if ((Extremum && high == dayHidh) || !Extremum)                       //       |                 |        //
     check = true;                                                        //      ---     --|- level |        //
    if (open <= level && close <= level && check)                         //      | |       |        |        //
     {                                                                    //      | |       |-- zone |        //
      return(true);                                                       //      ---       |        |        //
     }                                                                    //       |      --|      --|        //
   }                                                                      //                                  //
                                                                          //////////////////////////////////////
  return(false);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PinDown(datetime time, double open, double high, double low, double close, int depth)
 {
  int  range = (int)MathRound((high - low)/Pp);
  int  zone  = (int)MathRound(range * depth * 0.01);                      //////////////////////////////////////
  int  shift = iBarShift(_Symbol, PERIOD_D1, time, true);                 //                                  //
  double dayLow = iLow(_Symbol, PERIOD_D1, shift);                        //       |      --|      --|        //
  double level = NormalizeDouble(high - zone * Pp, _Digits);              //      ---       |        |        //
  bool check = false;                                                     //      | |       |-- zone |        //
                                                                          //      | |       |        |        //
  if (range > MinRange && range < MaxRange)                               //      ---     --|- level |        //
   {                                                                      //       |                 |        //
    if ((Extremum && low == dayLow) || !Extremum)                         //       |                 |- range //
     check = true;                                                        //       |                 |        //
    if (open >= level && close >= level && check)                         //       |                 |        //
     {                                                                    //       |                 |        //
      return(true);                                                       //       |                 |        //
     }                                                                    //       |               --|        //
   }                                                                      //                                  //
                                                                          //////////////////////////////////////
  return(false);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrowSellCreate(string name, datetime time, double price)
  {
   ResetLastError();
   
   if(ObjectCreate(0,name,OBJ_ARROW_SELL,0,time,price))
    {
     ObjectSetInteger(0,name,OBJPROP_COLOR,clrTomato);
     ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
     ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
     ObjectSetInteger(0,name,OBJPROP_BACK,true);
     ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
     ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
    }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrowBuyCreate(string name, datetime time, double price)
  {
   ResetLastError();
   
   if(ObjectCreate(0,name,OBJ_ARROW_BUY,0,time,price))
    {
     ObjectSetInteger(0,name,OBJPROP_COLOR,clrDodgerBlue);
     ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
     ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
     ObjectSetInteger(0,name,OBJPROP_BACK,true);
     ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
     ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
    }
  }
//+-----------------------------------------------------------------+