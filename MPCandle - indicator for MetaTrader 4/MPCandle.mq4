//+------------------------------------------------------------------+
//|                                                     MPCandle.mq4 |
//|                                     Copyright ?2013, Walter Choy |
//|                                             brother3th@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2013, Walter Choy"
#property link      "brother3th@yahoo.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow
#property indicator_width1 2
//--- parameters
extern string desc = "(Base on PERIOD values, must be smaller than the chart time frame) base_period = 1, 5, 15, 30, 60, 240...etc.";
extern int base_period = 1; //set base_period to 1 is best for M5 and M15; set to 5 is best for H4 and D1
extern int max_counting_bars = 250;

extern bool show_static = true;
extern int static_show_n = 250;
extern color static_txt_color = Black;

//--- buffers
double FocusBuffer[];
double tempBuffer[500][2];
double staticBuffer[];
int idx = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   IndicatorDigits(Digits);
 
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,FocusBuffer);
   SetIndexEmptyValue(0,0.0);
   
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, staticBuffer);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for (int n=0; n<static_show_n; n++){
      string objname = "MPC_STATIC_" + n;
      if(ObjectFind(objname) != -1){
         ObjectDelete(objname);
      }
   }   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int i = Bars - counted_bars;
   int j, k;
//----
   if(i > max_counting_bars) i = max_counting_bars;

   double interval = Period() / base_period;
      
   while(i >= 0){
      // Clear tempBuffer
      ArrayInitialize(tempBuffer, 0);
      //for (j=0; j<=idx; j++){
      //   tempBuffer[j][0] = 0;
      //   tempBuffer[j][1] = 0;
      //}
      // For each trade period, counting the occurrence
      idx = 0;      
      for(j=0; j<interval; j++){
         if(TimeCurrent() >= Time[i]+j*base_period*60){
            double cp = NormalizeDouble(iClose(NULL, base_period, iBarShift(NULL, base_period, Time[i]+j*base_period*60)), Digits - 1);
            for(k=0; k<idx; k++){
               if(tempBuffer[k][0] == cp){
                  break;
               }
            }
            if (tempBuffer[k][0] == 0) tempBuffer[k][0] = cp;
            tempBuffer[k][1]++;
            idx++;
         }
      }
      // Found out the max counting price
      int MaxNum = 0; int MaxIdx = 0;
      for (j=0; j<=idx; j++){
         if(MaxNum < tempBuffer[j][1]){
            MaxNum = tempBuffer[j][1];
            MaxIdx = j;
         }
      }
      // Set the price into indicator array
      FocusBuffer[i] = tempBuffer[MaxIdx][0];
      staticBuffer[i] = MaxNum;
      i--;
   }
   
   if(show_static){
      double sp = (WindowPriceMax() - WindowPriceMin()) * 0.01;
      for (int n=0; n<static_show_n; n++){
         string objname = "MPC_STATIC_" + n;
         if(ObjectFind(objname) == -1){
            ObjectCreate(objname, OBJ_TEXT, 0, 0, 0);
         }
         ObjectSet(objname, OBJPROP_TIME1, Time[n]);
         ObjectSet(objname, OBJPROP_PRICE1, FocusBuffer[n] - sp);
         ObjectSetText(objname, DoubleToStr(staticBuffer[n], 0), 6, "Arial", static_txt_color);
      }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+