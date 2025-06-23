//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Bugscoder Studio"
#property link      "https://www.bugscoder.com/"
#property version   "1.00"
#property strict
#property indicator_separate_window

#property indicator_buffers 2
#property indicator_minimum 0
#property indicator_maximum 180
#property indicator_type1   DRAW_NONE
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlack
#property indicator_width2  1

input int MA_PERIOD = 5;
input ENUM_MA_METHOD MA_METHOD = MODE_EMA;
input ENUM_APPLIED_PRICE MA_PRICE = PRICE_CLOSE;

double ma[], angle[];
string obj_prefix = "maangle_";

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorDigits(Digits);

   SetIndexLabel(0, "ma");
   SetIndexBuffer(0, ma);
   SetIndexLabel(1, "angle");
   SetIndexBuffer(1, angle);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
  {

   int startPos = rates_total-prev_calculated-3;
   if(startPos <= 2)
     {
      startPos = 2;
     }

   for(int pos=startPos; pos>=0; pos--)
     {
      ma[pos] = iMA(NULL, 0, MA_PERIOD, 0, MA_METHOD, MA_PRICE, pos);

      if(ma[pos+2] == EMPTY_VALUE || ma[pos+1] == EMPTY_VALUE)
        {
         continue;
        }

      double maND[3];
      maND[0] = NormalizeDouble(ma[pos]/Point, 0);
      maND[1] = NormalizeDouble(ma[pos+1]/Point, 0);
      maND[2] = NormalizeDouble(ma[pos+2]/Point, 0);

      double a = MathPow(1-2, 2)+MathPow(maND[2]-maND[1], 2);
      double b = MathPow(2-3, 2)+MathPow(maND[1]-maND[0], 2);
      double c = MathPow(1-3, 2)+MathPow(maND[2]-maND[0], 2);

      double rad   = MathArccos((a+b-c)/(2*MathSqrt(a)*MathSqrt(b)));
      angle[pos+1] = rad*(180/M_PI);
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, obj_prefix);
  }

//+------------------------------------------------------------------+
//| Time To String without semicolon and dot                         |
//+------------------------------------------------------------------+
string TimeCleanStr(int pos)
  {
   string _time = TimeToStr(Time[pos], TIME_DATE|TIME_MINUTES);

   StringReplace(_time, ":", "");
   StringReplace(_time, ".", "");
   StringReplace(_time, " ", "");

   return _time;
  }
//+------------------------------------------------------------------+
