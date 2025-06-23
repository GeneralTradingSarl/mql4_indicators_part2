//+------------------------------------------------------------------+
//|                                       TGP_Analyzer_0125_1545.mq4 |
//+------------------------------------------------------------------+
//| Copyright Jan 2013, Greedy Pig Trading  
//| http://greedypigtrading.blogspot.com/ 
//+------------------------------------------------------------------+
/* 
////////////////////////////////////////////////////////////////////////////
TGP_Analyzer_0125_1545
Blog: http://greedypigtrading.blogspot.com/ 
BUSINESS REQUIREMENTS: 
I want to take screen shots of charts at intervals for analysis of combinations of indicators or various settings.
Great for back testing to research indicators, timing, price action etc.
When you drop it onto a chart it:
   1 reads the Pair and creates a folder to store all the pics in
   Location C:\Program Files(x86)\MetaTrader4\experts\files\Pair\pic.gif (e.g. 20130125_215859_EURUSD_60.gif)
   2 reads the timeframe and sets the interval to take the pic (e.g. on M15 chart takes pic every hour/60 minutes)
INPUT-Select Broker or Local time option.
INPUT-Enter color of Watermark
INPUT-Enter font size for Watermark
INPUT-Enter corner to display Watermark
*****************************************
PERIOD_M1   takes a pic every 15 minutes 
PERIOD_M5   takes a pic every 30 minutes 
PERIOD_M15  takes a pic every 60 minutes 
PERIOD_M30  takes a pic every 60 minutes 
PERIOD_H1   takes a pic every 240 minutes 
PERIOD_H4   takes a pic every day 
PERIOD_D1   takes a pic every week 
PERIOD_W1   takes a pic every month 
PERIOD_MN1  takes a pic every month 
*/
#property copyright "Copyright 2012, Greedy Pig Trading"
#property link      "http://greedypigtrading.blogspot.com/" 
#property indicator_chart_window
//+------------------------------------------------------------------+
//|         Variables                                                |
//+------------------------------------------------------------------+

extern bool          Pic_Broker_Time      =  true;           //True uses broker times, False uses Local times
extern string        IIIIIIIIII           =  "<<<<< Display >>>>>"; 
extern color         t_Color              =  DimGray;        //Color for Watermark
extern int           t_fontsize           =  10;             //Font Size for Watermark 
extern int           d_Corner             =  2;              //Display Corner 0= top left,1= top right, 2= bottom left, 3= bottom right

int                  Pic_Timeframe;                         //How often do you want to take Picture of the chart?
string               Pic_Folder;                            //What folder do you want to store pictures in MetaTrader4\Experts\Files\"Pic_Folder"
datetime             Pic_Trigger;                           //Variable to store the datetime values in to compare if it is time for picture
string               TAG                  = "TGP";          //The Greedy Pig

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   Pic_Folder     = Symbol()+"\\";
   if (Period() == PERIOD_M1) Pic_Timeframe = PERIOD_M15;
      else if (Period() == PERIOD_M5) Pic_Timeframe = PERIOD_M30;
         else if (Period() == PERIOD_M15) Pic_Timeframe = PERIOD_H1;
            else if (Period() == PERIOD_M30) Pic_Timeframe = PERIOD_H1;
               else if (Period() == PERIOD_H1) Pic_Timeframe = PERIOD_H4;
                  else if (Period() == PERIOD_H4) Pic_Timeframe = PERIOD_D1;
                     else if (Period() == PERIOD_D1) Pic_Timeframe = PERIOD_W1;
                        else  Pic_Timeframe = PERIOD_MN1;
                         
   Pic_Trigger    = iTime(Symbol(),Pic_Timeframe,1);            // Initially set to previous (shift of 1) to start, then in Start function it is compared to Pic_Timeframe
   string         t_IndicatorName      = WindowExpertName(); 
   
  ObjectCreate    (TAG+"Watermark", OBJ_LABEL, 0, 0, 0);          //$$$ Watermark
  ObjectSet       (TAG+"Watermark", OBJPROP_CORNER, d_Corner);
  ObjectSet       (TAG+"Watermark", OBJPROP_XDISTANCE, 5);
  ObjectSet       (TAG+"Watermark", OBJPROP_YDISTANCE, 5);   
  ObjectSetText   (TAG+"Watermark",t_IndicatorName+"~Period="+Period(),t_fontsize, "Impact", t_Color);      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   DeleteObjectsByPrefix(TAG); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
      // Check here if it is time to take a picture
   if ( Take_Pic() ) // Take_Pic returns TRUE if the Pic_Trigger is NOT equal to current Pic_Timeframe iTime value.
      {
      Take_Screen_Shot(); // calls function to take the picture
      Pic_Trigger = iTime(Symbol(),Pic_Timeframe,0); // Reset Pic_Trigger to current time to compare later
      } // END Take_Pic
   return(0);
