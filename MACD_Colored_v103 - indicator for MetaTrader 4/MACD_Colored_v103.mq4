//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2007, Herb Spirit, Inc."
#property  link      "http://www.herbspirit.com/mql"
//----
#define INDICATOR_NAME      "MACD_Colored"
#define INDICATOR_VERSION   "v103" // this version implements various signals and alerts
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Lime
#property  indicator_color2  Red
#property  indicator_color3  Silver
#property  indicator_style3  STYLE_DOT
#property  indicator_level1  45
#property  indicator_level2  30
#property  indicator_level3  15
#property  indicator_level4  -15
#property  indicator_level5  -30
#property  indicator_level6  -45
#property  indicator_levelcolor  Gray
#property  indicator_levelstyle  STYLE_DOT
//---- indicator parameters
extern string Alert_On="ANY";
extern bool EMail_Alert=true;
extern int Max_Alerts=3;
extern int Alert_Before_Minutes=15;
extern int Alert_Every_Minutes=5;
extern bool ShowSignal=true;
int FastEMA=5;
int SlowEMA=13;
extern int FontSize=8;
extern color FontColor=Silver;
//---- indicator buffers
double     MacdBuffer[];
double     MacdBufferUp[];
double     MacdBufferDn[];
double     SignalBuffer[];
//----
string shortname;
datetime alertbartime,nextalerttime;
int alertcount;
string alerttype[]={"RT","RB","VT","VB","TC","ZB"};
int minlevel[]={5,10,15,-5,-10,-15};
int hourlevel[]={45,30,15,-15,-30,-45};
int daylevel[]={90,60,30,-30,-60,-90};
datetime nextbartime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_LINE);
   switch(Period())
     {
      case PERIOD_M1:
      case PERIOD_M5:
      case PERIOD_M15:
      case PERIOD_M30:
         for(int i=0;i<ArraySize(minlevel);i++)
         SetLevelValue(i,minlevel[i]);
         break;
      case PERIOD_H1:
      case PERIOD_H4:
         for(i=0;i<ArraySize(hourlevel);i++)
         SetLevelValue(i,hourlevel[i]);
         break;
      default:
         for(i=0;i<ArraySize(daylevel);i++)
         SetLevelValue(i,daylevel[i]);
     }
   SetIndexDrawBegin(1,SlowEMA);
   IndicatorDigits(1);
//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBufferUp);
   SetIndexBuffer(1,MacdBufferDn);
   SetIndexBuffer(2,SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   shortname=WindowExpertName();
   IndicatorShortName(shortname);
   SetIndexLabel(0,"MACD Up");
   SetIndexLabel(1,"MACD Down");
   SetIndexLabel(2,"Signal");
   ArrayResize(MacdBuffer,Bars-SlowEMA);
   ArraySetAsSeries(MacdBuffer,true);
// check input parms
   ValidateAlertType();
//---- initialization done
   alertbartime=0;
   nextalerttime=0;
   alertcount=0;
   nextbartime=0;
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   string objname=shortname+","+Symbol()+","+Period();
   int i;
   while(i<ObjectsTotal())
     {
      string nextobj=ObjectName(i);
      if(StringSubstr(nextobj,0,StringLen(objname))==objname)
         ObjectDelete(nextobj);
      else
         i++;
     }
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;

//if(Time[0]!=nextbartime)
     {
      int xsize=ArraySize(MacdBufferUp);
      ArrayResize(MacdBuffer,xsize);
      // nextbartime=Time[0];
     }

   for(int i=0;i<limit;i++)
     {
      MacdBuffer[i]=(iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
                     iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i))/Point;
     }
