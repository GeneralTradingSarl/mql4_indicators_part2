//+------------------------------------------------------------------+
//|                                         Market_Sessions_Indi.mq4 |
//|                                       Copyright 2010, KoliEr Li. |
//|                                                 http://kolier.li |
//+------------------------------------------------------------------+

/*
 * I here get paid to program for you. Just $15 for all scripts.
 *
 * I am a bachelor major in Financial-Mathematics.
 * I am good at programming in MQL for Meta Trader 4 platform. Senior Level. Have done hundreds of scripts.
 * No matter what it is, create or modify any indicators, expert advisors and scripts.
 * I will ask these jobs which are not too large, price from $15, surely refundable if you are not appreciate mine.
 * All products will deliver in 3 days.
 * Also, I am providing EA, Indicator and Trade System Improvement Consultant services, contact me for the detail.
 * If you need to have it done, don't hesitate to contact me at: kolier.li@gmail.com
 */

//+------------------------------------------------------------------+
//| Indicator Properties                                             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, KoliEr Li."
#property link      "http://kolier.li"
// Client: 
// Tags: Market Sessions, Time, Period
// Revision: 1

#property indicator_separate_window
#property indicator_maximum 5
#property indicator_minimum 0

//+------------------------------------------------------------------+
//| Universal Constants                                              |
//+------------------------------------------------------------------+
 
//+------------------------------------------------------------------+
//| User input variables                                             |
//+------------------------------------------------------------------+
extern string IndicatorName = "Market_Sessions_Indi";
extern string IndicatorVersion = "1.0";            // The version number of this script
extern string      ProjectPage = "http://kolier.li/indicator/kmsi-kolier-market-sessions-indicator";            // The project landing page
extern int    ShowLinesDayBack = 10; // Set to 0, count all
//extern double     ServerGMT = 0;
extern bool ShowPositionLabel = true;
extern string Position = "Europe,America,Asia,Pacific";
extern string Time_Start = "07:00,13:00,00:00,21:00";
extern string Time_End = "17:00,23:00,10:00,7:00";
extern string Width = "2,2,2,2";
extern string ColorSheet = "http://kolier.li/example/mt4-color-sheet";
extern string Color = "Red,Yellow,Blue,Green";

//+------------------------------------------------------------------+
//| Universal variables                                              |
//+------------------------------------------------------------------+
string positions[1], times_start[1], times_end[1];
color colors[1];
int widths[1];
bool drawed_positions=false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName(IndicatorName);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   
   explodeStr(positions, Position, ",");
   explodeStr(times_start, Time_Start, ",");
   explodeStr(times_end, Time_End, ",");
   explodeStr2Color(colors, Color, ",");
   explodeStr2Int(widths, Width, ",");
   
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   objClear(IndicatorName);
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int bars_counted = IndicatorCounted();
   if(bars_counted < 0) {
      return(1);
   }
   else if(bars_counted > 0) {
      bars_counted--;
   }
   int limit = Bars - bars_counted;
   int bars_of_day = 86400/(Period()*60);
   if(limit > ShowLinesDayBack*bars_of_day && ShowLinesDayBack > 0) {
      limit = ShowLinesDayBack*bars_of_day;
   }
   
   int size_positions = ArraySize(positions);
   datetime time_start, time_end;   
   
   int i, j;
   
   // Draw once, and leave the control to the user
   if(ShowPositionLabel && !drawed_positions) {
      drawed_positions = true;
      for(i=0; i<size_positions; i++) {
         objLabel(IndicatorName+"_"+positions[i], positions[i], 3, 15, 16*(i+1), 1, colors[i]);
      }
   }
   
   for(j=limit; j>=0; j--) {
      for(i=0; i<size_positions; i++) {
         time_start = StrToTime(TimeToStr(Time[j],TIME_DATE)+" "+times_start[i]);
         time_end = StrToTime(TimeToStr(Time[j],TIME_DATE)+" "+times_end[i]);
         // Sesstion start yesterday
         if(time_end<time_start) {
            // Sesstion start today, cross tomorrow
            if(Time[j]>=time_start) {
               time_end += 86400;
            }
            else {
               time_start -= 86400;
            }
         }
         
         objTrendLine(IndicatorName+"_"+positions[i]+"_"+time_start, time_start, i+1, time_end, i+1, 1, widths[i], colors[i], STYLE_SOLID, false);
      }
   }
   


   
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Explode String @http://kolier.li                                 |
//+------------------------------------------------------------------+  
void explodeStr(string& arr[], string text_arr, string separator)
  {
    int    start = 0,
           length,
           array_size;
    bool   eos = false;
    
    ArrayResize(arr, 0);
    
    while(eos==false) {
      length = StringFind(text_arr,separator,start)-start;
      if(length < 0) {
         // Avoid empty string
         if(StringLen(text_arr)==0) {
            return;
         }
         eos = true;
         length = StringLen(text_arr)-start;
      }
      
      array_size = ArraySize(arr);
      ArrayResize(arr, array_size+1);
      arr[array_size] = StringSubstr(text_arr, start, length);
      start += length+1;
    }
  }
  
