//+------------------------------------------------------------------+
//|                                                  spread swap.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property indicator_separate_window
#property indicator_color1 White
//----
double    swaplong,swapshort,MARGINREQUIRED;
extern color  BClockClr= Red;
extern color  ClksColor= Ivory;
extern color  TDCOL= White;
extern bool   show_Bclk=true ;
extern string myFont        ="Arial Bold" ;
extern string myFont2       ="Tahoma Bold" ;
extern bool show_M1=true ;
extern bool show_M5=true ;
extern bool show_M15=true ;
extern bool show_M30=true ;
extern bool show_M60=true ;
extern bool show_M240=false ;
extern bool show_M1440=false ;
int   TimeFrame   =0 ;
int spread;
double s1[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int init()
  {
   IndicatorShortName("spread/swap monitor ("+Symbol()+")");
//----
     switch(TimeFrame)
     {
      case 1  : string TimeFrameStr="M1";  break;
      case 5  :     TimeFrameStr=   "M5";  break;
      case 15 :     TimeFrameStr=   "M15";   break;
      case 30 :     TimeFrameStr=   "M30";   break;
      case 60 :     TimeFrameStr=   "H1";  break;
      case 240  :   TimeFrameStr=   "H4";  break;
      case 1440 :   TimeFrameStr=   "D1";  break;
      case 10080 :  TimeFrameStr=   "W1";  break;
      case 43200 :  TimeFrameStr=   "MN1";   break;
      default  :    TimeFrameStr=   "CurrTF";
     }
   //if (TimeFrame<Period()) TimeFrame=Period();
   return(0);
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("time");
   ObjectDelete("timey");
   ObjectDelete("time1");
   ObjectDelete("time2");
   ObjectDelete("time3");
   ObjectDelete("time4");
   ObjectDelete("time5");
   ObjectDelete("time6");
   ObjectDelete("time7");
   ObjectDelete("time8");
   ObjectDelete("T1");
   ObjectDelete("T2");
   ObjectDelete("T3");
   Comment("");
//----
   return(0);
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
  double i,i1,i2,i3,i4,i5,i6,i7;
   int m,s,
   m0, m1,m2,m3,m4,m5,m6,m7,
   s0, s1,s2,s3,s4,s5,s6,s7,
   h,h1,h2,h3,h4,h5,h6,h7;
   if (TimeFrame ==0)TimeFrame=Period();
   m=iTime(NULL,TimeFrame,0)+TimeFrame*60 - TimeCurrent();
   //  m=Time[0]+Period()*60-CurTime();
   m1=iTime(NULL,1440,0)+1440*60-CurTime();
   m2=iTime(NULL,240,0)+240*60-CurTime();
   m3=iTime(NULL,60,0)+60*60-CurTime();
   m4=iTime(NULL,30,0)+30*60-CurTime();
   m5=iTime(NULL,15,0)+15*60-CurTime();
   m6=iTime(NULL,5,0)+5*60-CurTime();
   m7=iTime(NULL,1,0)+1*60-CurTime();
//----
   i=m/60.0;
   i1=m1/60.0;
   i2=m2/60.0;
   i3=m3/60.0;
   i4=m4/60.0;
   i5=m5/60.0;
   i6=m6/60.0;
   i7=m7/60.0;
//----
   s=m%60;
   s0=m%60;
   s1=m1%60;
   s2=m2%60;
   s3=m3%60;
   s4=m4%60;
   s5=m5%60;
   s6=m6%60;
   s7=m7%60;
//----
   m=(m-m%60)/60;
   m0=(m-m%60)/60;
   m1=(m1-m1%60)/60;
   m2=(m2-m2%60)/60;
   m3=(m3-m3%60)/60;
   m4=(m4-m4%60)/60;
   m5=(m5-m5%60)/60;
   m6=(m6-m6%60)/60;
   m7=(m7-m7%60)/60;
//----
   h=m/60;
   h1=m1/60;
   h2=m2/60;
   h3=m3/60;
   h4=m4/60;
   h5=m5/60;
   h6=m6/60;
   h7=m7/60;
//----
   string Bclk=   "                   <"+m+":"+s;
   string M1=  "[M1] "+m7+"m :"+s7;
   string M5=  "[M5] "+m6+"m :"+s6;
   string M15= "[M15] "+m5+"m :"+s5;
   string M30= "[M30] "+m4+"m :"+s4;
   string M60= "[M60] "+m3+"m :"+s3;
   string M240= "[H4] "+m2+"m :"+s2;
   string M1440= "[D1] "+m1+"m :"+s1;
//----
  
   spread=MarketInfo(Symbol(),13);
   swaplong=NormalizeDouble(MarketInfo(Symbol(),18),2);
   swapshort=NormalizeDouble(MarketInfo(Symbol(),19),2);

   MARGINREQUIRED=NormalizeDouble(MarketInfo(Symbol(),32),2)/10;

//----
   ObjectCreate("spread/swap monitorA", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorA","Spread:", 9, "Tahoma", Blue);
   ObjectSet("spread/swap monitorA", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorA", OBJPROP_XDISTANCE, 155);
   ObjectSet("spread/swap monitorA", OBJPROP_YDISTANCE, 2);
//----
   ObjectCreate("spread/swap monitorB", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorB",DoubleToStr(spread ,0),9, "Tahoma", Black);
   ObjectSet("spread/swap monitorB", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorB", OBJPROP_XDISTANCE, 155);
   ObjectSet("spread/swap monitorB", OBJPROP_YDISTANCE, 15);
//----
   ObjectCreate("spread/swap monitorC", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorC","Buy Swap:", 9, "Tahoma", Green);
   ObjectSet("spread/swap monitorC", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorC", OBJPROP_XDISTANCE, 220);
   ObjectSet("spread/swap monitorC", OBJPROP_YDISTANCE, 2);
//----
   ObjectCreate("spread/swap monitorD", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorD",DoubleToStr( swaplong ,2),9, "Tahoma", Black);
   ObjectSet("spread/swap monitorD", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorD", OBJPROP_XDISTANCE, 220);
   ObjectSet("spread/swap monitorD", OBJPROP_YDISTANCE, 15);
//----
   ObjectCreate("spread/swap monitorE", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorE","Sell Swap:", 9, "Tahoma", Red);
   ObjectSet("spread/swap monitorE", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorE", OBJPROP_XDISTANCE, 300);
   ObjectSet("spread/swap monitorE", OBJPROP_YDISTANCE, 2);
//----
   ObjectCreate("spread/swap monitorF", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorF",DoubleToStr( swapshort ,2),9, "Tahoma", Black);
   ObjectSet("spread/swap monitorF", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorF", OBJPROP_XDISTANCE, 300);
   ObjectSet("spread/swap monitorF", OBJPROP_YDISTANCE, 15);
//----
//----
   ObjectCreate("spread/swap monitorG", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorG","Bid/Ask:", 9, "Tahoma", Black);
   ObjectSet("spread/swap monitorG", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorG", OBJPROP_XDISTANCE, 375);
   ObjectSet("spread/swap monitorG", OBJPROP_YDISTANCE, 2);
//----
   ObjectCreate("spread/swap monitorH", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorH",DoubleToStr(Bid ,4),9, "Tahoma", Red);
   ObjectSet("spread/swap monitorH", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorH", OBJPROP_XDISTANCE, 375);
   ObjectSet("spread/swap monitorH", OBJPROP_YDISTANCE, 15);
//----
   ObjectCreate("spread/swap monitorI", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorI",DoubleToStr(Ask ,4),9, "Tahoma", Blue);
   ObjectSet("spread/swap monitorI", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorI", OBJPROP_XDISTANCE, 375);
   ObjectSet("spread/swap monitorI", OBJPROP_YDISTANCE, 28);
//----  
   ObjectCreate("spread/swap monitorJ", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorJ","Depozyt($=0.1 L):",9, "Tahoma", DarkOrchid);
   ObjectSet("spread/swap monitorJ", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorJ", OBJPROP_XDISTANCE, 450);
   ObjectSet("spread/swap monitorJ", OBJPROP_YDISTANCE, 2);
//----     
   ObjectCreate("spread/swap monitorK", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorK",DoubleToStr(MARGINREQUIRED ,2),9, "Tahoma", Black);
   ObjectSet("spread/swap monitorK", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorK", OBJPROP_XDISTANCE, 450);
   ObjectSet("spread/swap monitorK", OBJPROP_YDISTANCE, 15);
//----     
//----  
   ObjectCreate("spread/swap monitorL", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
   ObjectSetText("spread/swap monitorL","~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",9, "Tahoma", Ivory);
   ObjectSet("spread/swap monitorL", OBJPROP_CORNER, 0);
   ObjectSet("spread/swap monitorL", OBJPROP_XDISTANCE, 155);
   ObjectSet("spread/swap monitorL", OBJPROP_YDISTANCE, 37);
      
      
   if(show_Bclk )
     {
     Comment( m + " minutes " + s + " seconds left to bar end");}
   ObjectDelete("time");
   if(ObjectFind("time")!=0)
     {
        if(show_Bclk )
        {
        ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0]+ 0.0000);}
        if(show_Bclk )
        {
        ObjectSetText("time",StringSubstr((Bclk),0), 9, "Tahoma" ,BClockClr);}
      //ObjectDelete("time");
     }
   else
     {
      ObjectMove("time", 0, Time[0], Close[0]+0.0005);
      //ObjectDelete("time");
     }
     {
      string P=Period();
 
      ObjectCreate("T1", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
      ObjectSetText("T1","Market time ->",10, "Tahoma Bold", Black);
      ObjectSet("T1", OBJPROP_CORNER, 0);
      ObjectSet("T1", OBJPROP_XDISTANCE, 155);
      ObjectSet("T1", OBJPROP_YDISTANCE, 47);  
      
      ObjectCreate("T2", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
      ObjectSetText("T2",TimeToStr(CurTime(),TIME_SECONDS),10, "Tahoma", Yellow);
      ObjectSet("T2", OBJPROP_CORNER, 0);
      ObjectSet("T2", OBJPROP_XDISTANCE, 245);
      ObjectSet("T2", OBJPROP_YDISTANCE, 47);
      
      ObjectCreate("T3", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
      ObjectSetText("T3",TimeToStr(CurTime(),TIME_DATE),10, "Tahoma", Yellow);
      ObjectSet("T3", OBJPROP_CORNER, 0);
      ObjectSet("T3", OBJPROP_XDISTANCE, 325);
      ObjectSet("T3", OBJPROP_YDISTANCE, 47);
 //----       
        if(show_M1)
        {
         ObjectCreate("spread/swap monitorM", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
         ObjectSetText("spread/swap monitorM",StringSubstr((M1),0), 11, myFont2 ,ClksColor);
         ObjectSet("spread/swap monitorM", OBJPROP_CORNER, 0);
         ObjectSet("spread/swap monitorM", OBJPROP_XDISTANCE, 10);
         ObjectSet("spread/swap monitorM", OBJPROP_YDISTANCE, 63);
        }
        if(show_M5)
        {
         ObjectCreate("spread/swap monitorN", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
         ObjectSetText("spread/swap monitorN",StringSubstr((M5),0) , 11, myFont2 ,ClksColor);
         ObjectSet("spread/swap monitorN", OBJPROP_CORNER, 0);
         ObjectSet("spread/swap monitorN", OBJPROP_XDISTANCE, 150);
         ObjectSet("spread/swap monitorN", OBJPROP_YDISTANCE, 63);
        }
        if(show_M15)
        {
         ObjectCreate("spread/swap monitorO", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
         ObjectSetText("spread/swap monitorO",StringSubstr((M15),0), 11, myFont2 ,ClksColor);
         ObjectSet("spread/swap monitorO", OBJPROP_CORNER, 0);
         ObjectSet("spread/swap monitorO", OBJPROP_XDISTANCE, 280);
         ObjectSet("spread/swap monitorO", OBJPROP_YDISTANCE, 63);
        }
        if(show_M30)
        {
         ObjectCreate("spread/swap monitorP", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
         ObjectSetText("spread/swap monitorP",StringSubstr((M30),0), 11, myFont2 ,ClksColor);
         ObjectSet("spread/swap monitorP", OBJPROP_CORNER, 0);
         ObjectSet("spread/swap monitorP", OBJPROP_XDISTANCE, 430);
         ObjectSet("spread/swap monitorP", OBJPROP_YDISTANCE, 63);}
        if(show_M60)
        {
         ObjectCreate("spread/swap monitorQ", OBJ_LABEL, WindowFind("spread/swap monitor ("+Symbol()+")"), 0, 0);
         ObjectSetText("spread/swap monitorQ",StringSubstr((M60),0), 11, myFont2 ,ClksColor);
         ObjectSet("spread/swap monitorQ", OBJPROP_CORNER, 0);
         ObjectSet("spread/swap monitorQ", OBJPROP_XDISTANCE, 580);
         ObjectSet("spread/swap monitorQ", OBJPROP_YDISTANCE, 63);
        }
      
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+