// macd colored set here
   bool firstsignal=true;
   for(i=0;i<limit;i++)
     {
      if(MacdBuffer[i]>MacdBuffer[i+1])
        {
         MacdBufferUp[i]=MacdBuffer[i];
         MacdBufferDn[i]=0;
        }
      else
        {
         MacdBufferDn[i]=MacdBuffer[i];
         MacdBufferUp[i]=0;
        }
      if(ShowSignal || firstsignal)
        {
         if(!ShowTops(i))
           {
            if(ShowBottoms(i))
               firstsignal=false;
           }
         else
            firstsignal=false;
        }
     }
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      //      SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
      SignalBuffer[i]=MacdBuffer[i];
//---- pips to change color calculation
   double priMACD=(iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,1)-
                   iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,1))/Point;
   double close[];
   ArrayResize(close,Bars);
   ArraySetAsSeries(close,true);
   ArrayCopy(close,Close,0,0,ArraySize(close));
   double curMACD=(iMAOnArray(close,0,FastEMA,0,MODE_EMA,0)-
                   iMAOnArray(close,0,SlowEMA,0,MODE_EMA,0))/Point;
   int pips;
   if(curMACD<priMACD)
     {
      while(curMACD<priMACD)
        {
         pips++;
         close[0]+=Point;
         curMACD=(iMAOnArray(close,0,FastEMA,0,MODE_EMA,0)-
                  iMAOnArray(close,0,SlowEMA,0,MODE_EMA,0))/Point;
        }
     }
   else
     {
      while(curMACD>priMACD)
        {
         pips--;
         close[0]-=Point;
         curMACD=(iMAOnArray(close,0,FastEMA,0,MODE_EMA,0)-
                  iMAOnArray(close,0,SlowEMA,0,MODE_EMA,0))/Point;
        }
     }
   string objname=shortname+","+Symbol()+","+Period()+",pips";
   if(ObjectFind(objname)<0)
      ObjectCreate(objname,OBJ_TEXT,
                   WindowFind(shortname),
                   Time[0]+Period()*60,MacdBuffer[0]/2);
   else
      ObjectMove(objname,0,Time[0]+Period()*60,MacdBuffer[0]/2);

   if(pips!=0)
      ObjectSetText(objname,DoubleToStr(pips,0),FontSize,"Courier",FontColor);
   else
      ObjectSetText(objname," ",FontSize,"Courier",FontColor);
//---- send alerts
   if(Max_Alerts==0)
      return(0);
   string alertmsg;
   if(!IsAlert(alertmsg))
      return(0);
   alertmsg=Symbol()+","+Period()+" : "+alertmsg;
   Alert(alertmsg);
   if(EMail_Alert)
      SendMail("MACD Colored Alert",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS)+" : "+alertmsg);
   Print(alertmsg);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
