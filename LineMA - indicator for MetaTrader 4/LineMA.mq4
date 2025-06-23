//+------------------------------------------------------------------+
//|                                                       LineMA.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window

extern string t1="Период первой МА:";
extern int PerMA1=13;
extern string t2="Период второй МА:";
extern int PerMA2=26;
extern string t3="Толщина линий:";
extern int tol=20;
double MA1;
double MA2;
double MA1old;
double MA2old;
double MA1oo;
double MA2oo;
double li;
string no;
int nomer;
bool line=false;
color cls=Red;
color clb=Lime;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
 while(nomer>0)
 {
 ObjectDelete(PerMA1+PerMA2+"lineMA"+nomer);
 nomer--;
 }  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i, 
       Counted_bars=IndicatorCounted();
   i=Bars-Counted_bars-1;
//----
      while(i>=0)                      // Цикл по непосчитанным барам     
      {
       MA1=iMA(Symbol(),0,PerMA1,0,MODE_SMA,PRICE_CLOSE,i);
       MA2=iMA(Symbol(),0,PerMA2,0,MODE_SMA,PRICE_CLOSE,i);  
       MA1old=iMA(Symbol(),0,PerMA1,0,MODE_SMA,PRICE_CLOSE,i+1);
       MA2old=iMA(Symbol(),0,PerMA2,0,MODE_SMA,PRICE_CLOSE,i+1);  
       MA1oo=iMA(Symbol(),0,PerMA1,0,MODE_SMA,PRICE_CLOSE,i+2);
       MA2oo=iMA(Symbol(),0,PerMA2,0,MODE_SMA,PRICE_CLOSE,i+2);  
       
       //--------------1--------------
       if (MA1oo>MA2oo && MA2old>MA1old && MA2>MA1) {line=true;CreateOb(Time[i+1],((MA1old+MA2old)/2),Time[i],((MA1+MA2)/2));}
       if (MA1oo<MA2oo && MA2old<MA1old && MA2<MA1) {line=true;CreateOb(Time[i+1],((MA1old+MA2old)/2),Time[i],((MA1+MA2)/2));}
       
       //--------------2--------------
       if (MA1old>MA2old && MA2>MA1) {line=false;}
       if (MA1old<MA2old && MA2<MA1) {line=false;}
       
       //--------------3--------------
       if (line==true) {SetOb(li,Time[i],((MA1+MA2)/2));}
       
       i--;                          // Расчёт индекса следующего бара     
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+

void CreateOb(datetime t1,double k1,datetime t2, double k2)
   {
   nomer=nomer+1;
   no=PerMA1+PerMA2+"lineMA"+nomer;
   ObjectCreate(no, OBJ_TREND, 0, t1, k1, t2, k2);
   ObjectSet(no, OBJPROP_STYLE, STYLE_SOLID);
   li=k1;
   if (k1>k2) {ObjectSet(no, OBJPROP_COLOR, cls);}
   if (k1<k2) {ObjectSet(no, OBJPROP_COLOR, clb);}
   ObjectSet(no, OBJPROP_BACK, True);
   ObjectSet(no, OBJPROP_RAY,false);
   ObjectSet(no, OBJPROP_WIDTH,tol);
   }

void SetOb(double k1, datetime t2,double k2)
   {
   ObjectSet(no,OBJPROP_TIME2,t2);
   ObjectSet(no,OBJPROP_PRICE2,k2);
   if (k1>k2) {ObjectSet(no, OBJPROP_COLOR, cls);}
   if (k1<k2) {ObjectSet(no, OBJPROP_COLOR, clb);}
   }}
   ObjectSet(no, OBJPROP_BACK, True);
   ObjectSet(no, OBJPROP_RAY,false);
   ObjectSet(no, OBJPROP_WIDTH,tol);
   }

void SetOb(double k1, datetime t2,double k2)
   {
   ObjectSet(no,OBJPROP_TIME2,t2);
   ObjectSet(no,OBJPROP_PRICE2,k2);
   ObjectSet(no, OBJPROP_STYLE, st);
   if (k1>k2) {ObjectSet(no, OBJPROP_COLOR, cls);}
   if (k1<k2) {ObjectSet(no, OBJPROP_COLOR, clb);}
   }