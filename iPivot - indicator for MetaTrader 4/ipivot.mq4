//+------------------------------------------------------------------+
//|                                                       iPivot.mq4 |
//|                                        Copyright © 2015, Awran5. |
//|                                                 awran5@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Awran5."
#property link      "awran5@yahoo.com"
#property version   "1.01"
#property description "Draw Daily Pivot Point with 4 Support and Resistance lines in most popular Formulas:\n"
#property description "- Standard, \n- Fibonacci, \n- Camarilla, \n- Woody’s, \n- DeMark"
#property strict
#property indicator_chart_window
#property indicator_buffers 9
#define INAME "iPivot: "
#define LOOKBACK 1
//---
enum Pivot
  {
   Standard,   // Standard
   Fibonacci,  // Fibonacci
   Camarilla,  // Camarilla
   Woodie,     // Woodie
   DeMark      // DeMark
  };
//---
input string          lb_0        = "";              // ------->  Settings
input Pivot           PivotMethod = Fibonacci;       // Pivot Forumlas
input color           pColor      = clrPurple;       // Pivot Color
input bool            Show_SR     = true;            // Show S/R
input color           rColor      = clrFireBrick;    // Resistance Color
input color           sColor      = clrDarkGreen;    // Support Color
input int             Width       = 2;               // Lines width
input ENUM_LINE_STYLE Style       = 0;               // Lines style
input color           LabelsColor = clrDimGray;      // Labels color
input string          lb_1        = "";              // --------------------------------------------------------
input string          lb_2        = "";              // ------->  Notification
input bool            UseAlert    = true;            // Enable Alert
input bool            UseEmail    = false;           // Enable Email
input bool            UseNotification=false;         // Enable Notification
input bool            UseSound    = false;           // Enable Sound
input string          SoundName   = "alert2.wav";    // Sound Name
//---
double P,R1,R2,R3,R4,S1,S2,S3,S4;
double PBuffer[],S1Buffer[],S2Buffer[],S3Buffer[],S4Buffer[],R1Buffer[],R2Buffer[],R3Buffer[],R4Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,PBuffer);
   SetIndexBuffer(1,R1Buffer);
   SetIndexBuffer(2,R2Buffer);
   SetIndexBuffer(3,R3Buffer);
   SetIndexBuffer(4,R4Buffer);
   SetIndexBuffer(5,S1Buffer);
   SetIndexBuffer(6,S2Buffer);
   SetIndexBuffer(7,S3Buffer);
   SetIndexBuffer(8,S4Buffer);
// Set styles
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexStyle(7,DRAW_NONE);
   SetIndexStyle(8,DRAW_NONE);
// Set labels
   SetIndexLabel(0,"Pivot");
   SetIndexLabel(1,"Resistance 1");
   SetIndexLabel(2,"Resistance 2");
   SetIndexLabel(3,"Resistance 3");
   SetIndexLabel(4,"Resistance 4");
   SetIndexLabel(5,"Support 1");
   SetIndexLabel(6,"Support 2");
   SetIndexLabel(7,"Support 3");
   SetIndexLabel(8,"Support 4");
// Set Empty valus
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
   SetIndexEmptyValue(6,0.0);
   SetIndexEmptyValue(7,0.0);
   SetIndexEmptyValue(8,0.0);

//---- indicator short name
   IndicatorShortName(INAME);
