//+------------------------------------------------------------------+
//|                                                  JJN-InfoBar.mq4 |
//|                                      Copyright © 2010, JJ Newark |
//|                                           http://jjnewark.atw.hu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, JJ Newark"
#property link      "http://jjnewark.atw.hu"

#property indicator_chart_window

int tframe[]={1,5,15,30,60,240,1440,10080,43200};
int tfnumber=9;    

extern string     _Copyright_                 = "http://jjnewark.atw.hu";
extern string     _IndicatorSetup_            = ">>> Indicator Setup:<<<";
extern int        ADX_Period                  = 14;
extern int        ADX_Price                   = PRICE_CLOSE;
extern double     Step_Psar                   = 0.02;
extern double     Max_Psar                    = 0.2;
extern int        RSI_Period                  = 14;
extern int        Stoch_KPeriod               = 5;
extern int        Stoch_DPeriod               = 3;
extern int        Stoch_Slowing               = 3;
extern int        Macd_FastP                  = 12;
extern int        Macd_SlowP                  = 26;
extern int        Macd_SignalP                = 9;

extern string     _DisplaySetup_              = ">>> Display Setup:<<<";
extern string     Help_for_BigPrice_Decimals  = "Used only: 2,3,4,5!";
extern int        BigPrice_Decimals           = 5;
extern color      UpColor                     = Lime;
extern color      DownColor                   = OrangeRed;
extern color      FlatColor                   = Gold;
extern color      TextColor                   = Silver;
extern color      SeparatorColor              = DimGray;
extern bool       ShowBackground              = TRUE;
extern color      BackgroundColor             = Black;
extern int        PosX                        = 0;
extern int        PosY                        = 0;

