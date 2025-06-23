//+------------------------------------------------------------------+
//|                                                GannSwingsXVI.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Rosh"
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrYellow
#property indicator_color2 clrYellow
#property indicator_color3 clrBlue
#property indicator_color4 clrRed
#property indicator_color5 clrAqua
#property indicator_color6 clrHotPink
//#property indicator_color7 Lime
#define version "XVI"
extern int kind=2;// тип тенденции, 1 - малая, 2 - промежуточная, 3 - основная
extern bool ShowHighLow=true;
extern bool ShowOutSideBars=true;
extern bool MoveLastSwing=false; // если равно true, то кончик хвоста будет сдвигаться ближе к нулевому бару для двух одинаковых баров по High или Low
//---- buffers
double HighSwings[];
double LowSwings[];
double HighsBuffer[];
double LowsBuffer[];
double TrendBuffer[];
double UpCloseOutSideBuffers[];
double DownCloseOutSideBuffers[];
double Needles[];
double SwingHigh,SwingLow;
int prevSwing,LastSwing,myBars,lowCounter,highCounter,cnt;
int ahtung;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
//---
   SetIndexStyle(0,DRAW_ZIGZAG);
   SetIndexBuffer(0,HighSwings);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,"HighSwing");
//---
   SetIndexStyle(1,DRAW_ZIGZAG);
   SetIndexBuffer(1,LowSwings);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,"LowSwing");
//---
   SetIndexBuffer(2,HighsBuffer);
   SetIndexLabel(2,"HighActive");
   SetIndexEmptyValue(2,0.0);
//---
   SetIndexBuffer(3,LowsBuffer);
   SetIndexLabel(3,"LowActive");
   SetIndexEmptyValue(3,0.0);
//---
   if(ShowHighLow)
     {
      SetIndexStyle(2,DRAW_ARROW);
      SetIndexArrow(2,159);
      SetIndexStyle(3,DRAW_ARROW);
      SetIndexArrow(3,159);
     }
   else
     {
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
     }
//---
   SetIndexBuffer(4,UpCloseOutSideBuffers);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,108);
   SetIndexLabel(4,"UpClose");
   SetIndexEmptyValue(4,0.0);
//---
   SetIndexBuffer(5,DownCloseOutSideBuffers);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,108);
   SetIndexLabel(5,"DownClose");
   SetIndexEmptyValue(5,0.0);
//---
   SetIndexBuffer(6,Needles);
//SetIndexStyle(6,DRAW_NONE);
   SetIndexEmptyValue(6,0.0);
//   SetIndexStyle(6,DRAW_ARROW);
//   SetIndexArrow(6,108);
//---
   SetIndexBuffer(7,TrendBuffer);
   SetIndexEmptyValue(7,0.0);
