//+------------------------------------------------------------------+
//|                                                   Percentage.mq4 |
//|  Copyright © 2009, Arif Endro Nugroho <arif_endro@vectra.web.id> |
//|                                         http://www.vectra.web.id |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Arif E. Nugroho <arif_endro@vectra.web.id>"
#property link      "http://www.vectra.web.id"

#property indicator_chart_window
//---- input parameters
extern int       corner=2;
extern int       xdis=5;
extern int       ydis=20;
extern string    Font="Lucida Console";
extern int       FontSize=8;
extern color     FontPlus=Blue;
extern color     FontMinus=Red;
extern int       timezone=7;
extern bool      back=0;

extern bool      ShowPriceLabel=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("DailyStat");
   ObjectDelete("WeeklyStat");
   ObjectDelete("MonthlyStat");

   if(ShowPriceLabel)
     {
      ObjectDelete("PLUp50");
      ObjectDelete("PLDown50");
      ObjectDelete("PLUp100");
      ObjectDelete("PLDown100");
      ObjectDelete("PLUp150");
      ObjectDelete("PLDown150");
      ObjectDelete("PLUp200");
      ObjectDelete("PLDown200");
      ObjectDelete("+0.5");
      ObjectDelete("-0.5");
      ObjectDelete("+1.0");
      ObjectDelete("-1.0");
      ObjectDelete("+1.5");
      ObjectDelete("-1.5");
      ObjectDelete("+2.0");
      ObjectDelete("-2.0");

      ObjectDelete("PL0.0");
      ObjectDelete("0.0");
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();

   int    DayOpShift  = iBarShift(NULL, PERIOD_D1, iTime(NULL, PERIOD_D1, 0)) + 0;
   int    DayClShift  = iBarShift(NULL, PERIOD_D1, iTime(NULL, PERIOD_D1, 0)) + 0;
   double DayOpPrice=iOpen(NULL,PERIOD_D1,DayOpShift); // this should be the close of the first hour (I doesn't like this idea) :(
   double DayClPrice= iClose(NULL, PERIOD_D1, DayClShift);

//   int    WeekOpShift = iBarShift(NULL, PERIOD_H4, iTime(NULL, PERIOD_W1, 0)) - 1;
   int    WeekClShift =iBarShift(NULL, PERIOD_W1, iTime(NULL, PERIOD_W1, 0)) + 0;
   double WeekOpPrice=iOpen(NULL,PERIOD_W1,WeekClShift); // this should be the close of the first at 4H bar in the first day (this from thomson reuters)
   double WeekClPrice= iClose(NULL, PERIOD_W1, WeekClShift);

   int    MonthClShift= iBarShift(NULL, PERIOD_MN1, iTime(NULL, PERIOD_MN1, 0)) + 0;
   double MonthOpPrice= iOpen(NULL, PERIOD_MN1, MonthClShift);
   double MonthClPrice= iClose(NULL, PERIOD_MN1, MonthClShift);

   color  FontColorDayPercentGain=Silver;
   color  FontColorWeekPercentGain=Silver;
   color  FontColorMonthPercentGain=Silver;

   string DailyInfo  = "Daily....: ";
   string WeeklyInfo = "Weekly...: ";
   string MonthlyInfo= "Monthly..: ";

   if(DayOpPrice!=0) DailyInfo="Daily....: "+DoubleToStr(DayOpPrice,Digits)+"/"+DoubleToStr(DayClPrice,Digits)+" ["+DoubleToStr(MathPow(10,Digits)*MathAbs(DayClPrice-DayOpPrice),0)+"|"+DoubleToStr(100*(MathAbs(DayClPrice-DayOpPrice)/DayOpPrice),2)+"%]";
   if(WeekOpPrice!=0) WeeklyInfo="Weekly...: "+DoubleToStr(WeekOpPrice,Digits)+"/"+DoubleToStr(WeekClPrice,Digits)+" ["+DoubleToStr(MathPow(10,Digits)*MathAbs(WeekClPrice-WeekOpPrice),0)+"|"+DoubleToStr(100*(MathAbs(WeekClPrice-WeekOpPrice)/WeekOpPrice),2)+"%]";
   if(MonthOpPrice!=0) MonthlyInfo="Monthly..: "+DoubleToStr(MonthOpPrice,Digits)+"/"+DoubleToStr(MonthClPrice,Digits)+" ["+DoubleToStr(MathPow(10,Digits)*MathAbs(MonthClPrice-MonthOpPrice),0)+"|"+DoubleToStr(100*(MathAbs(MonthClPrice-MonthOpPrice)/MonthOpPrice),2)+"%]";

   if((DayClPrice-DayOpPrice)<0)
      FontColorDayPercentGain=FontMinus;
   else
      FontColorDayPercentGain=FontPlus;

   if((WeekClPrice-WeekOpPrice)<0)
      FontColorWeekPercentGain=FontMinus;
   else
      FontColorWeekPercentGain=FontPlus;

   if((MonthClPrice-MonthOpPrice)<0)
      FontColorMonthPercentGain=FontMinus;
   else
      FontColorMonthPercentGain=FontPlus;

//----
   if(ObjectFind("DailyStat")==-1) 
     {
      SetUpTextObject("DailyStat",0);
      ObjectSetText("DailyStat",DailyInfo,FontSize,Font,FontColorDayPercentGain);
        } else {
      ObjectSetText("DailyStat",DailyInfo,FontSize,Font,FontColorDayPercentGain);
     }
   if(ObjectFind("WeeklyStat")==-1) 
     {
      SetUpTextObject("WeeklyStat",10);
      ObjectSetText("WeeklyStat",WeeklyInfo,FontSize,Font,FontColorWeekPercentGain);
        } else {
      ObjectSetText("WeeklyStat",WeeklyInfo,FontSize,Font,FontColorWeekPercentGain);
     }
   if(ObjectFind("MonthlyStat")==-1) 
     {
      SetUpTextObject("MonthlyStat",20);
      ObjectSetText("MonthlyStat",MonthlyInfo,FontSize,Font,FontColorMonthPercentGain);
        } else {
      ObjectSetText("MonthlyStat",MonthlyInfo,FontSize,Font,FontColorMonthPercentGain);
     }
//----

   if(ShowPriceLabel) 
     {
      SetUpPriceLabel("PL0.0"    , Gold, 1.000*DayOpPrice);
      SetUpPLText    ("0.0"      , Gold, 1.000*DayOpPrice);
      SetUpPriceLabel("PLUp50"   , Blue, 1.005*DayOpPrice); /* up   0.50% means 100.50% from opening price right :) */
      SetUpPLText    ("+0.5"     , Blue, 1.005*DayOpPrice);
      SetUpPriceLabel("PLDown50" ,  Red, 0.995*DayOpPrice); /* down 0.50% means  99.50% from opening price right :) */
      SetUpPLText    ("-0.5"     ,  Red, 0.995*DayOpPrice);
      SetUpPriceLabel("PLUp100"  , Blue, 1.010*DayOpPrice);  /* up   1.00% means 101.00% from opening price right :) */
      SetUpPLText    ("+1.0"     , Blue, 1.010*DayOpPrice);
      SetUpPriceLabel("PLDown100",  Red, 0.990*DayOpPrice);  /* down 1.00% means  99.00% from opening price right :) */
      SetUpPLText    ("-1.0"     ,  Red, 0.990*DayOpPrice);
      SetUpPriceLabel("PLUp150"  , Blue, 1.015*DayOpPrice);  /* up   1.50% means 101.50% from opening price right :) */
      SetUpPLText    ("+1.5"     , Blue, 1.015*DayOpPrice);
      SetUpPriceLabel("PLDown150",  Red, 0.985*DayOpPrice);  /* down 1.50% means  98.50% from opening price right :) */
      SetUpPLText    ("-1.5"     ,  Red, 0.985*DayOpPrice);
      SetUpPriceLabel("PLUp200"  , Blue, 1.020*DayOpPrice);  /* up   2.00% means 102.00% from opening price right :) */
      SetUpPLText    ("+2.0"     , Blue, 1.020*DayOpPrice);
      SetUpPriceLabel("PLDown200",  Red, 0.980*DayOpPrice);  /* down 2.00% means  98.00% from opening price right :) */
      SetUpPLText    ("-2.0"     ,  Red, 0.980*DayOpPrice);
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetUpTextObject(string name,int offset)
  {
   ObjectDelete(name);
   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_BACK,back);
   ObjectSet(name,OBJPROP_CORNER,corner);
   ObjectSet(name,OBJPROP_XDISTANCE,xdis);
   ObjectSet(name,OBJPROP_YDISTANCE,ydis+offset);
   GetLastError();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetUpPLText(string Name,color Color,double price)
  {
   ObjectDelete(Name);
   ObjectCreate(Name,OBJ_TEXT,0,0,0);
   ObjectSet(Name,OBJPROP_BACK,back);
   ObjectSet(Name,OBJPROP_TIME1,Time[0]);
   ObjectSet(Name,OBJPROP_PRICE1,price); /* double price */
   ObjectSetText(Name,Name,7,Font,Color);
   GetLastError();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetUpPriceLabel(string Name,color Color,double price)
  {
   ObjectDelete(Name);
   ObjectCreate(Name,OBJ_ARROW,0,0,0);
   ObjectSet(Name,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
   ObjectSet(Name,OBJPROP_COLOR,Color);
   ObjectSet(Name,OBJPROP_TIME1,Time[0]);
   ObjectSet(Name,OBJPROP_PRICE1,price); /* double price */
   GetLastError();
  }
//+------------------------------------------------------------------+  
