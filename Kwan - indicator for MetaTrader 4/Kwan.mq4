//+------------------------------------------------------------------+
//|                                                                  |
//|                 Copyright © 1999-2008, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property copyright "Metatrader4 Code by jjk2. Based on MBA Thesis from Simon Fraser University written by C.E. ALDEA."
#property link      ""
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//----
extern int Count_Bars=1000;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double Formula[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator drawing
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,3);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,3);
   SetIndexBuffer(1,ExtMapBuffer3);
   SetIndexStyle(2,DRAW_NONE,STYLE_SOLID,3,Yellow);//DRAW_NONE,EMPTY,EMPTY);
   SetIndexBuffer(2,ExtMapBuffer2);
   SetIndexBuffer(3,Formula);
   ///-----Name of Indicator 
   string short_name="ZigZag BETA    Current value calculated by indicator:";
   IndicatorShortName(short_name);
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
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int pos = Bars - counted_bars;
   if(counted_bars==0) pos-=1+1;
   int temp=pos;
   
   while(pos>=0)
     {
      //string xxx = "pos"; 
      double Stoch=iStochastic(NULL,0,9,6,2,MODE_SMA,1,0,pos);
      double RSI=iRSI(NULL,0,9,PRICE_CLOSE,pos);
      double moment=(iMomentum(NULL,0,9,PRICE_CLOSE,pos));
      //Main Forumla
      //double preFormula = (/Momentum);
      if (moment!=0)
         ExtMapBuffer2[pos]=Stoch*(RSI)/moment;
      //Alert("MACD: ", MACD," ","Stoch: ", Stoch," ", "RSI: ", RSI," ","Momentum: ", momentum," ","Volume: ", Volu);
      //Alert(Stoch*(RSI)/Roc);
      pos--;
     }
     while(temp >=0) 
     {
      ExtMapBuffer1[temp]=EMPTY_VALUE;
      ExtMapBuffer3[temp]=EMPTY_VALUE;
      Formula[temp]=iMAOnArray(ExtMapBuffer2,0,2,0,MODE_SMA,temp);
        if (Formula[temp]>Formula[temp+1])
        {
         ExtMapBuffer1[temp]=Formula[temp];
         if (ExtMapBuffer1[temp+1]==EMPTY_VALUE) ExtMapBuffer1[temp+1]=Formula[temp+1];
         }
         else
         {
         ExtMapBuffer3[temp]=Formula[temp];
         if (ExtMapBuffer3[temp+1]==EMPTY_VALUE) ExtMapBuffer3[temp+1]=Formula[temp+1];
        }
     temp--; 
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+