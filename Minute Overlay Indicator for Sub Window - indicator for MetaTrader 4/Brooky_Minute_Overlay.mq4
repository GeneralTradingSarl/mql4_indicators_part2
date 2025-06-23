//+------------------------------------------------------------------+
//|                                        Brooky_Minute_Overlay.mq4 |
//|                                          Copyright © 2010,Brooky |
//|                               http://forex-indicators.weebly.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010,Brooky"
#property link      "http://forex-indicators.weebly.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 DimGray
#property indicator_color2 Silver
#property indicator_color3 DarkOrange
#property indicator_color4 Orange

//---- input parameters
extern string     Author_Site = "forex-indicators.weebly.com";
extern string     Main_Minute = "Leave at 0 To Show Hour";
extern int        minute_end_1=0;
extern string     Secondary_Minute = "Possibly 30 for Half Hour";
extern int        minute_end_2=30;
extern string     Minor_Minutes = "Same as secondary or 15 and 45?";
extern int        minute_end_3=15;
extern int        minute_end_4=45;
extern string     Line_Height = "Height of Major and Minor. 1 is full height";
extern double        height_Main_Minute =1;
extern double        height_Secondary_Minute =0.9;
extern double        height_Minor_Minute_1 =0.8;
extern double        height_Minor_Minute_2 =0.8;
//---- buffers
double minute_end_1_Buffer[];
double minute_end_2_Buffer[];
double minute_end_3_Buffer[];
double minute_end_4_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);SetIndexBuffer(0,minute_end_1_Buffer);
         SetIndexLabel(0,"M ( "+minute_end_1+" )");
   
   SetIndexStyle(1,DRAW_HISTOGRAM);SetIndexBuffer(1,minute_end_2_Buffer);
         SetIndexLabel(1,"M ( "+minute_end_2+" )");
   
   SetIndexStyle(2,DRAW_HISTOGRAM);SetIndexBuffer(2,minute_end_3_Buffer);
         SetIndexLabel(2,"M ( "+minute_end_3+" )");
      
   SetIndexStyle(3,DRAW_HISTOGRAM);SetIndexBuffer(3,minute_end_4_Buffer);
         SetIndexLabel(3,"M ( "+minute_end_4+" )");      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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
     int limit;
     int counted_bars=IndicatorCounted();
  //---- check for possible errors
     if(counted_bars<0) return(-1);
  //---- the last counted bar will be recounted
     if(counted_bars>0) counted_bars--;
     limit=Bars-counted_bars;
  //---- main loop
     for(int i=0; i<limit; i++)
       {
        int m1 = TimeMinute(Time[i]);
        if (m1 == minute_end_1) 
         {
            minute_end_1_Buffer[i] = height_Main_Minute;
         }  else minute_end_1_Buffer[i]=0.0;
        
        int m2 = TimeMinute(Time[i]);
        if (m2 == minute_end_2) 
         {
            minute_end_2_Buffer[i]= height_Secondary_Minute;
         }  else minute_end_2_Buffer[i]=0.0;
         
         
        int m3 = TimeMinute(Time[i]);
        if (m3 == minute_end_3) 
         {
            minute_end_3_Buffer[i]= height_Minor_Minute_1;
         }  else minute_end_3_Buffer[i]=0.0;         
         
        int m4 = TimeMinute(Time[i]);
        if (m4 == minute_end_4) 
         {
            minute_end_4_Buffer[i]= height_Minor_Minute_2;
         }  else minute_end_4_Buffer[i]=0.0;         
       }
  //---- done
     return(0);
    }
//+------------------------------------------------------------------+