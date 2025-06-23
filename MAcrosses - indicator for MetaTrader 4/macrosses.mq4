//+-------------------------------------------------------------------------------------------------------+
//|                                                                                         MAcrosses.mq4 |
//|                                                                        Copyright © 2011, Matus German |                                                                                         
//|                                                                             http://www.MTexperts.net/ |
//| Counts crosses off MAs, it shows % that all MAs are above slower MAs                                  |
//| If an MA crosses above another, the indicator rises                                                   |
//| If an MA crosses under another, the indicator falls                                                   |
//| If the indicator rises to 100%, every MA is above MAs with higher period                              |
//| If the indicator falls to 0%, every MA is under MAs with higher period                                |                                    
//+-------------------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2011, Matus German"
#property link      "http://www.MTexperts.net/"
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_buffers 2               
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_color1 clrRed
#property indicator_color2 clrYellow

#include <MovingAverages.mqh>

enum line {Crosses, Average};

double MAcrs[];
double MAcrsAvg[];
extern int MAmax = 50;                 // Max MA
extern int Step = 5;                   // MAs Step, optimal Max MA/10
extern int MAavg = 20;                 // MA on MAs crosses
extern ENUM_MA_METHOD MAmethod = MODE_EMA;    // MA method	                                    
extern ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;           // Applied to price

extern bool UseAlert = False;          // Alert
extern line AlertLine = Crosses;       // Alert Line
extern double UpLevel = 90;            // Alert Up Level
extern double DownLevel = 10;          // Alert Down Level
                                      
double maxCrosses; // max crosses

datetime barTime = TimeCurrent();

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexDrawBegin(1,MAmax);
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MAcrosses("+IntegerToString(MAmax)+","+IntegerToString(Step)+","+IntegerToString(MAavg)+")");
   
//--- check for input parameters
   if(MAmax<=1 || Step<=1 || MAavg<=1)
   {
      Print("Wrong input parameters");
      return(INIT_FAILED);
   }

   IndicatorBuffers(2);
   SetIndexBuffer(0,MAcrs);
   SetIndexStyle (0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexLabel(0,"MAcrosses");
   SetIndexBuffer(1,MAcrsAvg);
   SetIndexStyle (1,DRAW_LINE,STYLE_DASH,1);
   SetIndexLabel(1,"MAcrossesAvg");
   
   SetLevelValue(0,10);
   SetLevelValue(1,90);
   maxCrosses=max(MAmax,Step);
   return(INIT_SUCCEEDED);
}

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

   int    i,j,k,limit;
   double crosses;

//---
   if(rates_total<=MAmax)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;

   for(i=0; i<limit; i++)
   {
      crosses=0;                   
      k=MAmax;
      while(k>0)
      {  
         j=MAmax;
         while(j>k)
         {  
            if(iMA(NULL,0,j,0,MAmethod,AppliedPrice,i)<iMA(NULL,0,k,0,MAmethod,AppliedPrice,i))
            {
               crosses=crosses+1; // count crosses
            }
            j=j-Step;
         }
         k=k-Step;
      }
      MAcrs[i]=(crosses/maxCrosses)*100; // % that all MAs are abowe slower MAs
   }
   // MA on MA crosses
   SimpleMAOnBuffer(rates_total,prev_calculated,0,MAavg,MAcrs,MAcrsAvg);
   
   // alert
   if(IsNewBar(Period()))
   {
      if(UseAlert)
      {
         if(AlertLine==Crosses)
         {
            if((MAcrs[1]>=UpLevel && MAcrs[2]<UpLevel) || (MAcrs[1]<=UpLevel && MAcrs[2]>UpLevel))
               Alert("Up Level crossed");
            if((MAcrs[1]>=DownLevel && MAcrs[2]<DownLevel) || (MAcrs[1]<=DownLevel && MAcrs[2]>DownLevel))
               Alert("Down Level crossed");
         }
         else
         {
            if((MAcrsAvg[1]>=UpLevel && MAcrsAvg[2]<UpLevel) || (MAcrsAvg[1]<=UpLevel && MAcrsAvg[2]>UpLevel))
               Alert("Up Level crossed");
            if((MAcrsAvg[1]>=DownLevel && MAcrsAvg[2]<DownLevel) || (MAcrsAvg[1]<=DownLevel && MAcrsAvg[2]>DownLevel))
               Alert("Down Level crossed");
         }
      }
   }
   return(rates_total);

}

//////////////////////////////////////////////////////////////////////////////////////////////////
// Function counts how many crosses could be made by MAs
double max(int MA,int MAstep)
{  
   int i=MA;
   int MAs=0;
   while(i>0)
   {
      i-=MAstep;
      MAs++;
   }
   double max=((MAs*MAs)-MAs)/2;
   return (max);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool IsNewBar(int timeFrame)
{
   if( barTime < iTime(Symbol(), timeFrame, 0)) 
   {
        // we have a new bar opened
      barTime = iTime(Symbol(), timeFrame, 0);
      return(true);
   }
   return (false);
}