//+------------------------------------------------------------------+
//| Explode String to Integer @http://kolier.li                      |
//+------------------------------------------------------------------+  
void explodeStr2Int(int& arr[], string text_arr, string separator)
  {
    int    start = 0,
           length,
           array_size;
    bool   eos = false;
    
    ArrayResize(arr, 0);
    
    while(eos==false) {
      length = StringFind(text_arr,separator,start)-start;
      if(length < 0) {
         // Avoid empty string
         if(StringLen(text_arr)==0) {
            return;
         }
         eos = true;
         length = StringLen(text_arr)-start;
      }
      
      array_size = ArraySize(arr);
      ArrayResize(arr, array_size+1);
      arr[array_size] = StrToInteger(StringSubstr(text_arr, start, length));
      start += length+1;
    }
  }
  
//+------------------------------------------------------------------+
//| Explode String to Integer @http://kolier.li                      |
//+------------------------------------------------------------------+  
void explodeStr2Color(color& arr[], string text_arr, string separator)
  {
    int    start = 0,
           length,
           array_size;
    bool   eos = false;
    
    ArrayResize(arr, 0);
    
    while(eos==false) {
      length = StringFind(text_arr,separator,start)-start;
      if(length < 0) {
         // Avoid empty string
         if(StringLen(text_arr)==0) {
            return;
         }
         eos = true;
         length = StringLen(text_arr)-start;
      }
      
      array_size = ArraySize(arr);
      ArrayResize(arr, array_size+1);
      arr[array_size] = StrToColor(StringSubstr(text_arr, start, length));
      start += length+1;
    }
  }
  
//+------------------------------------------------------------------+
//| Clear Objects @http://kolier.li                                  |
//+------------------------------------------------------------------+
void objClear(string prefix) 
  {
   string name;
   int obj_total = ObjectsTotal();
   for (int i=obj_total-1; i>=0; i--) {
      name = ObjectName(i);
      if (StringFind(name, prefix) == 0) ObjectDelete(name);
   }
  }  
  
//+------------------------------------------------------------------+
//| Set object Trend Line, create if not exist yet @http://kolier.li |
//+------------------------------------------------------------------+
void objTrendLine(string name, datetime time_1, double price_1, datetime time_2, double price_2, int window=0, int width=1, color col=White, int style=STYLE_SOLID, bool ray=true)
  {
   if(ObjectFind(name)==-1) {
      ObjectCreate(name, OBJ_TREND, window, time_1, price_1, time_2, price_2);
   }
   ObjectSet(name, OBJPROP_PRICE1, price_1);
   ObjectSet(name, OBJPROP_PRICE2, price_2);
   ObjectSet(name, OBJPROP_TIME1, time_1);
   ObjectSet(name, OBJPROP_TIME2, time_2);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_COLOR, col);
   ObjectSet(name, OBJPROP_STYLE, style);
   ObjectSet(name, OBJPROP_RAY, ray);
  }
  
//+------------------------------------------------------------------+
//| Set object Label, create if not exist yet @http://kolier.li      |
//+------------------------------------------------------------------+
void objLabel(string name, string tex, int corner, int position_x, int position_y, int window=0, color tex_color=White, string tex_font="Arial", int tex_size=12)
  {
   if(ObjectFind(name)==-1) {
      ObjectCreate(name, OBJ_LABEL, window, 0, 0);
   }
   ObjectSet(name, OBJPROP_CORNER, corner);
   ObjectSet(name, OBJPROP_XDISTANCE, position_x);
   ObjectSet(name, OBJPROP_YDISTANCE, position_y);
   ObjectSetText(name, tex, tex_size, tex_font, tex_color);
  }
  
