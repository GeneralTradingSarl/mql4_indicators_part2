//+------------------------------------------------------------------+
//|                                                          PVI.mq4 |
//|                                          Alexander Kocian, 2013  |      
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 3

#property indicator_color2 Yellow
#property indicator_style2 DRAW_LINE 
#property indicator_color3 White

extern int MA_Period=2; // PVI smoothing
extern int ME_Period=10;  // EMA for comparison

double PVI[];
double SmoothedPVI[];
double EMA[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   string shortName="PVI("+MA_Period+")  EMA("+ME_Period+")";
   IndicatorShortName(shortName);

   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,PVI);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,SmoothedPVI);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,EMA);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int pos;
 
   if (Bars<MA_Period) return(-1);
   int limit=Bars-2;

   double Vol0,Vol1;

//if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   
   PVI[0]=1.0;

   for(pos=1;pos<limit;pos++)
     {
      Vol0=Volume[pos-1];
      Vol1=Volume[pos];

      if(Vol0>Vol1)
         PVI[pos]=PVI[pos-1]*(1+((Close[pos]-Close[pos-1])/Close[pos-1]));
      else
         PVI[pos]=PVI[pos-1];
      
     }

//simple MA
   int limit_s=limit-MA_Period;
   double first_value=0.0;
   for(int i=0;i<MA_Period;i++)
      first_value+=PVI[limit_s+i];
   SmoothedPVI[limit_s]=first_value/MA_Period;

   pos=limit_s-1;
   while(pos>=0)
     {
      SmoothedPVI[pos]=SmoothedPVI[pos+1]+(PVI[pos]-PVI[pos+MA_Period])/MA_Period;
      pos--;
     }
//EMA10 for comparison
   int limit_e=limit-ME_Period;
   double SmoothFactor=2.0/(1.0+ME_Period);

   if(limit_e>=0) EMA[limit_e]=PVI[limit_e];
   pos=limit_e-1;
   while(pos>=0)
     {
      EMA[pos]=SmoothFactor*PVI[pos+1]+(1-SmoothFactor)*EMA[pos+1];
      pos--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
