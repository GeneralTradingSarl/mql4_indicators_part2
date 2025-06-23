//+------------------------------------------------------------------+
//|                                                 GG-RiverFlow.mq4 |
//|                                         Copyright © 2009, GGekko |
//|                                         http://www.fx-ggekko.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, GGekko"
#property link      "http://www.fx-ggekko.com"

#property indicator_chart_window

extern string   ___IndicatorSetup___   = ">>> Indicator Setup:<<<";
extern string   Help_for_TFNumbers     = "Maximum: 7";
extern int      TFNumbers              = 7; // max 7
extern int      MA_Shift               = 1;
extern string   ___DisplaySetup___     = ">>> Display Setup:<<<";
extern color    UpColor                = YellowGreen;
extern color    DownColor              = Tomato;
extern color    FlatColor              = Gold;
extern color    TextColor              = CadetBlue;
extern string   Help_for_Corner        = "LeftTop:0, RightTop:1, Not used:2,3!";
extern int      Corner                 = 0;
extern int      PosX                   = 0;
extern int      PosY                   = 0;
extern int      Unique_Id              = 52725;  

int tframe[]={1,5,15,30,60,240,1440};
string tf[]={"1","5","15","30","H1","H4","D1"};
int ma_period[]={2,3,5,8,13,21,34,55,89,144};

string ind[10];
double ma0_1[],ma0_2[];
double ma1_1[],ma1_2[];
double ma2_1[],ma2_2[];
double ma3_1[],ma3_2[];
double ma4_1[],ma4_2[];
double ma5_1[],ma5_2[];
double ma6_1[],ma6_2[];
double ma7_1[],ma7_2[];
double ma8_1[],ma8_2[];
double ma9_1[],ma9_2[];

