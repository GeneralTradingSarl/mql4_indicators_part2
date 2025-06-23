//+------------------------------------------------------------------+
//|                                                  PivotPoints.mq4 |
//|                                             2015 (C) PomeGranate |
//|                                       PomeGranate@gmx-topmail.de |
//+------------------------------------------------------------------+
/*Copyright (C) 2015 PomeGranate

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or 
 (at your option) any later version. 

 This program is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranty of 
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
 GNU General Public License for more details. 

 You should have received a copy of the GNU General Public License 
 along with this program; if not, see <http://www.gnu.org/licenses/>.*/

/*********************************************************************
* Description: Pivot Point (PP) indicator on daily level.            *
* Custom deviations from ordinary PP indicators:                     *
* - made for use with broker/server in UTC time zone                 *
* - sunday bars for those data feeds starting on sundays at 2200 UTC *
*   elimminated                                                      *
* - close time used for calculation is close of 2000 UTC bar; it     *
*   is an input variable and can easily be changed when indicator    *
*   is attached to chart (input int closetime_UTC)                   *
*                                                                    *
*********************************************************************/

/*********************************************************************
**********************************************************************
*********************WARNING!IMPORTANT NOTICE!************************
**********************************************************************
** PP values that are further back in time than the hourly bars     **
** provided reach are totally wrong. This is due to the algorithm,  **
** which counts the hourly bars back to 'yesterdays' 2000 (UTC) bar.**
** Those nonsense values are cut off in drawing (see init), however **
** they are still present in the arrays!                            **
**********************************************************************
**********************************************************************
*********************************************************************/

/*-------------------------------------------------------------------*
|  Version history:                                                  |
|  Version 2.10:                                                     |
|  - indicator calculation loop is counting DOWN, so that            |
|  indicator actualizes with every new bar                           |
|  - drawing of daily and weekly lines is cut off on timeframes>H1,  |
|  when wrong values begin (see switch at beginning of init).        |
|                                                                    |
|  Version 2.11:                                                     |
|  - inserted input variables for colors and line styles of          |
|  different pivot levels                                            |
|  - added assert for input closetime_UTC (0<closetime_UTC<23)       |
|                                                                    |
| Version 2.20:                                                      |
| - Preview PP color changed according to logic in Ver 2.11          |
| - added optional midpoints. They are drawn only for the current    |
|  day.                                                              |
*-------------------------------------------------------------------*/

#property copyright "2015 (C) PomeGranate"
#property version   "2.20"
#property strict
#property indicator_chart_window
#property indicator_buffers 30
#property indicator_plots   27

//--- plot Pivot Points
#property indicator_label1  "PP"
#property indicator_label2  "R1"
#property indicator_label3  "R2"
#property indicator_label4  "R3"
#property indicator_label5  "R4"
#property indicator_label6  "S1"
#property indicator_label7  "S2"
#property indicator_label8  "S3"
#property indicator_label9  "S4"
#property indicator_label10  "wPP"
#property indicator_label11  "wR1"
#property indicator_label12  "wS1"
#property indicator_label13  "wR2"
#property indicator_label14  "wS2"
#property indicator_label15  "wR3"
#property indicator_label16  "wS3"
#property indicator_label17  "wR4"
#property indicator_label18  "wS4"
#property indicator_label19  "mPP"
#property indicator_label20  "mR1"
#property indicator_label21  "mS1"
#property indicator_label22  "mR2"
#property indicator_label23  "mS2"
#property indicator_label24  "mR3"
#property indicator_label25  "mS3"
#property indicator_label26  "mR4"
#property indicator_label27  "mS4"
#property indicator_color28 clrNONE
#property indicator_color29 clrNONE
#property indicator_color30 clrNONE


