//+------------------------------------------------------------------+
//|                                               ^L_Correlation.mq4 |
//|                                        Copyright © 2008, lotos4u |
//|                                                lotos4u@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, lotos4u"
#property link      "lotos4u@gmail.com"

#define CLOSE_MODE 0
#define OPENCLOSE_MODE 1
#define CLOSE_RELATIVE_MODE 2
//#define OPENCLOSE_RELATIVE_MODE 3

#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 1
#property indicator_buffers 8

#property indicator_color1 Aqua
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Chocolate
#property indicator_color5 MediumVioletRed
#property indicator_color6 DarkOrange
#property indicator_color7 Magenta
#property indicator_color8 Lime

#property indicator_width1 1
#property indicator_width2 2


#property indicator_level1 0.5
#property indicator_level2 0.0
#property indicator_level3 -0.5
#property indicator_levelcolor BlueViolet

#include <stderror.mqh>
#include <stdlib.mqh>


extern int Mode = CLOSE_RELATIVE_MODE;
extern string Pair = "USDCHF";
extern bool ShowCorrelation = false;
extern bool ShowMA = true;
extern int CorrelationRadius = 15;
extern int MA_Period = 10;
extern int ResultingBars = 0;

extern string FontName = "Verdana";
extern int FontSize = 10;
extern color FontColor = Black;

double Correlation[], CorrelationBuffer[], AverageCorrelationBuffer[];
double AverageX, AverageY, AverageXY, DispersionX, DispersionY, CovariationXY;
int CalculateCounter, ValidDataCounter;
string ShortName = "L_Correlation";



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{
   ShortName = ShortName + " (" + Symbol() + "-" + Pair + ", " + Mode + ", " + CorrelationRadius + ", " + MA_Period + ")";
   IndicatorShortName(ShortName);
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, CorrelationBuffer);
   SetIndexEmptyValue(0, 0.0);

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, AverageCorrelationBuffer);
   SetIndexEmptyValue(1, 0.0);
   
   CalculateCounter = 0;
   ValidDataCounter = 0;
   
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   CalculateCounter = 0;
   ValidDataCounter = 0;
   DeleteObjectsByPhrase(ShortName);
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   double AverageCorrelation;
   int AverageLength;
   int window = WindowFind(ShortName);
   string ID = ShortName + " Label";
   if(ObjectCreate(ID, OBJ_LABEL, window, 0, 0))
   {
      ObjectSet(ID, OBJPROP_CORNER, 2);
      ObjectSet(ID, OBJPROP_XDISTANCE, 0);
      ObjectSet(ID, OBJPROP_YDISTANCE, FontSize);
   }

   if(CalculateCounter > 0 && Volume[0] > 1)return(0);

   
   int limit = Bars, counter = 0;

   ArrayResize(Correlation, limit);
   ArrayInitialize(Correlation, 0.0);
   ArraySetAsSeries(Correlation, true);

   for(int i = 0; i < limit; i++)
   {
      getAverages(i, CorrelationRadius);
      if(DispersionX*DispersionY > 0 && MathSqrt(DispersionX*DispersionY) > 0)
      {
         counter++;
         Correlation[i] = CovariationXY/MathSqrt(DispersionX*DispersionY);
      }
      else
      {
         Correlation[i] = 0.0;
      }
      if(ShowCorrelation)
         CorrelationBuffer[i] = Correlation[i];
   }
   
   for(i = 0; i < counter; i++)
   {
      AverageCorrelationBuffer[i] = iMAOnArray(Correlation, 0, MA_Period, 0, MODE_SMA, i);
   }
   
   AverageLength = MathMin(ResultingBars, counter);
   if(ResultingBars == 0)
      AverageLength = counter;
   AverageCorrelation = iMAOnArray(Correlation, 0, AverageLength, 0, MODE_SMA, 0);
   
   ObjectSetText(ID, Symbol() + " <-> " + Pair + "   " + DoubleToStr(AverageCorrelation, 2) + " (по " + AverageLength + " барам)", FontSize, FontName, FontColor);

   CalculateCounter = MathMin(1, counter);
   return(0);
}


double getX(int shift)
{
   switch(Mode)
   {
      case CLOSE_MODE: return(iClose(Symbol(), 0, shift));
      case OPENCLOSE_MODE: return(iClose(Symbol(), 0, shift) - iOpen(Symbol(), 0, shift));
      case CLOSE_RELATIVE_MODE: return(iClose(Symbol(), 0, shift)/iHigh(Symbol(), 0, shift));
   }
}



double getY(int shift)
{
   switch(Mode)
   {
      case CLOSE_MODE: return(iClose(Pair, 0, shift));
      case OPENCLOSE_MODE: return(iClose(Pair, 0, shift) - iOpen(Pair, 0, shift));
      case CLOSE_RELATIVE_MODE: return(iClose(Pair, 0, shift)/iHigh(Pair, 0, shift));
   }
}



bool isValidTime(int shift)
{
   return(iTime(Symbol(), 0, shift) == iTime(Pair, 0, shift));
}




bool isValidPrice(int shift)
{
   return((iOpen(Symbol(), 0, shift) > 0.0) && (iOpen(Pair, 0, shift) > 0.0));
}



double getAverages(int start, int interval)
{
   double retVal = 0;
   ValidDataCounter = 0;
   AverageX = 0;
   AverageY = 0;
   AverageXY = 0;
   DispersionX = 0;
   DispersionY = 0;
   for(int i = 0; i < interval; i++)
   {
      if(isValidTime(start + i))
      {
         if(!isValidPrice(start + i))
         {
            Sleep(2000);
            if(!isValidPrice(start + i))
               continue;
         }
         ValidDataCounter++;
         AverageX += getX(start + i);
         AverageY += getY(start + i);
         AverageXY += getX(start + i)*getY(start + i);
      }
   }
   if(ValidDataCounter == 0)return;
   AverageX /= ValidDataCounter;
   AverageY /= ValidDataCounter;
   AverageXY /= ValidDataCounter;

   ValidDataCounter = 0;
   for(i = 0; i < interval; i++)
   {
      if(isValidTime(start + i))
      {
         if(!isValidPrice(start + i))
         {
            Sleep(2000);
            if(!isValidPrice(start + i))
               continue;
         }
         ValidDataCounter++;
         DispersionX += (getX(start + i) - AverageX)*(getX(start + i) - AverageX);
         DispersionY += (getY(start + i) - AverageY)*(getY(start + i) - AverageY);
      }
   }
   if(ValidDataCounter == 0)return;
   DispersionX /= ValidDataCounter;
   DispersionY /= ValidDataCounter;
   
   CovariationXY = AverageXY - AverageX*AverageY;
}





/////////////////////////////////////////////////////////
//”дал€ютс€ все объекты, в именах которых содержитс€ строка
//Phrase (расположенна€ в произвольной позиции)
/////////////////////////////////////////////////////////
void DeleteObjectsByPhrase(string Phrase)
{
   string ObjName;
   for(int i = ObjectsTotal()-1; i >= 0; i--)
   {
      ObjName = ObjectName(i);
      if(StringFind(ObjName, Phrase, 0) > -1) 
      { 
         ObjectDelete(ObjName);
      }
   }
}