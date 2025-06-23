//+------------------------------------------------------------------+
//|                                                Level Trading.mq4 |
//|                                                         by Accel |
//+------------------------------------------------------------------+
#property copyright "Accel"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
//----
extern int     IndicatorNumber=1;
extern color   TrendUpColor=Blue;
extern color   TrendDownColor=Red;
extern color   LevelColor=DarkGray;
extern int     Width2LevelConfirmation=3;
extern int     Width3LevelConfirmation=5;
extern int     Width4LevelConfirmation=7;
extern int     Width5LevelConfirmation=10;
extern bool    SnapExtremumsToLevelOnChar=True;
extern int     FractalBarsOnEachSide=7;
extern int     ProceedMaxHistoryBars=2000;
extern int     LevelActuality=200;
extern bool    RestDefaultTimeframeValues=True;
extern int     ExtremumToLevelMaxGap=15;
extern double  PriceDeltaFor1Bar=0.4;
//----
int LevelLength[];
int LevelWidth[];
int PriceCrossedLevel;
double long1[];
double short1[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
   SetIndexBuffer(0,long1);
   SetIndexBuffer(1,short1);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   int i=0;
//----
   for(i=Bars-1;i>=0;i--)
      if (ObjectFind(StringConcatenate("Level_",IndicatorNumber,"_",i))!=-1)
         ObjectDelete(StringConcatenate("Level_",IndicatorNumber,"_",i));
   for(i=Bars-1;i>=0;i--)
      if (ObjectFind(StringConcatenate("Trend_",IndicatorNumber,"_",i))!=-1)
         ObjectDelete(StringConcatenate("Trend_",IndicatorNumber,"_",i));
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LastBarWasHighLow(int LELB, int LEHB)
  {
   if (LELB==-1 && LEHB!=-1)
      return(1);
   if (LELB!=-1 && LEHB==-1)
      return(-1);
   if (LELB!=-1 && LEHB!=-1 && LELB>LEHB)
      return(1);
   if (LELB!=-1 && LEHB!=-1 && LELB<LEHB)
      return(-1);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i,j;
   int BarsToCheck;
   int Stop;
   int CurrState; //CurrState=0 - не нашли пересечения, 1-пересечение вверх, -1-пересечение вниз
   int LastExtremumHighBar=-1;
   int LastExtremumLowBar=-1;
   int LastExtremumBar=-1;
   double iFractalValue=0,jFractalValue=0;
//----
   if (IndicatorCounted()<0)
      return(-1);
   if (Bars-IndicatorCounted()==1)
      return(0);
//----
   deinit();
   SetIndexStyle(0,DRAW_ARROW,0,3);
   SetIndexArrow(0,251);
   SetIndexStyle(1,DRAW_ARROW,0,3);
   SetIndexArrow(1,251);
   ArrayInitialize(long1,0);
   ArrayInitialize(short1,0);
//----
   if (RestDefaultTimeframeValues==1)
     {
      switch(Period())
        {
         case 1: //M1
           {
            ExtremumToLevelMaxGap=2;
            PriceDeltaFor1Bar=0.05;
            break;
           }
         case 5: //M5
           {
            ExtremumToLevelMaxGap=5;
            PriceDeltaFor1Bar=0.1;
            break;
           }
         case 15: //M15
           {
            ExtremumToLevelMaxGap=8;
            PriceDeltaFor1Bar=0.2;
            break;
           }
         case 30: //M30
           {
            ExtremumToLevelMaxGap=10;
            PriceDeltaFor1Bar=0.3;
            break;
           }
         case 60: //H1
           {
            ExtremumToLevelMaxGap=15;
            PriceDeltaFor1Bar=0.4;
            break;
           }
         case 240: //H4
           {
            ExtremumToLevelMaxGap=25;
            PriceDeltaFor1Bar=0.4;
            break;
           }
         case 1440: //D1
           {
            ExtremumToLevelMaxGap=75;
            PriceDeltaFor1Bar=1.5;
            break;
           }
         case 10080: //W1
           {
            ExtremumToLevelMaxGap=150;
            PriceDeltaFor1Bar=5;
            break;
           }
         case 43200: //MN
           {
            ExtremumToLevelMaxGap=300;
            PriceDeltaFor1Bar=24;
            break;
           }
        }
     }
   if (Width2LevelConfirmation<=1)
      Width2LevelConfirmation=2;
   if (Width3LevelConfirmation<=Width2LevelConfirmation)
      Width3LevelConfirmation=Width2LevelConfirmation+1;
   if (Width4LevelConfirmation<=Width3LevelConfirmation)
      Width4LevelConfirmation=Width3LevelConfirmation+1;
   if (Width5LevelConfirmation<=Width4LevelConfirmation)
      Width5LevelConfirmation=Width4LevelConfirmation+1;
//----
   PriceCrossedLevel=ExtremumToLevelMaxGap*2;
   ArrayResize(LevelLength,Bars);
   ArrayInitialize(LevelLength,0);
   ArrayResize(LevelWidth,Bars);
   ArrayInitialize(LevelWidth,1);
//----
   if (FractalBarsOnEachSide<=0)
      FractalBarsOnEachSide=1;
   //Ищем фракталы  
   for(i=MathMin(ProceedMaxHistoryBars,Bars-FractalBarsOnEachSide-1);i>=FractalBarsOnEachSide;i--)
     {
      //Ищем нижний фрактал
      if (i==Lowest(Symbol(),Period(),MODE_LOW,FractalBarsOnEachSide*2+1,i-FractalBarsOnEachSide))
        {
         switch(LastBarWasHighLow(LastExtremumLowBar,LastExtremumHighBar))
           {
            case -1:
              {
               if (Low[i]<Low[LastExtremumLowBar])
                 {
                  long1[i]=Low[i];
                  long1[LastExtremumLowBar]=0;
                  LastExtremumLowBar=i;
                 }
               break;
              }
            case 1:
              {
               if (Low[i]<High[LastExtremumHighBar])
                 {
                  long1[i]=Low[i];
                  LastExtremumLowBar=i;
                 }
               break;
              }
            case 0:
              {
               long1[i]=Low[i];
               LastExtremumLowBar=i;
               break;
              }
           }
        }
      //Ищем верхний фрактал
      if (i==Highest(Symbol(),Period(),MODE_HIGH,FractalBarsOnEachSide*2+1,i-FractalBarsOnEachSide) && long1[i]==0)
        {
         switch(LastBarWasHighLow(LastExtremumLowBar,LastExtremumHighBar))
           {
            case 1:
              {
               if (High[i]>High[LastExtremumHighBar])
                 {
                  short1[i]=High[i];
                  short1[LastExtremumHighBar]=0;
                  LastExtremumHighBar=i;
                 }
               break;
              }
            case -1:
              {
               if (High[i]>Low[LastExtremumLowBar])
                 {
                  short1[i]=High[i];
                  LastExtremumHighBar=i;
                 }
               break;
              }
            case 0:
              {
               short1[i]=High[i];
               LastExtremumHighBar=i;
               break;
              }
           }
        }
     }
   //Ищем, где заканчиваются уровни фракталов (двойное пересечение ценой уровня)
   for(i=MathMin(ProceedMaxHistoryBars,Bars-FractalBarsOnEachSide-1);i>=FractalBarsOnEachSide;i--)
     {
      if (long1[i]==Low[i])
        {
         Stop=-1;
         CurrState=0;
         for(j=i-1;j>=0 && Stop==-1;j--)
           {
            if (CurrState==-1)
               if (High[j]>Low[i]+(i-j)*PriceDeltaFor1Bar*Point+PriceCrossedLevel*Point)
                  Stop=j;
            if (CurrState==0)
               if (Low[j]<Low[i]+(i-j)*PriceDeltaFor1Bar*Point-PriceCrossedLevel*Point)
                  CurrState=-1;
           }
         if (Stop!=-1)
            LevelLength[i]=i-Stop;
         else
            LevelLength[i]=i;
        }
      if (short1[i]==High[i])
        {
         Stop=-1;
         CurrState=0;
         for(j=i-1;j>=0 && Stop==-1;j--)
           {
            if (CurrState==1)
               if (Low[j]<High[i]+(i-j)*PriceDeltaFor1Bar*Point-PriceCrossedLevel*Point)
                  Stop=j;
            if (CurrState==0)
               if (High[j]>High[i]+(i-j)*PriceDeltaFor1Bar*Point+PriceCrossedLevel*Point)
                  CurrState=1;
           }
         if (Stop!=-1)
            LevelLength[i]=i-Stop;
         else
            LevelLength[i]=i;
        }
     }
   //Объединяем близкие уровни разных фракталов   
   for(i=MathMin(ProceedMaxHistoryBars,Bars-FractalBarsOnEachSide-1);i>=FractalBarsOnEachSide;i--)
     {
      if (LevelLength[i]>0)
        {
         if (long1[i]!=0)
            iFractalValue=long1[i];
         if (short1[i]!=0)
            iFractalValue=short1[i];
         BarsToCheck=MathMin(LevelActuality,LevelLength[i]);
         j=i-1;
         LevelLength[i]=BarsToCheck;
         while(BarsToCheck>0)
           {
            if (LevelLength[j]>0)
              {
               if (long1[j]!=0)
                  jFractalValue=long1[j];
               if (short1[j]!=0)
                  jFractalValue=short1[j];
               if (MathAbs(iFractalValue+(i-j)*PriceDeltaFor1Bar*Point-jFractalValue)<ExtremumToLevelMaxGap*Point)
                 {
                  BarsToCheck=MathMin(LevelActuality,LevelLength[j]);
                  LevelLength[i]=i-j+BarsToCheck;
                  LevelLength[j]=0;
                  LevelWidth[i]++;
                  if (SnapExtremumsToLevelOnChar==1)
                    {
                     if (long1[j]!=0)
                       {
                        long1[j]=iFractalValue+(i-j)*PriceDeltaFor1Bar*Point;
                       }
                     if (short1[j]!=0)
                       {
                        short1[j]=iFractalValue+(i-j)*PriceDeltaFor1Bar*Point;
                       }
                    }
                 }
              }
            BarsToCheck--;
            j--;
           }
        }
     }
   //Рисуем ломаную
   for(i=MathMin(ProceedMaxHistoryBars,Bars-FractalBarsOnEachSide-1);i>=FractalBarsOnEachSide;i--)
     {
      if (long1[i]!=0 || short1[i]!=0)
        {
         if (LastExtremumBar!=-1)
           {
            if (long1[i]!=0)
              {
               ObjectCreate(StringConcatenate("Trend_",IndicatorNumber,"_",i),OBJ_TREND,0,
                  Time[LastExtremumBar],short1[LastExtremumBar],Time[i],long1[i]);
               ObjectSet(StringConcatenate("Trend_",IndicatorNumber,"_",i),OBJPROP_COLOR,TrendDownColor);
              }
            if (short1[i]!=0)
              {
               ObjectCreate(StringConcatenate("Trend_",IndicatorNumber,"_",i),OBJ_TREND,0,
                  Time[LastExtremumBar],long1[LastExtremumBar],Time[i],short1[i]);
               ObjectSet(StringConcatenate("Trend_",IndicatorNumber,"_",i),OBJPROP_COLOR,TrendUpColor);
              }
            ObjectSet(StringConcatenate("Trend_",IndicatorNumber,"_",i),OBJPROP_RAY,0);
            ObjectSet(StringConcatenate("Trend_",IndicatorNumber,"_",i),OBJPROP_WIDTH,2);
           }
         LastExtremumBar=i;
        }
     }
   //Рисуем уровни
   for(i=MathMin(ProceedMaxHistoryBars,Bars-FractalBarsOnEachSide-1);i>=FractalBarsOnEachSide;i--)
     {
      if (LevelLength[i]!=0)
        {
         if (long1[i]!=0)
            iFractalValue=long1[i];
         if (short1[i]!=0)
            iFractalValue=short1[i];
//----
         ObjectCreate(StringConcatenate("Level_",IndicatorNumber,"_",i),OBJ_TREND,0,
               Time[i],iFractalValue,Time[i-LevelLength[i]],iFractalValue+LevelLength[i]*PriceDeltaFor1Bar*Point);
         if (i!=LevelLength[i])
            ObjectSet(StringConcatenate("Level_",IndicatorNumber,"_",i),OBJPROP_RAY,0);
         ObjectSet(StringConcatenate("Level_",IndicatorNumber,"_",i),OBJPROP_COLOR,LevelColor);
         if (LevelWidth[i]>1)
           {
            ObjectSet(StringConcatenate("Level_",IndicatorNumber,"_",i),OBJPROP_WIDTH,1);
            if (LevelWidth[i]>=Width2LevelConfirmation)
               ObjectSet(StringConcatenate("Level_",IndicatorNumber,"_",i),OBJPROP_WIDTH,2);
            if (LevelWidth[i]>=Width3LevelConfirmation)
               ObjectSet(StringConcatenate("Level_",IndicatorNumber,"_",i),OBJPROP_WIDTH,3);
            if (LevelWidth[i]>=Width4LevelConfirmation)
               ObjectSet(StringConcatenate("Level_",IndicatorNumber,"_",i),OBJPROP_WIDTH,4);
            if (LevelWidth[i]>=Width5LevelConfirmation)
               ObjectSet(StringConcatenate("Level_",IndicatorNumber,"_",i),OBJPROP_WIDTH,5);
           }
         else
           {
            ObjectSet(StringConcatenate("Level_",IndicatorNumber,"_",i),OBJPROP_COLOR,LevelColor);
            ObjectSet(StringConcatenate("Level_",IndicatorNumber,"_",i),OBJPROP_STYLE,STYLE_DOT);
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+