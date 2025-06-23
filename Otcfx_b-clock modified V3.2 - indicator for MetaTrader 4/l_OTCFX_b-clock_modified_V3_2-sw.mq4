//+------------------------------------------------------------------+
//|                                           #OTCFX  b-clock_SW.mq4 |
//|                                     Core time code by Nick Bilak |
//|                                    http://metatrader.50webs.com/ |
//|                                              beluck[at]gmail.com |
//|                                  modified by adoleh2000 and dwt5 |
//|                                 Modified and improved by "OTCFX" |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Nick Bilak"
#property link      "http://metatrader.50webs.com/"
//----
#property indicator_separate_window
//----
extern color  BClockClr= clrAqua;
extern color  ClksColor= clrLime;
extern color  TDCOL=clrAqua;
extern bool   show_Bclk=true;
extern string myFont        ="Arial Bold";
extern string myFont2       ="Verdana Bold";
//extern int    myCFontSize     = 20 ;
//extern int    myCLKSize     = 16 ;
extern bool show_M1=true;
extern bool show_M5=true;
extern bool show_M15=true;
extern bool show_M30=true;
extern bool show_M60=true;
extern bool show_M240=true;
extern bool show_M1440=true;
int   TimeFrame=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("CLKV3");
//{
   switch(TimeFrame)
     {
      case 1  : string TimeFrameStr="M1";  break;
      case 5  :     TimeFrameStr=   "M5";  break;
      case 15 :     TimeFrameStr=   "M15";   break;
      case 30 :     TimeFrameStr=   "M30";   break;
      case 60 :     TimeFrameStr=   "H1";  break;
      case 240  :   TimeFrameStr=   "H4";  break;
      case 1440 :   TimeFrameStr=   "D1";  break;
      case 10080 :  TimeFrameStr=   "W1";  break;
      case 43200 :  TimeFrameStr=   "MN1";   break;
      default  :    TimeFrameStr=   "CurrTF";
     }
//if (TimeFrame<Period()) TimeFrame=Period();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("time");
   ObjectDelete("timey");
   ObjectDelete("time1");
   ObjectDelete("time2");
   ObjectDelete("time3");
   ObjectDelete("time4");
   ObjectDelete("time5");
   ObjectDelete("time6");
   ObjectDelete("time7");
   ObjectDelete("time8");
   ObjectDelete("T1");
   ObjectDelete("T2");
   ObjectDelete("T3");
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double i,i1,i2,i3,i4,i5,i6,i7;
   long m,s,
   m0,m1,m2,m3,m4,m5,m6,m7,
   s0,s1,s2,s3,s4,s5,s6,s7,
   h,h1,h2,h3,h4,h5,h6,h7;
   if(TimeFrame==0)TimeFrame=Period();
   m=iTime(NULL,TimeFrame,0)+TimeFrame*60-TimeCurrent();
//  m=Time[0]+Period()*60-CurTime();
   m1=iTime(NULL,1440,0)+1440*60-CurTime();
   m2=iTime(NULL,240,0)+240*60-CurTime();
   m3=iTime(NULL,60,0)+60*60-CurTime();
   m4=iTime(NULL,30,0)+30*60-CurTime();
   m5=iTime(NULL,15,0)+15*60-CurTime();
   m6=iTime(NULL,5,0)+5*60-CurTime();
   m7=iTime(NULL,1,0)+1*60-CurTime();
//----
   i=m/60.0;
   i1=m1/60.0;
   i2=m2/60.0;
   i3=m3/60.0;
   i4=m4/60.0;
   i5=m5/60.0;
   i6=m6/60.0;
   i7=m7/60.0;
//----
   s=m%60;
   s0=m%60;
   s1=m1%60;
   s2=m2%60;
   s3=m3%60;
   s4=m4%60;
   s5=m5%60;
   s6=m6%60;
   s7=m7%60;
//----
   m=(m-m%60)/60;
   m0=(m-m%60)/60;
   m1=(m1-m1%60)/60;
   m2=(m2-m2%60)/60;
   m3=(m3-m3%60)/60;
   m4=(m4-m4%60)/60;
   m5=(m5-m5%60)/60;
   m6=(m6-m6%60)/60;
   m7=(m7-m7%60)/60;
//----
   h=m/60;
   h1=m1/60;
   h2=m2/60;
   h3=m3/60;
   h4=m4/60;
   h5=m5/60;
   h6=m6/60;
   h7=m7/60;
//----
   string Bclk="                   <"+(string)m+":"+(string)s;
   string M1=  "|M1|  "+(string)m7+"m :"+(string)s7;
   string M5=  "|M5|  "+(string)m6+"m :"+(string)s6;
   string M15= "|M15| "+(string)m5+"m :"+(string)s5;
   string M30= "|M30| "+(string)m4+"m :"+(string)s4;
   string M60= "|M60| "+(string)m3+"m :"+(string)s3;
   string M240="|H4| "+(string)m2+"m :"+(string)s2;
   string M1440="|D1| "+(string)m1+"m :"+(string)s1;
