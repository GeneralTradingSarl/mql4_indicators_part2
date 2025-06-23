// Copyright © 2015 Alexandre Borela (alexandre.borela@gmail.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#property copyright "Copyright 2015, Alexandre Borela"
#property link ""
#property version "1.1"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 C'83,173,52'
#property indicator_color2 C'83,173,52'
#property indicator_color3 C'83,173,52'
#property indicator_style1 STYLE_DASH;
#property indicator_style2 STYLE_SOLID;
#property indicator_style3 STYLE_DASH;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum AvailablePeriods
  {
   PreviousDay=PERIOD_D1,// Previous day
   PreviousWeek=PERIOD_W1,// Previous week
   PreviousMonth=PERIOD_MN1 // Previous month
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TimeRange
  {
   bool Failed;
   datetime StartTime;
   datetime EndTime;

   TimeRange()
     {
      Failed=false;
      StartTime=0;
      EndTime=0;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct PeriodData
  {
   TimeRange PeriodRange;

   double PeriodHigh;
   double PeriodClose;
   double PeriodLow;

   PeriodData()
     {
      PeriodHigh=0;
      PeriodClose=0;
      PeriodLow=0;
     }
  };

input string _sepTimeShift=""; // /////// Calculation
input ENUM_TIMEFRAMES Precision=PERIOD_H1; // Precision
input AvailablePeriods TargetTimeFrame=PreviousDay; // Period
input int PeriodsToCalculate=1; // Periods to calculate
input int HoursShift=-2; // Hours shift
input int MinutesShift=0; // Minutes shift
input bool IgnoreSunday=true; // Ignore Sunday
input bool IgnoreSaturday=true; // Ignore Saturday

input string _sepBufferVisibility=""; // /////// Buffer visibility
input bool ShowHighBuffer=true; // High
input bool ShowCloseBuffer=true; // Close
input bool ShowLowBuffer=true; // Low

input string _sepProbeVisibility=""; // /////// Probe visibility
input bool ShowHighProbe=true; // High
input bool ShowCloseProbe=true; // Close
input bool ShowLowProbe=true; // Low

input string _sepProbeColor=""; // /////// Probe color
input color HighColor=C'83,173,52'; // High
input color CloseColor=C'83,173,52'; // Close
input color LowColor=C'83,173,52'; // Low

input string _sepProbeSize=""; // /////// Probe size
input int HighSize=2; // High
input int CloseSize=2; // Close
input int LowSize=2; // Low

input string _sepCustomLabel=""; // /////// Data window label
input string HighLabel="P.Day High"; // High
input string CloseLabel="P.Day Close"; // Close
input string LowLabel="P.Day Low"; // Low

string HighProbeName="HighPrevious"+IntegerToString(TargetTimeFrame)+IntegerToString(HoursShift)+IntegerToString(MinutesShift);
string CloseProbeName="ClosePrevious"+IntegerToString(TargetTimeFrame)+IntegerToString(HoursShift)+IntegerToString(MinutesShift);
string LowProbeName="LowPrevious"+IntegerToString(TargetTimeFrame)+IntegerToString(HoursShift)+IntegerToString(MinutesShift);

double PeriodHighBuffer[];
double PeriodCloseBuffer[];
double PeriodLowBuffer[];

PeriodData TempData;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PeriodData CalculateCommonSRData(datetime targetTime,TimeRange &periodRange)
  {
   if(TempData.PeriodRange.StartTime==periodRange.StartTime &&
      TempData.PeriodRange.EndTime==periodRange.EndTime)
      return( TempData );

   PeriodData result;

   int firstBar= iBarShift(Symbol(),Precision,periodRange.StartTime);
   int lastBar = iBarShift(Symbol(),Precision,periodRange.EndTime);

   datetime firstBarTime= iTime(Symbol(),Precision,firstBar);
   datetime lastBarTime = iTime(Symbol(),Precision,lastBar);

   int startBar=lastBar;
   int bars=firstBar-lastBar+1;

   int highestBar= iHighest(Symbol(),Precision,MODE_HIGH,bars,startBar);
   int lowestBar = iLowest(Symbol(),Precision,MODE_LOW,bars,startBar);

   result.PeriodRange= periodRange;
   result.PeriodHigh = iHigh(Symbol(),Precision,highestBar);
   result.PeriodClose= iClose(Symbol(),Precision,lastBar);
   result.PeriodLow=iLow(Symbol(),Precision,lowestBar);

   TempData=result;
   return( result );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime MoveDateToEndOfDay(datetime target)
  {
   MqlDateTime targetTime;
   TimeToStruct(target,targetTime);

   targetTime.hour= 23;
   targetTime.min = 59;
   targetTime.sec = 59;

   return( StructToTime( targetTime ) );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime MoveDateToEndOfMonth(datetime target)
  {
   MqlDateTime targetTime;
   TimeToStruct(target,targetTime);

   targetTime.mon++;
   targetTime.day=1;
   targetTime.hour= 0;
   targetTime.min = 0;
   targetTime.sec = 0;

   return( StructToTime( targetTime ) - 1 );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime MoveDateToEndOfWeek(datetime target)
  {
   MqlDateTime targetTime;
   TimeToStruct(target,targetTime);

   targetTime.day += 5 - targetTime.day_of_week;
   targetTime.hour = 23;
   targetTime.min = 59;
   targetTime.sec = 59;

   return( StructToTime( targetTime ) );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TimeRange CalculateTargetTimeRange(datetime targetTime,AvailablePeriods targetPeriod,int periodShift,ENUM_TIMEFRAMES precision,int hoursShift,int minutesShift,bool ignoreSunday,bool ignoreSaturday)
  {
   TimeRange currentRange=CalculateTimeRange(targetTime,(ENUM_TIMEFRAMES)(int)targetPeriod,precision,0,hoursShift,minutesShift,ignoreSunday,ignoreSaturday);

   if(targetTime<currentRange.StartTime)
      periodShift++;

   if(targetTime>currentRange.EndTime)
      periodShift--;

   if(periodShift==0)
      return( currentRange );

   TimeRange target=CalculateTimeRange(targetTime,(ENUM_TIMEFRAMES)(int)targetPeriod,precision,periodShift,hoursShift,minutesShift,ignoreSunday,ignoreSaturday);
   return( target );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TimeRange CalculateTimeRange(datetime targetTime,ENUM_TIMEFRAMES targetPeriod,ENUM_TIMEFRAMES precision,int periodShift,int hoursShift,int minutesShift,bool ignoreSunday,bool ignoreSaturday)
  {
   if(targetPeriod<precision)
      precision=targetPeriod;

   TimeRange result;
   int totalShift=hoursShift*3600+minutesShift*60;

// Start time.
   int periodStartBar=iBarShift(Symbol(),targetPeriod,targetTime)+periodShift;
   datetime periodStartTime=iTime(Symbol(),targetPeriod,periodStartBar);

   int precisePeriodStartBar=iBarShift(Symbol(),precision,periodStartTime);
   datetime precisePeriodStartTime=iTime(Symbol(),precision,precisePeriodStartBar);

   if(precisePeriodStartTime==0)
      result.Failed=true;

   if(precisePeriodStartTime>periodStartTime)
     {
      precisePeriodStartTime=iTime(Symbol(),precision,precisePeriodStartBar+1);

      if(precisePeriodStartTime==0)
         result.Failed=true;
     }

   if(result.Failed)
      return( result );

   if(precisePeriodStartTime<periodStartTime)
      precisePeriodStartTime=MoveDateToEndOfDay(precisePeriodStartTime)+1;

   result.StartTime=precisePeriodStartTime;

// End time.
   int nextPeriodStartBar = periodStartBar - 1;
   if(nextPeriodStartBar >= 0 )
     {
      // Exact calculation.
      datetime nextPeriodStartTime=iTime(Symbol(),targetPeriod,nextPeriodStartBar);

      int preciseNextPeriodStartBar=iBarShift(Symbol(),precision,nextPeriodStartTime);
      datetime preciseNextPeriodStartTime=iTime(Symbol(),precision,preciseNextPeriodStartBar);

      if(preciseNextPeriodStartTime==0)
         result.Failed=true;

      if(preciseNextPeriodStartTime>=nextPeriodStartTime)
        {
         preciseNextPeriodStartTime=iTime(Symbol(),precision,preciseNextPeriodStartBar+1);

         if(preciseNextPeriodStartTime==0)
            result.Failed=true;
        }

      if(result.Failed)
         return( result );

      if(preciseNextPeriodStartTime<nextPeriodStartTime)
         preciseNextPeriodStartTime=MoveDateToEndOfDay(preciseNextPeriodStartTime);

      if(TimeHour(preciseNextPeriodStartTime)==0)
         preciseNextPeriodStartTime--;

      result.EndTime=preciseNextPeriodStartTime;
     }
   else
     {
      // Approximation.
      switch(targetPeriod)
        {
         case PERIOD_D1 :
            result.EndTime=MoveDateToEndOfDay(iTime(Symbol(),precision,0));
            break;
         case PERIOD_W1 :
            result.EndTime=MoveDateToEndOfWeek(iTime(Symbol(),precision,0));
            break;
         case PERIOD_MN1 :
            result.EndTime=MoveDateToEndOfMonth(iTime(Symbol(),precision,0));
            break;
        }
     }

// Resulting shifted time.
   result.StartTime+=totalShift;
   result.EndTime+=totalShift;

// Sunday and saturday fix.
   if(targetPeriod==PERIOD_D1)
     {
      if(TimeDayOfWeek(result.StartTime)==SUNDAY && ignoreSunday)
         result.StartTime-=86400;

      if(TimeDayOfWeek(result.EndTime)==SATURDAY && ignoreSaturday)
         result.EndTime+=86400;
     }

   return( result );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawRightPriceProbe(int window,bool selectable,string name,int lineWidth,color lineColor,datetime date,double price,bool visible=true,int zorder=0,string tooltip="\n")
  {
   bool create=false;
   int foundAtWindow=ObjectFind(ChartID(),name);

   if(foundAtWindow<0)
      create=true;

   if(foundAtWindow>=0 && window!=foundAtWindow)
     {
      ObjectDelete(ChartID(),name);
      create=true;
     }

   if(!create)
     {
      ObjectSetInteger(ChartID(),name,OBJPROP_TIME,date);
      ObjectSetDouble(ChartID(),name,OBJPROP_PRICE,price);
     }
   else
      ObjectCreate(ChartID(),name,OBJ_ARROW_RIGHT_PRICE,window,date,price);

   ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,lineColor);
   ObjectSetInteger(ChartID(),name,OBJPROP_WIDTH,lineWidth);
   ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,!selectable);
   ObjectSetInteger(ChartID(),name,OBJPROP_SELECTABLE,selectable);

   if(!visible)
      ObjectSetInteger(ChartID(),name,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);

   ObjectSetInteger(ChartID(),name,OBJPROP_ZORDER,zorder);
   ObjectSetString(ChartID(),name,OBJPROP_TOOLTIP,tooltip);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(ChartID(),HighProbeName);
   ObjectDelete(ChartID(),CloseProbeName);
   ObjectDelete(ChartID(),LowProbeName);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);

   SetIndexBuffer(0,PeriodHighBuffer);
   SetIndexBuffer(1,PeriodCloseBuffer);
   SetIndexBuffer(2,PeriodLowBuffer);

   SetIndexLabel(0,HighLabel);
   SetIndexLabel(1,CloseLabel);
   SetIndexLabel(2,LowLabel);

   return( INIT_SUCCEEDED );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[])
  {
   if(Period()>=TargetTimeFrame)
      return( rates_total );

   int total=rates_total-prev_calculated;

   if(total>0)
     {
      int i = -1;
      int n = ( total + 7 ) / 8;
      int remainingPeriods=PeriodsToCalculate;

      PeriodData currentData;
      TimeRange currentTimeRange;
      TimeRange previousTimeRange;

      switch(total%8)
        {
         case 0 : OnCalculateStep( currentData, currentTimeRange, previousTimeRange, remainingPeriods, time, ++i );
         case 7 : OnCalculateStep( currentData, currentTimeRange, previousTimeRange, remainingPeriods, time, ++i );
         case 6 : OnCalculateStep( currentData, currentTimeRange, previousTimeRange, remainingPeriods, time, ++i );
         case 5 : OnCalculateStep( currentData, currentTimeRange, previousTimeRange, remainingPeriods, time, ++i );
         case 4 : OnCalculateStep( currentData, currentTimeRange, previousTimeRange, remainingPeriods, time, ++i );
         case 3 : OnCalculateStep( currentData, currentTimeRange, previousTimeRange, remainingPeriods, time, ++i );
         case 2 : OnCalculateStep( currentData, currentTimeRange, previousTimeRange, remainingPeriods, time, ++i );
         case 1 : OnCalculateStep( currentData, currentTimeRange, previousTimeRange, remainingPeriods, time, ++i );
        }

      while(--n>0)
        {
         OnCalculateStep(currentData,currentTimeRange,previousTimeRange,remainingPeriods,time,++i);
         OnCalculateStep(currentData,currentTimeRange,previousTimeRange,remainingPeriods,time,++i);
         OnCalculateStep(currentData,currentTimeRange,previousTimeRange,remainingPeriods,time,++i);
         OnCalculateStep(currentData,currentTimeRange,previousTimeRange,remainingPeriods,time,++i);
         OnCalculateStep(currentData,currentTimeRange,previousTimeRange,remainingPeriods,time,++i);
         OnCalculateStep(currentData,currentTimeRange,previousTimeRange,remainingPeriods,time,++i);
         OnCalculateStep(currentData,currentTimeRange,previousTimeRange,remainingPeriods,time,++i);
         OnCalculateStep(currentData,currentTimeRange,previousTimeRange,remainingPeriods,time,++i);
        }

      if(total==1)
        {
         TimeRange olderBarRange=CalculateTargetTimeRange(time[1],TargetTimeFrame,1,Precision,HoursShift,MinutesShift,IgnoreSunday,IgnoreSaturday);

         if(olderBarRange.StartTime!=currentTimeRange.StartTime)
           {
            PeriodHighBuffer[1]=EMPTY_VALUE;
            PeriodCloseBuffer[1]=EMPTY_VALUE;
            PeriodLowBuffer[1]=EMPTY_VALUE;
           }
        }
     }

   if(total>0 || prev_calculated>0)
     {
      if(ShowHighProbe && ShowHighBuffer)
         DrawRightPriceProbe(
                             ChartWindowFind(),
                             false,
                             HighProbeName,
                             HighSize,
                             HighColor,
                             time[0],
                             PeriodHighBuffer[0]
                             );

      if(ShowCloseProbe && ShowCloseBuffer)
         DrawRightPriceProbe(
                             ChartWindowFind(),
                             false,
                             CloseProbeName,
                             CloseSize,
                             CloseColor,
                             time[0],
                             PeriodCloseBuffer[0]
                             );

      if(ShowLowProbe && ShowLowBuffer)
         DrawRightPriceProbe(
                             ChartWindowFind(),
                             false,
                             LowProbeName,
                             LowSize,
                             LowColor,
                             time[0],
                             PeriodLowBuffer[0]
                             );
     }

   return( rates_total );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnCalculateStep(PeriodData &currentData,TimeRange &currentTimeRange,TimeRange &previousTimeRange,int &remainingPeriods,const datetime &time[],int i)
  {
   if(currentTimeRange.Failed || remainingPeriods<1)
     {
      PeriodHighBuffer[i]=EMPTY_VALUE;
      PeriodCloseBuffer[i]=EMPTY_VALUE;
      PeriodLowBuffer[i]=EMPTY_VALUE;
      return;
     }

   currentTimeRange=CalculateTargetTimeRange(time[i],TargetTimeFrame,1,Precision,HoursShift,MinutesShift,IgnoreSunday,IgnoreSaturday);

   if(i==0)
     {
      currentData=CalculateCommonSRData(time[i],currentTimeRange);
      previousTimeRange=currentTimeRange;
     }

   if(previousTimeRange.StartTime==currentTimeRange.StartTime)
     {
      if(ShowHighBuffer)
         PeriodHighBuffer[i]=currentData.PeriodHigh;

      if(ShowCloseBuffer)
         PeriodCloseBuffer[i]=currentData.PeriodClose;

      if(ShowLowBuffer)
         PeriodLowBuffer[i]=currentData.PeriodLow;
     }
   else
     {
      PeriodHighBuffer[i]=EMPTY_VALUE;
      PeriodCloseBuffer[i]=EMPTY_VALUE;
      PeriodLowBuffer[i]=EMPTY_VALUE;

      if(--remainingPeriods<1)
         return;

      currentData=CalculateCommonSRData(time[i],currentTimeRange);
     }

   previousTimeRange=currentTimeRange;
  }
//+------------------------------------------------------------------+
