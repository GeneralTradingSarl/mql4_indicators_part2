//+------------------------------------------------------------------+
//|                                                iMaxMinTrends.mq4 |
//|                                      A.Lopatin & V.Bocharov 2014 |
//|                                              diver.stv@gmail.com |
//+------------------------------------------------------------------+
#property copyright "A.Lopatin & V.Bocharov 2014"
#property link      "diver.stv@gmail.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
//--- plot DayHi
#property indicator_label1  "DayHi"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrWhite
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//--- plot DayLow
#property indicator_label2  "DayLow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrWhite
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5
//--- plot WeekHi
#property indicator_label3  "WeekHi"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_SOLID
#property indicator_width3  5
//--- plot WeekLow
#property indicator_label4  "WeekLow"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrYellow
#property indicator_style4  STYLE_SOLID
#property indicator_width4  5
//--- plot MonthHi
#property indicator_label5  "MonthHi"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrAqua
#property indicator_style5  STYLE_SOLID
#property indicator_width5  5
//--- plot MonthLow
#property indicator_label6  "MonthLow"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrAqua
#property indicator_style6  STYLE_SOLID
#property indicator_width6  5
//--- plot YearHi
#property indicator_label7  "YearHi"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrRed
#property indicator_style7  STYLE_SOLID
#property indicator_width7  5
//--- plot YearLow
#property indicator_label8  "YearLow"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrRed
#property indicator_style8  STYLE_SOLID
#property indicator_width8  5

/* --- Color and width settings for the trend lines --- */
input color MonthLinesColor   = clrBlue;
input int   MonthLinesWidth   = 1;
input color WeekLinesColor    = clrRed;
input int   WeekLinesWidth    = 1;

//--- indicator buffers
double         DayHiBuffer[];
double         DayLowBuffer[];
double         WeekHiBuffer[];
double         WeekLowBuffer[];
double         MonthHiBuffer[];
double         MonthLowBuffer[];
double         YearHiBuffer[];
double         YearLowBuffer[];

// --- string names for the trend lines
string up_week_line = "UpperWeekLine", lower_week_line = "LowerWeekLine", up_month_line = "UpperMonthLine", lower_month_line = "LowerMonthLine";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,DayHiBuffer);
   SetIndexBuffer(1,DayLowBuffer);
   SetIndexBuffer(2,WeekHiBuffer);
   SetIndexBuffer(3,WeekLowBuffer);
   SetIndexBuffer(4,MonthHiBuffer);
   SetIndexBuffer(5,MonthLowBuffer);
   SetIndexBuffer(6,YearHiBuffer);
   SetIndexBuffer(7,YearLowBuffer);
   
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);
   SetIndexEmptyValue(3, 0.0);
   SetIndexEmptyValue(4, 0.0);
   SetIndexEmptyValue(5, 0.0);
   SetIndexEmptyValue(6, 0.0);
   SetIndexEmptyValue(7, 0.0);
