//+------------------------------------------------------------------+
//|                                           ATeam-3ZigzagLevel.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright @2011, Rockyhoangdn"
#property link      "rockyhoangdn@gmail.com"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Yellow
#property indicator_color2 Aqua
#property indicator_color3 Red 
#property indicator_color4 Blue
#property indicator_color5 DarkViolet
#property indicator_color6 Green
//---- input parameters
extern int       depth=12;
extern int		 deviation=5;
extern int 		 backstep=3;
extern int GrossPeriod=0; 
extern int GrossPeriod2=60; 
extern int GrossPeriod3=240; 
extern int Barss=1000;
extern int Shift=1;
int Shift2=1;
int Shift3=1;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
datetime daytimes[]; 
datetime daytimes2[]; 
datetime daytimes3[]; 
int ArrowCode=129;
int ArrowCode2=130;
int ArrowCode3=131;
int ArrowWidth=1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

//---- indicators
   SetIndexStyle(0,DRAW_ARROW,0,1);
   SetIndexArrow(0,ArrowCode);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,"Peak 1");
   
   SetIndexStyle(1,DRAW_ARROW,0,1);
   SetIndexArrow(1,ArrowCode);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,"Lawn 1");

   SetIndexStyle(2,DRAW_ARROW,0,1);
   SetIndexArrow(2,ArrowCode2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);
   SetIndexLabel(2,"Peak 2");
   
   SetIndexStyle(3,DRAW_ARROW,0,1);
   SetIndexArrow(3,ArrowCode2);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
   SetIndexLabel(3,"Lawn 2");
   
   SetIndexStyle(4,DRAW_ARROW,0,3);
   SetIndexArrow(4,ArrowCode3);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexEmptyValue(4,0.0);
   SetIndexLabel(4,"Peak 3");

   SetIndexStyle(5,DRAW_ARROW,0,3);
   SetIndexArrow(5,ArrowCode3);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexEmptyValue(5,0.0);
   SetIndexLabel(5,"Lawn 3");
   

   IndicatorShortName("ATeam-3ZigzagLevel-rockyhoangdn");
   
//----
//---- 
   if (Period()>GrossPeriod) {GrossPeriod=Period();} 
   if (Period()>GrossPeriod2) {GrossPeriod2=Period();} 
   if (Period()>GrossPeriod3) {GrossPeriod3=Period();} 
	if	(Period()==240){GrossPeriod=240; GrossPeriod2=1440;GrossPeriod3=10080;}
	if	(Period()==1440){GrossPeriod=1440; GrossPeriod2=10080;GrossPeriod3=43200;}
	if	(Period()==10080){GrossPeriod=10080; GrossPeriod2=10080;GrossPeriod3=43200;}
   ArrayCopySeries(daytimes,MODE_TIME,Symbol(),GrossPeriod); 
   ArrayCopySeries(daytimes2,MODE_TIME,Symbol(),GrossPeriod2); 
   ArrayCopySeries(daytimes3,MODE_TIME,Symbol(),GrossPeriod3); 
   if(GrossPeriod==Period()) Shift=0;
   if(GrossPeriod2==Period()) Shift2=0;
   if(GrossPeriod3==Period()) Shift3=0;
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
//   int    counted_bars=IndicatorCounted();
//   int    limit=300;
   int bigshift,bigshift2,bigshift3;
   double zigzag1,zigzag2,zigzag3,zigzag4,zigzag5,zigzag6,zigzag01,zigzag02,zigzag03;
//   if (counted_bars<0) return(-1); 
    
//   if (counted_bars>0) counted_bars--; 
     int counted_bars = IndicatorCounted();
      if(counted_bars < 0)  return(-1);
      if(counted_bars > 0)   counted_bars--;
      int limit = Bars - counted_bars;
      if(counted_bars==0) limit-=1+1;
      
