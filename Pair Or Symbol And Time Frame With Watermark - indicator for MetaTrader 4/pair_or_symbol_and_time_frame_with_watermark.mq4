//+------------------------------------------------------------------+
//|                 Pair Or Symbol And Time Frame With Watermark.mq4 |
//|                                                    Dwi Sudarsono |
//|                                        https://t.me/DwiSudarsono |
//+------------------------------------------------------------------+
#property copyright "Dwi Sudarsono"
#property link      "https://t.me/DwiSudarsono"
#property version   "1.00"
#property description "Pair Or Symbol And Time Frame With Watermark"
#property strict
#property indicator_chart_window
#property indicator_plots 0
//---- input parameters
input ENUM_BASE_CORNER BASE_CORNER = CORNER_RIGHT_LOWER;
input int sidFontSize              = 45;
input string sidFontName           = "Times New Roman";
input string NoteRedGreenBlue      = "Red/Green/Blue each 0..255";
input int RGBRed                   = 30;
input int RGBGreen                 = 30;
input int RGBBlue                  = 30;
input int sidXPos                  = 400;
input int sidYPos                  = 70;
//---- data
string Pair = "Symbol";
int RGB = 0;
string tf;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   ObjectsDeleteAll(0);
   Comment("");
   switch(Period())
     {
      case PERIOD_M1:
         tf="m1";
         break;
      case PERIOD_M5:
         tf="m5";
         break;
      case PERIOD_M15:
         tf="m15";
         break;
      case PERIOD_M30:
         tf="m30";
         break;
      case PERIOD_H1:
         tf="h1";
         break;
      case PERIOD_H4:
         tf="h4";
         break;
      case PERIOD_D1:
         tf="d1";
         break;
      case PERIOD_W1:
         tf="w1";
         break;
      case PERIOD_MN1:
         tf="mn1";
         break;
      default:
         tf="Unknown";
         break;
     }
   if(RGBRed > 255 || RGBGreen > 255 || RGBBlue > 255)
     {
      Alert("Watermark Red/Green/Blue components must each be in range 0..255");
     }
   RGB = (RGBBlue << 16);
   RGB |= (RGBGreen << 8);
   RGB |= RGBRed;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0);
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
   watermark(Pair, tf + Symbol(), sidFontSize, sidFontName, RGB, sidXPos, sidYPos);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void watermark(string obj, string text, int fontSize, string fontName, color colour, int xPos, int yPos)
  {
   ObjectCreate(0,obj, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0,obj,OBJPROP_TEXT, text);
   ObjectSetInteger(0,obj,OBJPROP_COLOR,colour);
   ObjectSetString(0,obj,OBJPROP_FONT,fontName);
   ObjectSetInteger(0,obj,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,obj, OBJPROP_CORNER, BASE_CORNER);
   ObjectSetInteger(0,obj, OBJPROP_XDISTANCE, xPos);
   ObjectSetInteger(0,obj, OBJPROP_YDISTANCE, yPos);
   ObjectSetInteger(0,obj, OBJPROP_BACK, true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