//---
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
{
   // --- Delete lines at deinitialization
   ObjectDelete(up_week_line);
   ObjectDelete(lower_week_line);
   ObjectDelete(up_month_line);
   ObjectDelete(lower_month_line);
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
   int i = 1, ti  = iTime(Symbol(),1440,0), index = iBarShift(Symbol(), 0, ti),
       up_bar1 = iHighest (Symbol(),0,MODE_HIGH, index,1), low_bar1 = iLowest  (Symbol(),0,MODE_LOW, index,1), up_bar2 = 0, low_bar2 = 0;
   double hi_price = High[up_bar1]; // get day high value
   double low_price = Low [low_bar1]; // get day low value
   
   // --- fill buffers 0.0
   ArrayInitialize(DayHiBuffer, 0.0);
   ArrayInitialize(DayLowBuffer, 0.0);
   ArrayInitialize(WeekHiBuffer, 0.0);
   ArrayInitialize(WeekLowBuffer, 0.0);
   ArrayInitialize(MonthHiBuffer, 0.0);
   ArrayInitialize(MonthLowBuffer, 0.0);
   ArrayInitialize(YearHiBuffer, 0.0);
   ArrayInitialize(YearLowBuffer, 0.0);
   
   // --- fill buffer day high/low values  from 1st closed bar to open time of a day
   for(i = 1;i < index;i++)
   {
      DayHiBuffer[i] = hi_price;
      DayLowBuffer[i] = low_price;
   }
   // --- get time, bar index  for a open time of a week and high/low price
   ti  = iTime(Symbol(),10080,0); index = iBarShift(Symbol(), 0, ti);
   up_bar2 = iHighest (Symbol(),0,MODE_HIGH, index,1); low_bar2 = iLowest  (Symbol(),0,MODE_LOW, index,1);
   hi_price = High[up_bar2];
   low_price = Low [low_bar2];
    // --- fill buffer week high/low values  from 1st closed bar to open time of a week
   for(i = 1;i < index;i++)
   {
      WeekHiBuffer[i] = hi_price;
      WeekLowBuffer[i] = low_price;
   }
   // --- draw 2 lines from day to week for high/low
   if( up_bar1 > 0 && up_bar2 > 0 && up_bar1 != up_bar2 && PeriodSeconds() < 1440*60 )
      DrawLine(up_week_line, OBJ_TREND, Time[up_bar2], High[up_bar2], Time[up_bar1], High[up_bar1], WeekLinesColor, WeekLinesWidth);
   if( low_bar1 > 0 && low_bar2 > 0 && low_bar1 != low_bar2 && PeriodSeconds() < 1440*60 )
      DrawLine(lower_week_line, OBJ_TREND, Time[low_bar2], Low[low_bar2], Time[low_bar1], Low[low_bar1], WeekLinesColor, WeekLinesWidth);
      
   ti  = iTime(Symbol(),43200,0); index = iBarShift(Symbol(), 0, ti);
   up_bar1 = iHighest (Symbol(),0,MODE_HIGH, index,1); low_bar1 = iLowest  (Symbol(),0,MODE_LOW, index,1);
   hi_price = High[up_bar1];
   low_price = Low [low_bar1];
   
   for(i = 1;i < index;i++)
   {
      MonthHiBuffer[i] = hi_price;
      MonthLowBuffer[i] = low_price;
   }
   
   if( up_bar1 > 0 && up_bar2 > 0 && up_bar1 != up_bar2 && PeriodSeconds() < 10080*60 )
      DrawLine(up_month_line, OBJ_TREND, Time[up_bar1], High[up_bar1], Time[up_bar2], High[up_bar2], MonthLinesColor, MonthLinesWidth);
   if( low_bar1 > 0 && low_bar2 > 0 && low_bar1 != low_bar2 && PeriodSeconds() < 10080*60 )
      DrawLine(lower_month_line, OBJ_TREND, Time[low_bar1], Low[low_bar1], Time[low_bar2], Low[low_bar2], MonthLinesColor, MonthLinesWidth);
      
   ti  = iTime(Symbol(),518400,0); index = iBarShift(Symbol(), 0, ti);
   up_bar2 = iHighest (Symbol(),0,MODE_HIGH, index,1); low_bar2 = iLowest  (Symbol(),0,MODE_LOW, index,1);
   hi_price = High[up_bar2];
   low_price = Low [low_bar2];
   
   for(i = 1;i < index;i++)
   {
      YearHiBuffer[i] = hi_price;
      YearLowBuffer[i] = low_price;
   }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|               The function draws trend line                      |
//+------------------------------------------------------------------+

void DrawLine(string name,int type,datetime time1,double price1,datetime time2,double price2,color line_color,int line_width=1,int line_style=STYLE_SOLID)
{
    if(ObjectFind(name)==-1)
    {
      ObjectCreate(name,type,0,time1,price1,time2,price2);
      ObjectSet(name,OBJPROP_COLOR,line_color);
      ObjectSet(name,OBJPROP_WIDTH,line_width);
      ObjectSet(name,OBJPROP_STYLE,line_style);
    }
    else
    { 
      ObjectSet(name,OBJPROP_TIME1,time1);
      ObjectSet(name,OBJPROP_PRICE1,price1);
      ObjectSet(name,OBJPROP_TIME2,time2);
      ObjectSet(name,OBJPROP_PRICE2,price2);
      ObjectSet(name,OBJPROP_COLOR,line_color);
      ObjectSet(name,OBJPROP_STYLE,line_style);
      ObjectSet(name,OBJPROP_WIDTH,line_width);
    }
}