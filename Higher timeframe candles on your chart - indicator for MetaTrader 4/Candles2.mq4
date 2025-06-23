//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Julien Loutre"
#property link      "http://www.thetradingtheory.com"

#import "drawing.ex4"
void draw_bar(string uid,string i,int x,double y,int x2,double y2,color c);
void draw_line(string uid,string i,int x,double y,int x2,double y2,color c);
void draw_array_as_line(string uid,double &a[],color c);
void draw_erase(string uid);
void draw_erase_all();
int rgb2int(int r,int g,int b);
int colorGradient(int r,int g,int b,int r2,int g2,int b2,double min,double max,double pos);
double map(double x,double in_min,double in_max,double out_min,double out_max);
void draw_vline(string uid,string i,int x,double y,color c);
#import

#property  indicator_chart_window

extern string timeframe    = "D1";
extern color  BullColor    = SteelBlue;
extern color  BearColor    = White;
extern int    CandleNumber = 10;

double      extBuffer[],chart[];

double open,close,open1,close1,high,low;
int p;
int currentCandle=0;

string uid="candles";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("Candles["+timeframe+"]");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i;
   int c=0;
   int openTime,closeTime,openPos,currentPos;
   double openValue,closeValue;
   bool flag;
   int HLpos;
   int HLwidth;
   p=15;
   if(timeframe=="D1")
     {
      p=1440;
        } else if(timeframe=="H4") {
      p=240;
        } else if(timeframe=="H1") {
      p=60;
        } else if(timeframe=="M30") {
      p=30;
        } else if(timeframe=="M15") {
      p=15;
     }
   int tbars=p/Period()*CandleNumber+p/Period();

   if(Bars<tbars) return(-1);

   int barPerCandle=p/Period();
   double h,l;
   for(i=tbars;i>=0;i--)
     {
      if(timeframe=="D1")
        {
         flag=TimeHour(iTime(NULL,0,i))==0 && TimeMinute(iTime(NULL,0,i))==0;
           } else if(timeframe=="H4") {
         flag=TimeMinute(iTime(NULL,0,i))==0 && (TimeHour(iTime(NULL,0,i))==0 || TimeHour(iTime(NULL,0,i))==4 || TimeHour(iTime(NULL,0,i))==8 || TimeHour(iTime(NULL,0,i))==12 || TimeHour(iTime(NULL,0,i))==16 || TimeHour(iTime(NULL,0,i))==20);
           } else if(timeframe=="H1") {
         flag=TimeMinute(iTime(NULL,0,i))==0;
           } else if(timeframe=="M30") {
         flag=TimeMinute(iTime(NULL,0,i))==30;
           } else if(timeframe=="M15") {
         flag=TimeMinute(iTime(NULL,0,i))==0 || TimeMinute(iTime(NULL,0,i))==15 || TimeMinute(iTime(NULL,0,i))==30 || TimeMinute(iTime(NULL,0,i))==45;
        }
      tbars=p/Period()*CandleNumber+p/Period();
      barPerCandle=p/Period();
      if(flag)
        {
         c++;
         openTime=Time[i];
         openValue=Open[i];
         openPos=i;
         draw_bar(uid,c,openTime,openValue,openTime,openValue,BullColor);
         h = 0;
         l = 100000;
        }
      if(c>0)
        {
         if(Low[i]<l) {l=Low[i];}
         if(High[i]>h) {h=High[i];}
         currentPos=i;
         HLwidth=(openPos-currentPos)/8;
         closeTime=Time[i];
         closeValue=Close[i];
         HLpos=openPos-((openPos-currentPos)/2)-(HLwidth/2);
         if(openValue>closeValue)
           {
            // Down
            draw_bar(uid,c,openTime,openValue,closeTime,closeValue,BearColor);
            if(HLwidth>2)
              {
               draw_bar(uid+"_h",c,Time[HLpos],h,Time[HLpos+HLwidth],openValue,BearColor);
               draw_bar(uid+"_l",c,Time[HLpos],closeValue,Time[HLpos+HLwidth],l,BearColor);
              }
              } else {
            // Up
            draw_bar(uid,c,openTime,openValue,closeTime,closeValue,BullColor);
            if(HLwidth>1)
              {
               draw_bar(uid+"_h",c,Time[HLpos],h,Time[HLpos+HLwidth],closeValue,BullColor);
               draw_bar(uid+"_l",c,Time[HLpos],openValue,Time[HLpos+HLwidth],l,BullColor);
              }
           }
        }

     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   draw_erase_all();
   return(0);
  }
//+------------------------------------------------------------------+
