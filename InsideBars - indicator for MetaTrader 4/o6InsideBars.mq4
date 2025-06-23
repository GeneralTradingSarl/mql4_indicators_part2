//+------------------------------------------------------------------+
//|                                                 !!InsideBars.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright @2011, Rockyhoangdn"
#property link      "rockyhoangdn@gmail.com"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1  Blue
#property indicator_color2  Red
#property indicator_color3  Aqua
#property indicator_color4  DeepPink

#property indicator_width1 0
#property indicator_width2 0
#property indicator_width3 0
#property indicator_width4 0

//---- input parameters
extern int GrossPeriod=1440; 
extern int Barss=0; 
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
datetime daytimes[]; 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,"upline");
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,"downline");
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);
   SetIndexLabel(2,"upstopline");
   
   SetIndexStyle(3,DRAW_NONE);
   SetIndexArrow(3,159);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
   SetIndexLabel(3,"downstopline");
   
   
   
   IndicatorShortName("!!FXDNPrimerv1-"+GrossPeriod);
//----
//---- 
   if (Period()>GrossPeriod) {GrossPeriod=Period();} 

   ArrayCopySeries(daytimes,MODE_TIME,Symbol(),GrossPeriod); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int    limit,bigshift;
   double value1,value2,value3,value4;
   if (counted_bars<0) return(-1); 
    
   if (counted_bars>0) counted_bars--; 
   if (Barss>0) limit=Barss-counted_bars; else limit=Bars-counted_bars;
//---- 
   for (int i=0; i<limit; i++) 
   { 
   if(Time[i]>=daytimes[0]) bigshift=0; 
   else 
     { 
      bigshift = ArrayBsearch(daytimes,Time[i-1],WHOLE_ARRAY,0,MODE_DESCEND); 
      if(Period()<=GrossPeriod) bigshift++; 
     } 
      for (int cnt=bigshift; cnt<(1+bigshift); cnt++)
      {
         value1=iCustom(NULL,GrossPeriod,"#!InsideBars",0,cnt);
         value2=iCustom(NULL,GrossPeriod,"#!InsideBars",1,cnt);
         value3=iCustom(NULL,GrossPeriod,"#!InsideBars",2,cnt);
         value4=iCustom(NULL,GrossPeriod,"#!InsideBars",3,cnt);
      }
      
   ExtMapBuffer1[i]=value1; 
   ExtMapBuffer2[i]=value2; 
   ExtMapBuffer3[i]=value3; 
   ExtMapBuffer4[i]=value4; 
   
   ObjectsRedraw();

   }
 
//----
   return(0);
  }
//+------------------------------------------------------------------+