//----
   if(show_Bclk)
     {
      Comment((string)m+" minutes "+(string)s+" seconds left to bar end");
     }
   ObjectDelete("time");
   if(ObjectFind("time")!=0)
     {
      if(show_Bclk)
        {
         ObjectCreate("time",OBJ_TEXT,0,Time[0],Close[0]+0.0000);
        }
      if(show_Bclk)
        {
         ObjectSetText("time",StringSubstr((Bclk),0),10,"Verdana Bold",BClockClr);
        }
      //ObjectDelete("time");
     }
   else
     {
      ObjectMove("time",0,Time[0],Close[0]+0.0005);
      //ObjectDelete("time");
     }
     {
      string P=(string)Period();
      // string M15= "M15   "+m5+"m : "+s5;
      // ObjectCreate("time1", OBJ_LABEL, 0, 0, 0);
      // ObjectSetText("time1","   "+m+"m : "+s , myCFontSize, myFont ,TDCOL);
      // ObjectSet("time1", OBJPROP_CORNER,3);
      // ObjectMove("time1", 0, Time[0], Close[0]+0.0005);
      // ObjectSet("time1", OBJPROP_XDISTANCE, 10);
      // ObjectSet("time1", OBJPROP_YDISTANCE,10 );
      //----
      // ObjectCreate("T1", OBJ_LABEL,WindowFind("CLKV3"), 0, 0);
      // ObjectSetText("T1",StringSubstr((P),0),myCFontSize, "Verdana", TDCOL);
      // ObjectSet("T1", OBJPROP_CORNER, 3);
      // ObjectSet("T1", OBJPROP_XDISTANCE, 70);
      // ObjectSet("T1", OBJPROP_YDISTANCE, 65);  
      ObjectCreate("T2",OBJ_LABEL,WindowFind("CLKV3"),0,0);
      ObjectSetText("T2",TimeToStr(CurTime(),TIME_SECONDS),11,"Verdana Bold",TDCOL);
      ObjectSet("T2",OBJPROP_CORNER,0);
      ObjectSet("T2",OBJPROP_XDISTANCE,250);
      ObjectSet("T2",OBJPROP_YDISTANCE,5);
      ObjectCreate("T3",OBJ_LABEL,WindowFind("CLKV3"),0,0);
      ObjectSetText("T3",TimeToStr(CurTime(),TIME_DATE),10,"Verdana",TDCOL);
      ObjectSet("T3",OBJPROP_CORNER,0);
      ObjectSet("T3",OBJPROP_XDISTANCE,155);
      ObjectSet("T3",OBJPROP_YDISTANCE,5);
      if(show_M1)
        {
         ObjectCreate("time2",OBJ_LABEL,WindowFind("CLKV3"),0,0);
         ObjectSetText("time2",StringSubstr((M1),0),16,myFont,ClksColor);
         ObjectSet("time2",OBJPROP_CORNER,0);
         ObjectSet("time2",OBJPROP_XDISTANCE,10);
         ObjectSet("time2",OBJPROP_YDISTANCE,24);
        }
      if(show_M5)
        {
         ObjectCreate("time3",OBJ_LABEL,WindowFind("CLKV3"),0,0);
         ObjectSetText("time3",StringSubstr((M5),0),16,myFont,ClksColor);
         ObjectSet("time3",OBJPROP_CORNER,0);
         ObjectSet("time3",OBJPROP_XDISTANCE,150);
         ObjectSet("time3",OBJPROP_YDISTANCE,24);
        }
      if(show_M15)
        {
         ObjectCreate("time4",OBJ_LABEL,WindowFind("CLKV3"),0,0);
         ObjectSetText("time4",StringSubstr((M15),0),16,myFont,ClksColor);
         ObjectSet("time4",OBJPROP_CORNER,0);
         ObjectSet("time4",OBJPROP_XDISTANCE,280);
         ObjectSet("time4",OBJPROP_YDISTANCE,24);
        }
      if(show_M30)
        {
         ObjectCreate("time5",OBJ_LABEL,WindowFind("CLKV3"),0,0);
         ObjectSetText("time5",StringSubstr((M30),0),16,myFont,ClksColor);
         ObjectSet("time5",OBJPROP_CORNER,0);
         ObjectSet("time5",OBJPROP_XDISTANCE,430);
         ObjectSet("time5",OBJPROP_YDISTANCE,24);
        }
      if(show_M60)
        {
         ObjectCreate("time6",OBJ_LABEL,WindowFind("CLKV3"),0,0);
         ObjectSetText("time6",StringSubstr((M60),0),16,myFont,ClksColor);
         ObjectSet("time6",OBJPROP_CORNER,0);
         ObjectSet("time6",OBJPROP_XDISTANCE,580);
         ObjectSet("time6",OBJPROP_YDISTANCE,24);
        }
      if(show_M240)
        {
         ObjectCreate("time7",OBJ_LABEL,WindowFind("CLKV3"),0,0);
         ObjectSetText("time7",StringSubstr((M240),0),16,myFont,ClksColor);
         ObjectSet("time7",OBJPROP_CORNER,0);
         ObjectSet("time7",OBJPROP_XDISTANCE,740);
         ObjectSet("time7",OBJPROP_YDISTANCE,24);
        }
      if(show_M1440)
        {
         ObjectCreate("time8",OBJ_LABEL,WindowFind("CLKV3"),0,0);
         ObjectSetText("time8",StringSubstr((M1440),0),16,myFont,ClksColor);
         ObjectSet("time8",OBJPROP_CORNER,0);
         ObjectSet("time8",OBJPROP_XDISTANCE,876);
         ObjectSet("time8",OBJPROP_YDISTANCE,24);
        }
      ObjectCreate("time9",OBJ_LABEL,WindowFind("CLKV3"),0,0);
      ObjectSetText("time9","B-ClockV3",13,"Verdana Bold",Orchid);
      ObjectSet("time9",OBJPROP_CORNER,0);
      ObjectSet("time9",OBJPROP_XDISTANCE,40);
      ObjectSet("time9",OBJPROP_YDISTANCE,1);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
