//+------------------------------------------------------------------+
//|                                            MTrendLine  alert.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
 extern bool TrendLine1_Red = true ; //false true
extern bool TrendLine2_Blue = true ; //false true
extern bool TrendLine_3 = false ; //false true
extern bool TrendLine_4 = false ; //false true
 extern int Alert_Red=3;
 extern int Alert_Blue=3;
 extern bool Sound_Alert_Red=true,Sound_Alert_Blue=true,PopupON=false;
 extern bool EmailON=false;
 string AlertSound="alert.wav";

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
     ObjectDelete("1"); ObjectDelete("2");ObjectDelete("3"); ObjectDelete("4");  
    //   ObjectDelete("TrendLine 1"); ObjectDelete("TrendLine 2");// 
   //  ObjectDelete("TrendLine 3"); ObjectDelete("TrendLine 4");
  //это исправлено, что бы  при переходе с одного тайм фрейма на другой, тренд линии, не  меняли свое место расположение. 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
 //+-----------------------------------------------------------------------------------------------  
       if( TrendLine1_Red)      ObjectCreate("TrendLine 1", OBJ_TREND, 0, Time[12], Bid+25*Point , Time[0]+3600, Bid+25*Point );
         ObjectSet("TrendLine 1", OBJPROP_COLOR, Red);                                                      
      if    (ObjectFind("1")==-1){ ObjectCreate("1",OBJ_TEXT, 0, 0, 0); 
   }  ObjectSetText("1",DoubleToStr(MathAbs((NormalizeDouble(Bid,Digits)-NormalizeDouble
     (ObjectGetValueByShift("Trendline "+1,0),Digits))*MathPow(10,Digits)),0),8,"Arial",Red); 
      ObjectSet("1",OBJPROP_PRICE1,NormalizeDouble(ObjectGetValueByShift("Trendline "+1,0),Digits)); 
             ObjectSet("1",OBJPROP_TIME1,Time[0]) ;  
  //+---      
           double val1=ObjectGetValueByShift("Trendline 1", 0);
      if (Bid-Alert_Red*Point <= val1 && Bid+Alert_Red*Point >= val1)
     {   if (Sound_Alert_Red) PlaySound (AlertSound);
         if (PopupON) Alert (Symbol()," price within ",Alert_Red," pips of ","Trendline 1");
         if (EmailON) SendMail(Symbol()+" ",Alert_Red+" pips from "+"Trendline 1");  
     }   
  //+-----------------------------------------------------------------------------------------------  
   if( TrendLine2_Blue) ObjectCreate("TrendLine 2", OBJ_TREND, 0, Time[12], Bid-25*Point, Time[0]+3600, Bid-25*Point);
    ObjectSet("TrendLine 2", OBJPROP_COLOR, Blue);     
      if    (ObjectFind("2")==-1){ ObjectCreate("2",OBJ_TEXT, 0, 0, 0); 
   }  ObjectSetText("2",DoubleToStr(MathAbs((NormalizeDouble(Bid,Digits)-NormalizeDouble
     (ObjectGetValueByShift("Trendline "+2,0),Digits))*MathPow(10,Digits)),0),8,"Arial",Blue);        
      ObjectSet("2",OBJPROP_PRICE1,NormalizeDouble(ObjectGetValueByShift("Trendline "+2,0),Digits)); 
             ObjectSet("2",OBJPROP_TIME1,Time[0]) ; 
  //----  
      double val2=ObjectGetValueByShift("Trendline 2", 0);
      if (Bid-Alert_Blue*Point <= val2 && Bid+Alert_Blue*Point >= val2)
     {   if (Sound_Alert_Blue) PlaySound (AlertSound);
         if (PopupON) Alert (Symbol()," price within ",Alert_Blue," pips of ","Trendline 2");
         if (EmailON) SendMail(Symbol()+" ",Alert_Blue+" pips from "+"Trendline 2");  
    }     
 //+----------------------------------------------------------------------------------------------- 
 
  if( TrendLine_3)  ObjectCreate("TrendLine 3", OBJ_TREND, 0, Time[10], Bid+50*Point, Time[0]+3600, Bid+50*Point);
     ObjectSet("TrendLine 3", OBJPROP_COLOR, Magenta);     
      if    (ObjectFind("3")==-1){ ObjectCreate("3",OBJ_TEXT, 0, 0, 0); 
   } ObjectSetText("3",DoubleToStr(MathAbs((NormalizeDouble(Bid,Digits)-NormalizeDouble
     (ObjectGetValueByShift("Trendline "+3,0),Digits))*MathPow(10,Digits)),0),8,"Arial",Magenta);        
     ObjectSet("3",OBJPROP_PRICE1,NormalizeDouble(ObjectGetValueByShift("Trendline "+3,0),Digits)); 
             ObjectSet("3",OBJPROP_TIME1,Time[0]) ; 
  //+---      
           double val3=ObjectGetValueByShift("Trendline 3", 0);
      if (Bid-Alert_Red*Point <= val3 && Bid+Alert_Red*Point >= val3)
     {   if (Sound_Alert_Red) PlaySound (AlertSound);
         if (PopupON) Alert (Symbol()," price within ",Alert_Red," pips of ","Trendline 3");
         if (EmailON) SendMail(Symbol()+" ",Alert_Red+" pips from "+"Trendline 3");  
      }              
  //+-----------------------------------------------------------------------------------------------           
 if( TrendLine_4)  ObjectCreate("TrendLine 4", OBJ_TREND, 0, Time[10],Bid-50*Point, Time[0]+3600, Bid-50*Point);
      ObjectSet("TrendLine 4", OBJPROP_COLOR, Magenta);  
         if    (ObjectFind("4")==-1){ ObjectCreate("4",OBJ_TEXT, 0, 0, 0); 
   } ObjectSetText("4",DoubleToStr(MathAbs((NormalizeDouble(Bid,Digits)-NormalizeDouble
     (ObjectGetValueByShift("Trendline "+4,0),Digits))*MathPow(10,Digits)),0),8,"Arial",Magenta);        
     ObjectSet("4",OBJPROP_PRICE1,NormalizeDouble(ObjectGetValueByShift("Trendline "+4,0),Digits)); 
             ObjectSet("4",OBJPROP_TIME1,Time[0]) ;  
   //----  
      double val4=ObjectGetValueByShift("Trendline 4", 0);
      if (Bid-Alert_Blue*Point <= val4 && Bid+Alert_Blue*Point >= val4)
     {    if (Sound_Alert_Blue) PlaySound (AlertSound);
         if (PopupON) Alert (Symbol()," price within ",Alert_Blue," pips of ","Trendline 4");
         if (EmailON) SendMail(Symbol()+" ",Alert_Blue+" pips from "+"Trendline 4");  
      }          
 //+-----------------------------------------------------------------------------------------------   
   return(0);
  }
//+-------------------------------------------------------------------------------------------------+