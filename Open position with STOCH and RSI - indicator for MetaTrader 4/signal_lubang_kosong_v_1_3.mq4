//+------------------------------------------------------------------+
//|                                         signal lubang kosong.mq4 |
//|                                                      reza rahmad |
//|                                           reiz_gamer@yahoo.co.id |
//+------------------------------------------------------------------+
#property copyright "reza rahmad"
#property link      "reiz_gamer@yahoo.co.id"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_width1 3
#property indicator_width2 3


extern int fastrsi=3;
extern int slowrsi=13;
extern int kperiod=8;
extern int dperiod=3;
extern int slowingstoch=3;

extern int       FastEMA = 12;//启始买点
extern int       SlowEMA = 26;//启始买点
extern int       SignalSMA = 9;//启始买点
extern int       ARROWWIDTH = 3;
extern double    poin =15;
extern bool arrowmacd = true;



double buy[];
double sell[];
double m;
double harga1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int y = 0;
   for(int x=1;x<3;x++)
      for( y=0;y<x;y++)
      {
         ObjectCreate("signal"+x+y,OBJ_LABEL,0,0,0,0,0);
         ObjectSet("signal"+x+y,OBJPROP_XDISTANCE,x*40+100);
         ObjectSet("signal"+x+y,OBJPROP_YDISTANCE,y*20+200);
         ObjectSetText("signal"+x+y,CharToStr(73),40,"Wingdings",Magenta);
      }
 
         ObjectCreate("signal",OBJ_LABEL,0,0,0,0,0);
         ObjectSet("signal",OBJPROP_XDISTANCE,140);         
         ObjectSet("signal",OBJPROP_YDISTANCE,170);        
         ObjectSetText("signal","TAHAN",20,"TAHOMA",Magenta);
         
         ObjectCreate("trade",OBJ_LABEL,0,0,0,0,0);
         ObjectSet("trade",OBJPROP_XDISTANCE,140);         
         ObjectSet("trade",OBJPROP_YDISTANCE,160);         
         ObjectSetText("trade","kondisi masih bagus",10,"TAHOMA",Green);
         
         //        kondisi masih bagus
         ObjectCreate("jenuh",OBJ_LABEL,0,0,0,0,0);
         ObjectSet("jenuh",OBJPROP_XDISTANCE,140);         
         ObjectSet("jenuh",OBJPROP_YDISTANCE,145);
         ObjectSetText("jenuh","OP lubang kosong",10,"TAHOMA",Magenta);
        
         
         
         
         
            
       
 
   SetIndexStyle(0,DRAW_ARROW,EMPTY,3,Magenta);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,buy);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW,EMPTY,3,Magenta);
   
   SetIndexArrow(1,234);
   SetIndexBuffer(1,sell);
   SetIndexEmptyValue(1,0.0);
   
   
}
//----
 
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   ObjectsDeleteAll();
 
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   double Macd0,Macd1;
   int macd;
 
  
  // pergerakan sekarang
 
   // change the color of the mark named "signal00" (the upper left)
   // into green
 
  
  /*  
    if (arah == momen)
    {
    ObjectSetText("tremo","SEDANG TREND",10,"Tahoma",Green);
    
    } 
    else
    {
    
    ObjectSetText("tremo","reversal",10,"Tahoma",Green);
    }
   */
   //double bid   =MarketInfo("EMPTY_VALUE",MODE_BID);
   //ObjectSetText("price",DoubleToStr(bid,4),35,"TAHOMA",Green);
 
  for (int i = Bars - 1; i >= 0; i --)
  { 
      
    Macd0 = iMACD(NULL , 0 , FastEMA , SlowEMA ,SignalSMA , PRICE_CLOSE , MODE_MAIN , i);
    Macd1 = iMACD(NULL , 0 , FastEMA , SlowEMA ,SignalSMA , PRICE_CLOSE , MODE_MAIN , i+1);
    buy [i] = 0; sell [i] = 0;
    if (Macd0 > 0 && Macd1 < 0)
    {
        macd = 1;
     if (arrowmacd==true)
     {
      buy [i] = Low [i] - 5 * Point;
      
      if (Period () >= PERIOD_M30) buy [i] -= 8 * Point;
      if (Period () >= PERIOD_H1) buy [i] -= 8 * Point;
      if (Period () >= PERIOD_H4) buy [i] -= 8 * Point;
      if (Period () >= PERIOD_D1) buy [i] -= 8 * Point;
      if (Period () >= PERIOD_W1) buy [i] -= 12 * Point;
      if (Period () >= PERIOD_MN1) buy [i] -= 60 * Point;
      }
      
    }
    if (Macd0 < 0 && Macd1 > 0)
    {
       macd = 2;
     if (arrowmacd==true){
      sell [i] = High [i] + 5 * Point;
      
      if (Period () >= PERIOD_M30) sell [i] += 8 * Point;
      if (Period () >= PERIOD_H1) sell [i] += 8 * Point;
      if (Period () >= PERIOD_H4) sell [i] += 8 * Point;
      if (Period () >= PERIOD_D1) sell [i] += 8 * Point;
      if (Period () >= PERIOD_W1) sell [i] += 12 * Point;
      if (Period () >= PERIOD_MN1) sell [i] += 60 * Point;
      }
      
      
      
    }     
  }

   int r,s;
   //stoch
   if(iStochastic(NULL,0,kperiod,dperiod,slowingstoch,MODE_SMA,0,MODE_MAIN,0)>80  ||iStochastic (NULL,0,kperiod,dperiod,slowingstoch,MODE_SMA,0,MODE_MAIN,0)<20 )
      {        
       ObjectSetText("trade","OVERBOUGHT!,berubah arah take profit",11,"Tahoma",Tomato);       
      }
   else 
      {
       ObjectSetText("trade","Kondisi Masih Bagus",11,"Tahoma",Green);    
       }
   if(iStochastic(NULL,0,kperiod,dperiod,slowingstoch,MODE_SMA,0,MODE_MAIN,0)>iStochastic(NULL,0,kperiod,dperiod,slowingstoch,MODE_SMA,0,MODE_SIGNAL,0))
      {        
       ObjectSetText("signal20",CharToStr(221),20,"Wingdings",Green);
       s = 1;
      }
   else
       {
      ObjectSetText("signal20",CharToStr(222),20,"Wingdings",Tomato); 
      s = 2;
       }  
       
          //rsi
   if(iRSI(NULL,0,fastrsi,PRICE_CLOSE,0)>iRSI(NULL,0,slowrsi,PRICE_CLOSE,1))
      {
      ObjectSetText("signal21",CharToStr(221),20,"Wingdings",Green);
      r = 1;
      }
   else
      { 
      ObjectSetText("signal21",CharToStr(222),20,"Wingdings",Tomato); 
      r = 2 ;
      }
      
      // kode buy dan sell
      if (r ==1 && s == 1 && macd == 1)
      {
      ObjectSetText("signal10",CharToStr(67),40,"Wingdings",Green);
      ObjectSetText("signal","BUY KUAT",20,"TAHOMA",Green);
    
      }
      if (r ==1 && s == 1 && macd == 2)
      {
      ObjectSetText("signal10",CharToStr(67),40,"Wingdings",Green);
      ObjectSetText("signal","BUY ",20,"TAHOMA",Green);
     
      }
      if (r == 2 && s == 2 && macd == 2)
      {
      ObjectSetText("signal10",CharToStr(68),40,"Wingdings",Tomato);
      ObjectSetText("signal","SELL KUAT",20,"TAHOMA",Tomato);
      
      }
      if (r == 2 && s == 2 && macd == 1)
      {
      ObjectSetText("signal10",CharToStr(68),40,"Wingdings",Tomato);
      ObjectSetText("signal","SELL ",20,"TAHOMA",Tomato);
      
      }
      if (r == 2 && s == 1)
      {
      ObjectSetText("signal10",CharToStr(73),40,"Wingdings",Tomato);
      ObjectSetText("signal","TAHAN",20,"TAHOMA",Magenta);
      }
      if (r == 1 && s == 2)
      {
      ObjectSetText("signal10",CharToStr(73),40,"Wingdings",Tomato);
      ObjectSetText("signal","TAHAN",20,"TAHOMA",Magenta);
      }
      
   return(0);
}
//+------------------------------------------------------------------+