//----
   ArrayInitialize(HighSwings,EMPTY_VALUE);
   ArrayInitialize(LowSwings,EMPTY_VALUE);
   ArrayInitialize(HighsBuffer,EMPTY_VALUE);
   ArrayInitialize(LowsBuffer,EMPTY_VALUE);
   ArrayInitialize(TrendBuffer,EMPTY_VALUE);
   ArrayInitialize(UpCloseOutSideBuffers,EMPTY_VALUE);
   ArrayInitialize(DownCloseOutSideBuffers,EMPTY_VALUE);
   //---
   SwingHigh=0.0;
   SwingLow=0.0;
   prevSwing=0;
   LastSwing=0.0;
   myBars=0;
   lowCounter=0;
   highCounter=0;
   Comment("\n","GannSwings ",version," kind=",kind);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   Comment("\n","\n","            ");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void DownTrendOutSide()
  {
//---- 
//-1
   if(Close[cnt]<=Open[cnt] && lowCounter==1)
     {
      SwingHigh=High[cnt];
      SwingLow=Low[cnt];
      HighSwings[cnt]=High[cnt];
      LowSwings[cnt]=Low[cnt];
      highCounter=0;
      lowCounter=0;
      LastSwing=cnt;
      Needles[cnt]=1.0;
      ahtung=0.0;
      return;
     }
//-2
   if(Close[cnt]>Open[cnt] && lowCounter==1)
     {
      LowSwings[LastSwing]=0.0;
      SwingLow=Low[cnt];
      SwingHigh=High[cnt];
      HighSwings[cnt]=High[cnt];
      LowSwings[cnt]=Low[cnt];
      highCounter=0;
      LastSwing=cnt;
      if(kind>1)
        {
         Needles[cnt]=1.0;
         lowCounter=1;
         ahtung=-1; // ждем еще одного Low для продолжения вниз
         TrendBuffer[cnt]=1.0;
        }
      else
        {
         lowCounter=0;
         TrendBuffer[cnt]=1.0;
         ahtung=0.0;
        }
      return;
      //Print("breakout даунтренд через внешний бар");
     }
//-3
   if(Close[cnt]<=Open[cnt] && highCounter==kind)
     {
      SwingLow=Low[cnt];
      SwingHigh=High[cnt];
      LowSwings[cnt]=Low[cnt];
      HighSwings[cnt]=High[cnt];
      highCounter=0;
      lowCounter=0;
      LastSwing=cnt;
      Needles[cnt]=1.0;
      TrendBuffer[cnt]=1.0;
      ahtung=0.0;
      return;
      //Print("breakout даунтренд через внешний бар");
     }
//-4
   if(Close[cnt]>Open[cnt] && highCounter==kind)
     {
      Print("Этот блок №-4 не должен работать");
      SwingLow=Low[cnt];
      SwingHigh=High[cnt];
      if(Low[cnt]<LowSwings[LastSwing])
        {
         LowSwings[LastSwing]=0.0;
         LowSwings[cnt]=Low[cnt];
        }
      HighSwings[cnt]=High[cnt];
      highCounter=0;
      lowCounter=0;
      LastSwing=cnt;
      //Print("Разворот даунтренда через внешний бар");
      TrendBuffer[cnt]=1.0;
      Needles[cnt]=1.0;
      ahtung=0.0;
      return;
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void UpTrendOutSide()
  {
//---- 
//+1
   if(Close[cnt]>=Open[cnt] && highCounter==1)
     {
      SwingLow=Low[cnt];
      SwingHigh=High[cnt];
      LowSwings[cnt]=Low[cnt];
      HighSwings[cnt]=High[cnt];
      highCounter=0;
      lowCounter=0;
      LastSwing=cnt;
      Needles[cnt]=1.0;
      ahtung=0.0;
      //Print("Продолжение аптренд через внешний бар");
      return;
     }
//+2
   if(Close[cnt]<Open[cnt] && highCounter==1)
     {
      HighSwings[LastSwing]=0.0;
      SwingLow=Low[cnt];
      SwingHigh=High[cnt];
      LowSwings[cnt]=Low[cnt];
      HighSwings[cnt]=High[cnt];
      lowCounter=0;
      LastSwing=cnt;
      if(kind>1)
        {
         Needles[cnt]=1.0;
         highCounter=1;
         ahtung=1; // ждем еще одного High для продолжения вверх
         TrendBuffer[cnt]=-1.0;
        }
      else
        {
         highCounter=0;
         TrendBuffer[cnt]=-1.0;
         ahtung=0.0;
        }
      //Print("breakout аптренд через внешний бар");
      return;
     }
//+3
   if(Close[cnt]>=Open[cnt] && lowCounter==kind)
     {
      SwingLow=Low[cnt];
      SwingHigh=High[cnt];
      LowSwings[cnt]=Low[cnt];
      HighSwings[cnt]=High[cnt];
      highCounter=0;
      lowCounter=0;
      LastSwing=cnt;
      //TrendBuffer[cnt]=-1.0;
      Needles[cnt]=1.0;
      ahtung=0.0;
      //Print("breakout аптренд через внешний бар");
      return;
     }
//+4
   if(Close[cnt]<Open[cnt] && lowCounter==kind)
     {
      Print("Этот блок №+4 не должен работать");
      SwingLow=Low[cnt];
      SwingHigh=High[cnt];
      if(High[cnt]>HighSwings[LastSwing])
        {
         HighSwings[LastSwing]=0.0;
         HighSwings[cnt]=High[cnt];
        }
      LowSwings[cnt]=Low[cnt];
      highCounter=0;
      lowCounter=0;
      LastSwing=cnt;
      //Print("Разворот аптренда через внешний бар");
      TrendBuffer[cnt]=-1.0;
      ahtung=0.0;
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| OutSidePart function                                             |
//+------------------------------------------------------------------+
void OutSidePart()
  {
//---- 
   if(TrendBuffer[cnt+1]==1.0)
     {
      UpTrendOutSide();
     }//TrendBuffer[cnt+1]==1.0;
   else
     {// TrendBuffer[cnt+1]==-1.0
      DownTrendOutSide();
     }//TrendBuffer[cnt+1]==-1.0
//----
   return;
  }
//+------------------------------------------------------------------+
//| nonOutSidePart() function                                        |
//+------------------------------------------------------------------+
void nonOutSidePart()
  {
//---- 
   if(TrendBuffer[cnt+1]==-1.0)
     {
      if(lowCounter==1)
        {
         if(LastSwing!=Bars-1) LowSwings[LastSwing]=0.0; // затрем предыдущий свинг
                                                         //Print("затрем предыдущий Down свинг");
         LastSwing=cnt;
         //Neeldles[cnt]=1.0;
         SwingHigh=High[cnt];
         SwingLow=Low[cnt];
         //TrendBuffer[cnt]=-1.0;
         highCounter=0;
         lowCounter=0;
         LowSwings[cnt]=Low[cnt];
         HighsBuffer[cnt]=SwingHigh;
         ahtung=0.0;
         //Print("продолжение даунтренда");
        }
      else
        {
         if(highCounter==kind)
           {
            //if (LastSwing=!cnt) 
            if(ahtung==1) CutLastNeedle(cnt);
            LastSwing=cnt;
            SwingHigh=High[cnt];
            SwingLow=Low[cnt];
            TrendBuffer[cnt]=1.0;
            highCounter=0;
            lowCounter=0;
            HighSwings[cnt]=High[cnt];
            LowsBuffer[cnt]=SwingLow;
            ahtung=0.0;
            //Neeldles[cnt]=1.0;            
            //Print("разворот даунтренда");
           }
         else
           {
            if(Low[cnt]==SwingLow && MoveLastSwing)
              {
               LowSwings[LastSwing]=0.0;
               LastSwing=cnt;
               LowSwings[cnt]=Low[cnt];
               //                     continue;
              }
           }
        }
     }//   TrendBuffer[cnt+1]==-1.0
   else     //   TrendBuffer[cnt+1]==1.0          
     {
      if(highCounter==1)
        {
         if(LastSwing!=Bars-1) HighSwings[LastSwing]=0.0; // затрем предыдущий свинг
         LastSwing=cnt;
         //Neeldles[cnt]=1.0;
         SwingHigh=High[cnt];
         SwingLow=Low[cnt];
         highCounter=0;
         lowCounter=0;
         HighSwings[cnt]=High[cnt];
         HighsBuffer[cnt]=SwingHigh;
         LowsBuffer[cnt]=SwingLow;
         ahtung=0.0;
         //Print("продолжение аптренда");
        }
      else
        {
         if(lowCounter==kind)
           {
            if(ahtung==-1) CutLastNeedle(cnt);
            LastSwing=cnt;
            SwingHigh=High[cnt];
            SwingLow=Low[cnt];
            TrendBuffer[cnt]=-1.0;
            highCounter=0;
            lowCounter=0;
            LowSwings[cnt]=Low[cnt];
            HighsBuffer[cnt]=SwingHigh;
            LowsBuffer[cnt]=SwingLow;
            ahtung=0.0;
            //Neeldles[cnt]=1.0;
            //Print("разворот аптренда");
           }
         else
           {
            if(High[cnt]==SwingHigh && MoveLastSwing)
              {
               HighSwings[LastSwing]=0.0;
               LastSwing=cnt;
               HighSwings[cnt]=High[cnt];
              }
           }
        }
     } //TrendBuffer[cnt+1]==1.0           
//----
   return;
  }
//+------------------------------------------------------------------+
//| return shift of last swing                                       |
//+------------------------------------------------------------------+
int GetLastSwing()
  {
//---- 
   int point=1;
   while(HighSwings[point]==0.0 && Needles[point]==0.0 && point<Bars) point++;
//----
   return(point);
  }
//+------------------------------------------------------------------+
//| setting NULL values to last Needle                               |
//+------------------------------------------------------------------+
void CutLastNeedle(int shift)
  {
   while(Needles[shift]==0.0) shift++;
   HighSwings[shift]=0.0;
   LowSwings[shift]=0.0;
  }
//+------------------------------------------------------------------+
//| Check prev swing                                                 |
//+------------------------------------------------------------------+
void SetPrevSwing()
  {
//---- 
   int LastPoint;
   LastPoint=GetLastSwing();
   HighSwings[0]=0.0;
   SwingHigh=High[LastPoint];
   SwingLow=Low[LastPoint];
   LastSwing=LastPoint;
//----
   return;
  }
//+------------------------------------------------------------------+
//| check Out side bar                                               |
//+------------------------------------------------------------------+
bool isOutSideSwingBar(int shift)
  {
   bool res=false;
//---- 
   res=((High[shift]>SwingHigh) && (Low[shift]<SwingLow));
   if(res && ShowOutSideBars)
     {
      if(Close[shift]>Open[shift]) UpCloseOutSideBuffers[shift]=(High[shift]+Low[shift])/2.0;
      else DownCloseOutSideBuffers[shift]=(High[shift]+Low[shift])/2.0;
     }
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Check new low                                                    |
//+------------------------------------------------------------------+
void SetSwings(int shift)
  {
//---- 
//----
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int limit;
   bool nonOutSide;
   if(counted_bars==0)
     {
      limit=Bars-1;
      LowsBuffer[limit]=Low[limit];
      LowSwings[limit]=Low[limit];
      SwingHigh=High[limit];
      SwingLow=Low[limit];
      LastSwing=limit;
      TrendBuffer[limit]=-1.0;
      Needles[limit]=1.0; // зафиксируем первый узел свинга
     }
   if(counted_bars>0) limit=Bars-counted_bars;
   if((counted_bars<0) || ((counted_bars>0) && (Bars-myBars>1)))
      init();
   limit--;
//---- 
   for(cnt=limit;cnt>0;cnt--)
     {
      //if (cnt==0) SetPrevSwing();
      nonOutSide=!isOutSideSwingBar(cnt);
      //----
      if(High[cnt]>SwingHigh) {highCounter++;SwingHigh=High[cnt];HighsBuffer[cnt]=SwingHigh;}
      if(Low[cnt]<SwingLow) {lowCounter++;SwingLow=Low[cnt];LowsBuffer[cnt]=SwingLow;}
      //----
      TrendBuffer[cnt]=TrendBuffer[cnt+1];// если не будут изменений - тренд сохранится
      if(nonOutSide)
        {
         nonOutSidePart(); // тут мы работаем с обычными барами          
        }// if (nonOutSide)         
      else // outSideBars
        {
         OutSidePart();
        }// isOutSideSwingBar(cnt)          
     } // КОНЕЦ ЦИКЛА
   myBars=Bars;
//----
   return(0);
  }
//+------------------------------------------------------------------+
