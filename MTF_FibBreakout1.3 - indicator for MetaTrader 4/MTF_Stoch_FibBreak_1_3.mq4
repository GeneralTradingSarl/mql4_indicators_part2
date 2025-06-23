//+--------------------------------------------------------------------+
//|                                         #MTF_FibBreakout1.3.mq4    |
//|                                                     version 1.3    |
//| http://www.forexfactory.com/showthread.php?t=30109                 |
//| based on Spud's MTF FIB Breakout System                            |
//|                                                                    |
//| This indicator will display the K% line of the Stochastic only     |
//| You can turn the Alert on or off and it'll alert only once per bar |
//|                                                                    |
//| version 1.1: 2 stochs are combined into 1 indicator                |
//| version 1.2: changed alerts according to new rules                 |
//| version 1.3: added some dots where stochs crossed and this version |
//|                                         goes MTF (Multi Time Frame)|
//+--------------------------------------------------------------------+
#property copyright "Copyright © 2006-07, Keris2112"
#property link      "http://www.forex-tsd.com"
//----
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 4
#property indicator_color1 Blue //Stoch 5,3,3
#property indicator_color2 Red  //Stoch 14,3,3
#property indicator_style2 STYLE_DOT  //Stoch 14,3,3
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_level1 76.4
#property indicator_level2 61.8
#property indicator_level3 50.0
#property indicator_level4 38.2
#property indicator_level5 23.6
//---- input parameters
/*************************************************************************
_M1   1
_M5   5
_M15  15
_M30  30 
_H1   60
_H4   240
_D1   1440
_W1   10080
_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
---------------------------------------
MODE_SMA    0 Simple moving average, 
MODE_EMA    1 Exponential moving average, 
MODE_SMMA   2 Smoothed moving average, 
MODE_LWMA   3 Linear weighted moving average. 
You must use the numeric value of the MA Method that you want to use
when you set the 'ma_method' value with the indicator inputs.
**************************************************************************/
extern string note1="Current timeframe = 0, 30M chart = 30";
extern string note2="1H chart = 60, 4H chart = 240";
extern int TimeFrame=0;
extern string note3="First Stochastic";
extern int K1=5;
extern int D1=3;
extern int Slowing1=3;
extern string note4="Second Stochastic";
extern int K2=14;
extern int D2=3;
extern int Slowing2=3;
extern string note5="turn on Alert = true; turn off = false";
extern bool AlertOn=false;
extern string note6="draw dots? yes = true; no = false";
extern bool DotsDrawing=true;
//extern string note5 = "PriceField:  0=Hi/Low   1=Close/Close";
//extern int MAMethod1=0;
//extern int PriceField1=0;
//extern int MAMethod2=0;
//extern int PriceField2=0;
// PriceField:  0=Hi/Low   1=Close/Close
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double BuyBreakout[];
double SellBreakout[];
//+-- Show regular timeframe string (HCY) ---------------------------+
string AlertPrefix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  string GetTimeFrameStr() 
  {
   switch(TimeFrame)
     {
      case 1 : string TimeFrameStr2="M1"; break;
      case 5 : TimeFrameStr2="M5"; break;
      case 15 : TimeFrameStr2="M15"; break;
      case 30 : TimeFrameStr2="M30"; break;
      case 60 : TimeFrameStr2="H1"; break;
      case 240 : TimeFrameStr2="H4"; break;
      case 1440 : TimeFrameStr2="D1"; break;
      case 10080 : TimeFrameStr2="W1"; break;
      case 43200 : TimeFrameStr2="MN1"; break;
     }
   return(TimeFrameStr2);
  } //string GetTimeFrameStr()
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   IndicatorBuffers(4);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_LINE);
     if (DotsDrawing) 
     {
      SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID);
      SetIndexArrow(2,159);
      SetIndexBuffer(2,BuyBreakout);
      //
      SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID);
      SetIndexArrow(3,159);
      SetIndexBuffer(3,SellBreakout);
     } // if (DotsDrawing)
   // Show regular timeframe string (HCY)
     if (TimeFrame==0) 
     {
      TimeFrame=Period();
     }
   AlertPrefix=Symbol()+" ("+GetTimeFrameStr()+"):  ";