//---- force daily data load
   iBars(NULL,PERIOD_D1);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string name=ObjectName(i);
      if(StringFind(name,INAME)==0) ObjectDelete(name);
     }
   if(ObjectFind(0,"Pvt")==0) ObjectDelete("Pvt");
   if(ObjectFind(0,"R1")==0) ObjectDelete("R1");
   if(ObjectFind(0,"R2")==0) ObjectDelete("R2");
   if(ObjectFind(0,"R3")==0) ObjectDelete("R3");
   if(ObjectFind(0,"R4")==0) ObjectDelete("R4");
   if(ObjectFind(0,"S1")==0) ObjectDelete("S1");
   if(ObjectFind(0,"S2")==0) ObjectDelete("S2");
   if(ObjectFind(0,"S3")==0) ObjectDelete("S3");
   if(ObjectFind(0,"S4")==0) ObjectDelete("S4");
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // size of input time series
                 const int prev_calculated,  // bars handled in previous call
                 const datetime& time[],     // Time
                 const double& open[],       // Open
                 const double& high[],       // High
                 const double& low[],        // Low
                 const double& close[],      // Close
                 const long& tick_volume[],  // Tick Volume
                 const long& volume[],       // Real Volume
                 const int& spread[])        // Spread
  {
//---
   string formula="";
   double DayHigh=0,DayLow=0,DayClose=0,DayOpen=0,Range=0;
   if(Period() >= PERIOD_D1) return(rates_total);
   int indicator_counted=prev_calculated,limit;
   if(indicator_counted<LOOKBACK) indicator_counted=LOOKBACK;
   limit=rates_total-1-indicator_counted;
   for(int i=limit; i>=0; i--)
     {
      int iYesterday=i+1;
      datetime yesterday=iTime(NULL,PERIOD_D1,iYesterday);
      if(TimeDayOfWeek(yesterday)==0) iYesterday++; // Data from Friday not Sunday
      DayHigh=iHigh(NULL,PERIOD_D1,iYesterday);
      DayLow=iLow(NULL,PERIOD_D1,iYesterday);
      DayOpen=iOpen(NULL,PERIOD_D1,iYesterday);
      DayClose=iClose(NULL,PERIOD_D1,iYesterday);
      Range=(DayHigh-DayLow);
      if(PivotMethod==Standard)
        {
         P=(DayHigh+DayLow+DayClose)/3;
         R1=(2*P)-DayLow;
         R2=P+Range;
         R3=R2+Range;
         R4=R3+Range;
         //---
         S1=(2*P)-DayHigh;
         S2=P-Range;
         S3=S2-Range;
         S4=S3-Range;
         //---
         formula="Standard";
        }
      else if(PivotMethod==Fibonacci)
        {
         P=(DayHigh+DayLow+DayClose)/3;
         R1=P+(Range*0.382);
         R2=P+(Range*0.618);
         R3=P+(Range*1.0);
         R4=P+(Range*1.618);
         //---
         S1=P-(Range*0.382);
         S2=P-(Range*0.618);
         S3=P-(Range*1.0);
         S4=P-(Range*1.618);
         //---
         formula="Fibonacci";
        }
      else if(PivotMethod==Camarilla)
        {
         R1=DayClose+(Range*1.1/12);
         R2=DayClose+(Range*1.1/6);
         R3=DayClose+(Range*1.1/4);
         R4=DayClose+(Range*1.1/2);
         //---
         S1=DayClose-(Range*1.1/12);
         S2=DayClose-(Range*1.1/6);
         S3=DayClose-(Range*1.1/4);
         S4=DayClose-(Range*1.1/2);
         //---
         P=(R1+S1)/2;
         //---
         formula="Camarilla";
        }
      else if(PivotMethod==Woodie)
        {
         P=(DayHigh+DayLow+DayClose)/3;
         R1=(2*P)-DayLow;
         R2=P+Range;
         R3=DayHigh+2*(P-DayLow);
         R4=R3+Range;
         //---
         S1=(2*P)-DayHigh;
         S2=P-Range;
         S3=DayLow-2*(DayHigh-P);
         S4=S3-Range;
         //---
         formula="Woodie";
        }
      else if(PivotMethod==DeMark)
        {
         double x=DayHigh+DayLow+(DayClose*2);
         if(DayClose<DayOpen)x=DayHigh+DayClose+(DayLow*2);
         else if(DayClose>DayOpen)x=(DayHigh*2)+DayLow+DayClose;
         P=x/4;
         R1=(x/2)-DayLow;
         R2=0.0;
         R3=0.0;
         R4=0.0;
         //---
         S1=(x/2)-DayHigh;
         S2=0.0;
         S3=0.0;
         S4=0.0;
         //---
         formula="DeMark";
        }
      //--- Buffers
      PBuffer[i] =P;
      R1Buffer[i]=R1;
      R2Buffer[i]=R2;
      R3Buffer[i]=R3;
      R4Buffer[i]=R4;
      S1Buffer[i]=S1;
      S2Buffer[i]=S2;
      S3Buffer[i]=S3;
      S4Buffer[i]=S4;
     }
//--- Draw Line
   DrawLine(INAME+" Pivot","Pvt",pColor,P);
   if(Show_SR)
     {
      DrawLine(INAME+"Resistance 1","R1",rColor,R1);
      DrawLine(INAME+"Resistance 2","R2",rColor,R2);
      DrawLine(INAME+"Resistance 3","R3",rColor,R3);
      DrawLine(INAME+"Resistance 4","R4",rColor,R4);
      DrawLine(INAME+"Support 1","S1",sColor,S1);
      DrawLine(INAME+"Support 2","S2",sColor,S2);
      DrawLine(INAME+"Support 3","S3",sColor,S3);
      DrawLine(INAME+"Support 4","S4",sColor,S4);
     }
//--- Show comment
   ObjectDelete(INAME+"commant");
   ObjectCreate(INAME+"commant",OBJ_LABEL,0,0,0);
   ObjectSetText(INAME+"commant","Pivot Formula = "+formula,8,"Arial",clrDarkGray);
   ObjectSet(INAME+"commant",OBJPROP_CORNER,2);
   ObjectSet(INAME+"commant",OBJPROP_XDISTANCE,10);
   ObjectSet(INAME+"commant",OBJPROP_YDISTANCE,10);

//--- Alert
   Notifications();

//--- return value of prev_calculated for next call
   return(rates_total-1);
  }
