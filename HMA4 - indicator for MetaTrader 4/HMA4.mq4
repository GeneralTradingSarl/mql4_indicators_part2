//+------------------------------------------------------------------+
//|                                                       HMA4.mq4   |
//|                  Copyright © 2004-08, MetaQuotes Software Corp.  |
//|                                      http://www.metaquotes.net   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004-08, MetaQuotes Software Corp."
#property link "http://www.metaquotes.net/"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Aqua
#property indicator_width1 1
#property indicator_color2 Yellow
#property indicator_width2 1
#property indicator_color3 Magenta
#property indicator_width3 1
//---- indicator parameters
extern string note1="Hull Moving Average Period";
extern int HMA_Period=7;
extern int MA_Shift=0;
extern string note2="0=Simple,1=Exponential";
extern string note3="2=Smooth,3=Linear Weighted";
extern int MA_Method=3;
extern string note4="0=High/Low,1=Close/Close";
extern int MA_Price=6;
extern string note5="--------------------------------------------";
extern string note6="Filter # default = 2.0";
extern double FilterNumber=2.0;
extern string note7="Draw Dots = true";
extern string note8="Draw Lines = false";
extern bool DrawDots=false;
extern string note9="--------------------------------------------";
//----
int aTake_Profit=48;
int aStop_Loss=38;
//extern string note10 = "--------------------------------------------";
extern string note11="turn on HMA Pop-up Alert = true";
extern string note12="turn off = false";
extern bool aAlerts=true;
extern string note13="--------------------------------------------";
extern string note14="send HMA Email Alert = true";
extern string note15="turn off = false";
//----
extern bool EmailOn=false;
extern bool aTurnedUp=false;
extern bool aTurnedDown=false;
//---- indicator buffers
double ind_buffer0[];
double ind_buffer1[];
double ind_buffer2[];
double buffer[];
//----
int draw_begin0;
string AlertPrefix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrameStr()
  {
   switch(Period())
     {
      case 1 : string TimeFrameStr="M1"; break;
      case 5 : TimeFrameStr="M5"; break;
      case 15 : TimeFrameStr="M15"; break;
      case 30 : TimeFrameStr="M30"; break;
      case 60 : TimeFrameStr="H1"; break;
      case 240 : TimeFrameStr="H4"; break;
      case 1440 : TimeFrameStr="D1"; break;
      case 10080 : TimeFrameStr="W1"; break;
      case 43200 : TimeFrameStr="MN1"; break;
      default : TimeFrameStr=Period();
     }
   return(TimeFrameStr);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping
   IndicatorBuffers(4);
   SetIndexBuffer(0,ind_buffer0);
   SetIndexBuffer(1,ind_buffer1);
   SetIndexBuffer(2,ind_buffer2);
   SetIndexBuffer(3,buffer);
   Print("cannot set indicator buffers!");
// ArraySetAsSeries(ind_buffer1,true);
//---- drawing settings
   if(DrawDots)
     {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexStyle(2,DRAW_ARROW);
      SetIndexArrow(0,159);
      SetIndexArrow(1,159);
      SetIndexArrow(2,159);
     }
   else
     {
      SetIndexStyle(0,DRAW_LINE);
      SetIndexStyle(1,DRAW_LINE);
      SetIndexStyle(2,DRAW_LINE);
     }
   draw_begin0=HMA_Period+MathFloor(MathSqrt(HMA_Period));
   SetIndexDrawBegin(0,draw_begin0);
   SetIndexDrawBegin(1,draw_begin0);
   SetIndexDrawBegin(2,draw_begin0);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("HMA("+HMA_Period+")");
   SetIndexLabel(0,"Hull Moving Average");
//---- initialization done
   AlertPrefix=Symbol()+" ("+GetTimeFrameStr()+"):  ";
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit,i;
//---- check for possible errors
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit--;

   double tmp,tmpPrevious;

//---- MA difference counted in the 1-st buffer
   for(i=0; i<limit; i++)
     {
      buffer[i]=iMA(NULL,0,MathFloor
                    (HMA_Period/FilterNumber),MA_Shift,MA_Method,MA_Price,i)*2-//change the HMA_Period/xx will change when the colors chang at given rate
                    iMA(NULL,0,HMA_Period,MA_Shift,MA_Method,MA_Price,i);
     }
//---- HMA counted in the 0-th buffer
   tmp=iMAOnArray(buffer,0,MathFloor(MathSqrt(HMA_Period)),0,MA_Method,0);
   for(i=1; i<limit; i++)
     {
      tmpPrevious=iMAOnArray(buffer,0,MathFloor(MathSqrt(HMA_Period)),0,MA_Method,i);
      if(tmpPrevious>tmp)
        {
         ind_buffer0[i]=EMPTY_VALUE;
         ind_buffer1[i]=EMPTY_VALUE;
         ind_buffer2[i]=tmpPrevious;
         ind_buffer2[i-1]=tmp; // !
        }
      else if(tmpPrevious<tmp)
        {
         ind_buffer0[i]=tmpPrevious;
         ind_buffer0[i-1]=tmp; // !
         ind_buffer1[i]=EMPTY_VALUE;
         ind_buffer2[i]=EMPTY_VALUE;
        }
      else
        {
         ind_buffer0[i]=CLR_NONE;
         ind_buffer1[i]=tmpPrevious;
         ind_buffer2[i-1]=tmp; // !
         ind_buffer2[i]=CLR_NONE;
        }
      if(aAlerts)
        {
         if(tmpPrevious<tmp) //change the wt[?] number will change when the signal will trigger based on # of last bars
           {
            if(!aTurnedUp)
              {
               if(BarChanged())
                 {
                  Alert(AlertPrefix+"HMA "+(aRperiodf())+" Alert\nBUY signal @ Ask = $",Ask,"; Bid = $",Bid,"\nDate & Time = ",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime()));
                  PlaySound("alert.wav");
                  if(EmailOn)
                    {
                     SendMail(AlertPrefix,"HMA Alert\nBUY signal @ Ask = $"+DoubleToStr(Ask,4)+", Bid = $"+DoubleToStr(Bid,4)+", Date & Time = "+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime())+"  Stop:  "+DoubleToStr(aGetSLl(),4)+"  Limit:  "+DoubleToStr(aGetTPl(),4));
                    }
                 }
               aTurnedUp=true;
               aTurnedDown=false;
              }
           }
         if(tmpPrevious>tmp) //change the wt[?] number will change when the signal will trigger based on # of last bars
           {
            if(!aTurnedDown)
              {
               if(BarChanged())
                 {
                  Alert(AlertPrefix+"HMA Alert\nSELL signal @ Ask = $",Ask,"; Bid = $",Bid,"\nDate & Time = ",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime()));
                  PlaySound("alert.wav");
                  if(EmailOn)
                    {
                     SendMail(AlertPrefix,"HMA Alert\nSELL signal @ Ask = $"+DoubleToStr(Ask,4)+", Bid = $"+DoubleToStr(Bid,4)+", Date & Time = "+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime())+"  Stop:  "+DoubleToStr(aGetSLs(),4)
                              +"  Limit:  "+DoubleToStr(aGetTPs(),4));
                    }
                 }
               aTurnedDown=true;
               aTurnedUp=false;
              }
           }
        }
      tmp=tmpPrevious;
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BarChanged()
  {
   static datetime dt=0;
   if(dt!=Time[0])
     {
      dt=Time[0];
      return(true);
     }
   return(false);
  }
//---- done
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double aGetTPs() { return(Bid-aTake_Profit*Point); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double aGetTPl() { return(Ask+aTake_Profit*Point); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double aGetSLs() { return(Bid+aStop_Loss*Point); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double aGetSLl() { return(Ask-aStop_Loss*Point); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int aRperiodf() { return(HMA_Period*Point*10000); }
//+------------------------------------------------------------------+