//+------------------------------------------------------------------+
//| String to Color @http:/kolier.li                                 |
//+------------------------------------------------------------------+
int StrToColor(string str)
  {
   str = StringLower(str);
   if (str == "aliceblue")              return(0xFFF8F0);
   if (str == "antiquewhite")           return(0xD7EBFA);
   if (str == "aqua")                   return(0xFFFF00);
   if (str == "aquamarine")             return(0xD4FF7F);
   if (str == "beige")                  return(0xDCF5F5);
   if (str == "bisque")                 return(0xC4E4FF);
   if (str == "black")                  return(0x000000);
   if (str == "blanchedalmond")         return(0xCDEBFF);
   if (str == "blue")                   return(0xFF0000);
   if (str == "blueviolet")             return(0xE22B8A);
   if (str == "brown")                  return(0x2A2AA5);
   if (str == "burlywood")              return(0x87B8DE);
   if (str == "cadetblue")              return(0xA09E5F);
   if (str == "chartreuse")             return(0x00FF7F);
   if (str == "chocolate")              return(0x1E69D2);
   if (str == "coral")                  return(0x507FFF);
   if (str == "cornflowerblue")         return(0xED9564);
   if (str == "cornsilk")               return(0xDCF8FF);
   if (str == "crimson")                return(0x3C14DC);
   if (str == "darkblue")               return(0x8B0000);
   if (str == "darkgoldenrod")          return(0x0B86B8);
   if (str == "darkgray")               return(0xA9A9A9);
   if (str == "darkgreen")              return(0x006400);
   if (str == "darkkhaki")              return(0x6BB7BD);
   if (str == "darkolivegreen")         return(0x2F6B55);
   if (str == "darkorange")             return(0x008CFF);
   if (str == "darkorchid")             return(0xCC3299);
   if (str == "darksalmon")             return(0x7A96E9);
   if (str == "darkseagreen")           return(0x8BBC8F);
   if (str == "darkslateblue")          return(0x8B3D48);
   if (str == "darkslategray")          return(0x4F4F2F);
   if (str == "darkturquoise")          return(0xD1CE00);
   if (str == "darkviolet")             return(0xD30094);
   if (str == "deeppink")               return(0x9314FF);
   if (str == "deepskyblue")            return(0xFFBF00);
   if (str == "dimgray")                return(0x696969);
   if (str == "dodgerblue")             return(0xFF901E);
   if (str == "firebrick")              return(0x2222B2);
   if (str == "forestgreen")            return(0x228B22);
   if (str == "gainsboro")              return(0xDCDCDC);
   if (str == "gold")                   return(0x00D7FF);
   if (str == "goldenrod")              return(0x20A5DA);
   if (str == "gray")                   return(0x808080);
   if (str == "green")                  return(0x008000);
   if (str == "greenyellow")            return(0x2FFFAD);
   if (str == "honeydew")               return(0xF0FFF0);
   if (str == "hotpink")                return(0xB469FF);
   if (str == "indianred")              return(0x5C5CCD);
   if (str == "indigo")                 return(0x82004B);
   if (str == "ivory")                  return(0xF0FFFF);
   if (str == "khaki")                  return(0x8CE6F0);
   if (str == "lavender")               return(0xFAE6E6);
   if (str == "lavenderblush")          return(0xF5F0FF);
   if (str == "lawngreen")              return(0x00FC7C);
   if (str == "lemonchiffon")           return(0xCDFAFF);
   if (str == "lightblue")              return(0xE6D8AD);
   if (str == "lightcoral")             return(0x8080F0);
   if (str == "lightcyan")              return(0xFFFFE0);
   if (str == "lightgoldenrod")         return(0xD2FAFA);
   if (str == "lightgray")              return(0xD3D3D3);
   if (str == "lightgreen")             return(0x90EE90);
   if (str == "lightpink")              return(0xC1B6FF);
   if (str == "lightsalmon")            return(0x7AA0FF);
   if (str == "lightseagreen")          return(0xAAB220);
   if (str == "lightskyblue")           return(0xFACE87);
   if (str == "lightslategray")         return(0x998877);
   if (str == "lightsteelblue")         return(0xDEC4B0);
   if (str == "lightyellow")            return(0xE0FFFF);
   if (str == "lime")                   return(0x00FF00);
   if (str == "limegreen")              return(0x32CD32);
   if (str == "linen")                  return(0xE6F0FA);
   if (str == "magenta")                return(0xFF00FF);
   if (str == "maroon")                 return(0x000080);
   if (str == "mediumaquamarine")       return(0xAACD66);
   if (str == "mediumblue")             return(0xCD0000);
   if (str == "mediumorchid")           return(0xD355BA);
   if (str == "mediumpurple")           return(0xDB7093);
   if (str == "mediumseagreen")         return(0x71B33C);
   if (str == "mediumslateblue")        return(0xEE687B);
   if (str == "mediumspringgreen")      return(0x9AFA00);
   if (str == "mediumturquoise")        return(0xCCD148);
   if (str == "mediumvioletred")        return(0x8515C7);
   if (str == "midnightblue")           return(0x701919);
   if (str == "mintcream")              return(0xFAFFF5);
   if (str == "mistyrose")              return(0xE1E4FF);
   if (str == "moccasin")               return(0xB5E4FF);
   if (str == "navajowhite")            return(0xADDEFF);
   if (str == "navy")                   return(0x800000);
   if (str == "none")                   return(C'0x00,0x00,0x00');
   if (str == "oldlace")                return(0xE6F5FD);
   if (str == "olive")                  return(0x008080);
   if (str == "olivedrab")              return(0x238E6B);
   if (str == "orange")                 return(0x00A5FF);
   if (str == "orangered")              return(0x0045FF);
   if (str == "orchid")                 return(0xD670DA);
   if (str == "palegoldenrod")          return(0xAAE8EE);
   if (str == "palegreen")              return(0x98FB98);
   if (str == "paleturquoise")          return(0xEEEEAF);
   if (str == "palevioletred")          return(0x9370DB);
   if (str == "papayawhip")             return(0xD5EFFF);
   if (str == "peachpuff")              return(0xB9DAFF);
   if (str == "peru")                   return(0x3F85CD);
   if (str == "pink")                   return(0xCBC0FF);
   if (str == "plum")                   return(0xDDA0DD);
   if (str == "powderblue")             return(0xE6E0B0);
   if (str == "purple")                 return(0x800080);
   if (str == "red")                    return(0x0000FF);
   if (str == "rosybrown")              return(0x8F8FBC);
   if (str == "royalblue")              return(0xE16941);
   if (str == "saddlebrown")            return(0x13458B);
   if (str == "salmon")                 return(0x7280FA);
   if (str == "sandybrown")             return(0x60A4F4);
   if (str == "seagreen")               return(0x578B2E);
   if (str == "seashell")               return(0xEEF5FF);
   if (str == "sienna")                 return(0x2D52A0);
   if (str == "silver")                 return(0xC0C0C0);
   if (str == "skyblue")                return(0xEBCE87);
   if (str == "slateblue")              return(0xCD5A6A);
   if (str == "slategray")              return(0x908070);
   if (str == "snow")                   return(0xFAFAFF);
   if (str == "springgreen")            return(0x7FFF00);
   if (str == "steelblue")              return(0xB48246);
   if (str == "tan")                    return(0x8CB4D2);
   if (str == "teal")                   return(0x808000);
   if (str == "thistle")                return(0xD8BFD8);
   if (str == "tomato")                 return(0x4763FF);
   if (str == "turquoise")              return(0xD0E040);
   if (str == "violet")                 return(0xEE82EE);
   if (str == "wheat")                  return(0xB3DEF5);
   if (str == "white")                  return(0xFFFFFF);
   if (str == "whitesmoke")             return(0xF5F5F5);
   if (str == "yellow")                 return(0x00FFFF);
   if (str == "yellowgreen")            return(0x32CD9A);
   
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Converts any uppercase characters in a string to lowercase       |
//| Usage: string x=StringUpper("The Quick Brown Fox")               |
//|   returns x = "the quick brown fox"                              |
//+------------------------------------------------------------------+
string StringLower(string str)
  {
   string outstr = "";
   string lower  = "abcdefghijklmnopqrstuvwxyz";
   string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   for(int i=0; i<StringLen(str); i++)  {
     int t1 = StringFind(upper,StringSubstr(str,i,1),0);
     if (t1 >=0)  
       outstr = outstr + StringSubstr(lower,t1,1);
     else
       outstr = outstr + StringSubstr(str,i,1);
   }
   return(outstr);
  }