double Psar;
double PADX,NADX;
string TimeFrameStr;
double IndVal[9];
double Rsi1,Rsi2,Stoch_Main,Stoch_Signal,Macd_Main,Macd_Signal;
double Prev_Price;
string q="s";


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
   
   if(ShowBackground)
   {
   for(int x=0;x<6;x++) // 
   for(int w=0;w<6;w++)
      {
         ObjectCreate("Bkgrd"+x+q+w,OBJ_LABEL,0,0,0,0,0);
         ObjectSet("Bkgrd"+x+q+w,OBJPROP_CORNER,0);
         ObjectSet("Bkgrd"+x+q+w,OBJPROP_XDISTANCE,x*24+PosX+10);
         ObjectSet("Bkgrd"+x+q+w,OBJPROP_YDISTANCE,w*24+PosY);
         ObjectSetText("Bkgrd"+x+q+w,CharToStr(110),32,"Wingdings",BackgroundColor);
      }
   } 
      
      
   for(int j=0;j<tfnumber;j++)
      {
         ObjectCreate("Ind"+j,OBJ_LABEL,0,0,0,0,0);
         ObjectSet("Ind"+j,OBJPROP_CORNER,0);
         ObjectSet("Ind"+j,OBJPROP_XDISTANCE,j*16+PosX+15);
         ObjectSet("Ind"+j,OBJPROP_YDISTANCE,PosY+32);
         ObjectSetText("Ind"+j,CharToStr(110),12,"Wingdings",White);
      }


   ObjectCreate("IndName",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("IndName",OBJPROP_CORNER,0);
   ObjectSet("IndName",OBJPROP_XDISTANCE,PosX+56);
   ObjectSet("IndName",OBJPROP_YDISTANCE,PosY+10);
   ObjectSetText("IndName","JJN-InfoBar",8,"Tahoma",TextColor);
   
   ObjectCreate("Line0",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Line0",OBJPROP_CORNER,0);
   ObjectSet("Line0",OBJPROP_XDISTANCE,PosX+17);
   ObjectSet("Line0",OBJPROP_YDISTANCE,PosY+16);
   ObjectSetText("Line0","----------------------------------",8,"Tahoma",SeparatorColor);
   
   ObjectCreate("Line1",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Line1",OBJPROP_CORNER,0);
   ObjectSet("Line1",OBJPROP_XDISTANCE,PosX+17);
   ObjectSet("Line1",OBJPROP_YDISTANCE,PosY+18);
   ObjectSetText("Line1","----------------------------------",8,"Tahoma",SeparatorColor);

   ObjectCreate("TFrame",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("TFrame",OBJPROP_CORNER,0);
   ObjectSet("TFrame",OBJPROP_XDISTANCE,PosX+17);
   ObjectSet("TFrame",OBJPROP_YDISTANCE,PosY+24);
   ObjectSetText("TFrame","1    5   15  30  H1 H4  D  W   M",8,"Tahoma",TextColor);
   
   ObjectCreate("Line2",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Line2",OBJPROP_CORNER,0);
   ObjectSet("Line2",OBJPROP_XDISTANCE,PosX+16);
   ObjectSet("Line2",OBJPROP_YDISTANCE,PosY+40);
   ObjectSetText("Line2","..............................................",8,"Tahoma",SeparatorColor);

   ObjectCreate("Line3",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Line3",OBJPROP_CORNER,0);
   ObjectSet("Line3",OBJPROP_XDISTANCE,PosX+16);
   ObjectSet("Line3",OBJPROP_YDISTANCE,PosY+55);
   ObjectSetText("Line3","..............................................",8,"Tahoma",SeparatorColor);
   
   ObjectCreate("Line4",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Line4",OBJPROP_CORNER,0);
   ObjectSet("Line4",OBJPROP_XDISTANCE,PosX+16);
   ObjectSet("Line4",OBJPROP_YDISTANCE,PosY+70);
   ObjectSetText("Line4","..............................................",8,"Tahoma",SeparatorColor);
   
   ObjectCreate("Line5",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Line5",OBJPROP_CORNER,0);
   ObjectSet("Line5",OBJPROP_XDISTANCE,PosX+17);
   ObjectSet("Line5",OBJPROP_YDISTANCE,PosY+131);
   ObjectSetText("Line5","----------------------------------",8,"Tahoma",SeparatorColor);
   
   ObjectCreate("Line6",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Line6",OBJPROP_CORNER,0);
   ObjectSet("Line6",OBJPROP_XDISTANCE,PosX+17);
   ObjectSet("Line6",OBJPROP_YDISTANCE,PosY+133);
   ObjectSetText("Line6","----------------------------------",8,"Tahoma",SeparatorColor);
   
   ObjectCreate("GGekko",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("GGekko",OBJPROP_CORNER,0);
   ObjectSet("GGekko",OBJPROP_XDISTANCE,PosX+35);
   ObjectSet("GGekko",OBJPROP_YDISTANCE,PosY+140);
   ObjectSetText("GGekko","http://jjnewark.atw.hu",8,"Tahoma",TextColor);
   
   
   

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

   ObjectDelete("TFrame");
   for(int k=0;k<tfnumber;k++)
      ObjectDelete("Ind"+k);
   ObjectDelete("Line0");
   ObjectDelete("Line1");
   ObjectDelete("Line2");
   ObjectDelete("Line3");
   ObjectDelete("Line4");
   ObjectDelete("Line5");
   ObjectDelete("Line6");
   ObjectDelete("GGekko");
   ObjectDelete("IndName");
      
   ObjectDelete("Time_remain");
   ObjectDelete("Rsi_val");
   ObjectDelete("Stoch_val");
   ObjectDelete("Macd_val");
   ObjectDelete("Rsi_updown");
   ObjectDelete("Stoch_updown");
   ObjectDelete("Macd_updown");
   ObjectDelete("Spread");
   ObjectDelete("PriceDisplay");
   
   for(int x=0;x<46;x++)
   for(int w=0;w<130;w++)
      {
         ObjectDelete("Bkgrd"+x+q+w);
      }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
//----
   
     
  
   Rsi1=iRSI(NULL,0,RSI_Period,PRICE_CLOSE,0);
   Rsi2=iRSI(NULL,0,RSI_Period,PRICE_CLOSE,1);
   ObjectCreate("Rsi_val",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Rsi_val",OBJPROP_CORNER,0);
   ObjectSet("Rsi_val",OBJPROP_XDISTANCE,PosX+17);
   ObjectSet("Rsi_val",OBJPROP_YDISTANCE,PosY+50);
   ObjectSetText("Rsi_val",StringConcatenate("RSI: ",DoubleToStr(Rsi1,0)),8,"Tahoma",TextColor);
       
   ObjectCreate("Rsi_updown",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Rsi_updown",OBJPROP_CORNER,0);
   ObjectSet("Rsi_updown",OBJPROP_XDISTANCE,PosX+63);
   ObjectSet("Rsi_updown",OBJPROP_YDISTANCE,PosY+48);
   if(Rsi1>Rsi2)
   ObjectSetText("Rsi_updown",CharToStr(110),12,"Wingdings",UpColor); 
   if(Rsi1<Rsi2)
   ObjectSetText("Rsi_updown",CharToStr(110),12,"Wingdings",DownColor);
   if(Rsi1==Rsi2)
   ObjectSetText("Rsi_updown",CharToStr(110),12,"Wingdings",FlatColor);
   
   Stoch_Main=iStochastic(NULL,0,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,MODE_SMA,0,MODE_MAIN,0);
   Stoch_Signal=iStochastic(NULL,0,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,MODE_SMA,0,MODE_SIGNAL,0);
   ObjectCreate("Stoch_val",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Stoch_val",OBJPROP_CORNER,0);
   ObjectSet("Stoch_val",OBJPROP_XDISTANCE,PosX+81);
   ObjectSet("Stoch_val",OBJPROP_YDISTANCE,PosY+50);
   ObjectSetText("Stoch_val",StringConcatenate("STOCH: ",DoubleToStr(Stoch_Main,0)),8,"Tahoma",TextColor);
   
   ObjectCreate("Stoch_updown",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Stoch_updown",OBJPROP_CORNER,0);
   ObjectSet("Stoch_updown",OBJPROP_XDISTANCE,PosX+143);
   ObjectSet("Stoch_updown",OBJPROP_YDISTANCE,PosY+48);
   if(Stoch_Main>Stoch_Signal)
   ObjectSetText("Stoch_updown",CharToStr(110),12,"Wingdings",UpColor); 
   if(Stoch_Main<Stoch_Signal)
   ObjectSetText("Stoch_updown",CharToStr(110),12,"Wingdings",DownColor);
   if(Stoch_Main==Stoch_Signal)
   ObjectSetText("Stoch_updown",CharToStr(110),12,"Wingdings",FlatColor);
   
   Macd_Main=iMACD(NULL,0,Macd_FastP,Macd_SlowP,Macd_SignalP,PRICE_CLOSE,MODE_MAIN,0);
   Macd_Signal=iMACD(NULL,0,Macd_FastP,Macd_SlowP,Macd_SignalP,PRICE_CLOSE,MODE_SIGNAL,0);
   ObjectCreate("Macd_val",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Macd_val",OBJPROP_CORNER,0);
   ObjectSet("Macd_val",OBJPROP_XDISTANCE,PosX+17);
   ObjectSet("Macd_val",OBJPROP_YDISTANCE,PosY+65);
   ObjectSetText("Macd_val","MACD trend",8,"Tahoma",TextColor);
   
   ObjectCreate("Macd_updown",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Macd_updown",OBJPROP_CORNER,0);
   ObjectSet("Macd_updown",OBJPROP_XDISTANCE,PosX+79);
   ObjectSet("Macd_updown",OBJPROP_YDISTANCE,PosY+63);
   if(Macd_Main>Macd_Signal)
   ObjectSetText("Macd_updown",CharToStr(110),12,"Wingdings",UpColor); 
   if(Macd_Main<Macd_Signal)
   ObjectSetText("Macd_updown",CharToStr(110),12,"Wingdings",DownColor);
   if(Macd_Main==Macd_Signal)
   ObjectSetText("Macd_updown",CharToStr(110),12,"Wingdings",FlatColor);
   
   ObjectCreate("Spread",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Spread",OBJPROP_CORNER,0);
   ObjectSet("Spread",OBJPROP_XDISTANCE,PosX+103);
   ObjectSet("Spread",OBJPROP_YDISTANCE,PosY+65);
   ObjectSetText("Spread",StringConcatenate("Spread: ",MarketInfo(Symbol(),MODE_SPREAD)),8,"Tahoma",TextColor);
      
   datetime closetime=Time[0]+(Time[0]-Time[1])-TimeCurrent();
   ObjectCreate("Time_remain",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Time_remain",OBJPROP_CORNER,0);
   ObjectSet("Time_remain",OBJPROP_XDISTANCE,PosX+17);
   ObjectSet("Time_remain",OBJPROP_YDISTANCE,PosY+80);
   ObjectSetText("Time_remain",StringConcatenate("Remaining bartime:  ",TimeToStr(closetime,TIME_SECONDS)),8,"Tahoma",TextColor);
   
   ObjectCreate("PriceDisplay",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("PriceDisplay",OBJPROP_CORNER,0);
   if(BigPrice_Decimals==2)
   ObjectSet("PriceDisplay",OBJPROP_XDISTANCE,PosX+44);
   if(BigPrice_Decimals==3)
   ObjectSet("PriceDisplay",OBJPROP_XDISTANCE,PosX+40);
   if(BigPrice_Decimals==4)
   ObjectSet("PriceDisplay",OBJPROP_XDISTANCE,PosX+36);
   if(BigPrice_Decimals==5)
   ObjectSet("PriceDisplay",OBJPROP_XDISTANCE,PosX+28);
   ObjectSet("PriceDisplay",OBJPROP_YDISTANCE,PosY+95);
   if(iClose(NULL,0,0)>Prev_Price)
   ObjectSetText("PriceDisplay",DoubleToStr(iClose(NULL,0,0),BigPrice_Decimals),24,"Tahoma",UpColor);
   if(iClose(NULL,0,0)<Prev_Price)
   ObjectSetText("PriceDisplay",DoubleToStr(iClose(NULL,0,0),BigPrice_Decimals),24,"Tahoma",DownColor);
   Prev_Price=iClose(NULL,0,0);  
   
   
      
    
   for(int x=0;x<tfnumber;x++)
      {
      
      PADX=iADX(NULL,tframe[x],ADX_Period ,ADX_Price,1,0);
      NADX=iADX(NULL,tframe[x],ADX_Period ,ADX_Price,2,0);
      Psar=iSAR(NULL,tframe[x],Step_Psar,Max_Psar,0) ;
        if (Psar < iClose(NULL,tframe[x],0) && PADX > NADX)
        {
        IndVal[x]=1;
        }
        else if (Psar > iClose(NULL,tframe[x],0) && NADX > PADX)
        {
        IndVal[x]=-1;
        }
        else IndVal[x]=0;
      }
   
   
   
      for(int y=0;y<tfnumber;y++)
      {
         if(IndVal[y]==-1) ObjectSetText("Ind"+y,CharToStr(110),12,"Wingdings",DownColor);
         if(IndVal[y]==0) ObjectSetText("Ind"+y,CharToStr(110),12,"Wingdings",FlatColor);
         if(IndVal[y]==1) ObjectSetText("Ind"+y,CharToStr(110),12,"Wingdings",UpColor);
      }  
           
   
//----
   return(0);
  }
//+------------------------------------------------------------------+