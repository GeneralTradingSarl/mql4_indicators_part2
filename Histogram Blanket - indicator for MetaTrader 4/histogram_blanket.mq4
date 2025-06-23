//+------------------------------------------------------------------+
//|                                            Histogram_blanket.mq4 |
//|                                                  Matthieu Girard |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Girard Matthieu"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 11
#property strict

extern color ColorBull= clrGreen; //Color of Bull Line
extern color ColorBear= clrRed;   //Color of Bear Line

string Prefix;
double ExtMapBufferHighGreen1[];
double ExtMapBufferLowGreen1[];
double ExtMapBufferHighGreen2[];
double ExtMapBufferLowGreen2[];
double ExtMapBufferHighRed1[];
double ExtMapBufferLowRed1[];
double ExtMapBufferHighRed2[];
double ExtMapBufferLowRed2[];
double ExtMapBufferOpenClose1[];
double ExtMapBufferOpenClose2[];
double ExtMapBufferOpenClose3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   Prefix="HB_"+Symbol();
   ChartSetInteger(0,CHART_COLOR_CHART_UP,0,clrChocolate);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,0,clrChocolate);

   IndicatorShortName("HB_"+Symbol());
   ChartSetInteger(0,CHART_MODE,CHART_BARS);
   SetIndexBuffer(0,ExtMapBufferHighGreen1);
   SetIndexBuffer(1,ExtMapBufferLowGreen1);
   SetIndexBuffer(2,ExtMapBufferHighRed1);
   SetIndexBuffer(3,ExtMapBufferLowRed1);
   SetIndexBuffer(4,ExtMapBufferHighGreen2);
   SetIndexBuffer(5,ExtMapBufferLowGreen2);
   SetIndexBuffer(6,ExtMapBufferHighRed2);
   SetIndexBuffer(7,ExtMapBufferLowRed2);
   SetIndexBuffer(8,ExtMapBufferOpenClose1);
   SetIndexBuffer(9,ExtMapBufferOpenClose2);
   SetIndexBuffer(10,ExtMapBufferOpenClose3);

   SetIndexStyle(0,DRAW_LINE,0,3,ColorBull);
   SetIndexStyle(1,DRAW_LINE,0,3,ColorBull);
   SetIndexStyle(2,DRAW_LINE,0,3,ColorBear);
   SetIndexStyle(3,DRAW_LINE,0,3,ColorBear);
   SetIndexStyle(4,DRAW_LINE,0,3,ColorBull);
   SetIndexStyle(5,DRAW_LINE,0,3,ColorBull);
   SetIndexStyle(6,DRAW_LINE,0,3,ColorBear);
   SetIndexStyle(7,DRAW_LINE,0,3,ColorBear);
   SetIndexStyle(8,DRAW_LINE,0,2,clrChocolate);
   SetIndexStyle(9,DRAW_LINE,0,2,clrChocolate);
   SetIndexStyle(10,DRAW_LINE,0,2,clrChocolate);

   ArrayInitialize(ExtMapBufferHighGreen1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferLowGreen1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferHighRed1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferLowRed1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferHighGreen2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferLowGreen2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferHighRed2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferLowRed2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferOpenClose1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferOpenClose2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferOpenClose3,EMPTY_VALUE);
   return( 0 );
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int i;
   for(i=ObjectsTotal() -1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),"HB_"+Symbol())>-1)
        {
         ObjectDelete(0,ObjectName(i));
        }
     }
   return( 0 );
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int BarsCount;
   int i;
   double lasthigh=0;
   double lastLow=0;
   bool ishighbull,isLowbull;
   bool HG1=true;
   bool HR1=true;
   bool LG1=true;
   bool LR1=true;
   int Paire=1;
   RefreshRates();
   ArrayInitialize(ExtMapBufferHighGreen1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferLowGreen1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferHighRed1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferLowRed1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferHighGreen2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferLowGreen2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferHighRed2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferLowRed2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferOpenClose1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferOpenClose2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBufferOpenClose3,EMPTY_VALUE);

   BarsCount=WindowBarsPerChart()+20;
   for(i=0; i<BarsCount; i++)
     {
      if(i>0)
        {
         if(Paire==1)
           {
            ExtMapBufferOpenClose1[i]=NormalizeDouble(Open[i],5);
            ExtMapBufferOpenClose1[i+1]=NormalizeDouble(Close[i+1],5);
            Paire=2;
           }
         else if(Paire==2)
           {
            ExtMapBufferOpenClose2[i]=NormalizeDouble(Open[i],5);
            ExtMapBufferOpenClose2[i+1]=NormalizeDouble(Close[i+1],5);
            Paire=3;
           }
         else if(Paire==3)
           {
            ExtMapBufferOpenClose3[i]=NormalizeDouble(Open[i],5);
            ExtMapBufferOpenClose3[i+1]=NormalizeDouble(Close[i+1],5);
            Paire=1;
           }
         if(NormalizeDouble(High[i],5)<=NormalizeDouble(lasthigh,5))
           { //set and bigger
            if(ishighbull)
              {
               if(HG1)
                 {
                  ExtMapBufferHighGreen1[i]=NormalizeDouble(High[i],5);
                    }else{
                  ExtMapBufferHighGreen2[i]=NormalizeDouble(High[i],5);
                 }
                 }else{
               if(HG1)
                 {
                  ExtMapBufferHighGreen1[i-1]=NormalizeDouble(lasthigh,5);
                  ExtMapBufferHighGreen1[i]=NormalizeDouble(High[i],5);
                    }else{
                  ExtMapBufferHighGreen2[i-1]=NormalizeDouble(lasthigh,5);
                  ExtMapBufferHighGreen2[i]=NormalizeDouble(High[i],5);
                 }
               if(HR1)
                 {
                  HR1=false;
                    }else{
                  HR1=true;
                 }
              }
            ishighbull=true;
              }else{

            if(ishighbull)
              {
               if(HR1)
                 {
                  ExtMapBufferHighRed1[i-1]=NormalizeDouble(lasthigh,5);
                  ExtMapBufferHighRed1[i]=NormalizeDouble(High[i],5);
                    }else{
                  ExtMapBufferHighRed2[i-1]=NormalizeDouble(lasthigh,5);
                  ExtMapBufferHighRed2[i]=NormalizeDouble(High[i],5);;
                 }
               if(HG1)
                 {
                  HG1=false;
                    }else{
                  HG1=true;
                 }
                 }else{
               if(HR1)
                 {
                  ExtMapBufferHighRed1[i]=NormalizeDouble(High[i],5);
                    }else{
                  ExtMapBufferHighRed2[i]=NormalizeDouble(High[i],5);
                 }
              }
            ishighbull=false;
           }
         lasthigh=NormalizeDouble(High[i],5);

         if(NormalizeDouble(Low[i],5)<=NormalizeDouble(lastLow,5))
           { //set and bigger
            if(isLowbull)
              {
               if(LG1)
                 {
                  ExtMapBufferLowGreen1[i]=NormalizeDouble(Low[i],5);
                    }else{
                  ExtMapBufferLowGreen2[i]=NormalizeDouble(Low[i],5);
                 }
                 }else{
               if(LG1)
                 {
                  ExtMapBufferLowGreen1[i-1]=NormalizeDouble(lastLow,5);
                  ExtMapBufferLowGreen1[i]=NormalizeDouble(Low[i],5);
                    }else{
                  ExtMapBufferLowGreen2[i-1]=NormalizeDouble(lastLow,5);
                  ExtMapBufferLowGreen2[i]=NormalizeDouble(Low[i],5);
                 }
               if(LR1)
                 {
                  LR1=false;
                    }else{
                  LR1=true;
                 }
              }
            isLowbull=true;
              }else{

            if(isLowbull)
              {
               if(LR1)
                 {
                  ExtMapBufferLowRed1[i-1]=NormalizeDouble(lastLow,5);
                  ExtMapBufferLowRed1[i]=NormalizeDouble(Low[i],5);
                    }else{
                  ExtMapBufferLowRed2[i-1]=NormalizeDouble(lastLow,5);
                  ExtMapBufferLowRed2[i]=NormalizeDouble(Low[i],5);;
                 }
               if(LG1)
                 {
                  LG1=false;
                    }else{
                  LG1=true;
                 }
                 }else{
               if(LR1)
                 {
                  ExtMapBufferLowRed1[i]=NormalizeDouble(Low[i],5);
                    }else{
                  ExtMapBufferLowRed2[i]=NormalizeDouble(Low[i],5);
                 }
              }
            isLowbull=false;
           }
         lastLow=NormalizeDouble(Low[i],5);
           }else{
         if(HR1)
           {
            if(High[i+1]<=High[i])
              {
               ExtMapBufferHighGreen1[i]=NormalizeDouble(High[i],5);
               ExtMapBufferHighRed1[i]=EMPTY_VALUE;
                 }else{
               ExtMapBufferHighRed1[i]=NormalizeDouble(High[i],5);
               ExtMapBufferHighGreen1[i]=EMPTY_VALUE;
              }
              }else{
            if(High[i+1]<=High[i])
              {
               ExtMapBufferHighGreen2[i]=NormalizeDouble(High[i],5);
               ExtMapBufferHighRed2[i]=EMPTY_VALUE;
                 }else{
               ExtMapBufferHighRed2[i]=NormalizeDouble(High[i],5);
               ExtMapBufferHighGreen2[i]=EMPTY_VALUE;
              }
           }
         if(LR1)
           {
            if(Low[i+1]<=Low[i])
              {
               ExtMapBufferLowGreen1[i]=NormalizeDouble(Low[i],5);
               ExtMapBufferLowRed1[i]=EMPTY_VALUE;
                 }else{
               ExtMapBufferLowRed1[i]=NormalizeDouble(Low[i],5);
               ExtMapBufferLowGreen1[i]=EMPTY_VALUE;
              }
              }else{
            if(Low[i+1]<=Low[i])
              {
               ExtMapBufferLowGreen2[i]=NormalizeDouble(Low[i],5);
               ExtMapBufferLowRed2[i]=EMPTY_VALUE;
                 }else{
               ExtMapBufferLowRed2[i]=NormalizeDouble(Low[i],5);
               ExtMapBufferLowGreen2[i]=EMPTY_VALUE;
              }
           }
         lasthigh=NormalizeDouble(High[i],5);
         lastLow=NormalizeDouble(Low[i],5);
        }
     }
   return( 0 );
  }
//+------------------------------------------------------------------+
