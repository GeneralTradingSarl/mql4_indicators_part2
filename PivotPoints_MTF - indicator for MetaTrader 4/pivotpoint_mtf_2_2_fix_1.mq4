//+------------------------------------------------------------------+
//|                                             PivotPoint_MTF_2.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//including the stdlib will give some description to your errors,(if any)
#include <stdlib.mqh>
#property indicator_buffers 4
//extern bool pivots = true;
extern bool midpivots=true;
extern bool Fhr=false;
extern bool daily=true;
extern bool weekly=false;
extern bool monthly=false;
//---Set InpChartShift in % from 10 to 50
extern  double InpChartShift=25;
extern  int    LabelShift= 7;
datetime label_Shift_Time=0;
//---
int visibleBars=0;
//--- chart shift
bool isChartShifted=true;
bool isChartShiftSet=true;
bool setShift=true;
double amountChartShift=0;

//---
/*+----------------------------------------------------+
 MyPeriod = Period in minutes to consideration, could be:
 1440 for D1
 60 for H1
 240 for H4
 1 for M1
 15 for M15
 30 for M30
 5 for M5
 43200 for MN1
 10080 for W1
 +-------------------------------------------------------*/
//---------------------------------
double Fhr_day_high=0;
double Fhr_day_low=0;
double Fhr_yesterday_high=0;
double Fhr_yesterday_open=0;
double Fhr_yesterday_low=0;
double Fhr_yesterday_close=0;
double Fhr_today_open=0;
double Fhr_today_high=0;
double Fhr_today_low=0;
double Fhr_P=0;
double Fhr_Q=0;
double Fhr_R1,Fhr_R2,Fhr_R3;
double Fhr_M0,Fhr_M1,Fhr_M2,Fhr_M3,Fhr_M4,Fhr_M5;
double Fhr_S1,Fhr_S2,Fhr_S3;
double Fhr_nQ=0;
double Fhr_nD=0;
double Fhr_D=0;
double Fhr_rates_d1[2][6];
double Fhr_ExtMapBuffer[];
//---------------------------------
double D_day_high=0;
double D_day_low=0;
double D_yesterday_high=0;
double D_yesterday_open=0;
double D_yesterday_low=0;
double D_yesterday_close=0;
double D_today_open=0;
double D_today_high=0;
double D_today_low=0;
double D_P=0;
double D_Q=0;
double D_R1,D_R2,D_R3;
double D_M0,D_M1,D_M2,D_M3,D_M4,D_M5;
double D_S1,D_S2,D_S3;
double D_nQ=0;
double D_nD=0;
double D_D=0;
double D_rates_d1[2][6];
double D_ExtMapBuffer[];
//---------------------------------
double W_day_high=0;
double W_day_low=0;
double W_yesterday_high=0;
double W_yesterday_open=0;
double W_yesterday_low=0;
double W_yesterday_close=0;
double W_today_open=0;
double W_today_high=0;
double W_today_low=0;
double W_P=0;
double W_Q=0;
double W_R1,W_R2,W_R3;
double W_M0,W_M1,W_M2,W_M3,W_M4,W_M5;
double W_S1,W_S2,W_S3;
double W_nQ=0;
double W_nD=0;
double W_D=0;
double W_rates_d1[2][6];
double W_ExtMapBuffer[];
//---------------------------------
double M_day_high=0;
double M_day_low=0;
double M_yesterday_high=0;
double M_yesterday_open=0;
double M_yesterday_low=0;
double M_yesterday_close=0;
double M_today_open=0;
double M_today_high=0;
double M_today_low=0;
double M_P=0;
double M_Q=0;
double M_R1,M_R2,M_R3;
double M_M0,M_M1,M_M2,M_M3,M_M4,M_M5;
double M_S1,M_S2,M_S3;
double M_nQ=0;
double M_nD=0;
double M_D=0;
double M_rates_d1[2][6];
double M_ExtMapBuffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
 IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,Fhr_ExtMapBuffer);

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(1,D_ExtMapBuffer);

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(2,W_ExtMapBuffer);

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(3,M_ExtMapBuffer);
//--- Chart shift
//--- Catch bad input                     
   if(InpChartShift<10)InpChartShift=10;
   if(InpChartShift>50)InpChartShift=50;
   if(LabelShift>10)LabelShift=10;

ChartShiftGet(isChartShifted,0);
if(isChartShifted)Print("1_Chart shift set to true ");
if(isChartShifted==false)
   {
   Print("2_Chart is not shifted ! Atempting to shift now");
   if(ChartShiftSet(setShift,0)==true)
   Print("3_Chartshift is set to true");
   else Print("4_Error set chart shift ,Chartshift is set to false ");
   }
amountChartShift=ChartShiftSizeGet(0);
Print("5_Chartshift amount is : "+DoubleToString(ChartShiftSizeGet(0),Digits));
if(amountChartShift!= InpChartShift)
   {
   ChartShiftSizeSet(InpChartShift,0);
   Print("6_Chartshift amount now is : "+DoubleToString(ChartShiftSizeGet(0),Digits));
   }
//---

//---- indicators
   D_R1=0; D_R2=0; D_R3=0;
   D_M0=0; D_M1=0; D_M2=0; D_M3=0; D_M4=0; D_M5=0;
   D_S1=0; D_S2=0; D_S3=0;


   W_R1=0; W_R2=0; W_R3=0;
   W_M0=0; W_M1=0; W_M2=0; W_M3=0; W_M4=0; W_M5=0;
   W_S1=0; W_S2=0; W_S3=0;


   M_R1=0; M_R2=0; M_R3=0;
   M_M0=0; M_M1=0; M_M2=0; M_M3=0; M_M4=0; M_M5=0;
   M_S1=0; M_S2=0; M_S3=0;


   Fhr_R1=0; Fhr_R2=0; Fhr_R3=0;
   Fhr_M0=0; Fhr_M1=0; Fhr_M2=0; Fhr_M3=0; Fhr_M4=0; Fhr_M5=0;
   Fhr_S1=0; Fhr_S2=0; Fhr_S3=0;

  
//---
   return(INIT_SUCCEEDED);
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

   label_Shift_Time=time[0]+(_Period*60*LabelShift);
   if(InpChartShift<10)label_Shift_Time=time[0]-(_Period*60*10);
   //---
   visibleBars=WindowBarsPerChart();
//---- exit if period is greater than daily charts
   if(Period()>240)
     {
      if(daily==true)daily=false;
      if(Fhr==true)Fhr=false;
     }

//----------------------------------------------------------------------------- Get new 4hr ---------------
   ArrayCopyRates(Fhr_rates_d1,Symbol(),240);

   Fhr_yesterday_close= Fhr_rates_d1[1][4];
   Fhr_yesterday_open = Fhr_rates_d1[1][1];
   Fhr_today_open=Fhr_rates_d1[0][1];
   Fhr_yesterday_high= Fhr_rates_d1[1][3];
   Fhr_yesterday_low = Fhr_rates_d1[1][2];
   Fhr_day_high= Fhr_rates_d1[0][3];
   Fhr_day_low = Fhr_rates_d1[0][2];


//---- Calculate Pivots

   Fhr_D = (Fhr_day_high - Fhr_day_low);
   Fhr_Q = (Fhr_yesterday_high - Fhr_yesterday_low);
   Fhr_P = (Fhr_yesterday_high + Fhr_yesterday_low + Fhr_yesterday_close) / 3;
   Fhr_R1 = (2*Fhr_P)-Fhr_yesterday_low;
   Fhr_S1 = (2*Fhr_P)-Fhr_yesterday_high;
   Fhr_R2 = Fhr_P+(Fhr_yesterday_high - Fhr_yesterday_low);
   Fhr_S2 = Fhr_P-(Fhr_yesterday_high - Fhr_yesterday_low);


   Fhr_R3 = (2*Fhr_P)+(Fhr_yesterday_high-(2*Fhr_yesterday_low));
   Fhr_M5 = (Fhr_R2+Fhr_R3)/2;
