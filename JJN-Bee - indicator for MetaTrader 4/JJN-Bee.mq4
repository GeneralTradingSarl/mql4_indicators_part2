//+------------------------------------------------------------------+
//|                                                      JJN-Bee.mq4 |
//|                                      Copyright © 2012, JJ Newark |
//|                                            http:/jjnewark.atw.hu |
//|                                             jjnewark@freemail.hu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, JJ Newark"
#property link      "http:/jjnewark.atw.hu"


//---- indicator settings
#property indicator_chart_window
#property  indicator_buffers      4
#property  indicator_color1       YellowGreen
#property  indicator_color2       OrangeRed
#property  indicator_color3       YellowGreen
#property  indicator_color4       OrangeRed
#property  indicator_width1       1
#property  indicator_width2       1
#property  indicator_width3       1
#property  indicator_width4       1


//---- indicator parameters
extern string     __Copyright__               = "http://jjnewark.atw.hu";
extern int        AtrPeriod                   = 8;
extern bool       Show_TP_SL                  = true;
extern bool       Show_Levels                 = true;
extern color      BuyColor                    = YellowGreen;
extern color      SellColor                   = OrangeRed;
extern color      FontColor                   = Black;
extern int        DisplayDecimals             = 4;
extern int        PosX                        = 25;
extern int        PosY                        = 25;
extern bool       SoundAlert                  = false;


//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];


double Atr;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,167);//119
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,167);//119
   SetIndexBuffer(3,ExtMapBuffer4);
  
      
   SetIndexLabel(0,"BUY");
   SetIndexLabel(1,"SELL");
   SetIndexLabel(2,"TakeProfit");
   SetIndexLabel(3,"StopLoss");
   
      
