//+------------------------------------------------------------------+
//|                                               0 - OHLC Range.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com 
//
//| File45 - 	https://login.mql5.com/en/users/file45/publications
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

input color Font_Color = DodgerBlue;
input int Font_Size = 11;
input bool Font_Bold = true;
input int Left_Right = 20;
input int Up_Down = 170;
input ENUM_BASE_CORNER Corner = 1;

string Text_OC = "OC";
string Text_HL = "HL";
string The_Font;
double Pointz;

ENUM_ANCHOR_POINT corner_point;

int OnInit()
{
   Pointz = Point;
    // 1, 3 & 5 digits pricing
   if (Point == 0.1) Pointz =1;
   if ((Point == 0.00001) || (Point == 0.001)) Pointz *= 10;
   
   switch(Corner)
   {
      case 0: corner_point = ANCHOR_LEFT_UPPER; break;
      case 1: corner_point = ANCHOR_LEFT_LOWER; break;
      case 2: corner_point = ANCHOR_RIGHT_LOWER; break;
      case 3: corner_point = ANCHOR_RIGHT_UPPER;
   }        
   
   if(Font_Bold == true)
   {
      The_Font = "Arial Bold";
   }
   else
   {
      The_Font = "Arial";
   }      
   
   return(INIT_SUCCEEDED);
}

int deinit()
{
   ObjectDelete("OC_Rang");
   ObjectDelete("HL_Rang");
     
   return(0);
}

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
   string Open_CLose, Open_Close_Range;
   Open_CLose = "OC_Rang";
   
   // Open_Close_Range = DoubleToStr(MathAbs((Open[1] - Close[1]) / Pointz), 2);
   Open_Close_Range = DoubleToStr(MathAbs((Open[1] - Close[1])/Point),0);
      
   if (ObjectFind(Open_CLose) != -1) ObjectDelete(Open_CLose);
   ObjectCreate(Open_CLose,OBJ_LABEL,0,0,0);
   ObjectSetText(Open_CLose, Text_OC + " " + Open_Close_Range, Font_Size, The_Font, Font_Color);
   ObjectCreate(Open_CLose, OBJ_LABEL, 0,0,0 );
   ObjectSetInteger(0,"Ask",OBJPROP_ANCHOR,corner_point);
   ObjectSet(Open_CLose, OBJPROP_CORNER, Corner);
   ObjectSet(Open_CLose, OBJPROP_XDISTANCE, Left_Right);
   ObjectSet(Open_CLose, OBJPROP_YDISTANCE, Up_Down );
   
   string High_Low, High_Low_Range;
   High_Low = "HL_Rang";
   // High_Low_Range = DoubleToStr(MathAbs((High[1] - Low[1]) / Pointz), 2);
   High_Low_Range = DoubleToStr(MathAbs((High[1] - Low[1])/Point),0);
      
   if (ObjectFind(High_Low) != -1) ObjectDelete(High_Low);
   ObjectCreate(High_Low,OBJ_LABEL,0,0,0);
   ObjectSetText(High_Low, Text_HL + " " + High_Low_Range, Font_Size, The_Font, Font_Color);
   ObjectCreate(High_Low, OBJ_LABEL, 0,0,0 );
   ObjectSetInteger(0,"Ask",OBJPROP_ANCHOR,corner_point);
   ObjectSet(High_Low, OBJPROP_CORNER, Corner);
   ObjectSet(High_Low, OBJPROP_XDISTANCE, Left_Right);
   ObjectSet(High_Low, OBJPROP_YDISTANCE, Up_Down + 1.5*Font_Size);//}
   
   return(rates_total);
}