//+------------------------------------------------------------------+
//|  Draw lines
//+------------------------------------------------------------------+ 
void DrawLine(string name,string label,color clr,double price)
  {
//--- 
   datetime startline=iTime(NULL,1440,2);
//---
   ObjectDelete(name);
   ObjectCreate(name,OBJ_TREND,0,startline,price,Time[0],price);
   ObjectSet(name,OBJPROP_COLOR,clr);
   ObjectSet(name,OBJPROP_STYLE,Style);
   ObjectSet(name,OBJPROP_WIDTH,Width);
   ObjectSet(name,OBJPROP_RAY,true);
   ObjectDelete(label);
   ObjectCreate(label,OBJ_TEXT,0,Time[0]+(PeriodSeconds()*4),price);
   ObjectSetText(label,label,7,"Verdana",LabelsColor);
//---     
  }
//+------------------------------------------------------------------+
//| Notifications function
//+------------------------------------------------------------------+
void Notifications()
  {
//----
   if(Low[0]<P && High[0]>P)
      doAlert("Pivot Tocuh! - Price has tocuhed the Pivot line @ "+Symbol()+" @ "+PeriodToStr(Period())+" time frame");
   if(Low[0]<R1 && High[0]>R1)
      doAlert("R1 Tocuh! - Price has tocuhed the Resistance 1 line @ "+Symbol()+" @ "+PeriodToStr(Period())+" time frame");
   if(Low[0]<R2 && High[0]>R2)
      doAlert("R2 Tocuh! - Price has tocuhed the Resistance 2 line @ "+Symbol()+" @ "+PeriodToStr(Period())+" time frame");
   if(Low[0]<R3 && High[0]>R3)
      doAlert("R3 Tocuh! - Price has tocuhed the Resistance 3 line @ "+Symbol()+" @ "+PeriodToStr(Period())+" time frame");
   if(Low[0]<R4 && High[0]>R4)
      doAlert("R4 Tocuh! - Price has tocuhed the Resistance 4 line @ "+Symbol()+" @ "+PeriodToStr(Period())+" time frame");
//---
   if(Low[0]<S1 && High[0]>S1)
      doAlert("S1 Tocuh! - Price has tocuhed the Support 1 line @ "+Symbol()+" @ "+PeriodToStr(Period())+" time frame");
   if(Low[0]<S2 && High[0]>S2)
      doAlert("S2 Tocuh! - Price has tocuhed the Support 2 line @ "+Symbol()+" @ "+PeriodToStr(Period())+" time frame");
   if(Low[0]<S3 && High[0]>S3)
      doAlert("S3 Tocuh! - Price has tocuhed the Support 3 line @ "+Symbol()+" @ "+PeriodToStr(Period())+" time frame");
   if(Low[0]<S4 && High[0]>S4)
      doAlert("S4 Tocuh! - Price has tocuhed the Support 4 line @ "+Symbol()+" @ "+PeriodToStr(Period())+" time frame");
//----
  }
//+------------------------------------------------------------------+
//| Alert function
//+------------------------------------------------------------------+
void doAlert(string message)
  {
//----
   static datetime time=0;
   if(Time[0]!=time)
     {
      if(UseAlert) Alert(message);
      if(UseEmail) SendMail("iPivot Notification!",message);
      if(UseNotification) SendNotification(message);
      if(UseSound) PlaySound(SoundName);
      time=Time[0];
     }
//----
  }
//+------------------------------------------------------------------+
//| Period To String - Credit to the author
//+------------------------------------------------------------------+
string PeriodToStr(int period)
  {
//---
   if(period == NULL) return(PeriodToStr(Period()));
   int p[9]={1,5,15,30,60,240,1440,10080,43200};
   string sp[9]={"M1","M5","M15","M30","H1","H4","D1","W1","MN1"};
   for(int i= 0; i < 9; i++) if(p[i] == period) return(sp[i]);
   return("--");
//---
  }
//+------------------------------------------------------------------+
