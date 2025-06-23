//+------------------------------------------------------------------+
//|                MTF_4 TF XO_M30D1           ZZ MTF XO A.mq4    ik |
//|                                     /www.forex-tsd.com/xo-method |
//+------------------------------------------------------------------+
#property copyright " ZZ MTF XO A    MTF_4 TF XO_M30D1"
#property link      " ZZ MTF XO A "
//----
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 DarkGreen//PaleGreen
#property indicator_color2 Maroon
#property indicator_color3 LimeGreen  //Lime
#property indicator_color4 Red
#property indicator_width1 1//2
#property indicator_width2 1
#property indicator_width3 1//2
#property indicator_width4 1//2
//----
#property indicator_maximum 4
#property indicator_minimum -4
//----
extern double KirPER=7;                            //10
extern int TF1=30;       // PERIOD_M5
extern int TF2=60;
extern int TF3=240;
extern int TF4=1440;
//----
extern double KirPER1=4.5;//7
extern double KirPER2=4.5;
extern double KirPER3=4.5;
extern double KirPER4=4.5;//7
//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
**************************************************************************/
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,1);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,1);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,1);
   SetIndexBuffer(3,ExtMapBuffer4);
   //
   string short_name;
   short_name=("MTF_4TFXO");
   IndicatorShortName(short_name);
   SetIndexLabel(0,"MTF_4TF_XO_TF"+TF1+"");
   SetIndexLabel(1,"MTF_4TF_XO_TF"+TF2+"");
   SetIndexLabel(2,"MTF_4TF_XO_TF"+TF3+"");
   SetIndexLabel(3,"MTF_4TF_XO_TF"+TF4+"");
   return(0);
  }
//----
//+------------------------------------------------------------------+
//| MTF Parabolic Sar                                                |
//+------------------------------------------------------------------+
int start()
  {
   int    i,y=0;
//----
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit--;
   
   int lastp15=0, lastp30=0, lastp60=0;
   for(i=0,y=0;i<limit;i++)
     {
      int p1,p2,p3,p4;
      p1=iBarShift( NULL, TF1, Time[i], false );
      p2=iBarShift( NULL, TF2, Time[i], false );
      p3=iBarShift( NULL, TF3, Time[i], false );
      p4=iBarShift( NULL, TF4, Time[i], false );
/***********************************************************   
   Add your main indicator loop below.  You can reference an existing
      indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
 **********************************************************/
      double totalUp=0.0;
      double totalDown=0.0;
//----
      totalUp=iCustom(NULL,TF1,"XO",KirPER1,0,p1);
      totalDown=iCustom(NULL,TF1,"XO",KirPER1,1,p1);
      totalUp= totalUp + iCustom(NULL,TF2,"XO",KirPER2,0,p2);
      totalDown= totalDown + iCustom(NULL,TF2,"XO",KirPER2,1,p2);
      totalUp= totalUp + iCustom(NULL,TF3,"XO",KirPER3,0,p3);
      totalDown= totalDown + iCustom(NULL,TF3,"XO",KirPER3,1,p3);
      totalUp= totalUp + iCustom(NULL,TF4,"XO",KirPER4,0,p4);
      totalDown= totalDown + iCustom(NULL,TF4,"XO",KirPER4,1,p4);
//----
      ExtMapBuffer1[i]=0;
      ExtMapBuffer2[i]=0;
      ExtMapBuffer3[i]=0;
      ExtMapBuffer4[i]=0;
        if(totalUp==4 || totalDown==-4)
        {
         ExtMapBuffer3[i]=totalUp;
         ExtMapBuffer4[i]=totalDown;
         }
          else 
         {
         ExtMapBuffer1[i]=totalUp;
         ExtMapBuffer2[i]=totalDown;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+