//---- name for DataWindow and indicator subwindow label   
   IndicatorShortName(Symbol()+","+GetTimeFrameStr()+" Stoch("+(string)K1+","+(string)D1+","+(string)Slowing1+")"+" Stoch("+(string)K2+","+(string)D2+","+(string)Slowing2+")");
  return(0);
  }
//----
   
//+------------------------------------------------------------------+
bool NewBar()
  {
   static datetime lastbar;
   datetime curbar=Time[0];
   if(lastbar!=curbar)
     {
      lastbar=curbar;
      return(true);
     }
   else
     {
      return(false);
     }
  }
//+------------------------------------------------------------------+
//| MTF Stochastic                                                   |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();
   // Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
//----
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
/***********************************************************   
   Add your main indicator loop below.  You can reference an existing
   indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator timeframe
   Rule 3:  Use 'y' for the indicator's shift value
**********************************************************/
      //   ExtMapBuffer1[i]=iStochastic(NULL,TimeFrame,K1,D1,Slowing1,MAMethod,PriceField,0,y);
      //   ExtMapBuffer2[i]=iStochastic(NULL,TimeFrame,K2,D2,Slowing2,MAMethod,PriceField,0,y);
      ExtMapBuffer1[i]=iStochastic(NULL,TimeFrame,K1,D1,Slowing1,0,0,0,y);
      ExtMapBuffer2[i]=iStochastic(NULL,TimeFrame,K2,D2,Slowing2,0,0,0,y);
      SellBreakout[i]=EMPTY_VALUE;
      BuyBreakout[i]=EMPTY_VALUE;
        if (K2 > K1) 
        {
         if(ExtMapBuffer2[i]>=indicator_level1)
           {
            BuyBreakout[i]=indicator_level1;
           }
         else
            if(ExtMapBuffer2[i]<=indicator_level5)
              {
               SellBreakout[i]=indicator_level5;
              }
        } // if (K2 > K1)
        else 
        {
         if(ExtMapBuffer1[i]>=indicator_level1)
           {
            BuyBreakout[i]=indicator_level1;
           }
         else
            if(ExtMapBuffer1[i]<=indicator_level5)
              {
               SellBreakout[i]=indicator_level5;
              }
        } // if (K2 > K1)       
     }  //for(i=0,y=0;i<limit;i++)
//-- Alerts ---
     if(AlertOn && NewBar())
     {
      if((ExtMapBuffer1[0]>=indicator_level1) && (ExtMapBuffer2[0]>=indicator_level1))
        {
         Alert(AlertPrefix+"Both Stochs cross up 76.4%");
        }
      else
        {
         if(ExtMapBuffer1[0]>=indicator_level1)
           {
            Alert(AlertPrefix+"Only Stoch("+(string)K1+","+(string)D1+","+(string)Slowing1+") crosses up 76.4%");
           }
         if(ExtMapBuffer2[0]>=indicator_level1)
           {
            Alert(AlertPrefix+"Only Stoch("+(string)K2+","+(string)D2+","+(string)Slowing2+") crosses up 76.4%");
           }
        }
      if((ExtMapBuffer1[0]<=indicator_level5) && (ExtMapBuffer2[0]<=indicator_level5))
        {
         Alert(AlertPrefix+"Both Stochs cross down 23.6%");
        }
      else
        {
         if(ExtMapBuffer1[0]<=indicator_level5)
           {
            Alert(AlertPrefix+"Only Stoch("+(string)K1+","+(string)D1+","+(string)Slowing1+") crosses down 23.6%");
           }
         if(ExtMapBuffer2[0]<=indicator_level5)
           {
            Alert(AlertPrefix+"Only Stoch("+(string)K2+","+(string)D2+","+(string)Slowing2+") crosses down 23.6%");
           }
        }
     }
   //----
   return(0);
  }
//+------------------------------------------------------------------+