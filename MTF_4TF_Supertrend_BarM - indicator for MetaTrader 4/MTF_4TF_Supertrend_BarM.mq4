//+-----------------------------------------------------------------------------------------+
//|                                                             MTF_4TF_Supertrend_BarM.mq4 |
//|                               Modified  from: FF Add-on to be used with 4TF HAS Bar.mq4 |
//|                                         Modified by Matsu, from #MTF Supertrend Bar.mq4 |
//|               M:Up/Dn TF[0/TF+4](inc.order top to bottom)ik Copyright © 2006, Eli hayun |
//|                                                                 http://www.elihayun.com |
//+-----------------------------------------------------------------------------------------+
#property copyright "Copyright © 2006, Eli hayun"
#property link      "http://www.elihayun.com"
//----
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 5
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_color5 Red
#property indicator_color6 Lime
#property indicator_color7 Red
#property indicator_color8 Lime
//---- parameters
//extern int MaMetod  = 2;
//extern int MaPeriod = 6;
//extern int MaMetod2  = 3;
//extern int MaPeriod2 = 2;
extern int BarWidth=0;//3;
extern color UpBarColor=Blue;
extern color DownBarColor=Red;
extern color TextColor=White;
//----
double Gap=1; // Gap between the lines of bars
//---- buffers
double buf4_up[];
double buf4_down[];
double buf3_up[];
double buf3_down[];
double buf2_up[];
double buf2_down[];
double buf1_up[];
double buf1_down[];
double haOpen;
double haClose;
/*
extern int Period_1 = 15;
extern int Period_2 = 30;
extern int Period_3 = 60;
extern int Period_4 = 240;
extern bool AutoDisplay      = false;
*/
string shortname="";
bool firstTime=true;
//----
int ArrSize=110;//112;//168;//158;//159;
int UniqueNum=228;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //SetAutoDisplay();
   firstTime=true;
   //IndicatorShortName(shortname);