//----
  }
//+------------------------------------------------------------------+
//+-------------------- FUNCTION LIBRARY ----------------------------+
//+------------------------------------------------------------------+
//+--------------------     Take_Pic     ----------------------------+
//+------------------------------------------------------------------+
bool Take_Pic() 
{
  if((Pic_Trigger != iTime(Symbol(),Pic_Timeframe,0))) 
      {
      return(true); // New Pic_Timeframe, Pic_Trigger is not same as current iTime of Pic_Timeframe
      }
  else
      return(false); // Pic_Trigger is same as current iTime of Pic_Timeframe
}  // END Take_Pic
//+------------------------------------------------------------------+
//+-------------------- Take_Screen_Shot()  -------------------------+
//+------------------------------------------------------------------+
void Take_Screen_Shot() 
{   
// Take "ScreenShot" of chart and put it in a .gif file  
// by symbol, Pic_Timeframe, and time (hhmmss)the picture was taken.
// Default Location C:\Program Files\MetaTrader4\experts\files\Pic_Folder value
// Set _width and _height variables to match your screen resolution settings.
// If you prefer broker time change "TimeLocal()" to "TimeCurrent()".
   int   _width     = 2000;// set to match your screen resolution numbers
   int   _height    = 1080;// set to match your screen resolution numbers
   string SCREENSHOT_FILENAME;
   if (Pic_Broker_Time) // using TimeCurrent() option for Broker times
      {
      SCREENSHOT_FILENAME = Pic_Folder + StringConcatenate(TimeYear(TimeCurrent()),PadString(DoubleToStr(TimeMonth(TimeCurrent()),0),"0",2), PadString(DoubleToStr(TimeDay(TimeCurrent()),0),"0",2),"_",
      PadString(DoubleToStr(TimeHour(TimeCurrent()),0),"0",2), PadString(DoubleToStr(TimeMinute(TimeCurrent()),0),"0",2), 
      PadString(DoubleToStr(TimeSeconds(TimeCurrent()),0),"0",2), "_", Symbol(),"_", Period(), ".gif" );
      }
      else // using TimeLocal() option for your PC times
      {
      SCREENSHOT_FILENAME = Pic_Folder + StringConcatenate(TimeYear(TimeLocal()),PadString(DoubleToStr(TimeMonth(TimeLocal()),0),"0",2), PadString(DoubleToStr(TimeDay(TimeLocal()),0),"0",2),"_",
      PadString(DoubleToStr(TimeHour(TimeLocal()),0),"0",2), PadString(DoubleToStr(TimeMinute(TimeLocal()),0),"0",2), 
      PadString(DoubleToStr(TimeSeconds(TimeLocal()),0),"0",2), "_", Symbol(), "_",Period(), ".gif" );   
      }  
  WindowScreenShot(SCREENSHOT_FILENAME, _width, _height);    // Take the Picture of the chart
  }   
//+------------------------------------------------------------------+
//+--------------------      PadString      -------------------------+
//+------------------------------------------------------------------+
string PadString(string toBePadded, string paddingChar, int paddingLength) 
{
   while(StringLen(toBePadded) <  paddingLength)
   {
      toBePadded = StringConcatenate(paddingChar,toBePadded);
   }
   return (toBePadded);
}    
//+-----------------------------------------------------   
//---------- ObDeleteObjectsByPrefix(string Prefix) ----------------------------
//+-----------------------------------------------------
void DeleteObjectsByPrefix(string Prefix)
  {
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal())
     {
       string ObjName = ObjectName(i);
       if(StringSubstr(ObjName, 0, L) != Prefix) 
         { 
           i++; 
           continue;
         }
       ObjectDelete(ObjName);
     }
  } // END DeleteObjectsByPrefix 