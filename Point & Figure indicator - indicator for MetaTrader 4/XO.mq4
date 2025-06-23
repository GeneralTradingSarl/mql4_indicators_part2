//+------------------------------------------------------------------+
//|                                                           XO.mq4 |
//|                                                     GranParadiso |
//|                                                jaanus@jantson.ee |
//+------------------------------------------------------------------+
#property copyright "GranParadiso"
#property link      "jaanus@jantson.ee"

#property indicator_chart_window
#property indicator_buffers         2
#property indicator_color1          Red
#property indicator_style1          STYLE_SOLID
#property indicator_width1          2
#property indicator_color2          Green
#property indicator_style2          STYLE_SOLID
#property indicator_width2          2


extern int  BoxSize                 = 5;
extern int  ReversalAmount          = 3;


int         LastCalculatedBarIndex;
int         LastTrend;
double      arr_XO_Open[];
double      arr_XO_Close[];
double      arr_Open[];
double      arr_Close[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(4);
   SetIndexBuffer(0,arr_XO_Open);
   SetIndexStyle(0,DRAW_HISTOGRAM);

   SetIndexBuffer(1,arr_XO_Close);
   SetIndexStyle(1,DRAW_HISTOGRAM);

   SetIndexBuffer(2,arr_Open);
   SetIndexBuffer(3,arr_Close);

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int
   j,
   k;
   double   UP,
   DW;

   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;

   for(int i=limit;i>=0;i--)
     {
      LastTrend=0;
      if(i==Bars-1)
        {
         arr_Open[i]=MathRound(Close[i]*(MathPow(10,Digits)/BoxSize))/(MathPow(10,Digits)/BoxSize);
         arr_Close[i]=arr_Open[i];
         continue;
        }

      if(arr_Open[i+1]>arr_Close[i+1]) LastTrend=-1;
      if(arr_Open[i+1]<arr_Close[i+1]) LastTrend=1;

      arr_Close[i]=arr_Close[i+1];
      arr_Open[i]=arr_Open[i+1];

      UP=0.0;
      DW=0.0;

      UP=(High[i]-arr_Close[i])/Point;
      DW=(arr_Close[i]-Low[i])/Point;

      switch(LastTrend)
        {
         case  1:
            if(UP<BoxSize) UP=0.0;
            else UP=MathFloor(UP/BoxSize)*BoxSize;
            if(DW<(BoxSize*ReversalAmount)) DW=0.0;
            else DW=MathFloor(DW/BoxSize)*BoxSize;
            arr_Close[i]=arr_Close[i]+UP*Point;
            if(DW!=0.0)
              {
               arr_Close[i+1]=arr_Close[i+1]+UP*Point;
               arr_Open[i]=arr_Close[i+1]-BoxSize*Point;
               arr_Close[i]=arr_Close[i+1]-UP*Point-DW*Point;
              }
            break;

         case -1:
            if(UP<(BoxSize*ReversalAmount)) UP=0.0;
            else UP=MathFloor(UP/BoxSize)*BoxSize;
            if(DW<BoxSize) DW=0.0;
            else DW=MathFloor(DW/BoxSize)*BoxSize;
            arr_Close[i]=arr_Close[i]-DW*Point;
            if(UP!=0.0)
              {
               arr_Close[i+1]=arr_Close[i+1]-DW*Point;
               arr_Open[i]=arr_Close[i+1]+BoxSize*Point;
               arr_Close[i]=arr_Close[i+1]+UP*Point+DW*Point;
              }
            break;

         default:
            if(UP<(BoxSize*ReversalAmount)) UP=0.0;
            else UP=MathFloor(UP/BoxSize)*BoxSize;
            if(DW<(BoxSize*ReversalAmount)) DW=0.0;
            else DW=MathFloor(DW/BoxSize)*BoxSize;
            arr_Close[i]=arr_Close[i]+UP*Point;
            arr_Close[i]=arr_Close[i]-DW*Point;
            break;
        }
     }

   limit=0;
   k=0;
   if(arr_Open[0]!=arr_XO_Open[0])
     {
      limit=Bars;
      arr_XO_Open[0]=arr_Open[0];
      arr_XO_Close[0]=arr_Close[0];
     }
   for(j=1;j<limit;j++)
     {
      if(arr_Open[j]!=arr_XO_Open[k])
        {
         k++;
         arr_XO_Open[k]=arr_Open[j];
         arr_XO_Close[k]=arr_Close[j];
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