double IndVal[10][7];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   if(Corner==0)
   {
   for(int w=0;w<TFNumbers;w++)
      {
         ObjectCreate(Unique_Id+tf[w],OBJ_LABEL,0,0,0,0,0);
         ObjectSet(Unique_Id+tf[w],OBJPROP_CORNER,Corner);
         ObjectSet(Unique_Id+tf[w],OBJPROP_XDISTANCE,w*17+PosX+19);
         ObjectSet(Unique_Id+tf[w],OBJPROP_YDISTANCE,PosY+20);
         ObjectSetText(Unique_Id+tf[w],tf[w],8,"Tahoma",TextColor);
      } 

   for(int x=0;x<7;x++) // 
   for(w=0;w<10;w++)
      {
         ObjectCreate(Unique_Id+"Ind"+x+w,OBJ_LABEL,0,0,0,0,0);
         ObjectSet(Unique_Id+"Ind"+x+w,OBJPROP_CORNER,Corner);
         ObjectSet(Unique_Id+"Ind"+x+w,OBJPROP_XDISTANCE,x*17+PosX+15);
         ObjectSet(Unique_Id+"Ind"+x+w,OBJPROP_YDISTANCE,w*6+PosY);
         ObjectSetText(Unique_Id+"Ind"+x+w,"-",42,"Arial",TextColor);
      }
   }
   
   if(Corner==1)
   {
   for(w=0;w<TFNumbers;w++)
      {
         ObjectCreate(Unique_Id+tf[TFNumbers-1-w],OBJ_LABEL,0,0,0,0,0);
         ObjectSet(Unique_Id+tf[TFNumbers-1-w],OBJPROP_CORNER,Corner);
         ObjectSet(Unique_Id+tf[TFNumbers-1-w],OBJPROP_XDISTANCE,w*17+PosX+19);
         ObjectSet(Unique_Id+tf[TFNumbers-1-w],OBJPROP_YDISTANCE,PosY+20);
         ObjectSetText(Unique_Id+tf[TFNumbers-1-w],tf[TFNumbers-1-w],8,"Tahoma",TextColor);
      } 

   for(x=0;x<7;x++) // 
   for(w=0;w<10;w++)
      {
         ObjectCreate(Unique_Id+"Ind"+(TFNumbers-1-x)+w,OBJ_LABEL,0,0,0,0,0);
         ObjectSet(Unique_Id+"Ind"+(TFNumbers-1-x)+w,OBJPROP_CORNER,Corner);
         ObjectSet(Unique_Id+"Ind"+(TFNumbers-1-x)+w,OBJPROP_XDISTANCE,x*17+PosX+15);
         ObjectSet(Unique_Id+"Ind"+(TFNumbers-1-x)+w,OBJPROP_YDISTANCE,w*6+PosY);
         ObjectSetText(Unique_Id+"Ind"+(TFNumbers-1-x)+w,"-",42,"Arial",TextColor);
      }
   }
   
   if(Corner==0 || Corner==1)
   {
   ObjectCreate(Unique_Id+"LineTop0",OBJ_LABEL,0,0,0,0,0);
   ObjectSet(Unique_Id+"LineTop0",OBJPROP_CORNER,Corner);
   ObjectSet(Unique_Id+"LineTop0",OBJPROP_XDISTANCE,PosX+13);
   ObjectSet(Unique_Id+"LineTop0",OBJPROP_YDISTANCE,PosY+12);
   ObjectSetText(Unique_Id+"LineTop0","          ----------------          ",8,"Tahoma",TextColor);
   
   ObjectCreate(Unique_Id+"LineTop",OBJ_LABEL,0,0,0,0,0);
   ObjectSet(Unique_Id+"LineTop",OBJPROP_CORNER,Corner);
   ObjectSet(Unique_Id+"LineTop",OBJPROP_XDISTANCE,PosX+13);
   ObjectSet(Unique_Id+"LineTop",OBJPROP_YDISTANCE,PosY+14);
   ObjectSetText(Unique_Id+"LineTop","-------------------------------",8,"Tahoma",TextColor);
   
   ObjectCreate(Unique_Id+"LineHigh",OBJ_LABEL,0,0,0,0,0);
   ObjectSet(Unique_Id+"LineHigh",OBJPROP_CORNER,Corner);
   ObjectSet(Unique_Id+"LineHigh",OBJPROP_XDISTANCE,PosX+13);
   ObjectSet(Unique_Id+"LineHigh",OBJPROP_YDISTANCE,PosY+26);
   ObjectSetText(Unique_Id+"LineHigh","-------------------------------",8,"Tahoma",TextColor);
      
   ObjectCreate(Unique_Id+"LineLow",OBJ_LABEL,0,0,0,0,0);
   ObjectSet(Unique_Id+"LineLow",OBJPROP_CORNER,Corner);
   ObjectSet(Unique_Id+"LineLow",OBJPROP_XDISTANCE,PosX+13);
   ObjectSet(Unique_Id+"LineLow",OBJPROP_YDISTANCE,PosY+90);
   ObjectSetText(Unique_Id+"LineLow","-------------------------------",8,"Tahoma",TextColor);
   
   ObjectCreate(Unique_Id+"IndName",OBJ_LABEL,0,0,0,0,0);
   ObjectSet(Unique_Id+"IndName",OBJPROP_CORNER,Corner);
   ObjectSet(Unique_Id+"IndName",OBJPROP_XDISTANCE,PosX+43);
   ObjectSet(Unique_Id+"IndName",OBJPROP_YDISTANCE,PosY+6);
   ObjectSetText(Unique_Id+"IndName","GG-RiverFlow",8,"Tahoma",TextColor);
   
   ObjectCreate(Unique_Id+"Copyright",OBJ_LABEL,0,0,0,0,0);
   ObjectSet(Unique_Id+"Copyright",OBJPROP_CORNER,Corner);
   ObjectSet(Unique_Id+"Copyright",OBJPROP_XDISTANCE,PosX+28);
   ObjectSet(Unique_Id+"Copyright",OBJPROP_YDISTANCE,PosY+96);
   ObjectSetText(Unique_Id+"Copyright","www.fx-ggekko.com",8,"Tahoma",TextColor);
   }
                            
   ArrayResize(ma0_1,TFNumbers);ArrayResize(ma0_2,TFNumbers);
   ArrayResize(ma1_1,TFNumbers);ArrayResize(ma1_2,TFNumbers);
   ArrayResize(ma2_1,TFNumbers);ArrayResize(ma2_2,TFNumbers);
   ArrayResize(ma3_1,TFNumbers);ArrayResize(ma3_2,TFNumbers);
   ArrayResize(ma4_1,TFNumbers);ArrayResize(ma4_2,TFNumbers);
   ArrayResize(ma5_1,TFNumbers);ArrayResize(ma5_2,TFNumbers);
   ArrayResize(ma6_1,TFNumbers);ArrayResize(ma6_2,TFNumbers);
   ArrayResize(ma7_1,TFNumbers);ArrayResize(ma7_2,TFNumbers);
   ArrayResize(ma8_1,TFNumbers);ArrayResize(ma8_2,TFNumbers);
   ArrayResize(ma9_1,TFNumbers);ArrayResize(ma9_2,TFNumbers);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int w=0;w<TFNumbers;w++)
      {
         ObjectDelete(Unique_Id+tf[w]);
      }   
         
   for(int x=0;x<TFNumbers;x++)
   for(w=0;w<10;w++)
      {
         ObjectDelete(Unique_Id+"Ind"+x+w);
      }
   
   ObjectDelete(Unique_Id+"LineTop0");   
   ObjectDelete(Unique_Id+"LineTop");
   ObjectDelete(Unique_Id+"LineHigh");
   ObjectDelete(Unique_Id+"LineLow");
   ObjectDelete(Unique_Id+"IndName");
   ObjectDelete(Unique_Id+"Copyright");
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   
   for(int x=0;x<TFNumbers;x++)
   {
      ma0_1[x]=iMA(NULL,tframe[x],ma_period[0],0,MODE_EMA,PRICE_CLOSE,0);
      ma0_2[x]=iMA(NULL,tframe[x],ma_period[0],MA_Shift,MODE_EMA,PRICE_CLOSE,0);
      ma1_1[x]=iMA(NULL,tframe[x],ma_period[1],0,MODE_EMA,PRICE_CLOSE,0);
      ma1_2[x]=iMA(NULL,tframe[x],ma_period[1],MA_Shift,MODE_EMA,PRICE_CLOSE,0);
      ma2_1[x]=iMA(NULL,tframe[x],ma_period[2],0,MODE_EMA,PRICE_CLOSE,0);
      ma2_2[x]=iMA(NULL,tframe[x],ma_period[2],MA_Shift,MODE_EMA,PRICE_CLOSE,0);
      ma3_1[x]=iMA(NULL,tframe[x],ma_period[3],0,MODE_EMA,PRICE_CLOSE,0);
      ma3_2[x]=iMA(NULL,tframe[x],ma_period[3],MA_Shift,MODE_EMA,PRICE_CLOSE,0);
      ma4_1[x]=iMA(NULL,tframe[x],ma_period[4],0,MODE_EMA,PRICE_CLOSE,0);
      ma4_2[x]=iMA(NULL,tframe[x],ma_period[4],MA_Shift,MODE_EMA,PRICE_CLOSE,0);
      ma5_1[x]=iMA(NULL,tframe[x],ma_period[5],0,MODE_EMA,PRICE_CLOSE,0);
      ma5_2[x]=iMA(NULL,tframe[x],ma_period[5],MA_Shift,MODE_EMA,PRICE_CLOSE,0);
      ma6_1[x]=iMA(NULL,tframe[x],ma_period[6],0,MODE_EMA,PRICE_CLOSE,0);
      ma6_2[x]=iMA(NULL,tframe[x],ma_period[6],MA_Shift,MODE_EMA,PRICE_CLOSE,0);
      ma7_1[x]=iMA(NULL,tframe[x],ma_period[7],0,MODE_EMA,PRICE_CLOSE,0);
      ma7_2[x]=iMA(NULL,tframe[x],ma_period[7],MA_Shift,MODE_EMA,PRICE_CLOSE,0);
      ma8_1[x]=iMA(NULL,tframe[x],ma_period[8],0,MODE_EMA,PRICE_CLOSE,0);
      ma8_2[x]=iMA(NULL,tframe[x],ma_period[8],MA_Shift,MODE_EMA,PRICE_CLOSE,0);
      ma9_1[x]=iMA(NULL,tframe[x],ma_period[9],0,MODE_EMA,PRICE_CLOSE,0);
      ma9_2[x]=iMA(NULL,tframe[x],ma_period[9],MA_Shift,MODE_EMA,PRICE_CLOSE,0);
    }  
      
      
    for(x=0;x<TFNumbers;x++)
    {  
      if(ma0_1[x]>ma0_2[x]) IndVal[0][x]=1;
      else if(ma0_1[x]<ma0_2[x]) IndVal[0][x]=-1;
      else IndVal[0][x]=0;
      
      if(ma1_1[x]>ma1_2[x]) IndVal[1][x]=1;
      else if(ma1_1[x]<ma1_2[x]) IndVal[1][x]=-1;
      else IndVal[1][x]=0;
      
      if(ma2_1[x]>ma2_2[x]) IndVal[2][x]=1;
      else if(ma2_1[x]<ma2_2[x]) IndVal[2][x]=-1;
      else IndVal[2][x]=0;
      
      if(ma3_1[x]>ma3_2[x]) IndVal[3][x]=1;
      else if(ma3_1[x]<ma3_2[x]) IndVal[3][x]=-1;
      else IndVal[3][x]=0;
      
      if(ma4_1[x]>ma4_2[x]) IndVal[4][x]=1;
      else if(ma4_1[x]<ma4_2[x]) IndVal[4][x]=-1;
      else IndVal[4][x]=0;
      
      if(ma5_1[x]>ma5_2[x]) IndVal[5][x]=1;
      else if(ma5_1[x]<ma5_2[x]) IndVal[5][x]=-1;
      else IndVal[5][x]=0;
      
      if(ma6_1[x]>ma6_2[x]) IndVal[6][x]=1;
      else if(ma6_1[x]<ma6_2[x]) IndVal[6][x]=-1;
      else IndVal[6][x]=0;
      
      if(ma7_1[x]>ma7_2[x]) IndVal[7][x]=1;
      else if(ma7_1[x]<ma7_2[x]) IndVal[7][x]=-1;
      else IndVal[7][x]=0;
      
      if(ma8_1[x]>ma8_2[x]) IndVal[8][x]=1;
      else if(ma8_1[x]<ma8_2[x]) IndVal[8][x]=-1;
      else IndVal[8][x]=0;
      
      if(ma9_1[x]>ma9_2[x]) IndVal[9][x]=1;
      else if(ma9_1[x]<ma9_2[x]) IndVal[9][x]=-1;
      else IndVal[9][x]=0;
    }
      
      for(int y=0;y<10;y++)
      for(int z=0;z<TFNumbers;z++)
      {
         if(IndVal[y][z]==-1) ObjectSetText(Unique_Id+"Ind"+z+y,"-",42,"Arial",DownColor);
         if(IndVal[y][z]==0) ObjectSetText(Unique_Id+"Ind"+z+y,"-",42,"Arial",FlatColor);
         if(IndVal[y][z]==1) ObjectSetText(Unique_Id+"Ind"+z+y,"-",42,"Arial",UpColor);
         
      } 
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+