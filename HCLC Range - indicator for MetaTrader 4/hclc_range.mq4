//+------------------------------------------------------------------+
//|                                                   HCLC Range.mq4 |
//|                                         Copyright 2021, acelaert |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, acealert"
#property link      "https://www.mql5.com/en/users/acealert"
#property description "Draws two labels: High-Close and Low-Close range of the last closed candle left of the current candle. Rewrite by acealert from original code OHLC Range by file45 https://www.mql5.com/en/code/11715"
#property version   "1.00"
#property strict
#property indicator_chart_window

input color Font_Color = DodgerBlue;
input int Font_Size = 11;
input bool Font_Bold = true;
input int Left_Right = 20;
input int Up_Down = 170;
input ENUM_BASE_CORNER Corner = 1;

string Text_HC = "HC";
string Text_LC = "LC";
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
   ObjectDelete("HC_Rang");
   ObjectDelete("LC_Rang");
     
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
   string High_CLose, High_Close_Range;
   High_CLose = "HC_Rang";
   
   // High_Close_Range = DoubleToStr(MathAbs((High[1] - Close[1]) / Pointz), 2);
   High_Close_Range = DoubleToStr(MathAbs((High[1] - Close[1])/Point),0);
      
   if (ObjectFind(High_CLose) != -1) ObjectDelete(High_CLose);
   ObjectCreate(High_CLose,OBJ_LABEL,0,0,0);
   ObjectSetText(High_CLose, Text_HC + " " + High_Close_Range, Font_Size, The_Font, Font_Color);
   ObjectCreate(High_CLose, OBJ_LABEL, 0,0,0 );
   ObjectSetInteger(0,"Ask",OBJPROP_ANCHOR,corner_point);
   ObjectSet(High_CLose, OBJPROP_CORNER, Corner);
   ObjectSet(High_CLose, OBJPROP_XDISTANCE, Left_Right);
   ObjectSet(High_CLose, OBJPROP_YDISTANCE, Up_Down );
   
   string Low_Close, Low_Close_Range;
   Low_Close = "LC_Rang";
   // Low_Close_Range = DoubleToStr(MathAbs((Low[1] - Close[1]) / Pointz), 2);
   Low_Close_Range = DoubleToStr(MathAbs((Low[1] - Close[1])/Point),0);
      
   if (ObjectFind(Low_Close) != -1) ObjectDelete(Low_Close);
   ObjectCreate(Low_Close,OBJ_LABEL,0,0,0);
   ObjectSetText(Low_Close, Text_LC + " " + Low_Close_Range, Font_Size, The_Font, Font_Color);
   ObjectCreate(Low_Close, OBJ_LABEL, 0,0,0 );
   ObjectSetInteger(0,"Ask",OBJPROP_ANCHOR,corner_point);
   ObjectSet(Low_Close, OBJPROP_CORNER, Corner);
   ObjectSet(Low_Close, OBJPROP_XDISTANCE, Left_Right);
   ObjectSet(Low_Close, OBJPROP_YDISTANCE, Up_Down + 1.5*Font_Size);//}
   
   return(rates_total);
}
