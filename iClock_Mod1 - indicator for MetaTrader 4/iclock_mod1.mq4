//+------------------------------------------------------------------------+
//|                         Copyright 2015, MetaQuotes Software Corp.      |
//|                                             https://www.mql5.com       |
//| Indicator: iClock_Mod1                                                |                                                                  |
//| Author: mladen - https://www.forex-tsd.com                             |
//| Modifier: File45 - https://www.mql5.com/en/users/file45/publications   |
//| * 2015/4/09: Convert from mql5 to mql4                                 |
//| * 2015/4/09: Add alerts and label colored alert states.                |
//+------------------------------------------------------------------------+
#property copyright "mladen"
#property link      "www.forex-tsd.com"
#property version   "1.00"
#property description "Continuous-no-log candle timer with new candle alert options." 
#property description "Not dependent on incoming ticks."
#property description "Pop up and Sound only alert options."
#property description "Timer label colored according to Alert Mode: Off, On, Sound only."
#property description "Automatic Broker GMT and Daylight Saving Time adjustment."
//---
#property indicator_chart_window
//#property indicator_buffers 1
//#property indicator_plots   1

//#define clockName "CandleTimer"
//#property strict
enum AlertMode_z
  {
   NoAlert_z=0,// Off
   PopUpAlert_z = 1,// On
   SoundAlert_z = 2 // Sound only 
  };
input AlertMode_z AlertMode=0;                      // Select Alert Mode 
//input color ValuesPositiveColor = MediumSeaGreen; // Color for positive timer values
input color AlertOff            = LimeGreen;
input color AlertOn             = Magenta;
input color SoundOnly           = DodgerBlue;
input color NoBarColor=Red;                        // Color for negative timer values
input int   FontSize= 13;                          // Font Size 
input bool  FontBold            = true;            // Font Bold
input int   FontShift           = 8;               // Font Shift
//int  atrHandle;
datetime LastAlertTime;
string TMz;
string theFont;
string clockName="CandleTimer";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  OnInit()
  {
   switch(FontBold)
     {
      case 0: theFont = "Arial"; break;
      case 1: theFont = "Arial Bold"; break;
     }
   switch(Period())
     {
      case 1:     TMz = "M1";  break;
      case 2:     TMz = "M2";  break;
      case 3:     TMz = "M3";  break;
      case 4:     TMz = "M4";  break;
      case 5:     TMz = "M5";  break;
      case 6:     TMz = "M6";  break;
      case 7:     TMz = "M7";  break;
      case 8:     TMz = "M8";  break;
      case 9:     TMz = "M9";  break;
      case 10:    TMz = "M10"; break;
      case 11:    TMz = "M11"; break;
      case 12:    TMz = "M12"; break;
      case 13:    TMz = "M13"; break;
      case 14:    TMz = "M14"; break;
      case 15:    TMz = "M15"; break;
      case 20:    TMz = "M20"; break;
      case 25:    TMz = "M25"; break;
      case 30:    TMz = "M30"; break;
      case 40:    TMz = "M40"; break;
      case 45:    TMz = "M45"; break;
      case 50:    TMz = "M50"; break;
      case 60:    TMz = "H1";  break;
      case 120:   TMz = "H2";  break;
      case 180:   TMz = "H3";  break;
      case 240:   TMz = "H4";  break;
      case 300:   TMz = "H5";  break;
      case 360:   TMz = "H6";  break;
      case 420:   TMz = "H7";  break;
      case 480:   TMz = "H8";  break;
      case 540:   TMz = "H9";  break;
      case 600:   TMz = "H10"; break;
      case 660:   TMz = "H11"; break;
      case 720:   TMz = "H12"; break;
      case 1440:  TMz = "D1";  break;
      case 10080: TMz = "W1";  break;
      case 43200: TMz = "M1";  break;
     }
   LastAlertTime=TimeCurrent();
// atrHandle = (iATR(NULL,0,30,0)); 
   EventSetTimer(1);
//---
   return(0);
  }