//   if (Barss>0) limit=Barss; else limit=Bars;
//---- 
   for (int i=1; i<limit; i++) 
   { 
   if(Time[i]>=daytimes[0]) bigshift=0; 
   else 
     { 
      bigshift = ArrayBsearch(daytimes,Time[i-1],WHOLE_ARRAY,0,MODE_DESCEND); 
      if(Period()<=GrossPeriod) bigshift++; 
     } 
      for (int cnt=bigshift; cnt<(1+bigshift); cnt++)
      {
         zigzag01=iCustom(NULL,GrossPeriod,"ZigZag2",depth,deviation,backstep,0,cnt+Shift);
         zigzag1=iCustom(NULL,GrossPeriod,"ZigZag2",depth,deviation,backstep,1,cnt+Shift);
         zigzag2=iCustom(NULL,GrossPeriod,"ZigZag2",depth,deviation,backstep,2,cnt+Shift);
         if ( zigzag01!=0 ) break;
      }
      
   if (  iClose(NULL,0,i+1)<=zigzag1 )  ExtMapBuffer1[i]=zigzag1; else ExtMapBuffer1[i]=0.0;
   if (  iClose(NULL,0,i+1)>=zigzag2 )  ExtMapBuffer2[i]=zigzag2; else ExtMapBuffer2[i]=0.0;
   }
//----
//---- 
   for (int i2=0; i2<limit; i2++) 
   { 
   if(Time[i2]>=daytimes2[0]) bigshift2=0; 
   else 
     { 
      bigshift2 = ArrayBsearch(daytimes2,Time[i2-1],WHOLE_ARRAY,0,MODE_DESCEND); 
      if(Period()<=GrossPeriod2) bigshift2++; 
     } 
      for (int cnt2=bigshift2; cnt2<(1+bigshift2); cnt2++)
      {
         zigzag02=iCustom(NULL,GrossPeriod2,"ZigZag2",depth,deviation,backstep,0,cnt2+Shift2);
         zigzag3=iCustom(NULL,GrossPeriod2,"ZigZag2",depth,deviation,backstep,1,cnt2+Shift2);
         zigzag4=iCustom(NULL,GrossPeriod2,"ZigZag2",depth,deviation,backstep,2,cnt2+Shift2);
         if ( zigzag02!=0 ) break;
      }
      
   if (  iClose(NULL,0,i2+1)<=zigzag3 )  ExtMapBuffer3[i2]=zigzag3; else ExtMapBuffer3[i2]=0.0;
   if (  iClose(NULL,0,i2+1)>=zigzag4 )  ExtMapBuffer4[i2]=zigzag4; else ExtMapBuffer4[i2]=0.0;
   }
//----
//---- 
   for (int i3=1; i3<limit; i3++) 
   { 
   if(Time[i3]>=daytimes3[0]) bigshift3=0; 
   else 
     { 
      bigshift3 = ArrayBsearch(daytimes3,Time[i3-1],WHOLE_ARRAY,0,MODE_DESCEND); 
      if(Period()<=GrossPeriod3) bigshift3++; 
     } 
      for (int cnt3=bigshift3; cnt3<(1+bigshift3); cnt3++)
      {
         zigzag03=iCustom(NULL,GrossPeriod3,"ZigZag2",depth,deviation,backstep,0,cnt3+Shift3);
         zigzag5=iCustom(NULL,GrossPeriod3,"ZigZag2",depth,deviation,backstep,1,cnt3+Shift3);
         zigzag6=iCustom(NULL,GrossPeriod3,"ZigZag2",depth,deviation,backstep,2,cnt3+Shift3);
         if ( zigzag03!=0 ) break;
      }
      
   if (  iClose(NULL,0,i3+1)<=zigzag5 )  ExtMapBuffer5[i3]=zigzag5; else ExtMapBuffer5[i3]=0.0;
   if (  iClose(NULL,0,i3+1)>=zigzag6 )  ExtMapBuffer6[i3]=zigzag6; else ExtMapBuffer6[i3]=0.0;
   }
//----
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+