bool ShowTops(int shift)
  {
// check for basic pattern
   string objname=SetPatternObjectName(shift);
   bool basicpattern=(MacdBuffer[shift]<MacdBuffer[shift+1] && 
                      MacdBuffer[shift+2]<MacdBuffer[shift+1] && 
                      MacdBuffer[shift+3]<MacdBuffer[shift+2]);
   if(!basicpattern)
     {
      ObjectDelete(objname);
      return(false);
     }
   double diff2=MathAbs(MacdBuffer[shift+2]-MacdBuffer[shift+3]);
   double diff1=MathAbs(MacdBuffer[shift+1]-MacdBuffer[shift+2]);
   double diff0=MathAbs(MacdBuffer[shift]-MacdBuffer[shift+1]);
   bool roundpattern=(diff2>diff1);
   if(MacdBuffer[shift+2]!=0)
      double ratio2=MathAbs(MacdBuffer[shift+3]/MacdBuffer[shift+2]);
   else
      ratio2=1000;
   if(MacdBuffer[shift+1]!=0)
      double ratio1=MathAbs(MacdBuffer[shift+2]/MacdBuffer[shift+1]);
   else
      ratio1=1000;
   if(MacdBuffer[shift+1]!=0)
      double ratio0=MathAbs(MacdBuffer[shift]/MacdBuffer[shift+1]);
   else
      ratio0=1000;
   roundpattern=(roundpattern || MathAbs(ratio0-ratio1)>0.1); // 0 and 2 are close to each other
   double minratio=0.8;
   if(MacdBuffer[shift+1]<10 && MacdBuffer[shift+1]>-10)
      minratio=0.6;
   bool ratioround=(ratio0>minratio && ratio1>minratio && ratio2>minratio);
   bool ratiovtop=(MathAbs(ratio0-ratio1)<0.3);
   string patname=" ";
   if(ratiovtop)
      patname="VT"; // default is v-top
   if(ratioround && roundpattern)
      if(MacdBuffer[shift+1]<5)
         return(false);
   else
      patname="RT"; // round top pattern
   if(patname==" ")
      return(false);
   if(MacdBuffer[shift+1]<3 && MacdBuffer[shift+1]>-3)
      patname="ZB"; // zero line bounce
   if(MacdBuffer[shift+1]<=-3)
      patname="TC"; // trend continue
   bool strongpattern=(MacdBuffer[shift+4]<MacdBuffer[shift+3] && 
                       MacdBuffer[shift+5]<MacdBuffer[shift+4] && 
                       MacdBuffer[shift+1]>10);
   if(ObjectFind(objname)<0)
     {
      ObjectCreate(objname,OBJ_TEXT,
                   WindowFind(shortname),
                   Time[shift+1],0);
     }
   if(strongpattern)
      ObjectSetText(objname,patname,FontSize+2,"Arial",FontColor);
   else
      ObjectSetText(objname,patname,FontSize,"Arial",FontColor);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ShowBottoms(int shift)
  {
// check for basic pattern
   string objname=SetPatternObjectName(shift);
   string objdesc=ObjectDescription(objname);
   bool basicpattern=(MacdBuffer[shift]>MacdBuffer[shift+1] && 
                      MacdBuffer[shift+2]>MacdBuffer[shift+1] && 
                      MacdBuffer[shift+3]>MacdBuffer[shift+2]);
   if(!basicpattern)
     {
      ObjectDelete(objname);
      return(false);
     }
   double diff2=MathAbs(MacdBuffer[shift+2]-MacdBuffer[shift+3]);
   double diff1=MathAbs(MacdBuffer[shift+1]-MacdBuffer[shift+2]);
   double diff0=MathAbs(MacdBuffer[shift]-MacdBuffer[shift+1]);
   bool roundpattern=(diff2>diff1);//&&diff2>diff0);
   if(MacdBuffer[shift+3]!=0)
      double ratio2=MathAbs(MacdBuffer[shift+2]/MacdBuffer[shift+3]);
   else
      ratio2=1000;
   if(MacdBuffer[shift+2]!=0)
      double ratio1=MathAbs(MacdBuffer[shift+1]/MacdBuffer[shift+2]);
   else
      ratio1=1000;
   if(MacdBuffer[shift]!=0)
      double ratio0=MathAbs(MacdBuffer[shift+1]/MacdBuffer[shift]);
   else
      ratio0=1000;
   roundpattern=(roundpattern || MathAbs(ratio0-ratio1)>0.1); // 0 and 2 are close to each other
   double minratio=0.8;
   if(MacdBuffer[shift+1]<10 && MacdBuffer[shift+1]>-10)
      minratio=0.6;
   bool ratioround=(ratio0>minratio && ratio1>minratio && ratio2>minratio);
   bool ratiovtop=(MathAbs(ratio0-ratio1)<0.3);
   string patname=" ";
   if(ratiovtop)
      patname="VB"; // default is v-top
   if(ratioround && roundpattern)
      if(MacdBuffer[shift+1]>-5)
         return(false);
   else
      patname="RB"; // round top pattern
   if(patname==" ")
      return(false);
   if(MacdBuffer[shift+1]<3 && MacdBuffer[shift+1]>-3)
      patname="ZB"; // zero line bounce
   if(MacdBuffer[shift+1]>=3)
      patname="TC"; // trend continue
   bool strongpattern=(MacdBuffer[shift+4]>MacdBuffer[shift+3] && 
                       MacdBuffer[shift+5]>MacdBuffer[shift+4] && 
                       MacdBuffer[shift+1]>10);
   if(ObjectFind(objname)<0)
      ObjectCreate(objname,OBJ_TEXT,
                   WindowFind(shortname),
                   Time[shift+1],0);
   if(strongpattern)
      ObjectSetText(objname,patname,FontSize+2,"Arial",FontColor);
   else
      ObjectSetText(objname,patname,FontSize,"Arial",FontColor);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsAlert(string &alertmsg)
  {
   if(ArraySize(alerttype)==0)
      return(false);
   if(alerttype[0]=="")
      return(false);
   int shift;
   if(TimeCurrent()<Time[0]+(Period()-Alert_Before_Minutes)*60)
      shift=1;
   string objname=SetPatternObjectName(shift);
   if(ObjectFind(objname)<0)
      return(false);
   string thisalert=StringTrimLeft(StringTrimRight(ObjectDescription(objname)));
   bool needalert=false;
   if(alerttype[0]=="ANY")
      needalert=(thisalert!="");
   else
     {
      for(int i=0;i<ArraySize(alerttype);i++)
        {
         if(alerttype[i]==thisalert)
           {
            needalert=true;
            break;
           }
        }
     }
   if(alertbartime!=Time[shift])
     {
      nextalerttime=0;
      alertcount=0;
     }
   if(!needalert)
      return(false);
   alertbartime=Time[shift];
   if(TimeCurrent()>nextalerttime)
     {
      if(alertcount<Max_Alerts)
        {
         alertcount++;
         nextalerttime=TimeCurrent()+Alert_Every_Minutes*60;
         int timetoalert=(TimeCurrent()-Time[shift]-Period()*60)/60;
         string alertname=SetAlertName(thisalert);
         if(timetoalert<0)
            alertmsg=(-1*timetoalert)+" minutes till "+alertname;
         else
         if(timetoalert>0)
            alertmsg=timetoalert+" minutes since "+alertname;
         else
            alertmsg=alertname;
         if(alertcount<Max_Alerts)
            alertmsg=alertmsg+". Next Alert at "+TimeToStr(
                                                           nextalerttime+TimeLocal()-TimeCurrent(),TIME_SECONDS);
         else
            alertmsg=alertmsg+". This was the last Alert";
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SetAlertName(string alertabbr)
  {
   if(alertabbr=="RT")
      return("Round Top");
   if(alertabbr=="VT")
      return("V-Top");
   if(alertabbr=="RB")
      return("Round Bottom");
   if(alertabbr=="VB")
      return("V-Bottom");
   if(alertabbr=="TC")
      return("Trend Continue");
   if(alertabbr=="ZB")
      return("Zero Bounce");
   return("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SetPatternObjectName(int shift)
  {
   return(shortname+","+Symbol()+","+Period()+","+Time[shift]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ValidateAlertType()
  {
   StringUpperCase(Alert_On);
   StringToArray(StringTrimLeft(StringTrimRight(Alert_On)),alerttype,",");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StringUpperCase(string &input_p)
  {
   for(int i=0;i<StringLen(input_p);i++)
     {
      int char1=StringGetChar(input_p,i);
      if(char1>=97&&char1<=122)
         input_p=StringSetChar(input_p,i,char1-32);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StringToArray(string input_p,string &output[],string delim)
  {
   ArrayResize(output,0);
   int start1=0;
   while(start1<StringLen(input_p))
     {
      int delpos=StringFind(input_p,delim,start1);
      if(delpos<0)
        {
         string nextelem=StringSubstr(input_p,start1);
         start1=StringLen(input_p);
        }
      else
        {
         nextelem=StringSubstr(input_p,start1,delpos-start1);
         start1=delpos+1;
        }
      ArrayResize(output,ArraySize(output)+1);
      output[ArraySize(output)-1]=nextelem;
     }
  }
//+------------------------------------------------------------------+
