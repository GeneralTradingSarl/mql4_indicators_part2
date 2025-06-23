//+------------------------------------------------------------------+
//|                                                  MTF Fractal.mq4 |
//|                                         Copyright © 2014, TrueTL |
//|                                            http://www.truetl.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, TrueTL"
#property link      "http://www.truetl.com"
#property version "1.40"
#property indicator_chart_window
#property indicator_buffers 2

extern string  Version_140                      = "www.truetl.com";
extern int     Fractal_Timeframe                = 0;
extern int     Maxbar                           = 2000;
extern color   Up_Fractal_Color                 = Red;
extern int     Up_Fractal_Symbol                = 108;
extern color   Down_Fractal_Color               = Blue;
extern int     Down_Fractal_Symbol              = 108;
extern bool    Extend_Line                      = true;
extern bool    Extend_Line_to_Background        = true;
extern bool    Show_Validation_Candle           = true;
extern color   Up_Fractal_Extend_Line_Color     = Red;
extern int     Up_Fractal_Extend_Width          = 0;
extern int     Up_Fractal_Extend_Style          = 2;
extern color   Down_Fractal_Extend_Line_Color   = Blue;
extern int     Down_Fractal_Extend_Width        = 0;
extern int     Down_Fractal_Extend_Style        = 2;

double UpBuffer[], DoBuffer[], refchk, tempref, level;
int barc;

//+------------------------------------------------------------------+
//|                                                             INIT |
//+------------------------------------------------------------------+

int init() {

   SetIndexBuffer(0,UpBuffer);
   SetIndexStyle(0,DRAW_ARROW, DRAW_ARROW, 0, Up_Fractal_Color);
   SetIndexArrow(0,Up_Fractal_Symbol);
   SetIndexBuffer(1,DoBuffer);
   SetIndexStyle(1,DRAW_ARROW, DRAW_ARROW, 0, Down_Fractal_Color);
   SetIndexArrow(1,Down_Fractal_Symbol);
   
   return(0);
}

//+------------------------------------------------------------------+
//|                                                           DEINIT |
//+------------------------------------------------------------------+

int deinit() {
   for (int i = ObjectsTotal(); i >= 0; i--) {
      if (StringSubstr(ObjectName(i),0,12) == "MTF_Fractal_") {
         ObjectDelete(ObjectName(i));
      }
   }
   
   return(0);
}

//+------------------------------------------------------------------+
//|                                                            START |
//+------------------------------------------------------------------+

int start() {
   int i, c, dif;
   tempref =   iHigh(Symbol(), Fractal_Timeframe, 1) + 
               iHigh(Symbol(), Fractal_Timeframe, 51) + 
               iHigh(Symbol(), Fractal_Timeframe, 101);
   
   if (barc != Bars || IndicatorCounted() < 0 || tempref != refchk) {
      barc = Bars;
      refchk = tempref;
   } else
      return(0);
   
   deinit();
   
   if (Fractal_Timeframe <= Period()) Fractal_Timeframe = Period();
   
   dif = Fractal_Timeframe/Period();
   
   if (Maxbar > Bars) Maxbar = Bars-10;
   
   for(i = 0; i < Maxbar; i++) {
      if (iBarShift(NULL,Fractal_Timeframe,Time[i]) < 3) {
         UpBuffer[i] = 0;
         DoBuffer[i] = 0;
         continue;
      }
      UpBuffer[i] = iFractals(NULL,Fractal_Timeframe,1,iBarShift(NULL,Fractal_Timeframe,Time[i]));
      DoBuffer[i] = iFractals(NULL,Fractal_Timeframe,2,iBarShift(NULL,Fractal_Timeframe,Time[i]));
   }
   
   if (Extend_Line) {
      for(i = 0; i < Maxbar; i++) {
         if (UpBuffer[i] > 0) {
            level = UpBuffer[i];
            for (c = i; c > 0; c--) {
               if ((Open[c] < level && Close[c] > level) || (Open[c] > level && Close[c] < level)) 
                  break;
               if (Open[c] <= level && Close[c] <= level && Open[c-1] >= level && Close[c-1] >= level) 
                  break;
               if (Open[c] >= level && Close[c] >= level && Open[c-1] <= level && Close[c-1] <= level) 
                  break;
            }
            DrawLine ("H", i, c, level, Extend_Line_to_Background, Up_Fractal_Extend_Line_Color, Up_Fractal_Extend_Width, Up_Fractal_Extend_Style);
            if (Show_Validation_Candle) UpBuffer[i-2*dif] = level;
            i += dif;         
         }
      }
      
      for(i = 0; i < Maxbar; i++) {
         if (DoBuffer[i] > 0) {
            level = DoBuffer[i];
            for (c = i; c > 0; c--) {
               if ((Open[c] < level && Close[c] > level) || (Open[c] > level && Close[c] < level)) 
                  break;
               if (Open[c] <= level && Close[c] <= level && Open[c-1] >= level && Close[c-1] >= level) 
                  break;
               if (Open[c] >= level && Close[c] >= level && Open[c-1] <= level && Close[c-1] <= level) 
                  break;
            }
            DrawLine ("L", i, c, level, Extend_Line_to_Background, Down_Fractal_Extend_Line_Color, Down_Fractal_Extend_Width, Down_Fractal_Extend_Style);
            if (Show_Validation_Candle) DoBuffer[i-2*dif] = level;
            i += dif;
         }
      }
   }
   
   return(0);
}
//+------------------------------------------------------------------+
//|                                                        DRAW LINE |
//+------------------------------------------------------------------+

void DrawLine (string dir, int i, int c, double lev, bool back, color col, int width, int style) {
   ObjectCreate("MTF_Fractal_"+dir+i,OBJ_TREND,0,0,0,0,0);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_TIME1,iTime(Symbol(),Period(),i));
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_PRICE1,lev);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_TIME2,iTime(Symbol(),Period(),c));
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_PRICE2,lev);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_RAY,0);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_BACK,back);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_COLOR,col);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_WIDTH,width);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_STYLE,style);
}