// Fhr_R2 = Fhr_P-Fhr_S1+Fhr_R1;
   Fhr_M4=(Fhr_R1+Fhr_R2)/2;
// Fhr_R1 = (2*Fhr_P)-Fhr_yesterday_low;
   Fhr_M3=(Fhr_P+Fhr_R1)/2;
// Fhr_P = (Fhr_yesterday_high + Fhr_yesterday_low + Fhr_yesterday_close)/3;
   Fhr_M2=(Fhr_P+Fhr_S1)/2;
// Fhr_S1 = (2*Fhr_P)-Fhr_yesterday_high;
   Fhr_M1=(Fhr_S1+Fhr_S2)/2;
// Fhr_S2 = Fhr_P-Fhr_R1+Fhr_S1;
   Fhr_S3 = (2*Fhr_P)-((2* Fhr_yesterday_high)-Fhr_yesterday_low);
   Fhr_M0 = (Fhr_S2+Fhr_S3)/2;

   if(Fhr_Q>5)
     {
      Fhr_nQ=Fhr_Q;
     }
   else
     {
      Fhr_nQ=Fhr_Q*10000;
     }

   if(Fhr_D>5)
     {
      Fhr_nD=Fhr_D;
     }
   else
     {
      Fhr_nD=Fhr_D*10000;
     }
//----------------------------------------------------------------------------- Get DAY ---------------
   ArrayCopyRates(D_rates_d1,Symbol(),1440);

   D_yesterday_close= D_rates_d1[1][4];
   D_yesterday_open = D_rates_d1[1][1];
   D_today_open=D_rates_d1[0][1];
   D_yesterday_high= D_rates_d1[1][3];
   D_yesterday_low = D_rates_d1[1][2];
   D_day_high= D_rates_d1[0][3];
   D_day_low = D_rates_d1[0][2];


//---- Calculate Pivots

   D_D = (D_day_high - D_day_low);
   D_Q = (D_yesterday_high - D_yesterday_low);
   D_P = (D_yesterday_high + D_yesterday_low + D_yesterday_close) / 3;
   D_R1 = (2*D_P)-D_yesterday_low;
   D_S1 = (2*D_P)-D_yesterday_high;
   D_R2 = D_P+(D_yesterday_high - D_yesterday_low);
   D_S2 = D_P-(D_yesterday_high - D_yesterday_low);


   D_R3 = (2*D_P)+(D_yesterday_high-(2*D_yesterday_low));
   D_M5 = (D_R2+D_R3)/2;
// D_R2 = D_P-D_S1+D_R1;
   D_M4=(D_R1+D_R2)/2;
// D_R1 = (2*D_P)-D_yesterday_low;
   D_M3=(D_P+D_R1)/2;
// D_P = (D_yesterday_high + D_yesterday_low + D_yesterday_close)/3;
   D_M2=(D_P+D_S1)/2;
// D_S1 = (2*D_P)-D_yesterday_high;
   D_M1=(D_S1+D_S2)/2;
// D_S2 = D_P-D_R1+D_S1;
   D_S3=(2*D_P)-((2 *D_yesterday_high)-D_yesterday_low);

   D_M0=(D_S2+D_S3)/2;

   if(D_Q>5)
     {
      D_nQ=D_Q;
     }
   else
     {
      D_nQ=D_Q*10000;
     }

   if(D_D>5)
     {
      D_nD=D_D;
     }
   else
     {
      D_nD=D_D*10000;
     }

//----------------------------------------------------------------------------- Weekly ---------------
   ArrayCopyRates(W_rates_d1,Symbol(),10080);

   W_yesterday_close= W_rates_d1[1][4];
   W_yesterday_open = W_rates_d1[1][1];
   W_today_open=W_rates_d1[0][1];
   W_yesterday_high= W_rates_d1[1][3];
   W_yesterday_low = W_rates_d1[1][2];
   W_day_high= W_rates_d1[0][3];
   W_day_low = W_rates_d1[0][2];


//---- Calculate Pivots

   W_D = (W_day_high - W_day_low);
   W_Q = (W_yesterday_high - W_yesterday_low);
   W_P = (W_yesterday_high + W_yesterday_low + W_yesterday_close) / 3;
   W_R1 = (2*W_P)-W_yesterday_low;
   W_S1 = (2*W_P)-W_yesterday_high;
   W_R2 = W_P+(W_yesterday_high - W_yesterday_low);
   W_S2 = W_P-(W_yesterday_high - W_yesterday_low);


   W_R3 = (2*W_P)+(W_yesterday_high-(2*W_yesterday_low));
   W_M5 = (W_R2+W_R3)/2;
// W_R2 = W_P-W_S1+W_R1;
   W_M4=(W_R1+W_R2)/2;
// W_R1 = (2*W_P)-W_yesterday_low;
   W_M3=(W_P+W_R1)/2;
// W_P = (W_yesterday_high + W_yesterday_low + W_yesterday_close)/3;
   W_M2=(W_P+W_S1)/2;
// W_S1 = (2*W_P)-W_yesterday_high;
   W_M1=(W_S1+W_S2)/2;
// W_S2 = W_P-W_R1+W_S1;
   W_S3 = (2*W_P)-((2* W_yesterday_high)-W_yesterday_low);
   W_M0 = (W_S2+W_S3)/2;

   if(W_Q>5)
     {
      W_nQ=W_Q;
     }
   else
     {
      W_nQ=W_Q*10000;
     }

   if(W_D>5)
     {
      W_nD=W_D;
     }
   else
     {
      W_nD=W_D*10000;
     }

//-------------------------------------------------------------MONTHLY-------------------------------------------
   ArrayCopyRates(M_rates_d1,Symbol(),43200);

   M_yesterday_close= M_rates_d1[1][4];
   M_yesterday_open = M_rates_d1[1][1];
   M_today_open=M_rates_d1[0][1];
   M_yesterday_high= M_rates_d1[1][3];
   M_yesterday_low = M_rates_d1[1][2];
   M_day_high= M_rates_d1[0][3];
   M_day_low = M_rates_d1[0][2];


//---- Calculate Pivots

   M_D = (M_day_high - M_day_low);
   M_Q = (M_yesterday_high - M_yesterday_low);
   M_P = (M_yesterday_high + M_yesterday_low + M_yesterday_close) / 3;
   M_R1 = (2*M_P)-M_yesterday_low;
   M_S1 = (2*M_P)-M_yesterday_high;
   M_R2 = M_P+(M_yesterday_high - M_yesterday_low);
   M_S2 = M_P-(M_yesterday_high - M_yesterday_low);


   M_R3 = (2*M_P)+(M_yesterday_high-(2*M_yesterday_low));
   M_M5 = (M_R2+M_R3)/2;
// M_R2 = M_P-M_S1+M_R1;
   M_M4=(M_R1+M_R2)/2;
// M_R1 = (2*M_P)-M_yesterday_low;
   M_M3=(M_P+M_R1)/2;
// M_P = (M_yesterday_high + M_yesterday_low + M_yesterday_close)/3;
   M_M2=(M_P+M_S1)/2;
// M_S1 = (2*M_P)-M_yesterday_high;
   M_M1=(M_S1+M_S2)/2;
// M_S2 = M_P-M_R1+M_S1;
   M_S3=(2*M_P)-((2 *M_yesterday_high)-M_yesterday_low);

   M_M0=(M_S2+M_S3)/2;

   if(M_Q>5)
     {
      M_nQ=M_Q;
     }
   else
     {
      M_nQ=M_Q*10000;
     }

   if(M_D>5)
     {
      M_nD=M_D;
     }
   else
     {
      M_nD=M_D*10000;
     }
