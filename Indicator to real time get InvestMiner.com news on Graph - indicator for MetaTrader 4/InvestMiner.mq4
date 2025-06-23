
//+------------------------------------------------------------------+
//|                                                  InvestMiner.mq4 |
//|                                     Copyright © 2009 InvestMiner |
//|                                       http://www.investminer.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 InvestMiner"
#property link      "http://www.investminer.com"
#property indicator_chart_window

// version 2009-09-03

#include <http51.mqh>

extern int width=32;

static int timer=-1;
static int max=41;
static int left=3;
static int top=5;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator
   for (int news=0; news<max; news++) { 
      string label=StringConcatenate("news",news);
      ObjectMakeLabel(label,left,top+news*14);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for (int news=0; news<max; news++) { 
      string label=StringConcatenate("news",news);
      ObjectDelete(label);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| StringSplit (http://forum.mql4.com/21733)                        |
//+------------------------------------------------------------------+
string StringSplit(string input,string sep, int index)
{
   int count=0;
   int oldpos=0;
   int pos=StringFind(input,sep,0);
   
   while(pos>=0&&count<=index) {
      if(count==index) {
         if(pos==oldpos) {
            return("");
         }
         else {
            return(StringSubstr(input,oldpos,pos-oldpos));
         }
      }
      oldpos=pos+StringLen(sep);
      pos=StringFind(input,sep,oldpos);
      count++;
   }
   if(count==index) {
      return(StringSubstr(input,oldpos));
   }
   return("");
}
//+------------------------------------------------------------------+
//| ObjectMakeLabel (http://forum.mql4.com/12057)                    |
//+------------------------------------------------------------------+
int ObjectMakeLabel(string n,int xoff,int yoff) {
   ObjectCreate(n,OBJ_LABEL,0,0,0);
   ObjectSet(n,OBJPROP_CORNER,1);
   ObjectSet(n,OBJPROP_XDISTANCE,xoff);
   ObjectSet(n,OBJPROP_YDISTANCE,yoff);
   ObjectSet(n,OBJPROP_BACK,true);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   string msg,line,trend,label;
   string params [0,2];
   ArrayResize( params, 0); // Flush old data
   int status[1];           // HTTP Status code
   int counted_bars=IndicatorCounted();
   
   if (timer==(Minute()/5)) return;
   timer=(Minute()/5);
   
   // setup parameters addParam(Key,Value,paramArray)
   addParam("metatrader","20",params);
   addParam("instrument",Symbol(),params);

   // create URLEncoded string from parameters array
   // http://codebase.mql4.com/4428
   string req = ArrayEncode(params);
   msg = httpPOST("http://www.investminer.com/index.php", req, status);
   if (StringLen(msg)<=100) msg=StringConcatenate("Searching InvestMiner.com for ",Symbol()," news ...");
   
   // show lines
   for (int news=0; news<max; news++) { 
      line=StringSplit(msg,"\r\n",news);
      if (news>0) {
         trend=StringSubstr(line,0,1);
         if (width>58) width=58; // metatrader graph text limit
         if (StringLen(line)>20) 
            line=StringConcatenate(StringSubstr(line,2,width)," ...");
         else
            line=StringSubstr(line,2,width);
      }
      else trend="C";
      label=StringConcatenate("news",news);
      if (trend=="L")
         ObjectSetText(label,line,10,"Arial",Blue);
      else if (trend=="S")
         ObjectSetText(label,line,10,"Arial",Red);
      else if (trend=="T")
         ObjectSetText(label,line,8,"Arial",Gray);
      else if (trend=="C")
         ObjectSetText(label,line,10,"Arial",Black);
      else 
         ObjectSetText(label,line,10,"Arial",Orange);
   }
   
//----
  return(0);
  }
//+------------------------------------------------------------------+
 

