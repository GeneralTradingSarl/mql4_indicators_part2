//+------------------------------------------------------------------+
//|                             LGP_Ivanoff_Maloma-Demark_levels.mq4 |
//|                      Copyright © 2006, LGP                       |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, LGP"
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Orange
#property indicator_color3 Red
#property indicator_color4 Orange
//---- input parameters
extern   int      nBars=1000;
extern   color    color1=Red;
extern   color    color2=Orange;
extern   int      width_H_L=0;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//----
int D1=1440, H4=240, H1=60, M15=15;
double P;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if (nBars>Bars)
      nBars=Bars;
//----
   if (Period()==D1)P=15*Point;
   if (Period()==H4)P=7*Point;
   if (Period()==H1)P=4*Point;
   if (Period()==30)P=3*Point;
   if (Period()==M15)P=2*Point;
   if (Period()==5)P=1*Point;
   if (Period()==1)P=0.5*Point;
//---- indicators
   SetIndexStyle(0,DRAW_ARROW,EMPTY,width_H_L,color1);
   SetIndexArrow(0,217);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   //
   SetIndexStyle(1,DRAW_ARROW,EMPTY,width_H_L,color2);
   SetIndexArrow(1,217);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
   // 
   SetIndexStyle(2,DRAW_ARROW,EMPTY,width_H_L,color1);
   SetIndexArrow(2,218);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);
   //
   SetIndexStyle(3,DRAW_ARROW,EMPTY,width_H_L,color2);
   SetIndexArrow(3,218);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   //High
   for(int i=1;i<=nBars-2;i++)
     {
      int j=i;
      for(int k=i;k<=nBars-2;k++)
        {
         if(Close[j+1]!=Close[i] )
            break;
         j++;
        }
      //    
      if(Close[i]>Close[i-1] && Close[i]>Close[j+1] && Close[j+1]>Close[j+2] )
        {
         if(Close[i]>High[i-1] )
         { ExtMapBuffer2[i-1]=Close[i-1]+P; }  
         else { ExtMapBuffer1[i]=High[i]+P; }
        }
      //
      i=j;
     }
   //Low  
   for(i=1;i<=nBars-2;i++)
     {
      j=i;
      for(k=i;k<=nBars-2;k++)
        {
         if(Close[j+1]!=Close[i] )
            break;
         j++;
        }
      //    
      if(Close[i]<Close[i-1] && Close[i]<Close[j+1] && Close[j+1]<Close[j+2] )
        {
         if(Close[i]<Low[i-1] )
         { ExtMapBuffer4[i-1]=Close[i-1]-P; } 
         else { ExtMapBuffer3[i]=Low[i]-P; }
        }
      //
      i=j;
     }
   return(0);
  }
//+------------------------------------------------------------------+