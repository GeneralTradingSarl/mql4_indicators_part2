//+------------------------------------------------------------------+
//|                                             open position MA.mq4 |
//|                                                      reza rahmad |
//|                                           reiz_gamer@yahoo.co.id |
//+------------------------------------------------------------------+
#property copyright "reza rahmad"
#property link      "reiz_gamer@yahoo.co.id"
#property version   "1.00"
#property strict
#property indicator_chart_window
extern double MA_fast = 5;
extern double MA_slow = 20;
extern double MA_shift_fast = 2;
extern double MA_shift_slow = 0;

  double h15 =iMA( NULL,PERIOD_H1, MA_fast, MA_shift_fast,MODE_SMA,PRICE_CLOSE,0);
   double h120=iMA( NULL,PERIOD_H1,MA_slow, MA_shift_slow,MODE_SMA,PRICE_CLOSE,0);
   double h45=iMA( NULL,PERIOD_H4, MA_fast, MA_shift_fast,MODE_SMA,PRICE_CLOSE,0);
   double h420=iMA( NULL,PERIOD_H4, MA_shift_slow, MA_shift_slow,MODE_SMA,PRICE_CLOSE,0);
  
//---jectSet("text",OBJPROP_YDISTANCE,60);
int init(){
   

ObjectCreate("texti",OBJ_LABEL,0,0,0,0,0);
ObjectSet("texti",OBJPROP_CORNER,1);
   ObjectSet("texti",OBJPROP_XDISTANCE,50);
   ObjectSet("texti",OBJPROP_YDISTANCE,60);
   ObjectSetText("texti","TEST",24,"Times New Roman",Green);
   
   ObjectCreate("textir",OBJ_LABEL,0,0,0,0,0);
ObjectSet("textir",OBJPROP_CORNER,1);
   ObjectSet("textir",OBJPROP_XDISTANCE,50);
   ObjectSet("textir",OBJPROP_YDISTANCE,40);
   ObjectSetText("textir","created by reza rahmad",10,"Times New Roman",Green);

   ObjectCreate("text1",OBJ_TEXT,0,0,0,0,0);
   ObjectSet("text1",OBJPROP_CORNER,1);
   ObjectSet("text1",OBJPROP_TIME1,Time[0]);
   ObjectSet("text1",OBJPROP_PRICE1,h15 +5 * Point); 
    ObjectSetText("text1","MA 5",7,"Times New Roman",Magenta);
    
  ObjectCreate("text2",OBJ_TEXT,0,0,0,0,0);
   ObjectSet("text2",OBJPROP_CORNER,1);
   ObjectSet("text2",OBJPROP_TIME1,Time[0]);
   ObjectSet("text2",OBJPROP_PRICE1,h120 +5 * Point); 
    ObjectSetText("text2","MA 20",7,"Times New Roman",Magenta);
    
    
    return(0);
   }
  
 int deinit(){
  ObjectDelete("texti");
 ObjectDelete("text1");
 ObjectDelete("text2");
 ObjectDelete("h15");
  ObjectDelete("h120");
  ObjectDelete("h55");
   ObjectDelete("h420");
   return(0);
 }
 
  int start(){
 
      ObjectCreate("b1",OBJ_TREND,0,0,0,0,0);
      ObjectSet("b1",OBJPROP_PRICE1,h15);
      ObjectSet("b1",OBJPROP_PRICE2,h15);
      ObjectSet("b1",OBJPROP_TIME1,Time[0]);
      ObjectSet("b1",OBJPROP_TIME2,Time[7]);
      ObjectSet("b1",OBJPROP_RAY,false);
      ObjectSet("b1",OBJPROP_WIDTH,2);
      ObjectSet("b1",OBJPROP_COLOR,clrRed);
     
      ObjectCreate("s1",OBJ_TREND,0,0,0,0,0);
      ObjectSet("s1",OBJPROP_PRICE1,h120);
      ObjectSet("s1",OBJPROP_PRICE2,h120);
      ObjectSet("s1",OBJPROP_TIME1,Time[0]);
      ObjectSet("s1",OBJPROP_TIME2,Time[7]);
      ObjectSet("s1",OBJPROP_RAY,false);
      ObjectSet("s1",OBJPROP_WIDTH,2);
      ObjectSet("s1",OBJPROP_COLOR,clrRed);
     
/*break h4 strong       
      ObjectSet("b4",OBJPROP_PRICE1,h45);
      ObjectSet("b4",OBJPROP_PRICE2,h45);
      ObjectSet("b4",OBJPROP_TIME1,Time[0]);
      ObjectSet("b4",OBJPROP_TIME2,Time[7]);
      ObjectSet("b4",OBJPROP_RAY,false);
      ObjectSet("b4",OBJPROP_WIDTH,4);
      ObjectSet("b4",OBJPROP_COLOR,clrGreen);

      ObjectCreate("s4",OBJ_TREND,0,0,0,0,0);
      ObjectSet("s4",OBJPROP_PRICE1,h420);
      ObjectSet("s4",OBJPROP_PRICE2,h420);
      ObjectSet("s4",OBJPROP_TIME1,Time[0]);
      ObjectSet("s4",OBJPROP_TIME2,Time[7]);
      ObjectSet("s4",OBJPROP_RAY,false);
      ObjectSet("s4",OBJPROP_WIDTH,4);
      ObjectSet("s4",OBJPROP_COLOR,clrGreen);
 */
if(iClose (NULL,PERIOD_H1,0) > h15 && iClose (NULL,PERIOD_H1,0) > h120)
  {
   ObjectSetText("texti","STRONG BUY",24,"Times New Roman",Green);
  }
else if(iClose (NULL,PERIOD_H1,0) > h15 && iClose (NULL,PERIOD_H1,0) < h120)
       {
        ObjectSetText("texti","WEAK BUY",24,"Times New Roman",Green);
       }
    else if(iClose (NULL,PERIOD_H1,0) < h15 && iClose (NULL,PERIOD_H1,0) < h120)
              {
               ObjectSetText("texti","STRONG SELL",24,"Times New Roman",Red);
              }
       else if(iClose (NULL,PERIOD_H1,0) < h15 && iClose (NULL,PERIOD_H1,0) > h120)
              {
               ObjectSetText("texti","WEAK SELL",24,"Times New Roman",Red);
              }     
 
 else
     {
      ObjectSetText("texti","NO LOGIC",24,"Times New Roman",Red);
     }
   
   
 
  return(0);
 }
//+---------------------------------------------------------------+