//--- input parameters
input int closetime_UTC=20;                        //set the hour for use in PP calculation
input bool preview=true;                           //display tomorrows PP 
input bool Weekly_Pivots=false;                    //display weekly PP
input bool Monthly_Pivots=false;                   //display monthly PP
input bool midpoints=false;                        //display midpoints
input color MPcolor=clrBlack;                      //set color of midpoints
input color dPPcolor=clrBlack;                     //set color of daily PP
input color dRcolor=clrTomato;                     //set color of daily resistance pivots
input color dScolor=clrDeepSkyBlue;                //set color of daily support pivots
input color wPPcolor=clrDimGray;                   //set color of weekly PP
input color wRcolor=clrMagenta;                    //set color of weekly resistance pivots
input color wScolor=clrSeaGreen;                   //set color of weekly support pivots
input color mPPcolor=clrDarkOliveGreen;            //set color of monthly PP
input color mRcolor=clrDarkOliveGreen;             //set color of monthly resistance pivots
input color mScolor=clrDarkOliveGreen;             //set color of monthly support pivots
input ENUM_LINE_STYLE dStyle=STYLE_SOLID;          //set line style of daily PP
input ENUM_LINE_STYLE wStyle=STYLE_DASHDOT;        //set line style of weekly PP
input ENUM_LINE_STYLE mStyle=STYLE_DASHDOT;        //set line style of monthly PP

