//+------------------------------------------------------------------+
//|                                     Higher_TimeFrame_Trend .mq4  |
//|                                     Copyright © 2010, Des ORegan |
//|                                     mailto:                      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Des ORegan"
#property link      ""


#property indicator_chart_window

#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Gray 


#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2


//---- input parameters
extern int Upper_Timeframe = 240;
extern int Upper_Timeframe_MA_1 = 10;
extern int Upper_Timeframe_MA_2 = 20;
extern int Upper_Timeframe_MA_3 = 50;
extern int Upper_Timeframe_MA_4 = 100;
extern bool RSI_Check_On = true;
extern bool RSI_Alert_On = true;
extern int RSI_Period = 12;
extern int Upper_RSI_Limit = 70;
extern int Lower_RSI_Limit = 30;
extern int PCI_Period = 5;
extern int PCI_Shift = 1;
extern double Entry_Buffer = 0.0002;
extern color Dot_Color = Blue;



int MA_Factor;
bool RSI_OverSold = false;
bool RSI_OverBought = false;
datetime Current_Alert_Time = 0;
bool OB_Alert_Active = false; //OverBought Alert Active
bool OS_Alert_Active = false; //OverSold Alert Active


//---- buffers
double Trend_Up[];
double Trend_Down[];
double Trend_Sideways[];



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
   {
   

   //======================
   // Indicator Labels
   //======================
   SetIndexStyle(0,DRAW_LINE,0,2); //,Up_Trend);
   SetIndexBuffer(0,Trend_Up);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_LINE,0,2); //,Down_Trend);
   SetIndexBuffer(1,Trend_Down);
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(2,DRAW_LINE,0,2); //,No_Trend);
   SetIndexBuffer(2,Trend_Sideways);   
   SetIndexEmptyValue(2,0.0);
  
   
   
   
   //======================
   // Indicator Labels
   //======================
   SetIndexLabel(0,"Trending Up");   
   SetIndexLabel(1,"Trending Down");
   SetIndexLabel(2,"No Trend");     
   
   
   MA_Factor = Upper_Timeframe/Period();




   return(0);
   }
   
   
   
   
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
   {

    int Total = ObjectsTotal();
    string String;

    for(int i = Total-1; i >= 0; i--)
        { 

        if (StringFind(ObjectName(i), "Higher_TimeFrame_Trend",0) >= 0 ) ObjectDelete(ObjectName(i));
        }    



   return(0);
   }
   
   
   
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

  
   //=======================
   // Indicator Optimization
   //=======================
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return;
   if(counted_bars > 0) counted_bars--;
   int Limit = Bars - counted_bars;

   
   //======================
   // Main Indicator Loop
   //======================   
   for (int i= Limit; i >= 0; i--) // Main indicator FOR loop
      {  
      
  
      double  MA_1 = iMA(Symbol(),0,(Upper_Timeframe_MA_1*MA_Factor),0,MODE_EMA,PRICE_CLOSE,i);
      double  MA_2 = iMA(Symbol(),0,(Upper_Timeframe_MA_2*MA_Factor),0,MODE_EMA,PRICE_CLOSE,i);
      double  MA_3 = iMA(Symbol(),0,(Upper_Timeframe_MA_3*MA_Factor),0,MODE_EMA,PRICE_CLOSE,i);
      double  MA_4 = iMA(Symbol(),0,(Upper_Timeframe_MA_4*MA_Factor),0,MODE_EMA,PRICE_CLOSE,i);
      double  RSI  = iRSI(Symbol(),0,RSI_Period,PRICE_CLOSE,i);
      double  Upper_PCI = iHigh(Symbol(),0,iHighest(Symbol(),0, MODE_HIGH, PCI_Period,i+PCI_Shift));
      double  Lower_PCI = iLow(Symbol(),0,iLowest(Symbol(),0, MODE_LOW, PCI_Period,i+PCI_Shift));
   
          
   
   
      if (MA_1 > MA_2 && MA_2 > MA_3 && MA_3 > MA_4) // Up Trend
         {
         Trend_Up[i] = Upper_PCI+Entry_Buffer;
         Trend_Sideways[i] = 0;
         Trend_Down[i] = 0;
         if (RSI <= Lower_RSI_Limit && RSI_Check_On == true)
            {
            ObjectCreate("Higher_TimeFrame_Trend_"+TimeToStr(iTime(Symbol(),0,i)),OBJ_ARROW,0,iTime(0,0,i),iLow(0,0,i));
            ObjectSet("Higher_TimeFrame_Trend_"+TimeToStr(iTime(Symbol(),0,i)),OBJPROP_COLOR,Dot_Color);
            ObjectSet("Higher_TimeFrame_Trend_"+TimeToStr(iTime(Symbol(),0,i)),OBJPROP_ARROWCODE,108);
            ObjectSet("Higher_TimeFrame_Trend_"+TimeToStr(iTime(Symbol(),0,i)),OBJPROP_BACK,false);
            ObjectSet("Higher_TimeFrame_Trend_"+TimeToStr(iTime(Symbol(),0,i)),OBJPROP_WIDTH,1); 
            if (OS_Alert_Active == false && RSI_Alert_On == true && i == 0 && Current_Alert_Time != iTime(0,0,0))
               {
               Alert("RSI OverSold");
               Current_Alert_Time = iTime(0,0,0);
               OS_Alert_Active = true;
               }      
            }        
         }
      else if (MA_1 < MA_2 && MA_2 < MA_3 && MA_3 < MA_4) // Down Trend
         {
         Trend_Down[i] = Lower_PCI-Entry_Buffer;         
         Trend_Sideways[i] = 0;
         Trend_Up[i] = 0;
         if (RSI >= Upper_RSI_Limit && RSI_Check_On == true)
            {
            ObjectCreate("Higher_TimeFrame_Trend_"+TimeToStr(iTime(Symbol(),0,i)),OBJ_ARROW,0,iTime(0,0,i),iHigh(0,0,i));
            ObjectSet("Higher_TimeFrame_Trend_"+TimeToStr(iTime(Symbol(),0,i)),OBJPROP_COLOR,Dot_Color);
            ObjectSet("Higher_TimeFrame_Trend_"+TimeToStr(iTime(Symbol(),0,i)),OBJPROP_ARROWCODE,108);
            ObjectSet("Higher_TimeFrame_Trend_"+TimeToStr(iTime(Symbol(),0,i)),OBJPROP_BACK,false);
            ObjectSet("Higher_TimeFrame_Trend_"+TimeToStr(iTime(Symbol(),0,i)),OBJPROP_WIDTH,1);  
            if (OB_Alert_Active == false && RSI_Alert_On == true && i == 0 && Current_Alert_Time != iTime(0,0,0)) //RSI_Alerted(0) == false
               {
               Alert("RSI OverBought");
               Current_Alert_Time = iTime(0,0,0);
               OB_Alert_Active = true;
               }
            }       
         }
      else // No Higher TimeFrame Trend
         {
         Trend_Sideways[i] = iClose(Symbol(),0,i);
         Trend_Up[i] = 0;
         Trend_Down[i] = 0;     
         }         
           

      if (RSI < 50 && i == 0)
         {
         OB_Alert_Active = false;
         }
      else if (RSI > 50 && i == 0)
         {
         OS_Alert_Active = false;
         }      

         
         

      } // end of main function loop
      
         


   return(0);
  }
  
  
  

    

