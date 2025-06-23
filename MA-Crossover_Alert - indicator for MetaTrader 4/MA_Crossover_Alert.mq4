//+------------------------------------------------------------------+
//|                                           MA-Crossover_Alert.mq4 |
//|         Copyright © 2005, Jason Robinson (jnrtrading)            |
//|                   http://www.jnrtading.co.uk                     |
//| Modified by Robert Hill to add LSMA and alert or send email      |
//| Added Global LastAlert to try to have alert only on new cross    |
//| but does not seem to work. So indicator does alert every bar     |
//+------------------------------------------------------------------+
/*
  +------------------------------------------------------------------+
  | Allows you to enter two ma periods and it will then show you at  |
  | Which point they crossed over. It is more usful on the shorter   |
  | periods that get obscured by the bars / candlesticks and when    |
  | the zoom level is out. Also allows you then to remove the  mas   |
  | from the chart. (emas are initially set at 5 and 6)              |
  +------------------------------------------------------------------+
*/
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)"
#property link      "http://www.jnrtrading.co.uk"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LawnGreen
#property indicator_color2 Red
//----
extern bool SoundON=true;
extern bool EmailON=false;
//----
extern int FastMA_Mode=1; //0=sma, 1=ema, 2=smma, 3=lwma, 4=lsma
extern int FastMA_Period=  5;
extern int FastPriceMode=0;//0=close, 1=open, 2=high, 3=low, 4=median(high+low)/2, 5=typical(high+low+close)/3, 6=weighted(high+low+close+close)/4
extern int SlowMA_Mode=1; //0=sma, 1=ema, 2=smma, 3=lwma, 4=lsma
extern int SlowMA_Period=  6;
extern int SlowPriceMode=0;//0=close, 1=open, 2=high, 3=low, 4=median(high+low)/2, 5=typical(high+low+close)/3, 6=weighted(high+low+close+close)/4
double CrossUp[];
double CrossDown[];
int flagval1=0;
int flagval2=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW,EMPTY,3);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,CrossUp);
   SetIndexStyle(1,DRAW_ARROW,EMPTY,3);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,CrossDown);
   GlobalVariableSet("AlertTime"+Symbol()+Period(),CurTime());
   GlobalVariableSet("SignalType"+Symbol()+Period(),OP_SELLSTOP);
//   GlobalVariableSet("LastAlert"+Symbol()+Period(),0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   GlobalVariableDel("AlertTime"+Symbol()+Period());
   GlobalVariableDel("SignalType"+Symbol()+Period());
