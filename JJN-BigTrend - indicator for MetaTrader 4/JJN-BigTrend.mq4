//+------------------------------------------------------------------+
//|                                                 JJN-BigTrend.mq4 |
//|                                      Copyright © 2012, JJ Newark |
//|                                            http:/jjnewark.atw.hu |
//|                                             jjnewark@freemail.hu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, JJ Newark"
#property link      "http:/jjnewark.atw.hu"


#property indicator_chart_window


//+------------------------------------------------------------------------------------------------------------------+
// YOU CAN CHANGE THESE PARAMETERS ACCORDING TO YOUR TASTE:
//+------------------------------------------------------------------------------------------------------------------+
int     tfnumber      = 5; // Number of the timeframes
int     tframe[]      = {5,15,30,60,240}; // Timeframes in minutes
double  IndVal[][5]; // Be the second array-index equal with tfnumber
int     NumberOfPairs = 8; // Number of the pairs
string  Pairs[]       = {"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDJPY","GBPJPY","EURJPY","USDCHF"}; // Requested pairs
//+------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------+




extern int        TrendPeriod                 = 55;
extern int        Ma_Price                    = PRICE_CLOSE;
extern color      UpColor                     = Lime;
extern color      DownColor                   = OrangeRed;
extern color      FlatColor                   = Gold;
extern color      FontColor                   = Black;
extern int        PosX                        = 20;
extern int        PosY                        = 20;

double val_0,val_1;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   for(int w=0;w<NumberOfPairs;w++)
      {
      for(int j=0;j<tfnumber;j++)
      {
         ObjectCreate("BigTrendInd"+w+j,OBJ_LABEL,0,0,0,0,0);
         ObjectSet("BigTrendInd"+w+j,OBJPROP_CORNER,0);
         ObjectSet("BigTrendInd"+w+j,OBJPROP_XDISTANCE,j*16+PosX+50);
         ObjectSet("BigTrendInd"+w+j,OBJPROP_YDISTANCE,w*16+PosY+10);
         ObjectSetText("BigTrendInd"+w+j,CharToStr(110),12,"Wingdings",Silver);
      } 
      }
   
   for(w=0;w<NumberOfPairs;w++)
      {
         ObjectCreate("BigTrendPairs"+w,OBJ_LABEL,0,0,0,0,0);
         ObjectSet("BigTrendPairs"+w,OBJPROP_CORNER,0);
         ObjectSet("BigTrendPairs"+w,OBJPROP_XDISTANCE,PosX);
         ObjectSet("BigTrendPairs"+w,OBJPROP_YDISTANCE,w*16+PosY+12);
         ObjectSetText("BigTrendPairs"+w,Pairs[w],8,"Tahoma",FontColor);
      }
      
   ObjectCreate("BigTrendLine0",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("BigTrendLine0",OBJPROP_CORNER,0);
   ObjectSet("BigTrendLine0",OBJPROP_XDISTANCE,PosX+10);
   ObjectSet("BigTrendLine0",OBJPROP_YDISTANCE,NumberOfPairs*16+PosY+6);
   ObjectSetText("BigTrendLine0","   ----------------------",8,"Tahoma",FontColor);
   
   ObjectCreate("BigTrendLine1",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("BigTrendLine1",OBJPROP_CORNER,0);
   ObjectSet("BigTrendLine1",OBJPROP_XDISTANCE,PosX+10);
   ObjectSet("BigTrendLine1",OBJPROP_YDISTANCE,NumberOfPairs*16+PosY+8);
   ObjectSetText("BigTrendLine1","   ----------------------",8,"Tahoma",FontColor);

   ObjectCreate("BigTrendIndName",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("BigTrendIndName",OBJPROP_CORNER,0);
   ObjectSet("BigTrendIndName",OBJPROP_XDISTANCE,PosX+20);
   ObjectSet("BigTrendIndName",OBJPROP_YDISTANCE,NumberOfPairs*16+PosY+16);
   ObjectSetText("BigTrendIndName","JJN-BigTrend ("+TrendPeriod+")",8,"Tahoma",FontColor);
   
   
      
      
   ArrayResize(IndVal,NumberOfPairs);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int w=0;w<NumberOfPairs;w++)
      {
      for(int j=0;j<tfnumber;j++)
      {
      ObjectDelete("BigTrendInd"+w+j);
      }
      }   
      
   for(w=0;w<NumberOfPairs;w++)
      {
         ObjectDelete("BigTrendPairs"+w);
      }
      
   ObjectDelete("BigTrendLine0");
   ObjectDelete("BigTrendLine1");
   ObjectDelete("BigTrendIndName");
      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   for(int z=0;z<NumberOfPairs;z++)
      {
   for(int x=0;x<tfnumber;x++)
      {
      
      val_0=iMA(Pairs[z],tframe[x],TrendPeriod,0,MODE_EMA,Ma_Price,0);
      val_1=iMA(Pairs[z],tframe[x],TrendPeriod,1,MODE_EMA,Ma_Price,0);
      
            
        if (val_0 > val_1 && iLow(Pairs[z],tframe[x],0) > val_0) // UPTREND
        {
        IndVal[z][x]=1;
        }
        else if (val_0 < val_1 && iHigh(Pairs[z],tframe[x],0) < val_0) // DOWNTREND
        {
        IndVal[z][x]=-1;
        }
        else IndVal[z][x]=0; // RANGING
      }
      }
     
   
   for(int q=0;q<NumberOfPairs;q++)
      {
      for(int y=0;y<tfnumber;y++)
      {
         if(IndVal[q][y]==-1) ObjectSetText("BigTrendInd"+q+y,CharToStr(110),12,"Wingdings",DownColor);
         if(IndVal[q][y]==0) ObjectSetText("BigTrendInd"+q+y,CharToStr(110),12,"Wingdings",FlatColor);
         if(IndVal[q][y]==1) ObjectSetText("BigTrendInd"+q+y,CharToStr(110),12,"Wingdings",UpColor);
      }
      }
     
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+