//---- 
   IndicatorShortName("JJN-Bee");
   
   
   ObjectCreate("JJNBeeIndName",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("JJNBeeIndName",OBJPROP_CORNER,0);
   ObjectSet("JJNBeeIndName",OBJPROP_XDISTANCE,PosX+20);
   ObjectSet("JJNBeeIndName",OBJPROP_YDISTANCE,PosY);
   ObjectSetText("JJNBeeIndName","JJN-Bee",8,"Lucida Sans Unicode",FontColor);
   
   ObjectCreate("JJNBeeLine0",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("JJNBeeLine0",OBJPROP_CORNER,0);
   ObjectSet("JJNBeeLine0",OBJPROP_XDISTANCE,PosX+5);
   ObjectSet("JJNBeeLine0",OBJPROP_YDISTANCE,PosY+8);
   ObjectSetText("JJNBeeLine0","------------------",8,"Tahoma",FontColor);
   
   ObjectCreate("JJNBeeLine1",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("JJNBeeLine1",OBJPROP_CORNER,0);
   ObjectSet("JJNBeeLine1",OBJPROP_XDISTANCE,PosX+5);
   ObjectSet("JJNBeeLine1",OBJPROP_YDISTANCE,PosY+10);
   ObjectSetText("JJNBeeLine1","------------------",8,"Tahoma",FontColor);
   
   ObjectCreate("JJNBeeDirection",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("JJNBeeDirection",OBJPROP_CORNER,0);
   ObjectSet("JJNBeeDirection",OBJPROP_XDISTANCE,PosX);
   ObjectSet("JJNBeeDirection",OBJPROP_YDISTANCE,PosY+12);
   ObjectSetText("JJNBeeDirection","Wait",20,"Lucida Sans Unicode",FontColor);
      
   ObjectCreate("JJNBeeLevel",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("JJNBeeLevel",OBJPROP_CORNER,0);
   ObjectSet("JJNBeeLevel",OBJPROP_XDISTANCE,PosX);
   ObjectSet("JJNBeeLevel",OBJPROP_YDISTANCE,PosY+50);
   ObjectSetText("JJNBeeLevel","",9,"Lucida Sans Unicode",FontColor);
   
   
//---- initialization done
   return(0);
  }

int deinit()
  {
//----
  
   ObjectDelete("JJNBeeLine0");
   ObjectDelete("JJNBeeLine1");
   ObjectDelete("JJNBeeIndName");
   ObjectDelete("JJNBeeDirection");
   ObjectDelete("JJNBeeLevel");   
   
   ObjectDelete("JJNBeeEntryLevel");  
   ObjectDelete("JJNBeeTPLevel");
   ObjectDelete("JJNBeeSLLevel");     
//----
   return(0);
  }

int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;
//---- 

   
   
      
   for(int i=0; i<limit; i++)
   {
   Atr=iATR(NULL,0,AtrPeriod,i);
   
   if(Close[i]>Open[i+1] && Close[i+1]<Open[i+1])
      { 
      ExtMapBuffer1[i]=Low[i];
      ExtMapBuffer2[i]=EMPTY_VALUE;
      if(Show_TP_SL) ExtMapBuffer3[i]=Open[i+1]+Atr;
      if(Show_TP_SL) ExtMapBuffer4[i]=Open[i+1]-Atr;
      }
   else if(Close[i]<Open[i+1] && Close[i+1]>Open[i+1])
      {
      ExtMapBuffer1[i]=EMPTY_VALUE;
      ExtMapBuffer2[i]=High[i];
      if(Show_TP_SL) ExtMapBuffer3[i]=Open[i+1]-Atr;
      if(Show_TP_SL) ExtMapBuffer4[i]=Open[i+1]+Atr;
      }
   else 
      {
      ExtMapBuffer1[i]=EMPTY_VALUE;
      ExtMapBuffer2[i]=EMPTY_VALUE;
      ExtMapBuffer3[i]=EMPTY_VALUE;
      ExtMapBuffer4[i]=EMPTY_VALUE;
      }
   }
  
  
   if(Close[0]>Open[1] && Close[1]<Open[1]) // BUY
      { 
      ObjectDelete("JJNBeeEntryLevel");  
      ObjectDelete("JJNBeeTPLevel");
      ObjectDelete("JJNBeeSLLevel"); 
      
      ObjectSet("JJNBeeDirection",OBJPROP_XDISTANCE,PosX+5);
      ObjectSetText("JJNBeeDirection","BUY",28,"Lucida Sans Unicode",BuyColor); 
      ObjectSetText("JJNBeeLevel","above "+DoubleToStr(Open[1],DisplayDecimals),9,"Lucida Sans Unicode",BuyColor);
      if(Show_Levels)
         {
         ObjectCreate("JJNBeeEntryLevel",OBJ_TREND,0,Time[1],Open[1],Time[0],Open[1]);
         ObjectSet("JJNBeeEntryLevel",OBJPROP_RAY,True);
         ObjectSet("JJNBeeEntryLevel",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNBeeEntryLevel",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNBeeEntryLevel",OBJPROP_WIDTH,1);
         ObjectSet("JJNBeeEntryLevel",OBJPROP_COLOR,FontColor);
         ObjectCreate("JJNBeeTPLevel",OBJ_TREND,0,Time[1],Open[1]+Atr,Time[0],Open[1]+Atr);
         ObjectSet("JJNBeeTPLevel",OBJPROP_RAY,True);
         ObjectSet("JJNBeeTPLevel",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNBeeTPLevel",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNBeeTPLevel",OBJPROP_WIDTH,1);
         ObjectSet("JJNBeeTPLevel",OBJPROP_COLOR,BuyColor);
         ObjectCreate("JJNBeeSLLevel",OBJ_TREND,0,Time[1],Open[1]-Atr,Time[0],Open[1]-Atr);
         ObjectSet("JJNBeeSLLevel",OBJPROP_RAY,True);
         ObjectSet("JJNBeeSLLevel",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNBeeSLLevel",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNBeeSLLevel",OBJPROP_WIDTH,1);
         ObjectSet("JJNBeeSLLevel",OBJPROP_COLOR,SellColor);
         }
      if(SoundAlert) PlaySound("alert.wav");
      }
   else if(Close[0]<Open[1] && Close[1]>Open[1]) // SELL
      {
      ObjectSet("JJNBeeDirection",OBJPROP_XDISTANCE,PosX+2);
      ObjectSetText("JJNBeeDirection","SELL",28,"Lucida Sans Unicode",SellColor); 
      ObjectSetText("JJNBeeLevel","under "+DoubleToStr(Open[1],DisplayDecimals),9,"Lucida Sans Unicode",SellColor); 
      if(Show_Levels)
         {
         ObjectCreate("JJNBeeEntryLevel",OBJ_TREND,0,Time[1],Open[1],Time[0],Open[1]);
         ObjectSet("JJNBeeEntryLevel",OBJPROP_RAY,True);
         ObjectSet("JJNBeeEntryLevel",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNBeeEntryLevel",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNBeeEntryLevel",OBJPROP_WIDTH,1);
         ObjectSet("JJNBeeEntryLevel",OBJPROP_COLOR,FontColor);
         ObjectCreate("JJNBeeTPLevel",OBJ_TREND,0,Time[1],Open[1]-Atr,Time[0],Open[1]-Atr);
         ObjectSet("JJNBeeTPLevel",OBJPROP_RAY,True);
         ObjectSet("JJNBeeTPLevel",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNBeeTPLevel",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNBeeTPLevel",OBJPROP_WIDTH,1);
         ObjectSet("JJNBeeTPLevel",OBJPROP_COLOR,BuyColor);
         ObjectCreate("JJNBeeSLLevel",OBJ_TREND,0,Time[1],Open[1]+Atr,Time[0],Open[1]+Atr);
         ObjectSet("JJNBeeSLLevel",OBJPROP_RAY,True);
         ObjectSet("JJNBeeSLLevel",OBJPROP_BACK,True); // obj in the background
         ObjectSet("JJNBeeSLLevel",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet("JJNBeeSLLevel",OBJPROP_WIDTH,1);
         ObjectSet("JJNBeeSLLevel",OBJPROP_COLOR,SellColor);
         }
      if(SoundAlert) PlaySound("alert.wav");
      }
   else 
      {
      ObjectSet("JJNBeeDirection",OBJPROP_XDISTANCE,PosX+8);
      ObjectSetText("JJNBeeDirection","WAIT",20,"Lucida Sans Unicode",FontColor); 
      ObjectSetText("JJNBeeLevel","",9,"Lucida Sans Unicode",FontColor);
      ObjectDelete("JJNBeeEntryLevel");  
      ObjectDelete("JJNBeeTPLevel");
      ObjectDelete("JJNBeeSLLevel");
      }
  
   //Comment("");
   
         
    
//---- done
   return(0);
  }
//+------------------------------------------------------------------+