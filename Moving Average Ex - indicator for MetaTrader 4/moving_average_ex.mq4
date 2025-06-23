//	Copyright © 2015 Alexandre Borela (alexandre.borela@gmail.com)
//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//	
//	    http://www.apache.org/licenses/LICENSE-2.0
//	
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.

#property copyright "Copyright 2015, Alexandre Borela"
#property link ""
#property version "1.00"
#property strict
#property indicator_buffers 1
#property indicator_chart_window
#property indicator_color1 C'101,160,226'
#property indicator_style1 STYLE_DASHDOTDOT

input string Label="20 Day EMA";   //	Custom Label
input int MAPeriod=20;   //	Period
input int MAShift=1;   //	Shift
input ENUM_TIMEFRAMES MATimeFrame=PERIOD_D1;   //	Time Frame
input ENUM_MA_METHOD MAMethod=MODE_EMA;   //	Method
input ENUM_APPLIED_PRICE MAPrice=PRICE_CLOSE;   //	Applied Price

double buffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,buffer);
   SetIndexLabel(0,Label);
   return( INIT_SUCCEEDED );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[])
  {
   if(Period()>MATimeFrame)
      return( rates_total );

   int target=-1;
   int oldTarget= -1;
   double value = 0;
   int totalBars= rates_total-prev_calculated;

   for(int i=1; i<totalBars; i++)
     {
      target=iBarShift(Symbol(),MATimeFrame,time[i]);

      if(oldTarget!=target)
        {
         oldTarget=target;
         value=iMA(Symbol(),MATimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,target);

         if(oldTarget !=-1 && Period() !=MATimeFrame)
            buffer[i-1]=EMPTY_VALUE;
        }

      buffer[i]=value;
     }

   return( rates_total );
  }
//+------------------------------------------------------------------+