//   GlobalVariableDel("LastAlert"+Symbol()+Period());
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| LSMA with PriceMode                                              |
//| PrMode  0=close, 1=open, 2=high, 3=low, 4=median(high+low)/2,    |
//| 5=typical(high+low+close)/3, 6=weighted(high+low+close+close)/4  |
//+------------------------------------------------------------------+
double LSMA(int Rperiod,int prMode,int shift)
  {
   int i;
   double sum,pr;
   int length;
   double lengthvar;
   double tmp;
   double wt;
//----
   length=Rperiod;
//----
   sum=0;
   for(i=length; i>=1;i--)
     {
      lengthvar=length+1;
      lengthvar/=3;
      tmp=0;
      switch(prMode)
        {
         case 0: pr=Close[length-i+shift];break;
         case 1: pr=Open[length-i+shift];break;
         case 2: pr=High[length-i+shift];break;
         case 3: pr=Low[length-i+shift];break;
         case 4: pr=(High[length-i+shift] + Low[length-i+shift])/2;break;
         case 5: pr=(High[length-i+shift] + Low[length-i+shift] + Close[length-i+shift])/3;break;
         case 6: pr=(High[length-i+shift] + Low[length-i+shift] + Close[length-i+shift] + Close[length-i+shift])/4;break;
        }
      tmp =(i - lengthvar)*pr;
      sum+=tmp;
     }
   wt=sum*6/(length*(length+1));
//----
   return(wt);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,counter;
   double tmp=0;
   double fastMAnow,slowMAnow,fastMAprevious,slowMAprevious;
   double Range,AvgRange;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+9;
//----
   for(i=0; i<=limit; i++)
     {
      counter=i;
      Range=0;
      AvgRange=0;
      for(counter=i;counter<=i+9;counter++)
        {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
        }
      Range=AvgRange/10;
      //----
      if(FastMA_Mode==4)
        {
         fastMAnow=LSMA(FastMA_Period,FastPriceMode,i);
         fastMAprevious=LSMA(FastMA_Period,FastPriceMode,i+1);
        }
      else
        {
         fastMAnow=iMA(NULL,0,FastMA_Period,0,FastMA_Mode,FastPriceMode,i);
         fastMAprevious=iMA(NULL,0,FastMA_Period,0,FastMA_Mode,FastPriceMode,i+1);
        }
      if(SlowMA_Mode==4)
        {
         slowMAnow=LSMA(SlowMA_Period,SlowPriceMode,i);
         slowMAprevious=LSMA(SlowMA_Period,SlowPriceMode,i+1);
        }
      else
        {
         slowMAnow=iMA(NULL,0,SlowMA_Period,0,SlowMA_Mode,SlowPriceMode,i);
         slowMAprevious=iMA(NULL,0,SlowMA_Period,0,SlowMA_Mode,SlowPriceMode,i+1);
        }
      if((fastMAnow>slowMAnow) && (fastMAprevious<slowMAprevious))
        {
         if(i==1 && flagval1==0){  flagval1=1; flagval2=0; }
         CrossUp[i]=Low[i]-Range*0.75;
        }
      else if((fastMAnow<slowMAnow) && (fastMAprevious>slowMAprevious))
        {
         if(i==1 && flagval2==0) { flagval2=1; flagval1=0; }
         CrossDown[i]=High[i]+Range*0.75;
        }
     }
   if(flagval1==1 && CurTime()>GlobalVariableGet("AlertTime"+Symbol()+Period()) && GlobalVariableGet("SignalType"+Symbol()+Period())!=OP_BUY)
     {
      //      if (GlobalVariableGet("LastAlert"+Symbol()+Period()) < 0.5)
      //      {
      if(SoundON) Alert("BUY signal at Ask=",Ask,"\n Bid=",Bid,"\n Time=",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime()),"\n Symbol=",Symbol()," Period=",Period());
      if(EmailON) SendMail("BUY signal alert","BUY signal at Ask="+DoubleToStr(Ask,4)+", Bid="+DoubleToStr(Bid,4)+", Date="+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime())+" Symbol="+Symbol()+" Period="+Period());
      //      }
      tmp=CurTime()+(Period()-MathMod(Minute(),Period()))*60;
      GlobalVariableSet("AlertTime"+Symbol()+Period(),tmp);
      GlobalVariableSet("SignalType"+Symbol()+Period(),OP_SELL);
      //      GlobalVariableSet("LastAlert"+Symbol()+Period(),1);
     }
   if(flagval2==1 && CurTime()>GlobalVariableGet("AlertTime"+Symbol()+Period()) && GlobalVariableGet("SignalType"+Symbol()+Period())!=OP_SELL) 
     {
      //      if (GlobalVariableGet("LastAlert"+Symbol()+Period()) > -0.5)
      //      {
      if(SoundON) Alert("SELL signal at Ask=",Ask,"\n Bid=",Bid,"\n Date=",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime()),"\n Symbol=",Symbol()," Period=",Period());
      if(EmailON) SendMail("SELL signal alert","SELL signal at Ask="+DoubleToStr(Ask,4)+", Bid="+DoubleToStr(Bid,4)+", Date="+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime())+" Symbol="+Symbol()+" Period="+Period());
      //      }
      tmp=CurTime()+(Period()-MathMod(Minute(),Period()))*60;
      GlobalVariableSet("AlertTime"+Symbol()+Period(),tmp);
      GlobalVariableSet("SignalType"+Symbol()+Period(),OP_BUY);
      //      GlobalVariableSet("LastAlert"+Symbol()+Period(),-1);
     }
   return(0);
  }
//+------------------------------------------------------------------+
