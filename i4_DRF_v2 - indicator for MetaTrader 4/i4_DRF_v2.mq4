//+------------------------------------------------------------------+ 
//|                                                    i4_DRF_v2.mq4 | 
//|                                               goldenlion@ukr.net | 
//|                                      http://GlobeInvestFund.com/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright (c) 2005, goldenlion@ukr.net"
#property link      "http://GlobeInvestFund.com/"
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- input parameters 
//---- buffers 
double Buffer1[];
int MyPeriod=21;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init()
  {
   string short_name;
//---- indicator line 
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buffer1);
//---- name for DataWindow and indicator subwindow label 
   short_name="i4_DRF_v1.mq4("+MyPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//---- 
   SetIndexDrawBegin(0,0);
//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int d, i, ii, counted_bars=IndicatorCounted();
//---- 
   if(Bars<=MyPeriod)return(0);
   ii=Bars-MyPeriod*1.1;
   if(counted_bars>=MyPeriod)ii=Bars-MyPeriod*1.1;
   while( ii>=0)
     {
      d=0;
      for( i=11;i < 21;  i++)
         if(Close[ii]>=Close[ii+i])d=d+1; else d=d-1;
      //if d=0 then d=0.0000001; 
      Buffer1[ii]=d;
      ii--;
     }
//----     
   return(0);
  }
//+------------------------------------------------------------------+ 