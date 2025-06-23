//+------------------------------------------------------------------+
//|                                                          GMT.mq4 |
//|                                     Copyright 2020,PHILIP PANKAJ |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020,PHILIP PANKAJ"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
input int x_axis=0;
input int y_axis=20;
input color font_color=clrWhiteSmoke;
input int font_size=7;
int Interval=1;

string box;
string valuestr;
ENUM_LINE_STYLE         style=STYLE_SOLID;
int                     line_width=1;
ENUM_BORDER_TYPE        border=BORDER_FLAT;
string                  font="Verdana Bold";
double                  angle=0.0;

//+------------------------------------------------------------------+
//|Initialization                                                               |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
   EventSetTimer(Interval);
   //---
   return(INIT_SUCCEEDED);
}  

//+------------------------------------------------------------------+
//|Deinitialization                                                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(ChartID(),valuestr);
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
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnTimer()
{
   box="box";
   StringAdd(box,string(x_axis));
   StringAdd(box,string(y_axis));


   valuestr="value";
   StringAdd(valuestr,string(x_axis));
   StringAdd(valuestr,string(y_axis));

   ObjectDelete(ChartID(),valuestr);
   ObjectCreate(ChartID(),valuestr,OBJ_LABEL,0,0,0) ;
   ObjectSetInteger(ChartID(),valuestr,OBJPROP_XDISTANCE,x_axis+10);
   ObjectSetInteger(ChartID(),valuestr,OBJPROP_YDISTANCE,y_axis);
   ObjectSetString(ChartID(),valuestr,OBJPROP_TEXT,TimeToStr(TimeGMT(),TIME_DATE |TIME_SECONDS));
   ObjectSetString(ChartID(),valuestr,OBJPROP_FONT,font);
   ObjectSetInteger(ChartID(),valuestr,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(ChartID(),valuestr,OBJPROP_ANGLE,angle);
   ObjectSetInteger(ChartID(),valuestr,OBJPROP_COLOR,font_color);
   ObjectSetInteger(ChartID(),valuestr,OBJPROP_HIDDEN,true);
   ObjectSetInteger(ChartID(),valuestr,OBJPROP_SELECTABLE,false);
}