//--------------------------------------------------------------------------------------------------------------
//---- Set line labels on chart window
//---------------------------------------------------------------------4hr Pivot Lines --------------------
   if(Fhr==true)
     {
      if(ObjectFind(0,"Fhr_R1 label")!=0)
        {
         ObjectCreate("Fhr_R1 label",OBJ_TEXT,0,label_Shift_Time,Fhr_R1);
         ObjectSetText("Fhr_R1 label","Fhr_R1 "+DoubleToStr(Fhr_R1,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_R1 label",0,label_Shift_Time,Fhr_R1);
        }

      if(ObjectFind("Fhr_R2 label")!=0)
        {
         ObjectCreate(0,"Fhr_R2 label",OBJ_TEXT,0,label_Shift_Time,Fhr_R2);
         ObjectSetText("Fhr_R2 label","Fhr_R2 "+DoubleToStr(Fhr_R2,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_R2 label",0,label_Shift_Time,Fhr_R2);
        }

      if(ObjectFind("Fhr_R3 label")!=0)
        {
         ObjectCreate(0, "Fhr_R3 label",OBJ_TEXT,0,label_Shift_Time,Fhr_R3);
         ObjectSetText("Fhr_R3 label","Fhr_R3 "+DoubleToStr(Fhr_R3,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_R3 label",0,label_Shift_Time,Fhr_R3);
        }

      if(ObjectFind("Fhr_P label")!=0)
        {
         ObjectCreate(0,"Fhr_P label",OBJ_TEXT,0,label_Shift_Time,Fhr_P);
         ObjectSetText("Fhr_P label","Fhr_Pivot "+DoubleToStr(Fhr_P,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_P label",0,label_Shift_Time,Fhr_P);
        }

      if(ObjectFind("Fhr_S1 label")!=0)
        {
         ObjectCreate(0,"Fhr_S1 label",OBJ_TEXT,0,label_Shift_Time,Fhr_S1);
         ObjectSetText("Fhr_S1 label","Fhr_S1 "+DoubleToStr(Fhr_S1,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_S1 label",0,label_Shift_Time,Fhr_S1);
        }

      if(ObjectFind("Fhr_S2 label")!=0)
        {
         ObjectCreate(0,"Fhr_S2 label",OBJ_TEXT,0,label_Shift_Time,Fhr_S2);
         ObjectSetText("Fhr_S2 label","Fhr_S2 "+DoubleToStr(Fhr_S2,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_S2 label",0,label_Shift_Time,Fhr_S2);
        }

      if(ObjectFind("Fhr_S3 label")!=0)
        {
         ObjectCreate(0,"Fhr_S3 label",OBJ_TEXT,0,label_Shift_Time,Fhr_S3);
         ObjectSetText("Fhr_S3 label","Fhr_S3 "+DoubleToStr(Fhr_S3,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_S3 label",0,label_Shift_Time,Fhr_S3);
        }

      //--- Draw Pivot lines on chart
      if(ObjectFind("Fhr_S1 line")!=0)
        {
         ObjectCreate(0,"Fhr_S1 line",OBJ_HLINE,0,time[0],Fhr_S1);
         ObjectSet("Fhr_S1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_S1 line",OBJPROP_WIDTH,2);
         ObjectSet("Fhr_S1 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("Fhr_S1 line",0,time[0],Fhr_S1);
        }

      if(ObjectFind("Fhr_S2 line")!=0)
        {
         ObjectCreate(0,"Fhr_S2 line",OBJ_HLINE,0,time[0],Fhr_S2);
         ObjectSet("Fhr_S2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_S2 line",OBJPROP_WIDTH,2);
         ObjectSet("Fhr_S2 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("Fhr_S2 line",0,time[0],Fhr_S2);
        }

      if(ObjectFind("Fhr_S3 line")!=0)
        {
         ObjectCreate(0,"Fhr_S3 line",OBJ_HLINE,0,time[0],Fhr_S3);
         ObjectSet("Fhr_S3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_S3 line",OBJPROP_WIDTH,2);
         ObjectSet("Fhr_S3 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("Fhr_S3 line",0,time[0],Fhr_S3);
        }

      if(ObjectFind("Fhr_P line")!=0)
        {
         ObjectCreate(0,"Fhr_P line",OBJ_HLINE,0,time[0],Fhr_P);
         ObjectSet("Fhr_P line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_P line",OBJPROP_WIDTH,2);
         ObjectSet("Fhr_P line",OBJPROP_COLOR,LightBlue);
        }
      else
        {
         ObjectMove("Fhr_P line",0,time[0],Fhr_P);
        }

      if(ObjectFind("Fhr_R1 line")!=0)
        {
         ObjectCreate(0,"Fhr_R1 line",OBJ_HLINE,0,time[0],Fhr_R1);
         ObjectSet("Fhr_R1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_R1 line",OBJPROP_WIDTH,2);
         ObjectSet("Fhr_R1 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("Fhr_R1 line",0,time[0],Fhr_R1);
        }

      if(ObjectFind("Fhr_R2 line")!=0)
        {
         ObjectCreate(0,"Fhr_R2 line",OBJ_HLINE,0,time[0],Fhr_R2);
         ObjectSet("Fhr_R2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_R2 line",OBJPROP_WIDTH,2);
         ObjectSet("Fhr_R2 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("Fhr_R2 line",0,time[0],Fhr_R2);
        }

      if(ObjectFind("Fhr_R3 line")!=0)
        {
         ObjectCreate(0,"Fhr_R3 line",OBJ_HLINE,0,time[0],Fhr_R3);
         ObjectSet("Fhr_R3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_R3 line",OBJPROP_WIDTH,2);
         ObjectSet("Fhr_R3 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("Fhr_R3 line",0,time[0],Fhr_R3);
        }
     }
//---- End of 4 Hour Pivot Line Draw

//------ Midpoints Pivots

   if(Fhr==true && midpivots==true)
     {

      if(ObjectFind("Fhr_M5 label")!=0)
        {
         ObjectCreate(0,"Fhr_M5 label",OBJ_TEXT,0,label_Shift_Time,Fhr_M5);
         ObjectSetText("Fhr_M5 label"," Fhr_M5 "+DoubleToStr(Fhr_M5,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_M5 label",0,label_Shift_Time,Fhr_M5);
        }

      if(ObjectFind("Fhr_M4 label")!=0)
        {
         ObjectCreate("Fhr_M4 label",OBJ_TEXT,0,label_Shift_Time,Fhr_M4);
         ObjectSetText("Fhr_M4 label","Fhr_M4 "+DoubleToStr(Fhr_M4,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_M4 label",0,label_Shift_Time,Fhr_M4);
        }

      if(ObjectFind("Fhr_M3 label")!=0)
        {
         ObjectCreate(0,"Fhr_M3 label",OBJ_TEXT,0,label_Shift_Time,Fhr_M3);
         ObjectSetText("Fhr_M3 label","Fhr_M3 "+DoubleToStr(Fhr_M3,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_M3 label",0,label_Shift_Time,Fhr_M3);
        }

      if(ObjectFind("Fhr_M2 label")!=0)
        {
         ObjectCreate(0,"Fhr_M2 label",OBJ_TEXT,0,label_Shift_Time,Fhr_M2);
         ObjectSetText("Fhr_M2 label","Fhr_M2 "+DoubleToStr(Fhr_M2,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_M2 label",0,label_Shift_Time,Fhr_M2);
        }

      if(ObjectFind("Fhr_M1 label")!=0)
        {
         ObjectCreate(0,"Fhr_M1 label",OBJ_TEXT,0,label_Shift_Time,Fhr_M1);
         ObjectSetText("Fhr_M1 label","Fhr_M1 "+DoubleToStr(Fhr_M1,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_M1 label",0,label_Shift_Time,Fhr_M1);
        }

      if(ObjectFind("Fhr_M0 label")!=0)
        {
         ObjectCreate(0,"Fhr_M0 label",OBJ_TEXT,0,label_Shift_Time,Fhr_M0);
         ObjectSetText("Fhr_M0 label","Fhr_M0 "+DoubleToStr(Fhr_M0,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("Fhr_M0 label",0,label_Shift_Time,Fhr_M0);
        }

      //---- Draw Midpoint Pivots on Chart
      if(ObjectFind("Fhr_M5 line")!=0)
        {
         ObjectCreate(0,"Fhr_M5 line",OBJ_HLINE,0,time[0],Fhr_M5);
         ObjectSet("Fhr_M5 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_M5 line",OBJPROP_WIDTH,1);
         ObjectSet("Fhr_M5 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("Fhr_M5 line",0,time[0],Fhr_M5);
        }

      if(ObjectFind("Fhr_M4 line")!=0)
        {
         ObjectCreate(0,"Fhr_M4 line",OBJ_HLINE,0,time[0],Fhr_M4);
         ObjectSet("Fhr_M4 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_M4 line",OBJPROP_WIDTH,1);
         ObjectSet("Fhr_M4 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("Fhr_M4 line",0,time[0],Fhr_M4);
        }

      if(ObjectFind("Fhr_M3 line")!=0)
        {
         ObjectCreate(0,"Fhr_M3 line",OBJ_HLINE,0,time[0],Fhr_M3);
         ObjectSet("Fhr_M3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_M3 line",OBJPROP_WIDTH,1);
         ObjectSet("Fhr_M3 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("Fhr_M3 line",0,time[0],Fhr_M3);
        }

      if(ObjectFind("Fhr_M2 line")!=0)
        {
         ObjectCreate(0,"Fhr_M2 line",OBJ_HLINE,0,time[0],Fhr_M2);
         ObjectSet("Fhr_M2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_M2 line",OBJPROP_WIDTH,1);
         ObjectSet("Fhr_M2 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("Fhr_M2 line",0,time[0],Fhr_M2);
        }

      if(ObjectFind("Fhr_M1 line")!=0)
        {
         ObjectCreate(0,"Fhr_M1 line",OBJ_HLINE,0,time[0],Fhr_M1);
         ObjectSet("Fhr_M1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_M1 line",OBJPROP_WIDTH,1);
         ObjectSet("Fhr_M1 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("Fhr_M1 line",0,time[0],Fhr_M1);
        }

      if(ObjectFind("Fhr_M0 line")!=0)
        {
         ObjectCreate(0,"Fhr_M0 line",OBJ_HLINE,0,time[0],Fhr_M0);
         ObjectSet("Fhr_M0 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("Fhr_M0 line",OBJPROP_WIDTH,1);
         ObjectSet("Fhr_M0 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("Fhr_M0 line",0,time[0],Fhr_M0);
        }

     }
//--------------------------------------------------------End of 4 hour 
//----------------------------------------------------------------------------DAILY Pivot Lines --------------------
   if(daily==true)
     {
      if(ObjectFind("D_R1 label")!=0)
        {
         ObjectCreate(0,"D_R1 label",OBJ_TEXT,0,label_Shift_Time,D_R1);
         ObjectSetText("D_R1 label","D_R1 "+DoubleToStr(D_R1,4),8,"Arial",Red);
        }
      else
        {
         ObjectMove("D_R1 label",0,label_Shift_Time,D_R1);
        }

      if(ObjectFind("D_R2 label")!=0)
        {
         ObjectCreate(0,"D_R2 label",OBJ_TEXT,0,label_Shift_Time,D_R2);
         ObjectSetText("D_R2 label","D_R2 "+DoubleToStr(D_R2,4),8,"Arial",Red);
        }
      else
        {
         ObjectMove("D_R2 label",0,label_Shift_Time,D_R2);
        }

      if(ObjectFind("D_R3 label")!=0)
        {
         ObjectCreate(0,"D_R3 label",OBJ_TEXT,0,label_Shift_Time,D_R3);
         ObjectSetText("D_R3 label","D_R3 "+DoubleToStr(D_R3,4),8,"Arial",Red);
        }
      else
        {
         ObjectMove("D_R3 label",0,label_Shift_Time,D_R3);
        }

      if(ObjectFind("D_P label")!=0)
        {
         ObjectCreate(0,"D_P label",OBJ_TEXT,0,label_Shift_Time,D_P);
         ObjectSetText("D_P label","D_PP : "+DoubleToStr(D_P,4),8,"Arial",Magenta);
        }
      else
        {
         ObjectMove("D_P label",0,label_Shift_Time,D_P);
        }

      if(ObjectFind("D_S1 label")!=0)
        {
         ObjectCreate(0,"D_S1 label",OBJ_TEXT,0,label_Shift_Time,D_S1);
         ObjectSetText("D_S1 label","D_S1 "+DoubleToStr(D_S1,4),8,"Arial",Green);
        }
      else
        {
         ObjectMove("D_S1 label",0,label_Shift_Time,D_S1);
        }

      if(ObjectFind("D_S2 label")!=0)
        {
         ObjectCreate(0,"D_S2 label",OBJ_TEXT,0,label_Shift_Time,D_S2);
         ObjectSetText("D_S2 label","D_S2 "+DoubleToStr(D_S2,4),8,"Arial",Green);
        }
      else
        {
         ObjectMove("D_S2 label",0,label_Shift_Time,D_S2);
        }

      if(ObjectFind("D_S3 label")!=0)
        {
         ObjectCreate(0,"D_S3 label",OBJ_TEXT,0,label_Shift_Time,D_S3);
         ObjectSetText("D_S3 label","D_S3 "+DoubleToStr(D_S3,4),8,"Arial",Green);
        }
      else
        {
         ObjectMove("D_S3 label",0,label_Shift_Time,D_S3);
        }

      //--- Draw Pivot lines on chart
      if(ObjectFind("D_S1 line")!=0)
        {
         ObjectCreate(0,"D_S1 line",OBJ_HLINE,0,time[0],D_S1);
         ObjectSet("D_S1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_S1 line",OBJPROP_WIDTH,2);
         ObjectSet("D_S1 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("D_S1 line",0,time[0],D_S1);
        }

      if(ObjectFind("D_S2 line")!=0)
        {
         ObjectCreate(0,"D_S2 line",OBJ_HLINE,0,time[0],D_S2);
         ObjectSet("D_S2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_S2 line",OBJPROP_WIDTH,2);
         ObjectSet("D_S2 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("D_S2 line",0,time[0],D_S2);
        }

      if(ObjectFind("D_S3 line")!=0)
        {
         ObjectCreate(0,"D_S3 line",OBJ_HLINE,0,time[0],D_S3);
         ObjectSet("D_S3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_S3 line",OBJPROP_WIDTH,2);
         ObjectSet("D_S3 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("D_S3 line",0,time[0],D_S3);
        }

      if(ObjectFind("D_P line")!=0)
        {
         ObjectCreate(0,"D_P line",OBJ_HLINE,0,time[0],D_P);
         ObjectSet("D_P line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_P line",OBJPROP_WIDTH,2);
         ObjectSet("D_P line",OBJPROP_COLOR,Magenta);
        }
      else
        {
         ObjectMove("D_P line",0,time[0],D_P);
        }

      if(ObjectFind("D_R1 line")!=0)
        {
         ObjectCreate(0,"D_R1 line",OBJ_HLINE,0,time[0],D_R1);
         ObjectSet("D_R1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_R1 line",OBJPROP_WIDTH,2);
         ObjectSet("D_R1 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("D_R1 line",0,time[0],D_R1);
        }

      if(ObjectFind("D_R2 line")!=0)
        {
         ObjectCreate(0,"D_R2 line",OBJ_HLINE,0,time[0],D_R2);
         ObjectSet("D_R2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_R2 line",OBJPROP_WIDTH,2);
         ObjectSet("D_R2 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("D_R2 line",0,time[0],D_R2);
        }

      if(ObjectFind("D_R3 line")!=0)
        {
         ObjectCreate(0,"D_R3 line",OBJ_HLINE,0,time[0],D_R3);
         ObjectSet("D_R3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_R3 line",OBJPROP_WIDTH,2);
         ObjectSet("D_R3 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("D_R3 line",0,time[0],D_R3);
        }
     }
//---- End of Pivot Line Draw


//------ Midpoints Pivots

   if(daily==true && midpivots==true)
     {

      if(ObjectFind("D_M5 label")!=0)
        {
         ObjectCreate(0,"D_M5 label",OBJ_TEXT,0,label_Shift_Time,D_M5);
         ObjectSetText("D_M5 label","D_M5 "+DoubleToStr(D_M5,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("D_M5 label",0,label_Shift_Time,D_M5);
        }

      if(ObjectFind("D_M4 label")!=0)
        {
         ObjectCreate(0,"D_M4 label",OBJ_TEXT,0,label_Shift_Time,D_M4);
         ObjectSetText("D_M4 label","D_M4 "+DoubleToStr(D_M4,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("D_M4 label",0,label_Shift_Time,D_M4);
        }

      if(ObjectFind("D_M3 label")!=0)
        {
         ObjectCreate(0,"D_M3 label",OBJ_TEXT,0,label_Shift_Time,D_M3);
         ObjectSetText("D_M3 label","D_M3 "+DoubleToStr(D_M3,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("D_M3 label",0,label_Shift_Time,D_M3);
        }

      if(ObjectFind("D_M2 label")!=0)
        {
         ObjectCreate(0,"D_M2 label",OBJ_TEXT,0,label_Shift_Time,D_M2);
         ObjectSetText("D_M2 label","D_M2 "+DoubleToStr(D_M2,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("D_M2 label",0,label_Shift_Time,D_M2);
        }

      if(ObjectFind("D_M1 label")!=0)
        {
         ObjectCreate(0,"D_M1 label",OBJ_TEXT,0,label_Shift_Time,D_M1);
         ObjectSetText("D_M1 label","D_M1 "+DoubleToStr(D_M1,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("D_M1 label",0,label_Shift_Time,D_M1);
        }

      if(ObjectFind("D_M0 label")!=0)
        {
         ObjectCreate(0,"D_M0 label",OBJ_TEXT,0,label_Shift_Time,D_M0);
         ObjectSetText("D_M0 label","D_M0 "+DoubleToStr(D_M0,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("D_M0 label",0,label_Shift_Time,D_M0);
        }

      //---- Draw Midpoint Pivots on Chart
      if(ObjectFind("D_M5 line")!=0)
        {
         ObjectCreate(0,"D_M5 line",OBJ_HLINE,0,time[0],D_M5);
         ObjectSet("D_M5 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_M5 line",OBJPROP_WIDTH,1);
         ObjectSet("D_M5 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("D_M5 line",0,time[0],D_M5);
        }

      if(ObjectFind("D_M4 line")!=0)
        {
         ObjectCreate(0,"D_M4 line",OBJ_HLINE,0,time[0],D_M4);
         ObjectSet("D_M4 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_M4 line",OBJPROP_WIDTH,1);
         ObjectSet("D_M4 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("D_M4 line",0,time[0],D_M4);
        }

      if(ObjectFind("D_M3 line")!=0)
        {
         ObjectCreate(0,"D_M3 line",OBJ_HLINE,0,time[0],D_M3);
         ObjectSet("D_M3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_M3 line",OBJPROP_WIDTH,1);
         ObjectSet("D_M3 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("D_M3 line",0,time[0],D_M3);
        }

      if(ObjectFind("D_M2 line")!=0)
        {
         ObjectCreate(0,"D_M2 line",OBJ_HLINE,0,time[0],D_M2);
         ObjectSet("D_M2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_M2 line",OBJPROP_WIDTH,1);
         ObjectSet("D_M2 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("D_M2 line",0,time[0],D_M2);
        }

      if(ObjectFind("D_M1 line")!=0)
        {
         ObjectCreate(0,"D_M1 line",OBJ_HLINE,0,time[0],D_M1);
         ObjectSet("D_M1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_M1 line",OBJPROP_WIDTH,1);
         ObjectSet("D_M1 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("D_M1 line",0,time[0],D_M1);
        }

      if(ObjectFind("D_M0 line")!=0)
        {
         ObjectCreate(0,"D_M0 line",OBJ_HLINE,0,time[0],D_M0);
         ObjectSet("D_M0 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("D_M0 line",OBJPROP_WIDTH,1);
         ObjectSet("D_M0 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("D_M0 line",0,time[0],D_M0);
        }

     }
//-------------=---------------------------------------------------------------------End of DAILY
//---------------------------------------------------------------------WEEKLY Pivot Lines --------------------
   if(weekly==true)
     {
      if(ObjectFind("W_R1 label")!=0)
        {
         ObjectCreate(0,"W_R1 label",OBJ_TEXT,0,label_Shift_Time,W_R1);
         ObjectSetText("W_R1 label","W_R1 "+DoubleToStr(W_R1,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_R1 label",0,label_Shift_Time,W_R1);
        }

      if(ObjectFind("W_R2 label")!=0)
        {
         ObjectCreate(0,"W_R2 label",OBJ_TEXT,0,label_Shift_Time,W_R2);
         ObjectSetText("W_R2 label","W_R2 "+DoubleToStr(W_R2,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_R2 label",0,label_Shift_Time,W_R2);
        }

      if(ObjectFind("W_R3 label")!=0)
        {
         ObjectCreate(0,"W_R3 label",OBJ_TEXT,0,label_Shift_Time,W_R3);
         ObjectSetText("W_R3 label","W_R3 "+DoubleToStr(W_R3,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_R3 label",0,label_Shift_Time,W_R3);
        }

      if(ObjectFind("W_P label")!=0)
        {
         ObjectCreate(0,"W_P label",OBJ_TEXT,0,label_Shift_Time,W_P);
         ObjectSetText("W_P label","W_Pivot "+DoubleToStr(W_P,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_P label",0,label_Shift_Time,W_P);
        }

      if(ObjectFind("W_S1 label")!=0)
        {
         ObjectCreate(0,"W_S1 label",OBJ_TEXT,0,label_Shift_Time,W_S1);
         ObjectSetText("W_S1 label","W_S1 "+DoubleToStr(W_S1,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_S1 label",0,label_Shift_Time,W_S1);
        }

      if(ObjectFind("W_S2 label")!=0)
        {
         ObjectCreate(0,"W_S2 label",OBJ_TEXT,0,label_Shift_Time,W_S2);
         ObjectSetText("W_S2 label","W_S2 "+DoubleToStr(W_S2,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_S2 label",0,label_Shift_Time,W_S2);
        }

      if(ObjectFind("W_S3 label")!=0)
        {
         ObjectCreate(0,"W_S3 label",OBJ_TEXT,0,label_Shift_Time,W_S3);
         ObjectSetText("W_S3 label","W_S3 "+DoubleToStr(W_S3,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_S3 label",0,label_Shift_Time,W_S3);
        }

      //--- Draw Pivot lines on chart
      if(ObjectFind("W_S1 line")!=0)
        {
         ObjectCreate(0,"W_S1 line",OBJ_HLINE,0,time[0],W_S1);
         ObjectSet("W_S1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_S1 line",OBJPROP_WIDTH,2);
         ObjectSet("W_S1 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("W_S1 line",0,time[0],W_S1);
        }

      if(ObjectFind("W_S2 line")!=0)
        {
         ObjectCreate(0,"W_S2 line",OBJ_HLINE,0,time[0],W_S2);
         ObjectSet("W_S2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_S2 line",OBJPROP_WIDTH,2);
         ObjectSet("W_S2 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("W_S2 line",0,time[0],W_S2);
        }

      if(ObjectFind("W_S3 line")!=0)
        {
         ObjectCreate(0,"W_S3 line",OBJ_HLINE,0,time[0],W_S3);
         ObjectSet("W_S3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_S3 line",OBJPROP_WIDTH,2);
         ObjectSet("W_S3 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("W_S3 line",0,time[0],W_S3);
        }

      if(ObjectFind("W_P line")!=0)
        {
         ObjectCreate(0,"W_P line",OBJ_HLINE,0,time[0],W_P);
         ObjectSet("W_P line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_P line",OBJPROP_WIDTH,2);
         ObjectSet("W_P line",OBJPROP_COLOR,LightBlue);
        }
      else
        {
         ObjectMove("W_P line",0,time[0],W_P);
        }

      if(ObjectFind("W_R1 line")!=0)
        {
         ObjectCreate(0,"W_R1 line",OBJ_HLINE,0,time[0],W_R1);
         ObjectSet("W_R1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_R1 line",OBJPROP_WIDTH,2);
         ObjectSet("W_R1 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("W_R1 line",0,time[0],W_R1);
        }

      if(ObjectFind("W_R2 line")!=0)
        {
         ObjectCreate(0,"W_R2 line",OBJ_HLINE,0,time[0],W_R2);
         ObjectSet("W_R2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_R2 line",OBJPROP_WIDTH,2);
         ObjectSet("W_R2 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("W_R2 line",0,time[0],W_R2);
        }

      if(ObjectFind("W_R3 line")!=0)
        {
         ObjectCreate(0,"W_R3 line",OBJ_HLINE,0,time[0],W_R3);
         ObjectSet("W_R3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_R3 line",OBJPROP_WIDTH,2);
         ObjectSet("W_R3 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("W_R3 line",0,time[0],W_R3);
        }
     }
//---- End of Pivot Line Draw


//------ Midpoints Pivots

   if(weekly==true && midpivots==true)
     {

      if(ObjectFind("W_M5 label")!=0)
        {
         ObjectCreate(0,"W_M5 label",OBJ_TEXT,0,label_Shift_Time,W_M5);
         ObjectSetText("W_M5 label","W_M5 "+DoubleToStr(W_M5,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_M5 label",0,label_Shift_Time,W_M5);
        }

      if(ObjectFind("W_M4 label")!=0)
        {
         ObjectCreate(0,"W_M4 label",OBJ_TEXT,0,label_Shift_Time,W_M4);
         ObjectSetText("W_M4 label","W_M4 "+DoubleToStr(W_M4,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_M4 label",0,label_Shift_Time,W_M4);
        }

      if(ObjectFind("W_M3 label")!=0)
        {
         ObjectCreate(0,"W_M3 label",OBJ_TEXT,0,label_Shift_Time,W_M3);
         ObjectSetText("W_M3 label","W_M3 "+DoubleToStr(W_M3,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_M3 label",0,label_Shift_Time,W_M3);
        }

      if(ObjectFind("W_M2 label")!=0)
        {
         ObjectCreate(0,"W_M2 label",OBJ_TEXT,0,label_Shift_Time,W_M2);
         ObjectSetText("W_M2 label","W_M2 "+DoubleToStr(W_M2,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_M2 label",0,label_Shift_Time,W_M2);
        }

      if(ObjectFind("W_M1 label")!=0)
        {
         ObjectCreate(0,"W_M1 label",OBJ_TEXT,0,label_Shift_Time,W_M1);
         ObjectSetText("W_M1 label","W_M1 "+DoubleToStr(W_M1,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_M1 label",0,label_Shift_Time,W_M1);
        }

      if(ObjectFind("W_M0 label")!=0)
        {
         ObjectCreate(0,"W_M0 label",OBJ_TEXT,0,label_Shift_Time,W_M0);
         ObjectSetText("W_M0 label","W_M0 "+DoubleToStr(W_M0,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("W_M0 label",0,label_Shift_Time,W_M0);
        }

      //---- Draw Midpoint Pivots on Chart
      if(ObjectFind("W_M5 line")!=0)
        {
         ObjectCreate(0,"W_M5 line",OBJ_HLINE,0,time[0],W_M5);
         ObjectSet("W_M5 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_M5 line",OBJPROP_WIDTH,1);
         ObjectSet("W_M5 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("W_M5 line",0,time[0],W_M5);
        }

      if(ObjectFind("W_M4 line")!=0)
        {
         ObjectCreate(0,"W_M4 line",OBJ_HLINE,0,time[0],W_M4);
         ObjectSet("W_M4 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_M4 line",OBJPROP_WIDTH,1);
         ObjectSet("W_M4 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("W_M4 line",0,time[0],W_M4);
        }

      if(ObjectFind("W_M3 line")!=0)
        {
         ObjectCreate(0,"W_M3 line",OBJ_HLINE,0,time[0],W_M3);
         ObjectSet("W_M3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_M3 line",OBJPROP_WIDTH,1);
         ObjectSet("W_M3 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("W_M3 line",0,time[0],W_M3);
        }

      if(ObjectFind("W_M2 line")!=0)
        {
         ObjectCreate(0,"W_M2 line",OBJ_HLINE,0,time[0],W_M2);
         ObjectSet("W_M2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_M2 line",OBJPROP_WIDTH,1);
         ObjectSet("W_M2 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("W_M2 line",0,time[0],W_M2);
        }

      if(ObjectFind("W_M1 line")!=0)
        {
         ObjectCreate(0,"W_M1 line",OBJ_HLINE,0,time[0],W_M1);
         ObjectSet("W_M1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_M1 line",OBJPROP_WIDTH,1);
         ObjectSet("W_M1 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("W_M1 line",0,time[0],W_M1);
        }

      if(ObjectFind("W_M0 line")!=0)
        {
         ObjectCreate(0,"W_M0 line",OBJ_HLINE,0,time[0],W_M0);
         ObjectSet("W_M0 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("W_M0 line",OBJPROP_WIDTH,1);
         ObjectSet("W_M0 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("W_M0 line",0,time[0],W_M0);
        }

     }
//-------------=-------------------------------------------End WEEKLY 



//--------------------------------------------------------------------Monthly Pivot Lines --------------------
   if(monthly==true)
     {
      if(ObjectFind(0,"M_R1 label")!=0)
        {
         ObjectCreate("M_R1 label",OBJ_TEXT,0,label_Shift_Time,M_R1);
         ObjectSetText("M_R1 label"," M_R1 "+DoubleToStr(M_R1,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_R1 label",0,label_Shift_Time,M_R1);
        }

      if(ObjectFind("M_R2 label")!=0)
        {
         ObjectCreate(0,"M_R2 label",OBJ_TEXT,0,label_Shift_Time,M_R2);
         ObjectSetText("M_R2 label"," M_R2 "+DoubleToStr(M_R2,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_R2 label",0,label_Shift_Time,M_R2);
        }

      if(ObjectFind("M_R3 label")!=0)
        {
         ObjectCreate(0,"M_R3 label",OBJ_TEXT,0,label_Shift_Time,M_R3);
         ObjectSetText("M_R3 label"," M_R3 "+DoubleToStr(M_R3,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_R3 label",0,label_Shift_Time,M_R3);
        }

      if(ObjectFind("M_P label")!=0)
        {
         ObjectCreate(0,"M_P label",OBJ_TEXT,0,label_Shift_Time,M_P);
         ObjectSetText("M_P label","M_Pivot "+DoubleToStr(M_P,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_P label",0,label_Shift_Time,M_P);
        }

      if(ObjectFind("M_S1 label")!=0)
        {
         ObjectCreate(0,"M_S1 label",OBJ_TEXT,0,label_Shift_Time,M_S1);
         ObjectSetText("M_S1 label","M_S1 "+DoubleToStr(M_S1,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_S1 label",0,label_Shift_Time,M_S1);
        }

      if(ObjectFind("M_S2 label")!=0)
        {
         ObjectCreate(0,"M_S2 label",OBJ_TEXT,0,label_Shift_Time,M_S2);
         ObjectSetText("M_S2 label","S2 "+DoubleToStr(M_S2,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_S2 label",0,label_Shift_Time,M_S2);
        }

      if(ObjectFind("M_S3 label")!=0)
        {
         ObjectCreate(0,"M_S3 label",OBJ_TEXT,0,label_Shift_Time,M_S3);
         ObjectSetText("M_S3 label","M_S3 "+DoubleToStr(M_S3,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_S3 label",0,label_Shift_Time,M_S3);
        }

      //--- Draw Pivot lines on chart
      if(ObjectFind("M_S1 line")!=0)
        {
         ObjectCreate(0,"M_S1 line",OBJ_HLINE,0,time[0],M_S1);
         ObjectSet("M_S1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_S1 line",OBJPROP_WIDTH,2);
         ObjectSet("M_S1 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("M_S1 line",0,time[0],M_S1);
        }

      if(ObjectFind("M_S2 line")!=0)
        {
         ObjectCreate(0,"M_S2 line",OBJ_HLINE,0,time[0],M_S2);
         ObjectSet("M_S2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_S2 line",OBJPROP_WIDTH,2);
         ObjectSet("M_S2 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("M_S2 line",0,time[0],M_S2);
        }

      if(ObjectFind("M_S3 line")!=0)
        {
         ObjectCreate(0,"M_S3 line",OBJ_HLINE,0,time[0],M_S3);
         ObjectSet("M_S3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_S3 line",OBJPROP_WIDTH,2);
         ObjectSet("M_S3 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("M_S3 line",0,time[0],M_S3);
        }

      if(ObjectFind("M_P line")!=0)
        {
         ObjectCreate(0,"M_P line",OBJ_HLINE,0,time[0],M_P);
         ObjectSet("M_P line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_P line",OBJPROP_WIDTH,2);
         ObjectSet("M_P line",OBJPROP_COLOR,LightBlue);
        }
      else
        {
         ObjectMove("M_P line",0,time[0],M_P);
        }

      if(ObjectFind("M_R1 line")!=0)
        {
         ObjectCreate(0,"M_R1 line",OBJ_HLINE,0,time[0],M_R1);
         ObjectSet("M_R1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_R1 line",OBJPROP_WIDTH,2);
         ObjectSet("M_R1 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("M_R1 line",0,time[0],M_R1);
        }

      if(ObjectFind("M_R2 line")!=0)
        {
         ObjectCreate(0,"M_R2 line",OBJ_HLINE,0,time[0],M_R2);
         ObjectSet("M_R2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_R2 line",OBJPROP_WIDTH,2);
         ObjectSet("M_R2 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("M_R2 line",0,time[0],M_R2);
        }

      if(ObjectFind("M_R3 line")!=0)
        {
         ObjectCreate(0,"M_R3 line",OBJ_HLINE,0,time[0],M_R3);
         ObjectSet("M_R3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_R3 line",OBJPROP_WIDTH,2);
         ObjectSet("M_R3 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("M_R3 line",0,time[0],M_R3);
        }
     }
//---- End of Pivot Line Draw


//------ Midpoints Pivots

   if(monthly==true && midpivots==true)
     {

      if(ObjectFind("M_M5 label")!=0)
        {
         ObjectCreate(0,"M_M5 label",OBJ_TEXT,0,label_Shift_Time,M_M5);
         ObjectSetText("M_M5 label"," M_M5 "+DoubleToStr(M_M5,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_M5 label",0,label_Shift_Time,M_M5);
        }

      if(ObjectFind("M_M4 label")!=0)
        {
         ObjectCreate(0,"M_M4 label",OBJ_TEXT,0,label_Shift_Time,M_M4);
         ObjectSetText("M_M4 label"," M_M4 "+DoubleToStr(M_M4,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_M4 label",0,label_Shift_Time,M_M4);
        }

      if(ObjectFind("M_M3 label")!=0)
        {
         ObjectCreate(0,"M_M3 label",OBJ_TEXT,0,label_Shift_Time,M_M3);
         ObjectSetText("M_M3 label"," M_M3 "+DoubleToStr(M_M3,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_M3 label",0,label_Shift_Time,M_M3);
        }

      if(ObjectFind("M_M2 label")!=0)
        {
         ObjectCreate(0,"M_M2 label",OBJ_TEXT,0,label_Shift_Time,M_M2);
         ObjectSetText("M_M2 label"," M_M2 "+DoubleToStr(M_M2,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_M2 label",0,label_Shift_Time,M_M2);
        }

      if(ObjectFind("M_M1 label")!=0)
        {
         ObjectCreate(0,"M_M1 label",OBJ_TEXT,0,label_Shift_Time,M_M1);
         ObjectSetText("M_M1 label"," M_M1 "+DoubleToStr(M_M1,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_M1 label",0,label_Shift_Time,M_M1);
        }

      if(ObjectFind("M_M0 label")!=0)
        {
         ObjectCreate(0,"M_M0 label",OBJ_TEXT,0,label_Shift_Time,M_M0);
         ObjectSetText("M_M0 label"," M_M0 "+DoubleToStr(M_M0,4),8,"Arial",EMPTY);
        }
      else
        {
         ObjectMove("M_M0 label",0,label_Shift_Time,M_M0);
        }

      //---- Draw Midpoint Pivots on Chart
      if(ObjectFind("M_M5 line")!=0)
        {
         ObjectCreate(0,"M_M5 line",OBJ_HLINE,0,time[0],M_M5);
         ObjectSet("M_M5 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_M5 line",OBJPROP_WIDTH,1);
         ObjectSet("M_M5 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("M_M5 line",0,time[0],M_M5);
        }

      if(ObjectFind("M_M4 line")!=0)
        {
         ObjectCreate(0,"M_M4 line",OBJ_HLINE,0,time[0],M_M4);
         ObjectSet("M_M4 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_M4 line",OBJPROP_WIDTH,1);
         ObjectSet("M_M4 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("M_M4 line",0,time[0],M_M4);
        }

      if(ObjectFind("M_M3 line")!=0)
        {
         ObjectCreate(0,"M_M3 line",OBJ_HLINE,0,time[0],M_M3);
         ObjectSet("M_M3 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_M3 line",OBJPROP_WIDTH,1);
         ObjectSet("M_M3 line",OBJPROP_COLOR,Red);
        }
      else
        {
         ObjectMove("M_M3 line",0,time[0],M_M3);
        }

      if(ObjectFind("M_M2 line")!=0)
        {
         ObjectCreate(0,"M_M2 line",OBJ_HLINE,0,time[0],M_M2);
         ObjectSet("M_M2 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_M2 line",OBJPROP_WIDTH,1);
         ObjectSet("M_M2 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("M_M2 line",0,time[0],M_M2);
        }

      if(ObjectFind("M_M1 line")!=0)
        {
         ObjectCreate(0,"M_M1 line",OBJ_HLINE,0,time[0],M_M1);
         ObjectSet("M_M1 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_M1 line",OBJPROP_WIDTH,1);
         ObjectSet("M_M1 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("M_M1 line",0,time[0],M_M1);
        }

      if(ObjectFind("M_M0 line")!=0)
        {
         ObjectCreate(0,"M_M0 line",OBJ_HLINE,0,time[0],M_M0);
         ObjectSet("M_M0 line",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("M_M0 line",OBJPROP_WIDTH,1);
         ObjectSet("M_M0 line",OBJPROP_COLOR,Blue);
        }
      else
        {
         ObjectMove("M_M0 line",0,time[0],M_M0);
        }

     }
//-END of MONTHLY   
//--- return value of prev_calculated for next call

   //OnDeinit(const int reason);
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---- TODO: add your code here
// 4 hour--------------------------
   ObjectDelete(0,"Fhr_R1 label");
   ObjectDelete(0,"Fhr_R1 line");
   ObjectDelete(0,"Fhr_R2 label");
   ObjectDelete(0,"Fhr_R2 line");
   ObjectDelete(0,"Fhr_R3 label");
   ObjectDelete(0,"Fhr_R3 line");
   ObjectDelete(0,"Fhr_S1 label");
   ObjectDelete(0,"Fhr_S1 line");
   ObjectDelete(0,"Fhr_S2 label");
   ObjectDelete(0,"Fhr_S2 line");
   ObjectDelete(0,"Fhr_S3 label");
   ObjectDelete(0,"Fhr_S3 line");
   ObjectDelete(0,"Fhr_P label");
   ObjectDelete(0,"Fhr_P line");
   ObjectDelete(0,"Fhr_M5 label");
   ObjectDelete(0,"Fhr_M5 line");
   ObjectDelete(0,"Fhr_M4 label");
   ObjectDelete(0,"Fhr_M4 line");
   ObjectDelete(0,"Fhr_M3 label");
   ObjectDelete(0,"Fhr_M3 line");
   ObjectDelete(0,"Fhr_M2 label");
   ObjectDelete(0,"Fhr_M2 lne");
   ObjectDelete(0,"Fhr_M1 label");
   ObjectDelete(0,"Fhr_M1 line");
   ObjectDelete(0,"Fhr_M0 label");
   ObjectDelete(0,"Fhr_M0 line");
//
   ObjectDelete(0,"D_R1 label");
   ObjectDelete(0,"D_R1 line");
   ObjectDelete(0,"D_R2 label");
   ObjectDelete(0,"D_R2 line");
   ObjectDelete(0,"D_R3 label");
   ObjectDelete(0,"D_R3 line");
   ObjectDelete(0,"D_S1 label");
   ObjectDelete(0,"D_S1 line");
   ObjectDelete(0,"D_S2 label");
   ObjectDelete(0,"D_S2 line");
   ObjectDelete(0,"D_S3 label");
   ObjectDelete(0,"D_S3 line");
   ObjectDelete(0,"D_P label");
   ObjectDelete(0,"D_P line");
   ObjectDelete(0,"D_M5 label");
   ObjectDelete(0,"D_M5 line");
   ObjectDelete(0,"D_M4 label");
   ObjectDelete(0,"D_M4 line");
   ObjectDelete(0,"D_M3 label");
   ObjectDelete(0,"D_M3 line");
   ObjectDelete(0,"D_M2 label");
   ObjectDelete(0,"D_M2 line");
   ObjectDelete(0,"D_M1 label");
   ObjectDelete(0,"D_M1 line");
   ObjectDelete(0,"D_M0 label");
   ObjectDelete(0,"D_M0 line");
//--------------------------------------
   ObjectDelete(0,"W_R1 label");
   ObjectDelete(0,"W_R1 line");
   ObjectDelete(0,"W_R2 label");
   ObjectDelete(0,"W_R2 line");
   ObjectDelete(0,"W_R3 label");
   ObjectDelete(0,"W_R3 line");
   ObjectDelete(0,"W_S1 label");
   ObjectDelete(0,"W_S1 line");
   ObjectDelete(0,"W_S2 label");
   ObjectDelete(0,"W_S2 line");
   ObjectDelete(0,"W_S3 label");
   ObjectDelete(0,"W_S3 line");
   ObjectDelete(0,"W_P label");
   ObjectDelete(0,"W_P line");
   ObjectDelete(0,"W_M5 label");
   ObjectDelete(0,"W_M5 line");
   ObjectDelete(0,"W_M4 label");
   ObjectDelete(0,"W_M4 line");
   ObjectDelete(0,"W_M3 label");
   ObjectDelete(0,"W_M3 line");
   ObjectDelete(0,"W_M2 label");
   ObjectDelete(0,"W_M2 line");
   ObjectDelete(0,"W_M1 label");
   ObjectDelete(0,"W_M1 line");
   ObjectDelete(0,"W_M0 label");
   ObjectDelete(0,"W_M0 line");
//--------------------------------------
   ObjectDelete(0,"M_R1 label");
   ObjectDelete(0,"M_R1 line");
   ObjectDelete(0,"M_R2 label");
   ObjectDelete(0,"M_R2 line");
   ObjectDelete(0,"M_R3 label");
   ObjectDelete(0,"M_R3 line");
   ObjectDelete(0,"M_S1 label");
   ObjectDelete(0,"M_S1 line");
   ObjectDelete(0,"M_S2 label");
   ObjectDelete(0,"M_S2 line");
   ObjectDelete(0,"M_S3 label");
   ObjectDelete(0,"M_S3 line");
   ObjectDelete(0,"M_P label");
   ObjectDelete(0,"M_P line");
   ObjectDelete(0,"M_M5 label");
   ObjectDelete(0,"M_M5 line");
   ObjectDelete(0,"M_M4 label");
   ObjectDelete(0,"M_M4 line");
   ObjectDelete(0,"M_M3 label");
   ObjectDelete(0,"M_M3 line");
   ObjectDelete(0,"M_M2 label");
   ObjectDelete(0,"M_M2 line");
   ObjectDelete(0,"M_M1 label");
   ObjectDelete(0,"M_M1 line");
   ObjectDelete(0,"M_M0 label");
   ObjectDelete(0,"M_M0 line");
//----
   return;
  }
//+------------------------------------------------------------------+
// This are functions for check and set chart shit as provided in MQL documentation
// To have labels showing on the right of time[0], the chart needs to be shifted
//+---------------------------------------------------------------------------+
//| The function receives shift size of the zero bar from the right border    |
//| of the chart in percentage values (from 10% up to 50%).                   |
//+---------------------------------------------------------------------------+
double ChartShiftSizeGet(const long chart_ID=0)
  {
//--- prepare the variable to get the result
   double result=EMPTY_VALUE;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetDouble(0,CHART_SHIFT_SIZE,0,result))
     {
      //--- display the error message in Experts journal
      Print("ChartShiftSizeGet"+", Error Code = ",ErrorDescription(GetLastError()));
     }
//--- return the value of the chart property
   return(result);
  }
//+--------------------------------------------------------------------------------------+
//| The function sets the shift size of the zero bar from the right                      |
//| border of the chart in percentage values (from 10% up to 50%). To enable the shift   |
//| mode, CHART_SHIFT property value should be set to                                    |
//| true.                                                                                |
//+--------------------------------------------------------------------------------------+
bool ChartShiftSizeSet(const double value,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//---


//--- set property value
   if(!ChartSetDouble(chart_ID,CHART_SHIFT_SIZE,value))
     {
      //--- display the error message in Experts journal
      Print("ChartShiftSizeSet"+", Error Code = ",ErrorDescription(GetLastError()));
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------+
//| The function defines if the mode of shift of the price chart from the right border |
//| is enabled.                                                                        |
//+------------------------------------------------------------------------------------+
bool ChartShiftGet(bool &result,const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long value;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_SHIFT,0,value))
     {
      //--- display the error message in Experts journal
      Print("ChartShiftGet"+", Error Code = ",GetLastError());
      return(false);
     }
//--- store the value of the chart property in memory
   result=value;
//--- successful execution
   return(true);
  }
//+--------------------------------------------------------------------------+
//| The function enables/disables the mode of displaying a price chart with  |
//| a shift from the right border.                                           |
//+--------------------------------------------------------------------------+
bool ChartShiftSet(const bool value,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set property value
   if(!ChartSetInteger(chart_ID,CHART_SHIFT,value))
     {
      //--- display the error message in Experts journal
      Print("ChartShiftSet"+", Error Code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
