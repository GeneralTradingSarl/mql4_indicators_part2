//+------------------------------------------------------------------+
//|                                  MA_Cross_3MACross_AlertWarnSig  |
//|                                             2008forextsd mladen  |
//|                 Copyright © 1999-2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//----
#property indicator_chart_window
#property indicator_buffers 4
//----
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_color4 Gold
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
//----
extern int FasterMA   =5;
extern int FasterMode =1; // 0 = sma, 1 = ema, 2 = smma, 3 = lwma
extern int MediumMA    =13;
extern int MediumMode =1; // 0 = sma, 1 = ema, 2 = smma, 3 = lwma
extern int SlowerMA    =34;
extern int SlowerMode =1; // 0 = sma, 1 = ema, 2 = smma, 3 = lwma
extern bool crossesOnCurrent=true;
extern bool alertsOn        =true;
extern bool alertsMessage   =true;
extern bool alertsSound     =false;
extern bool alertsEmail     =false;
extern string   MA_Shift ="all MA_Shift = 0";
extern string   MA_Mode="SMA0 EMA1 SMMA2 LWMA3";
//----
double CrossUp[];
double CrossDown[];
double CrossWUp[];
double CrossWDown[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0, CrossUp);    SetIndexStyle(0, DRAW_ARROW); SetIndexArrow(0, 233);
   SetIndexBuffer(1, CrossDown);  SetIndexStyle(1, DRAW_ARROW); SetIndexArrow(1, 234);
   SetIndexBuffer(2, CrossWUp);   SetIndexStyle(2, DRAW_ARROW); SetIndexArrow(2, 233);
   SetIndexBuffer(3, CrossWDown); SetIndexStyle(3, DRAW_ARROW); SetIndexArrow(3, 234);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   int    i;
   double fasterMAnow, fasterMAprevious, fasterMAafter;
   double mediumMAnow, mediumMAprevious, mediumMAafter;
   double slowerMAnow, slowerMAprevious, slowerMAafter;
//----
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+9;
//----
   for(i=limit; i >=0; i--)
     {
      double Range=0.0;
      for(int counter=i ;counter<=i+9;counter++) Range+=MathAbs(High[counter]-Low[counter]);
      Range/=10;
//----
      fasterMAnow     =iMA(NULL, 0, FasterMA, 0,FasterMode, PRICE_CLOSE, i);
      fasterMAprevious=iMA(NULL, 0, FasterMA, 0,FasterMode, PRICE_CLOSE, i+1);
      mediumMAnow     =iMA(NULL, 0, MediumMA, 0,MediumMode, PRICE_CLOSE, i);
      mediumMAprevious=iMA(NULL, 0, MediumMA, 0,MediumMode, PRICE_CLOSE, i+1);
      slowerMAnow     =iMA(NULL, 0, SlowerMA, 0,SlowerMode, PRICE_CLOSE, i);
      slowerMAprevious=iMA(NULL, 0, SlowerMA, 0,SlowerMode, PRICE_CLOSE, i+1);
      //avoid current bar if not allowed to check crosses on current (i==0)
      if (crossesOnCurrent==false && i==0) continue;
//----
      int    crossID=0;
      double curr;
      double prev;
      double point;
      while(true)
        {
         curr=fasterMAnow      - mediumMAnow;
         prev=fasterMAprevious - mediumMAprevious;
         point=(fasterMAnow      + fasterMAprevious)/2;
         if (curr*prev<=0) { crossID=1; break; }
         curr=fasterMAnow      - slowerMAnow;
         prev=fasterMAprevious - slowerMAprevious;
         if (curr*prev<=0) { crossID=2; break; }
         curr=mediumMAnow      - slowerMAnow;
         prev=mediumMAprevious - slowerMAprevious;
         point=(mediumMAnow      + mediumMAprevious)/2;
         if (curr*prev<=0) { crossID=3; break; }
         break;
        }
      //    the interesting thing is the direction of the crossing
      //    which MA is the primary and which one the secondary
      //    if you do not know that you can not determine the "direction"
      //    of the cross
      CrossUp[i]   =EMPTY_VALUE;
      CrossDown[i] =EMPTY_VALUE;
      CrossWUp[i]  =EMPTY_VALUE;
      CrossWDown[i]=EMPTY_VALUE;
      if (crossID>0)
        {
         if (alertsOn)
            if ((i==0 && crossesOnCurrent==true) || (i==1 && crossesOnCurrent==false))
              {
               switch(crossID)
                 {
                  case 1:
                     if(curr>0) doAlert(" 3MACross: Fast MA crossed Medium MA UP");
                     else       doAlert(" 3MACross: Fast MA crossed Medium MA DOWN");
                     break;
                  case 2:
                     if(curr>0) doAlert(" 3MACross: Fast MA crossed Slow MA UP");
                     else       doAlert(" 3MACross: Fast MA crossed Slow MA DOWN");
                     break;
                  case 3:
                     if(curr>0) doAlert(" 3MACross: Medium MA crossed Slow MA UP");
                     else       doAlert(" 3MACross: Medium MA crossed Slow MA DOWN");
                     break;
                 }
              }
         //----
         if (i==0)
           {
            if (curr>0)
               CrossWUp[i]  =point - Range*0.5;
            else  CrossWDown[i]=point + Range*0.5;
           }
         else
           {
            if (curr>0)
               CrossUp[i]  =point - Range*0.5;
            else  CrossDown[i]=point + Range*0.5;
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(string doWhat)
  {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
//----
     if (previousAlert!=doWhat || previousTime!=Time[0]) 
     {
      previousAlert =doWhat;
      previousTime  =Time[0];
      //        if time needed :
      //        message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," @",Bid," ", doWhat);
      message= StringConcatenate(Symbol()," at ",Bid," ", doWhat);
      if (alertsMessage) Alert(message);
      if (alertsEmail)   SendMail(StringConcatenate(Symbol()," 3MACross:"," M",Period()),message);
      if (alertsSound)   PlaySound("alert2.wav");
     }
  }
//+------------------------------------------------------------------+