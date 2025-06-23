#property copyright   "MACD Above Below Zero Color Bars"                              // copyright
#property copyright   "ckart1.simplesite.com"                              // copyright
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 8

#property indicator_type1 DRAW_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_width1 3
#property indicator_color1 0xFF2600
#property indicator_label1 "MACD Above Zero"

#property indicator_type2 DRAW_HISTOGRAM
#property indicator_style2 STYLE_SOLID
#property indicator_width2 3
#property indicator_color2 0xFF0303
#property indicator_label2 "MACD Above Zero"

#property indicator_type3 DRAW_HISTOGRAM
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_color3 0xFF0033
#property indicator_label3 "MACD Above Zero"

#property indicator_type4 DRAW_HISTOGRAM
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_color4 0xFF0059
#property indicator_label4 "MACD Above Zero"

#property indicator_type5 DRAW_HISTOGRAM
#property indicator_style5 STYLE_SOLID
#property indicator_width5 3
#property indicator_color5 0x0000FF
#property indicator_label5 "MACD Below Zero"

#property indicator_type6 DRAW_HISTOGRAM
#property indicator_style6 STYLE_SOLID
#property indicator_width6 3
#property indicator_color6 0x0000FF
#property indicator_label6 "MACD Below Zero"

#property indicator_type7 DRAW_HISTOGRAM
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_color7 0x0000FF
#property indicator_label7 "MACD Below Zero"

#property indicator_type8 DRAW_HISTOGRAM
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_color8 0x0000FF
#property indicator_label8 "MACD Below Zero"

//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];
double Buffer7[];
double Buffer8[];

extern int Fast_EMA = 12;
extern int Slow_EMA2 = 26;
extern int MACD_SMA3 = 9;
datetime time_alert; //used when sending alert
extern bool Send_Email = false;
extern bool Audible_Alerts = true;
extern bool Push_Notifications = false;
double myPoint; //initialized in OnInit

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | MACD Above Below Zero @ "+Symbol()+","+Period()+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
   else if(type == "indicator")
     {
      Print(type+" | MACD Above Below Zero @ "+Symbol()+","+Period()+" | "+message);
      if(Audible_Alerts) Alert(type+" | MACD Above Below Zero @ "+Symbol()+","+Period()+" | "+message);
      if(Send_Email) SendMail("MACD Above Below Bars", type+" | Gann Arrow @ "+Symbol()+","+Period()+" | "+message);
      if(Push_Notifications) SendNotification(type+" | MACD Above Below Zero @ "+Symbol()+","+Period()+" | "+message);
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   IndicatorBuffers(8);
   SetIndexBuffer(0, Buffer1);
   SetIndexEmptyValue(0, 0);
   SetIndexBuffer(1, Buffer2);
   SetIndexEmptyValue(1, 0);
   SetIndexBuffer(2, Buffer3);
   SetIndexEmptyValue(2, 0);
   SetIndexBuffer(3, Buffer4);
   SetIndexEmptyValue(3, 0);
   SetIndexBuffer(4, Buffer5);
   SetIndexEmptyValue(4, 0);
   SetIndexBuffer(5, Buffer6);
   SetIndexEmptyValue(5, 0);
   SetIndexBuffer(6, Buffer7);
   SetIndexEmptyValue(6, 0);
   SetIndexBuffer(7, Buffer8);
   SetIndexEmptyValue(7, 0);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(Buffer4, true);
   ArraySetAsSeries(Buffer5, true);
   ArraySetAsSeries(Buffer6, true);
   ArraySetAsSeries(Buffer7, true);
   ArraySetAsSeries(Buffer8, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, 0);
      ArrayInitialize(Buffer2, 0);
      ArrayInitialize(Buffer3, 0);
      ArrayInitialize(Buffer4, 0);
      ArrayInitialize(Buffer5, 0);
      ArrayInitialize(Buffer6, 0);
      ArrayInitialize(Buffer7, 0);
      ArrayInitialize(Buffer8, 0);
     }
   else
      limit++;
   
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(1000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      //Indicator Buffer 1
      if(iMACD(NULL, PERIOD_CURRENT, Fast_EMA, Slow_EMA2, MACD_SMA3, PRICE_CLOSE, MODE_MAIN, i) > 0 //MACD > fixed value
      )
        {
         Buffer1[i] = Open[i]; //Set indicator value at Candlestick Open
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "MACD Above Above Zero"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer1[i] = 0;
        }
      //Indicator Buffer 2
      if(iMACD(NULL, PERIOD_CURRENT, Fast_EMA, Slow_EMA2, MACD_SMA3, PRICE_CLOSE, MODE_MAIN, i) > 0 //MACD > fixed value
      )
        {
         Buffer2[i] = Close[i]; //Set indicator value at Candlestick Close
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "MACD Above Above Zero"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer2[i] = 0;
        }
      //Indicator Buffer 3
      if(iMACD(NULL, PERIOD_CURRENT, Fast_EMA, Slow_EMA2, MACD_SMA3, PRICE_CLOSE, MODE_MAIN, i) > 0 //MACD > fixed value
      )
        {
         Buffer3[i] = High[i]; //Set indicator value at Candlestick High
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "MACD Above Above Zero"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer3[i] = 0;
        }
      //Indicator Buffer 4
      if(iMACD(NULL, PERIOD_CURRENT, Fast_EMA, Slow_EMA2, MACD_SMA3, PRICE_CLOSE, MODE_MAIN, i) > 0 //MACD > fixed value
      )
        {
         Buffer4[i] = Low[i]; //Set indicator value at Candlestick Low
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "MACD Above Above Zero"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer4[i] = 0;
        }
      //Indicator Buffer 5
      if(iMACD(NULL, PERIOD_CURRENT, Fast_EMA, Slow_EMA2, MACD_SMA3, PRICE_CLOSE, MODE_MAIN, i) < 0 //MACD < fixed value
      )
        {
         Buffer5[i] = Open[i]; //Set indicator value at Candlestick Open
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "MACD Above Below Zero"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer5[i] = 0;
        }
      //Indicator Buffer 6
      if(iMACD(NULL, PERIOD_CURRENT, Fast_EMA, Slow_EMA2, MACD_SMA3, PRICE_CLOSE, MODE_MAIN, i) < 0 //MACD < fixed value
      )
        {
         Buffer6[i] = Close[i]; //Set indicator value at Candlestick Close
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "MACD Above Below Zero"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer6[i] = 0;
        }
      //Indicator Buffer 7
      if(iMACD(NULL, PERIOD_CURRENT, Fast_EMA, Slow_EMA2, MACD_SMA3, PRICE_CLOSE, MODE_MAIN, i) < 0 //MACD < fixed value
      )
        {
         Buffer7[i] = High[i]; //Set indicator value at Candlestick High
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "MACD Above Below Zero"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer7[i] = 0;
        }
      //Indicator Buffer 8
      if(iMACD(NULL, PERIOD_CURRENT, Fast_EMA, Slow_EMA2, MACD_SMA3, PRICE_CLOSE, MODE_MAIN, i) < 0 //MACD < fixed value
      )
        {
         Buffer8[i] = Low[i]; //Set indicator value at Candlestick Low
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "MACD Above Below Zero"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer8[i] = 0;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+