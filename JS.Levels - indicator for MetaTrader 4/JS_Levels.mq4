//+------------------------------------------------------------------+
//|                                                    JS.Levels.mq4 |
//|     Trading systems developer, contact js_sergey@list.ru  © 2009 |
//+------------------------------------------------------------------+
#property copyright " js_sergey@list.ru "
#property link      " http://multiexperts.ru/ "
 
#property indicator_chart_window
 
extern int   style  = 0;
extern int   width = 1;
extern bool  ray    = True;
extern color color1   = Magenta;
 
string lineLow[300];
string lineHigh[300];
double dLow[300];
double dHigh[300];
//+------------------------------------------------------------------+
int start()
  {
//----
   for (int i=0; i<300; i++) {
   
    dLow[i] = iLow(Symbol(),43200,i);
    dHigh[i] = iHigh(Symbol(),43200,i);
    
    datetime Ts = Time[0]+Period()*40*(WindowBarsPerChart());
   
    lineLow[i] = "Level.Low = "+i;
    lineHigh[i]= "Level.High = "+i;
    
    if(ObjectFind(lineLow[i])!=0)
    ObjectDelete(lineLow[i]);
    if(ObjectFind(lineLow[i])<0){
    ObjectCreate(lineLow[i], OBJ_TREND, 0, Ts, dLow[i], Time[10],dLow[i]);
    ObjectSet(lineLow[i], OBJPROP_STYLE, style);
    ObjectSet(lineLow[i], OBJPROP_WIDTH, width); 
    ObjectSet(lineLow[i], OBJPROP_COLOR, color1);
    ObjectSet(lineLow[i], OBJPROP_BACK,  true);
    ObjectSet(lineLow[i], OBJPROP_RAY,   ray); // ray  
   } else {
      ObjectMove(lineLow[i], 1, Time[10],dLow[i]);
      ObjectMove(lineLow[i], 0, Ts,dLow[i]);
   }
   
   
    if(ObjectFind(lineHigh[i])!=0)
    ObjectDelete(lineHigh[i]);
    if(ObjectFind(lineHigh[i])<0){
    ObjectCreate(lineHigh[i], OBJ_TREND, 0, Ts, dHigh[i], Time[10],dHigh[i]);
    ObjectSet(lineHigh[i], OBJPROP_STYLE, style);
    ObjectSet(lineHigh[i], OBJPROP_WIDTH, width); 
    ObjectSet(lineHigh[i], OBJPROP_COLOR, color1);
    ObjectSet(lineHigh[i], OBJPROP_BACK,  true);
    ObjectSet(lineHigh[i], OBJPROP_RAY,   ray); // ray  
   } else {
      ObjectMove(lineHigh[i], 1,Time[10],dHigh[i]);
      ObjectMove(lineHigh[i], 0,Ts,dHigh[i]);
   }
 }
//----
   return(0);
}
//+------------------------------------------------------------------+
int deinit()
  {
  //----
    for (int i=0; i<300; i++) {
    
    lineLow[i] = "Level.Low = "+i;
    lineHigh[i]= "Level.High = "+i;
   
    ObjectDelete(lineLow[i]);
    ObjectDelete(lineHigh[i]);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+