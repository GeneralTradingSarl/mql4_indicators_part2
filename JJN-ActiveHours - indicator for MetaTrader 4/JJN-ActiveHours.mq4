//+------------------------------------------------------------------+
//|                                              JJN-ActiveHours.mq4 |
//|                                      Copyright © 2010, JJ Newark |
//|                                           http://jjnewark.atw.hu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, JJ Newark"
#property link      "http://jjnewark.atw.hu"
//---- indicator settings
#property  indicator_chart_window
//---- indicator parameters
extern string   __Copyright__               = "http://jjnewark.atw.hu";
extern string   _IndicatorSetup_            = ">>> Indicator Setup:<<<";
extern int      Start_Hour                  = 9;
extern int      Stop_Hour                   = 21;
extern int      BarsToProcess               = 500;
extern string   _DisplaySetup_              = ">>> Display Setup:<<<";
extern int      LineWidth                   = 1;
extern color    LineColor                   = Lavender;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   Comment(">> JJN-ActiveHours || http://jjnewark.atw.hu");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int w=0; w<BarsToProcess; w++)
     {
      ObjectDelete("_HourLines"+w);
     }
   Comment("");
//----
   return(0);
  }
//

int start()
  {
   if (Bars<BarsToProcess) return(-1);
  
//---- 
   for(int w=0; w<BarsToProcess; w++)
     {
      ObjectDelete("_HourLines"+w);
     }
   Comment("");

   for(w=0; w<BarsToProcess; w++)
     {
      if(Start_Hour<Stop_Hour)
        {
         if(TimeHour(Time[w])>=Start_Hour && TimeHour(Time[w])<Stop_Hour)
           {
            ObjectCreate("_HourLines"+w,OBJ_TREND,0,Time[w],0.0001,Time[w],0.001);
            ObjectSet("_HourLines"+w,OBJPROP_RAY,TRUE);
            ObjectSet("_HourLines"+w,OBJPROP_BACK,TRUE); // obj in the background
            ObjectSet("_HourLines"+w,OBJPROP_STYLE,STYLE_SOLID);
            ObjectSet("_HourLines"+w,OBJPROP_WIDTH,LineWidth);
            ObjectSet("_HourLines"+w,OBJPROP_COLOR,LineColor);
           }
        }
      else if(Start_Hour>Stop_Hour)
        {
         if(TimeHour(Time[w])>=Start_Hour || TimeHour(Time[w])<Stop_Hour)
           {
            ObjectCreate("_HourLines"+w,OBJ_TREND,0,Time[w],0.0001,Time[w],0.001);
            ObjectSet("_HourLines"+w,OBJPROP_RAY,TRUE);
            ObjectSet("_HourLines"+w,OBJPROP_BACK,TRUE); // obj in the background
            ObjectSet("_HourLines"+w,OBJPROP_STYLE,STYLE_SOLID);
            ObjectSet("_HourLines"+w,OBJPROP_WIDTH,LineWidth);
            ObjectSet("_HourLines"+w,OBJPROP_COLOR,LineColor);
           }
        }
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
