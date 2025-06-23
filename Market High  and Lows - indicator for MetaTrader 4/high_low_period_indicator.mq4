//+------------------------------------------------------------------+
//|                                                  High Low v1.mq4 |
//|                                        Copyright 2022, dev Boaz. |
//|                                     mailto:boazmoses98@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, dev Boaz."
#property link      "mailto:boazmoses98@gmail.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define PREFIX "DHL_"

extern ENUM_TIMEFRAMES hl_tf = PERIOD_D1; //High Low timeframe
extern color           h_clr = clrRed;    //High color
extern color           l_clr = clrGreen;  //Low color
extern color           p_clr = clrGray;   //Period separator color

//+------------------------------------------------------------------+
int OnInit()
  {
      //delete undeleted objects
      DeleteObjects();
      
      //scale
      string tf = TimeFrame();
      Scale(PREFIX + "scale",clrBrown,"Scale:",140,90);
      Scale(PREFIX + "highscale",h_clr,"--------- " + tf + " High",140,70);
      Scale(PREFIX + "lowscale",l_clr,"--------- " + tf + " Low",140,50);
      
      
      return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
      DeleteObjects();
      
      Comment(" ");
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
      
      int Limit = rates_total - prev_calculated;
      if(!prev_calculated)Limit = rates_total - 1;
      
      for(int i = Limit -1; i >= 0; i--)
         {
            double d_low = iLow(Symbol(),hl_tf,i+1);
            double d_high = iHigh(Symbol(),hl_tf,i+1);
            
            datetime time1 = iTime(Symbol(),hl_tf,i);
            datetime time2 = iTime(Symbol(),hl_tf,i+1);
            
            DailyLines(time1);
            DailyLows(time1,d_low,time2,d_low);
            DailyHighs(time1,d_low,time2,d_high);
            
         }
      
      return(rates_total);
  }
  
//+------------------------------------------------------------------+
void DailyLines(datetime time)
   {
      string name = PREFIX + "daily_tf_" + string(time);
      
      if(ObjectFind(0,name) == 0)return;
      
      ObjectCreate(0,name,OBJ_VLINE,0,time,0);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,name,OBJPROP_COLOR,p_clr);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
   }
   
   
//+------------------------------------------------------------------+
void DailyLows(datetime time1,double price1,datetime time2,double price2)
   {
      string name = PREFIX + "daily_low_" + string(time1);
      
      if(ObjectFind(0,name) == 0)return;
      
      ObjectCreate(0,name,OBJ_TREND,0,time2,price2,time1,price2);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,name,OBJPROP_COLOR,l_clr);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_RAY,false);
   }
   
//+------------------------------------------------------------------+
void DailyHighs(datetime time1,double price1,datetime time2,double price2)
   {
      string name = PREFIX + "daily_high_" + string(time1);
      
      if(ObjectFind(0,name) == 0)return;
      
      ObjectCreate(0,name,OBJ_TREND,0,time2,price2,time1,price2);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,name,OBJPROP_COLOR,h_clr);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_RAY,false);
   }
   
   
//+------------------------------------------------------------------+
void Scale(string name, color clr,string text, int x,int y)
   {
      
      if(ObjectFind(0,name) == 0)return;
      
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   }
   
//+------------------------------------------------------------------+
string TimeFrame()
   {
      string period = "";
      
      if(hl_tf == 1)period = "1 minute";
      if(hl_tf == 5)period = "5 minutes";
      if(hl_tf == 15)period = "15 minutes";
      if(hl_tf == 30)period = "30 minutes";
      if(hl_tf == 60)period = "1 Hour";
      if(hl_tf == 240)period = "4 Hour";
      if(hl_tf == 1440)period = "Daily";
      if(hl_tf == 10080)period = "Weekly";
      if(hl_tf == 43200)period = "Monthly";
      
      return period;
   }
   
//+------------------------------------------------------------------+
void DeleteObjects()
   {
      for(int i = ObjectsTotal()-1; i >= 0; i--)
         {
            string name = ObjectName(i);
            if(StringFind(name,PREFIX) > -1)ObjectDelete(name);
         }
   }