//---- indicators
   SetIndexStyle(0,DRAW_ARROW,0,BarWidth,UpBarColor);
   SetIndexArrow(0,ArrSize);
   SetIndexBuffer(0,buf1_up);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW,0,BarWidth,DownBarColor);
   SetIndexArrow(1,ArrSize);
   SetIndexBuffer(1,buf1_down);
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(2,DRAW_ARROW,0,BarWidth,UpBarColor);
   SetIndexArrow(2,ArrSize);
   SetIndexBuffer(2,buf2_up);
   SetIndexEmptyValue(2,0.0);
   SetIndexStyle(3,DRAW_ARROW,0,BarWidth,DownBarColor);
   SetIndexArrow(3,ArrSize);
   SetIndexBuffer(3,buf2_down);
   SetIndexEmptyValue(3,0.0);
   SetIndexStyle(4,DRAW_ARROW,0,BarWidth,UpBarColor);
   SetIndexArrow(4,ArrSize);
   SetIndexBuffer(4,buf3_up);
   SetIndexEmptyValue(4,0.0);
   SetIndexStyle(5,DRAW_ARROW,0,BarWidth,DownBarColor);
   SetIndexArrow(5,ArrSize);
   SetIndexBuffer(5,buf3_down);
   SetIndexEmptyValue(5,0.0);
   SetIndexStyle(6,DRAW_ARROW,0,BarWidth,UpBarColor);
   SetIndexArrow(6,ArrSize);
   SetIndexBuffer(6,buf4_up);
   SetIndexEmptyValue(6,0.0);
   SetIndexStyle(7,DRAW_ARROW,0,BarWidth,DownBarColor);
   SetIndexArrow(7,ArrSize);
   SetIndexBuffer(7,buf4_down);
   SetIndexEmptyValue(7,0.0);
   //
   IndicatorDigits(0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   //SetAutoDisplay();
   //   shortname = "# Forex Freedom("+Period_1+","+Period_2+","+Period_3+","+Period_4+")";
   firstTime=true;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int i=0, y15m=0, y4h=0, y1h=0, y30m=0, yy;
   int limit=Bars-counted_bars;
   int Period_1, Period_2, Period_3, Period_4;
   switch(Period())
     {
      case 1:
         Period_1=1; Period_2=5; Period_3=15; Period_4=30;
         break;
      case 5:
         Period_1=5; Period_2=15; Period_3=30; Period_4=60;
         break;
      case 15:
         Period_1=15; Period_2=30; Period_3=60; Period_4=240;
         break;
      case 30:
         Period_1=30; Period_2=60; Period_3=240; Period_4=1440;
         break;
      case 60:
         Period_1=60; Period_2=240; Period_3=1440; Period_4=10080;
         break;
      case 240:
         Period_1=240; Period_2=1440; Period_3=10080; Period_4=43200;
         break;
      case 1440:
         Period_1=1440; Period_2=10080; Period_3=43200; Period_4=43200;
         break;
      case 10080:
         Period_1=10080; Period_2=43200; Period_3=43200; Period_4=43200;
         break;
      case 43200:
         Period_1=43200; Period_2=43200; Period_3=43200; Period_4=43200;
         break;
     }
   shortname="MTF_4TF_Supertrend_BarM("+Period_1+","+Period_2+","+Period_3+","+Period_4+")";
   IndicatorShortName(shortname);
//----
   SetIndexLabel(0,"MTF_ST,"+Period_4+"");
   SetIndexLabel(1,"MTF_SV,"+Period_4+"");
   SetIndexLabel(2,"MTF_ST,"+Period_3+"");
   SetIndexLabel(3,"MTF_ST,"+Period_3+"");
   SetIndexLabel(4,"MTF_ST,"+Period_2+"");
   SetIndexLabel(5,"MTF_ST,"+Period_2+"");
   SetIndexLabel(6,"MTF_ST,"+Period_1+"");
   SetIndexLabel(7,"MTF_ST,"+Period_1+"");
   datetime TimeArray_4H[], TimeArray_1H[], TimeArray_30M[], TimeArray_15M[];
//----
   if (firstTime || NewBar())
     {
      firstTime=false;
      int win=UniqueNum; // WindowFind(shortname);
      double dif=Time[0] - Time[1];
      for(int ii=ObjectsTotal()-1; ii>-1; ii--)
        {
         if (StringFind(ObjectName(ii),"FF_"+win+"_")>=0)
            ObjectDelete(ObjectName(ii));
         else
            ii=-1;
        }
      double shift=0.2;
      for(ii=0; ii<4; ii++)
        {
         string txt="??";
         double gp;
         switch(ii)
           {
            case 0: txt=tf2txt(Period_4);  gp=1 + shift;
               break;
            case 1: txt=tf2txt(Period_3);  gp=1 + Gap + shift;
               break;
            case 2: txt=tf2txt(Period_2);  gp=1 + Gap*2 + shift;
               break;
            case 3: txt=tf2txt(Period_1);  gp=1 + Gap*3 + shift;
               break;
           }
         string name="ST_"+win+"_"+ii+"_"+txt;
         ObjectCreate(name, OBJ_TEXT, WindowFind(shortname),
iTime(NULL,0,0)+dif*3, gp);
         ObjectSetText(name, txt,6,"Arial", TextColor);
        }
     }
   ArrayCopySeries(TimeArray_4H,MODE_TIME,Symbol(),Period_4);
   ArrayCopySeries(TimeArray_1H,MODE_TIME,Symbol(),Period_3);
   ArrayCopySeries(TimeArray_30M,MODE_TIME,Symbol(),Period_2);
   ArrayCopySeries(TimeArray_15M,MODE_TIME,Symbol(),Period_1);
//----
   for(i=0, y15m=0,  y4h=0,  y1h=0,  y30m=0;i<limit;i++)
     {
      if (Time[i]<TimeArray_15M[y15m]) y15m++;
      if (Time[i]<TimeArray_4H[y4h])   y4h++;
      if (Time[i]<TimeArray_1H[y1h])   y1h++;
      if (Time[i]<TimeArray_30M[y30m]) y30m++;
      for(int tf=0; tf < 4; tf++)
        {
         int prd;
         switch(tf)
           {
            case 0: prd=Period_1; yy=y15m;  break;
            case 1: prd=Period_2; yy=y30m;  break;
            case 2: prd=Period_3;  yy=y1h;   break;
            case 3: prd=Period_4;  yy=y4h;   break;
           }
         haOpen=iCustom(NULL,prd,"Supertrend",1,yy) ;
         haClose=iCustom(NULL,prd,"Supertrend",0,yy) ;
//----
         double dUp=EMPTY_VALUE; //   iCustom(NULL, prd, "SuperTrend", false, 1, yy);
         double dDn=EMPTY_VALUE; //iCustom(NULL, prd, "SuperTrend", false, 0, yy);
         if (haOpen<haClose) dDn=1; else dUp=1;
         switch(tf)
           {
            case 3: if (dUp==EMPTY_VALUE)  buf1_down[i]=1;
               else buf1_up[i]=1; break;
            case 2: if (dUp==EMPTY_VALUE)  buf2_down[i]=1 + Gap *
                  1; else buf2_up[i]=1 + Gap * 1; break;
            case 1: if (dUp==EMPTY_VALUE)  buf3_down[i] =1 + Gap *
                  2; else buf3_up[i] =1 + Gap * 2; break;
            case 0: if (dUp==EMPTY_VALUE)  buf4_down[i] =1  + Gap *
                  3; else buf4_up[i] =1 + Gap * 3; break;
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
string tf2txt(int tf)
  {
   if (tf==PERIOD_M1)    return("M1");
   if (tf==PERIOD_M5)    return("M5");
   if (tf==PERIOD_M15)    return("M15");
   if (tf==PERIOD_M30)    return("M30");
   if (tf==PERIOD_H1)    return("H1");
   if (tf==PERIOD_H4)    return("H4");
   if (tf==PERIOD_D1)    return("D1");
   if (tf==PERIOD_W1)    return("W1");
   if (tf==PERIOD_MN1)    return("MN1");
//----
   return("??");
  }
/*void SetValues(int p1, int p2, int p3, int p4)
{
   Period_1 = p1;   Period_2 = p2; Period_3 = p3; Period_4 = p4; 
}
void SetAutoDisplay()
{
   if (AutoDisplay)
   {
      switch (Period())
      {
         case PERIOD_M1  :  SetValues(PERIOD_M1,  PERIOD_M5, 
PERIOD_M15,PERIOD_M30); break;
         case PERIOD_M5  :  SetValues(PERIOD_M5,  PERIOD_M15,PERIOD_M30,PERIOD_H1); break;
         case PERIOD_M15 :  SetValues(PERIOD_M5,  PERIOD_M15,PERIOD_M30,PERIOD_H1); break;
         case PERIOD_M30 :  SetValues(PERIOD_M5,  PERIOD_M15,PERIOD_M30,PERIOD_H1); break;
         case PERIOD_H1  :  SetValues(PERIOD_M15, PERIOD_M30,PERIOD_H1, PERIOD_H4); break;
         case PERIOD_H4  :  SetValues(PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1); break;
         case PERIOD_D1  :  SetValues(PERIOD_H1,  PERIOD_H4, PERIOD_D1, PERIOD_W1); break;
         case PERIOD_W1  :  SetValues(PERIOD_H4,  PERIOD_D1, PERIOD_W1,PERIOD_MN1); break;
         case PERIOD_MN1 :  SetValues(PERIOD_H4,  PERIOD_D1, PERIOD_W1,PERIOD_MN1); break;
      }
   }
}
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {
   static datetime dt=0;
   if (Time[0]!=dt)
     {
      dt=Time[0];
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+