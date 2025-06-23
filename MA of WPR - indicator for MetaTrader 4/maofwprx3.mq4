//+------------------------------------------------------------------+
//|                                                    MAofWPRx3.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_maximum 0
#property indicator_minimum -100
#property indicator_level1 -15
#property indicator_level2 -45
#property indicator_level3 -50
#property indicator_level4 -55
#property indicator_level5 -85

double WPR1[]; 
double WPR2[];
double WPR3[];
double maWPR1[];
double maWPR2[];
double maWPR3[];

extern int periodeWPR1 =15; // period of wpr#1
extern int periodeWPR2 =45; // period of wpr#2
extern int periodeWPR3 =90; // period of wpr#3
extern int periodeMAWPR1 =5; // period of ma of wpr#1
extern int periodeMAWPR2 =5; // period of ma of wpr#2
extern int periodeMAWPR3 =5; // period of ma of wpr#3
extern int methodemoyenne = 2; // method of MAWPR buffers
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,WPR1);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(1,WPR2);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(2,WPR3);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(3,maWPR1);
   SetIndexStyle(3,DRAW_LINE,0,2,clrRed);
   SetIndexBuffer(4,maWPR2);
   SetIndexStyle(4,DRAW_LINE,0,2,clrGreenYellow);
   SetIndexBuffer(5,maWPR3);
   SetIndexStyle(5,DRAW_LINE,0,2,clrBlue);


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i;
   for(i=Bars-1; i>=0; i--)
     {
      WPR1[i]=iWPR(NULL,0,periodeWPR1,i);
      WPR2[i]=iWPR(NULL,0,periodeWPR2,i);
      WPR3[i]=iWPR(NULL,0,periodeWPR3,i);
      maWPR1[i]=iMAOnArray(WPR1,0,periodeMAWPR1,0,methodemoyenne,i);
      maWPR2[i]=iMAOnArray(WPR2,0,periodeMAWPR2,0,methodemoyenne,i);
      maWPR3[i]=iMAOnArray(WPR3,0,periodeMAWPR3,0,methodemoyenne,i);

     }
   return(0);
  }
//+------------------------------------------------------------------
//+------------------------------------------------------------------+