//--- indicator buffers
double PPBuffer[],
R1Buffer[],
R2Buffer[],
R3Buffer[],
R4Buffer[],
S1Buffer[],
S2Buffer[],
S3Buffer[],
S4Buffer[],
wPPBuffer[],
wR1Buffer[],
wS1Buffer[],
wR2Buffer[],
wS2Buffer[],
wR3Buffer[],
wS3Buffer[],
wR4Buffer[],
wS4Buffer[],
mPPBuffer[],
mR1Buffer[],
mS1Buffer[],
mR2Buffer[],
mS2Buffer[],
mR3Buffer[],
mS3Buffer[],
mR4Buffer[],
mS4Buffer[],
HighBuffer[],
LowBuffer[],
CloseBuffer[];
int IBARS=iBars(NULL,PERIOD_H1),
DL; //Data limit for drawing of daily and weekly PP
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(closetime_UTC<0 || closetime_UTC>23)
     {
      Alert("Wrong input parameter for closetime_UTC!\n It must be an integer value between 0 and 23.\n Try again!");
      return(-1);
     }
   switch(_Period)
     {
      case PERIOD_H4:
         DL=iBars(NULL,PERIOD_H4)-(IBARS/4);
         break;
      case PERIOD_D1:
         DL=iBars(NULL,PERIOD_D1)-(IBARS/24);
         break;
      case PERIOD_W1:
         DL=iBars(NULL,PERIOD_W1)-(IBARS/120);
         break;
      case PERIOD_MN1:
         DL=iBars(NULL,PERIOD_MN1)-(IBARS/520);
         break;
      default:
         DL=0;
         break;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,PPBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,R1Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,R2Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,R3Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,R4Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,S1Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,S2Buffer,INDICATOR_DATA);
   SetIndexBuffer(7,S3Buffer,INDICATOR_DATA);
   SetIndexBuffer(8,S4Buffer,INDICATOR_DATA);
   SetIndexBuffer(9,wPPBuffer,INDICATOR_DATA);
   SetIndexBuffer(10,wR1Buffer,INDICATOR_DATA);
   SetIndexBuffer(11,wS1Buffer,INDICATOR_DATA);
   SetIndexBuffer(12,wR2Buffer,INDICATOR_DATA);
   SetIndexBuffer(13,wS2Buffer,INDICATOR_DATA);
   SetIndexBuffer(14,wR3Buffer,INDICATOR_DATA);
   SetIndexBuffer(15,wS3Buffer,INDICATOR_DATA);
   SetIndexBuffer(16,wR4Buffer,INDICATOR_DATA);
   SetIndexBuffer(17,wS4Buffer,INDICATOR_DATA);
   SetIndexBuffer(18,mPPBuffer,INDICATOR_DATA);
   SetIndexBuffer(19,mR1Buffer,INDICATOR_DATA);
   SetIndexBuffer(20,mS1Buffer,INDICATOR_DATA);
   SetIndexBuffer(21,mR2Buffer,INDICATOR_DATA);
   SetIndexBuffer(22,mS2Buffer,INDICATOR_DATA);
   SetIndexBuffer(23,mR3Buffer,INDICATOR_DATA);
   SetIndexBuffer(24,mS3Buffer,INDICATOR_DATA);
   SetIndexBuffer(25,mR4Buffer,INDICATOR_DATA);
   SetIndexBuffer(26,mS4Buffer,INDICATOR_DATA);
   SetIndexBuffer(27,HighBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(28,LowBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(29,CloseBuffer,INDICATOR_CALCULATIONS);

   SetIndexStyle(0,DRAW_LINE,dStyle,1,dPPcolor);
   SetIndexStyle(1,DRAW_LINE,dStyle,1,dRcolor);
   SetIndexStyle(2,DRAW_LINE,dStyle,1,dRcolor);
   SetIndexStyle(3,DRAW_LINE,dStyle,1,dRcolor);
   SetIndexStyle(4,DRAW_LINE,dStyle,1,dRcolor);
   SetIndexStyle(5,DRAW_LINE,dStyle,1,dScolor);
   SetIndexStyle(6,DRAW_LINE,dStyle,1,dScolor);
   SetIndexStyle(7,DRAW_LINE,dStyle,1,dScolor);
   SetIndexStyle(8,DRAW_LINE,dStyle,1,dScolor);
   SetIndexStyle(9,DRAW_LINE,wStyle,1,wPPcolor);
   SetIndexStyle(10,DRAW_LINE,wStyle,1,wRcolor);
   SetIndexStyle(11,DRAW_LINE,wStyle,1,wScolor);
   SetIndexStyle(12,DRAW_LINE,wStyle,1,wRcolor);
   SetIndexStyle(13,DRAW_LINE,wStyle,1,wScolor);
   SetIndexStyle(14,DRAW_LINE,wStyle,1,wRcolor);
   SetIndexStyle(15,DRAW_LINE,wStyle,1,wScolor);
   SetIndexStyle(16,DRAW_LINE,wStyle,1,wRcolor);
   SetIndexStyle(17,DRAW_LINE,wStyle,1,wScolor);
   SetIndexStyle(18,DRAW_LINE,mStyle,1,mPPcolor);
   SetIndexStyle(19,DRAW_LINE,mStyle,1,mRcolor);
   SetIndexStyle(20,DRAW_LINE,mStyle,1,mScolor);
   SetIndexStyle(21,DRAW_LINE,mStyle,1,mRcolor);
   SetIndexStyle(22,DRAW_LINE,mStyle,1,mScolor);
   SetIndexStyle(23,DRAW_LINE,mStyle,1,mRcolor);
   SetIndexStyle(24,DRAW_LINE,mStyle,1,mScolor);
   SetIndexStyle(25,DRAW_LINE,mStyle,1,mRcolor);
   SetIndexStyle(26,DRAW_LINE,mStyle,1,mScolor);

   SetIndexDrawBegin(0,DL);
   SetIndexDrawBegin(1,DL);
   SetIndexDrawBegin(2,DL);
   SetIndexDrawBegin(3,DL);
   SetIndexDrawBegin(4,DL);
   SetIndexDrawBegin(5,DL);
   SetIndexDrawBegin(6,DL);
   SetIndexDrawBegin(7,DL);
   SetIndexDrawBegin(8,DL);
   SetIndexDrawBegin(9,DL);
   SetIndexDrawBegin(10,DL);
   SetIndexDrawBegin(11,DL);
   SetIndexDrawBegin(12,DL);
   SetIndexDrawBegin(13,DL);
   SetIndexDrawBegin(14,DL);
   SetIndexDrawBegin(15,DL);
   SetIndexDrawBegin(16,DL);
   SetIndexDrawBegin(17,DL);

   IndicatorDigits(Digits);
//---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete("MP_lvl_-4");
   ObjectDelete("MP_lvl_-3");
   ObjectDelete("MP_lvl_-2");
   ObjectDelete("MP_lvl_-1");
   ObjectDelete("MP_lvl_1");
   ObjectDelete("MP_lvl_2");
   ObjectDelete("MP_lvl_3");
   ObjectDelete("MP_lvl_4");
   ObjectDelete("PP");
   ObjectDelete("R1");
   ObjectDelete("R2");
   ObjectDelete("R3");
   ObjectDelete("S1");
   ObjectDelete("S2");
   ObjectDelete("S3");
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
//---

   int start=0;
   if(prev_calculated==0)
      start=rates_total-1;
   else
      start=rates_total-prev_calculated;
//---
   for(int i=start;i>=0 && !IsStopped();i--)
     {
/*--------------------------------------------------------------------------------
  ---> The indicator is calculated seperately for different days of the week. <---
  ---> Like this, it is possible to set closing time by looking for the resp. <---
  ---> hourly bar. However, this also bears lots of error origins. If some-   <---
  ---> body with greater programming skills would find a better way to do it  <---
  ---> I'd be very happy to learn!                                            <---
--------------------------------------------------------------------------------*/

      int h=0,
      f=0,
      g=0;

      switch(TimeDayOfWeek(time[i]))
        {
         case 0:
            h=1;
            f=0;
            g=3+closetime_UTC;
            break;
         case 1:
            h=2;
            f=26;
            g=0;
            break;
         case 2:
            h=1;
            f=24;
            g=0;
            break;
         case 3:
            h=1;
            f=24;
            g=0;
            break;
         case 4:
            h=1;
            f=24;
            g=0;
            break;
         case 5:
            h=1;
            f=24;
            g=0;
            break;
         case 6:
            h=1;
            f=24;
            g=0;
            break;
        }
      int dshift=iBarShift(NULL,PERIOD_D1,Time[i],false);
      datetime Today=iTime(NULL,PERIOD_D1,dshift); //determine time[i]'s 00:00 bar as anchor
      int hshift=iBarShift(NULL,PERIOD_H1,Today,false)+f; //go back f hourly bars

                                                          // High, low, close and open 
      double HIGH=iHigh(NULL,PERIOD_D1,dshift+h),
      LOW=iLow(NULL,PERIOD_D1,dshift+h),
      CLOSE=iClose(NULL,PERIOD_H1,hshift-closetime_UTC+g),//add the preset number of hours, thereby select 20:00 bar
      OPEN=iOpen(NULL,PERIOD_D1,dshift+h);

      //fill Highbuffer + Lowbuffer
      HighBuffer[i]= HIGH;
      LowBuffer[i] = LOW;
      CloseBuffer[i]=CLOSE;

      // Pivot Point
      double pivotpoint=(HighBuffer[i]+LowBuffer[i]+CloseBuffer[i])/3;
      PPBuffer[i]=pivotpoint;

      // Calcuations 
      R1Buffer[i] = 2 * PPBuffer[i] - LowBuffer[i];
      S1Buffer[i] = 2 * PPBuffer[i] - HighBuffer[i];
      R2Buffer[i] = PPBuffer[i] + HighBuffer[i] - LowBuffer[i];
      S2Buffer[i] = PPBuffer[i] - HighBuffer[i] + LowBuffer[i];
      R3Buffer[i] = 2 * PPBuffer[i] - 2*LowBuffer[i] + HighBuffer[i];
      S3Buffer[i] = 2 * PPBuffer[i] - 2*HighBuffer[i] + LowBuffer[i];
      R4Buffer[i] = R3Buffer[i] + PPBuffer[i] - LowBuffer[i];
      S4Buffer[i] = S3Buffer[i] + PPBuffer[i] - HighBuffer[i];

      if(midpoints==true) // Midpoints, can be useful for SL
        {
         double mpS34=(S3Buffer[i]+S4Buffer[i])/2,
         mpS23=(S2Buffer[i]+S3Buffer[i])/2,
         mpS12=(S1Buffer[i]+S2Buffer[i])/2,
         mpPS1=(S1Buffer[i]+PPBuffer[i])/2,
         mpPR1=(R1Buffer[i]+PPBuffer[i])/2,
         mpR12=(R1Buffer[i]+R2Buffer[i])/2,
         mpR23=(R2Buffer[i]+R3Buffer[i])/2,
         mpR34=(R3Buffer[i]+R4Buffer[i])/2;

         DrawMidpoints("MP_lvl_-4",0,mpS34,MPcolor);
         DrawMidpoints("MP_lvl_-3",0,mpS23,MPcolor);
         DrawMidpoints("MP_lvl_-2",0,mpS12,MPcolor);
         DrawMidpoints("MP_lvl_-1",0,mpPS1,MPcolor);
         DrawMidpoints("MP_lvl_1",0,mpPR1,MPcolor);
         DrawMidpoints("MP_lvl_2",0,mpR12,MPcolor);
         DrawMidpoints("MP_lvl_3",0,mpR23,MPcolor);
         DrawMidpoints("MP_lvl_4",0,mpR34,MPcolor);
        }

      if(preview==true)
        {
         // High, low, close and open 
         double preHigh=iHigh(NULL,PERIOD_D1,0),
         preLow     = iLow(NULL, PERIOD_D1,0),
         preClose   = iClose(NULL, PERIOD_CURRENT,0),
         preOpen    = iOpen(NULL, PERIOD_D1,0);

         // Pivot Point
         double prepivotpoint=(preHigh+preLow+preClose)/3;

         // Calcuations 
         double preR1=2*prepivotpoint-preLow,
         preS1 = 2*prepivotpoint-preHigh,
         preR2 = prepivotpoint+preHigh-preLow,
         preS2 = prepivotpoint-preHigh+preLow,
         preR3 = 2*prepivotpoint - 2*preLow + preHigh,
         preS3 = 2*prepivotpoint - 2*preHigh + preLow;

         DrawPreview("PP",0,prepivotpoint,dPPcolor);
         DrawPreview("R1",0,preR1,dRcolor);
         DrawPreview("R2",0,preR2,dRcolor);
         DrawPreview("R3",0,preR3,dRcolor);
         DrawPreview("S1",0,preS1,dScolor);
         DrawPreview("S2",0,preS2,dScolor);
         DrawPreview("S3",0,preS3,dScolor);
        }

      //Calculation of Weekly Pivots, sunday belongs to monday.
      if(Weekly_Pivots==true)
        {
         int   d=0,
         e=0;
         switch(TimeDayOfWeek(Time[i]))
           {
            case 0:
               d=0;
               e=1;
               break;
            case 1:
               d=0;
               e=4;
               break;
            case 2:
               d=24;
               e=4;
               break;
            case 3:
               d=48;
               e=4;
               break;
            case 4:
               d=72;
               e=4;
               break;
            case 5:
               d=96;
               e=4;
               break;
            case 6:
               d=120;
               e=4;
               break;
           }
         int dshift_w = iBarShift(NULL, PERIOD_D1, Time[i], false);
         int wshift_w = iBarShift(NULL,PERIOD_W1,Time[i],false);
         datetime Today_w=iTime(NULL,PERIOD_D1,dshift); //determine time[i]'s 00:00 bar as anchor
         int hshift_w=iBarShift(NULL,PERIOD_H1,Today,false)+d+e;

         double whigh=iHigh(NULL,PERIOD_W1,wshift_w+1),
         wlow     = iLow(NULL, PERIOD_W1, wshift_w+1),
         wclose   = iClose(NULL, PERIOD_H1, hshift_w-closetime_UTC),
         wopen    = iOpen(NULL, PERIOD_W1, wshift_w+1);

         // Pivot Point
         double pivotpoint_w=(whigh+wlow+wclose)/3;
         wPPBuffer[i]=pivotpoint_w;

         // Calcuations 
         wR1Buffer[i] = 2 * wPPBuffer[i] - wlow;
         wS1Buffer[i] = 2 * wPPBuffer[i] - whigh;
         wR2Buffer[i] = wPPBuffer[i] + whigh - wlow;
         wS2Buffer[i] = wPPBuffer[i] - whigh + wlow;
         wR3Buffer[i] = 2 * wPPBuffer[i] - 2*wlow + whigh;
         wS3Buffer[i] = 2 * wPPBuffer[i] - 2*whigh + wlow;
         wR4Buffer[i] = wR3Buffer[i] + wPPBuffer[i] - wlow;
         wS4Buffer[i] = wS3Buffer[i] + wPPBuffer[i] - whigh;
        }

      //monthly PP do NOT use closetime_UTC ! They are calculated 'old school', using PERIOD_MN1 data.
      if(Monthly_Pivots==true)
        {
         int mshift=iBarShift(NULL,PERIOD_MN1,Time[i],false);

         double mHigh=iHigh(NULL,PERIOD_MN1,mshift+1),
         mLow     = iLow(NULL, PERIOD_MN1, mshift+1),
         mClose   = iClose(NULL, PERIOD_MN1, mshift+1),
         mOpen=iOpen(NULL,PERIOD_MN1,mshift+1);

         // Pivot Point
         double mPP=(mHigh+mLow+mClose)/3;
         mPPBuffer[i]=mPP;

         // Calcuations 
         mR1Buffer[i] = 2 * mPPBuffer[i] - mLow;
         mS1Buffer[i] = 2 * mPPBuffer[i] - mHigh;
         mR2Buffer[i] = mPPBuffer[i] + mHigh - mLow;
         mS2Buffer[i] = mPPBuffer[i] - mHigh + mLow;
         mR3Buffer[i] = 2 * mPPBuffer[i] - 2*mLow + mHigh;
         mS3Buffer[i] = 2 * mPPBuffer[i] - 2*mHigh + mLow;
         mR4Buffer[i] = mR3Buffer[i] + mPPBuffer[i] - mLow;
         mS4Buffer[i] = mS3Buffer[i] + mPPBuffer[i] - mHigh;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| This block sets the function for drawing of preview PP           |
//+------------------------------------------------------------------+
void DrawPreview(string arrowlabel,int shift,double PriceToDraw,color ColorToDraw)
  {
// Time
   datetime TimeToDraw=Time[shift]+PeriodSeconds(PERIOD_CURRENT)*15; //preview labels will be drawn 15 bars into future,
                                                                     //regardless of timeframe
// Label
   string label=arrowlabel;

   if(ObjectFind(label)!=-1) ObjectDelete(label);

   ObjectCreate(label,OBJ_ARROW_RIGHT_PRICE,0,TimeToDraw,PriceToDraw);
   ObjectSetInteger(0,label,OBJPROP_COLOR,ColorToDraw);
  }
//+------------------------------------------------------------------+
void DrawMidpoints(string midlabel,int shift,double PriceToDraw,color ColorToDraw)
  {
// Time
   datetime TimeToDraw=Time[shift]+PeriodSeconds(PERIOD_CURRENT)*10; //midpoint markers will be drawn 10 bars into future,
                                                                     //regardless of timeframe
// Label
   string midpoint=midlabel;

   if(ObjectFind(midpoint)!=-1) ObjectDelete(midpoint);

   ObjectCreate(midpoint,OBJ_ARROW,0,TimeToDraw,PriceToDraw);
   ObjectSetInteger(0,midpoint,OBJPROP_COLOR,ColorToDraw);
   ObjectSetInteger(0,midpoint,OBJPROP_ARROWCODE,159);
  }
//+------------------------------------------------------------------+