void OnDeinit(const int reason) { EventKillTimer(); ObjectDelete(clockName);}
void OnTimer( )                 { refreshClock();  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  OnCalculate(const int rates_total,
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
   if((AlertMode==1) && (LastAlertTime<Time[0]))
     {
      Alert("New Bar  -  ",Symbol(),"  -  "+TMz+"  -  "+AccountCompany());
      LastAlertTime=Time[0];
     }
   else if((AlertMode==2) && (LastAlertTime<Time[0]))
     {
      PlaySound("Alert.wav");
      LastAlertTime=Time[0];
     }
   refreshClock();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void refreshClock()
  {
   static bool inRefresh=false;
   if(inRefresh) return;
   inRefresh=true;
   ShowClock(); ChartRedraw();
   inRefresh=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowClock()
  {
   int periodMinutes = periodToMinutes(Period());
   int shift         = periodMinutes*FontShift*60;
   int currentTime   = (int)TimeCurrent();
   int localTime     = (int)TimeLocal();
   int barTime       = (int)iTime();
   int diff          = (int)MathMax(round((currentTime-localTime)/3600.0)*3600,-24*3600);
//---
   color  theColor;
   string time=getTime(barTime+periodMinutes*60-localTime-diff,theColor);
   time=(TerminalInfoInteger(TERMINAL_CONNECTED)) ? time : time+" x";
//---
   if(ObjectFind(0,clockName)<0)
      ObjectCreate(0,clockName,OBJ_TEXT,0,barTime+shift,0);
   ObjectSetString(0,clockName,OBJPROP_TEXT,time);
   ObjectSetString(0,clockName,OBJPROP_FONT,theFont);
   ObjectSetInteger(0,clockName,OBJPROP_FONTSIZE,FontSize);
   ObjectSetInteger(0,clockName,OBJPROP_COLOR,theColor);
   if(ChartGetInteger(0,CHART_SHIFT,0)==0 && (shift>=0))
      ObjectSetInteger(0,clockName,OBJPROP_TIME,barTime-shift*3);
   else  ObjectSetInteger(0,clockName,OBJPROP_TIME,barTime+shift);
//---
   double price[]; if(CopyClose(Symbol(),0,0,1,price)<=0) return;
   double atr[];
//if (CopyBuffer(atrHandle,0,0,1,atr)<=0) return;
   price[0]+=3.0*atr[0]/4.0;
//---
   bool visible=((ChartGetInteger(0,CHART_VISIBLE_BARS,0)-ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0))>0);
   if(visible && price[0]>=ChartGetDouble(0,CHART_PRICE_MAX,0))
      ObjectSetDouble(0,clockName,OBJPROP_PRICE,price[0]-1.5*atr[0]);
   else  ObjectSetDouble(0,clockName,OBJPROP_PRICE,price[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTime(int times,color &theColor)
  {
   string stime="";
   int    seconds;
   int    minutes;
   int    hours;
// if (times < 0) {theColor = ValuesNegativeColor; times = (int)fabs(times);}
// else  theColor = ValuesPositiveColor;
   if(times<0)
     {
      theColor=NoBarColor; times=(int)fabs(times);
     }
   else if(times>0)
     {
      switch(AlertMode)
        {
         case 0: theColor = AlertOff; break;
         case 1: theColor = AlertOn; break;
         case 2: theColor = SoundOnly;
        }
     }
   seconds = (times%60);
   hours   = (times-times%3600)/3600;
   minutes = (times-seconds)/60-hours*60;
//---
   if(hours>0)
      if(minutes<10)
         stime = stime+(string)hours+":0";
   else  stime = stime+(string)hours+":";
   stime=stime+(string)minutes;
   if(seconds<10)
      stime=stime+":0"+(string)seconds;
   else  stime=stime+":"+(string)seconds;
   return(stime);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime iTime(ENUM_TIMEFRAMES forPeriod=PERIOD_CURRENT)
  {
   datetime times[]; if(CopyTime(Symbol(),forPeriod,0,1,times)<=0) return(TimeLocal());
   return(times[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int periodToMinutes(int period)
  {
   int i;
   static int _per[]={1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200,0x4001,0x4002,0x4003,0x4004,0x4006,0x4008,0x400c,0x4018,0x8001,0xc001};
   static int _min[]={1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200};
//---
   if(period==PERIOD_CURRENT)
      period=Period();
   for(i=0;i<20;i++) if(period==_per[i]) break;
   return(_min[i]);
  }
//+------------------------------------------------------------------+
