//+------------------------------------------------------------------+
//|                                                ind_SupportEX.mq4 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window

extern bool MN           = false;
extern bool RECTANGLE_MN = false;
extern bool W1           = false;
extern bool RECTANGLE_W1 = false;
extern bool D1           = false;
extern bool RECTANGLE_D1 = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
  for (int i=0;i<Bars;i++)
    {
    //----------------D1
    ObjectDelete("high_D1"+DoubleToStr(iTime(Symbol(),1440,i),0));    
    ObjectDelete("low_D1"+DoubleToStr(iTime(Symbol(),1440,i),0));    
    ObjectDelete("open_D1"+DoubleToStr(iTime(Symbol(),1440,i),0));    
    ObjectDelete("close_D1"+DoubleToStr(iTime(Symbol(),1440,i),0));
    ObjectDelete("se_D1"+DoubleToStr(iTime(Symbol(),1440,i),0));
    ObjectDelete("os_D1"+DoubleToStr(iTime(Symbol(),1440,i),0));
    ObjectDelete("RECTANGLE"+DoubleToStr(iTime(Symbol(),1440,i),0));
    //----------------W1
    ObjectDelete("high_W1"+DoubleToStr(iTime(Symbol(),10080,i),0));    
    ObjectDelete("low_W1"+DoubleToStr(iTime(Symbol(),10080,i),0));    
    ObjectDelete("open_W1"+DoubleToStr(iTime(Symbol(),10080,i),0));    
    ObjectDelete("close_W1"+DoubleToStr(iTime(Symbol(),10080,i),0));
    ObjectDelete("se_W1"+DoubleToStr(iTime(Symbol(),10080,i),0));
    ObjectDelete("os_W1"+DoubleToStr(iTime(Symbol(),10080,i),0));
    ObjectDelete("RECTANGLE_W1"+DoubleToStr(iTime(Symbol(),10080,i),0));    
    //----------------MN
    ObjectDelete("high_MN"+DoubleToStr(iTime(Symbol(),43200,i),0));    
    ObjectDelete("low_MN"+DoubleToStr(iTime(Symbol(),43200,i),0));    
    ObjectDelete("open_MN"+DoubleToStr(iTime(Symbol(),43200,i),0));    
    ObjectDelete("close_MN"+DoubleToStr(iTime(Symbol(),43200,i),0));
    ObjectDelete("se_MN"+DoubleToStr(iTime(Symbol(),43200,i),0));
    ObjectDelete("os_MN"+DoubleToStr(iTime(Symbol(),43200,i),0));
    ObjectDelete("RECTANGLE_MN"+DoubleToStr(iTime(Symbol(),43200,i),0));                       
    }
    //----------------D1
    ObjectDelete("PriceHighD1");
    ObjectDelete("PriceLowD1");
    ObjectDelete("PriceOpenD1");
    //----------------W1
    ObjectDelete("PriceHighW1");
    ObjectDelete("PriceLowW1");
    ObjectDelete("PriceOpenW1");    
    //----------------MN
    ObjectDelete("PriceHighMN");
    ObjectDelete("PriceLowMN");
    ObjectDelete("PriceOpenMN");       
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   int limit;
   int counted_bars=IndicatorCounted();
   
   if(counted_bars<0) return(-1);

   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(int i=limit; i>=0; i--)
   {
    //----------------D1
    if(Period()<=240 && D1){
    double   high_D1   = iHigh(Symbol(),1440,i);
    double   low_D1    = iLow(Symbol(),1440,i);    
    double   open_D1   = iOpen(Symbol(),1440,i);   
    double   close_D1  = iClose(Symbol(),1440,i);
    datetime delta_D1  = 86400;
    datetime timeOP_D1 = iTime(Symbol(),1440,i);
    datetime timeCL_D1 = iTime(Symbol(),1440,i)+delta_D1;
    color    color_D1  = FireBrick;
        
    TrendLineGraf("high_D1"+DoubleToStr(timeOP_D1, 0),timeOP_D1,high_D1,timeCL_D1,high_D1,Red,0,1);
    TrendLineGraf("low_D1"+DoubleToStr(timeOP_D1, 0),timeOP_D1,low_D1,timeCL_D1,low_D1,Red,0,1);
    TrendLineGraf("open_D1"+DoubleToStr(timeOP_D1, 0),timeOP_D1,open_D1,timeCL_D1,open_D1,Red,0,2);    
    TrendLineGraf("close_D1"+DoubleToStr(timeOP_D1, 0),timeOP_D1,close_D1,timeCL_D1,close_D1,Red,0,1);    
    TrendLineGraf("se_D1"+DoubleToStr(timeOP_D1, 0),timeOP_D1,high_D1,timeOP_D1,low_D1,Red,0,1);
    TrendLineGraf("os_D1"+DoubleToStr(timeOP_D1, 0),timeCL_D1,high_D1,timeCL_D1,low_D1,Red,0,1);
    if(open_D1<close_D1)color_D1 = DarkGreen;
    if(RECTANGLE_D1)RECTANGLE("RECTANGLE"+DoubleToStr(timeOP_D1, 0),timeOP_D1,open_D1,timeCL_D1,close_D1,color_D1);

    RICE_ARROW("PriceHighD1",timeCL_D1,high_D1,Red,1);
    RICE_ARROW("PriceLowD1",timeCL_D1,low_D1,Red,1);    
    RICE_ARROW("PriceOpenD1",timeCL_D1,open_D1,Red,1);
    }
    //----------------W1
    if(Period()<=1440 && W1){
    double   high_W1   = iHigh(Symbol(),10080,i);
    double   low_W1    = iLow(Symbol(),10080,i);    
    double   open_W1   = iOpen(Symbol(),10080,i);   
    double   close_W1  = iClose(Symbol(),10080,i);
    datetime delta_W1  = 10080*60;
    datetime timeOP_W1 = iTime(Symbol(),10080,i);
    datetime timeCL_W1 = iTime(Symbol(),10080,i)+delta_W1;
    color    color_W1  = Maroon;
        
    TrendLineGraf("high_W1"+DoubleToStr(timeOP_W1, 0),timeOP_W1,high_W1,timeCL_W1,high_W1,DarkTurquoise,0,2);
    TrendLineGraf("low_W1"+DoubleToStr(timeOP_W1, 0),timeOP_W1,low_W1,timeCL_W1,low_W1,DarkTurquoise,0,2);
    TrendLineGraf("open_W1"+DoubleToStr(timeOP_W1, 0),timeOP_W1,open_W1,timeCL_W1,open_W1,DarkTurquoise,0,2);    
    TrendLineGraf("close_W1"+DoubleToStr(timeOP_W1, 0),timeOP_W1,close_W1,timeCL_W1,close_W1,DarkTurquoise,0,1);    
    TrendLineGraf("se_W1"+DoubleToStr(timeOP_W1, 0),timeOP_W1,high_W1,timeOP_W1,low_W1,DarkTurquoise,0,2);
    TrendLineGraf("os_W1"+DoubleToStr(timeOP_W1, 0),timeCL_W1,high_W1,timeCL_W1,low_W1,DarkTurquoise,0,2);
    if(open_W1<close_W1)color_W1 = OliveDrab;
    if(RECTANGLE_W1)RECTANGLE("RECTANGLE_W1"+DoubleToStr(timeOP_W1, 0),timeOP_W1,open_W1,timeCL_W1,close_W1,color_W1);

    RICE_ARROW("PriceHighW1",timeCL_W1,high_W1,DarkTurquoise,2);
    RICE_ARROW("PriceLowW1",timeCL_W1,low_W1,DarkTurquoise,2);    
    RICE_ARROW("PriceOpenW1",timeCL_W1,open_W1,DarkTurquoise,2);
    }    
    //----------------MN
    if(Period()<=10080 && MN){
    double   high_MN   = iHigh(Symbol(),43200,i);
    double   low_MN    = iLow(Symbol(),43200,i);    
    double   open_MN   = iOpen(Symbol(),43200,i);   
    double   close_MN  = iClose(Symbol(),43200,i);
    datetime delta_MN  = 43200*60;
    datetime timeOP_MN = iTime(Symbol(),43200,i);
    datetime timeCL_MN = iTime(Symbol(),43200,i)+delta_MN;
    color    color_MN  = LightSeaGreen;
        
    TrendLineGraf("high_MN"+DoubleToStr(timeOP_MN, 0),timeOP_MN,high_MN,timeCL_MN,high_MN,Yellow,0,3);
    TrendLineGraf("low_MN"+DoubleToStr(timeOP_MN, 0),timeOP_MN,low_MN,timeCL_MN,low_MN,Yellow,0,3);
    TrendLineGraf("open_MN"+DoubleToStr(timeOP_MN, 0),timeOP_MN,open_MN,timeCL_MN,open_MN,Yellow,0,3);    
    TrendLineGraf("close_MN"+DoubleToStr(timeOP_MN, 0),timeOP_MN,close_MN,timeCL_MN,close_MN,Yellow,0,1);    
    TrendLineGraf("se_MN"+DoubleToStr(timeOP_MN, 0),timeOP_MN,high_MN,timeOP_MN,low_MN,Yellow,0,3);
    TrendLineGraf("os_MN"+DoubleToStr(timeOP_MN, 0),timeCL_MN,high_MN,timeCL_MN,low_MN,Yellow,0,3);
    if(open_MN<close_MN)color_MN = Peru;
    if(RECTANGLE_MN)RECTANGLE("RECTANGLE_MN"+DoubleToStr(timeOP_MN, 0),timeOP_MN,open_MN,timeCL_MN,close_MN,color_MN);

    RICE_ARROW("PriceHighMN",timeCL_MN,high_MN,Yellow,3);
    RICE_ARROW("PriceLowMN",timeCL_MN,low_MN,Yellow,3);    
    RICE_ARROW("PriceOpenMN",timeCL_MN,open_MN,Yellow,3);
    }        
   }   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Функция отображения трендовой линии                              |
//| автор: Юрий Токмань                                              |
//| e-mail: yuriytokman@gmail.com                                    |
//| ICQ#    481-971-287                                              |
//| Skype:  yuriy.g.t                                                |
//+------------------------------------------------------------------+
 void TrendLineGraf(string labebe,datetime time1,double price1,datetime time2,double price2,
                    color colir,int STYLE,int WIDTH )
  {
   if (ObjectFind(labebe)!=-1) ObjectDelete(labebe);
   ObjectCreate(labebe, OBJ_TREND, 0,time1,price1,time2,price2);
   ObjectSet(labebe, OBJPROP_COLOR, colir);
   ObjectSet(labebe, OBJPROP_STYLE,STYLE);
   ObjectSet(labebe, OBJPROP_WIDTH,WIDTH);
   ObjectSet(labebe, OBJPROP_RAY,0);
   ObjectSet(labebe, OBJPROP_BACK, true);
  }
//+------------------------------------------------------------------+
//| Функция отображения прямоугольника                               |
//| автор: Юрий Токмань                                              |
//| e-mail: yuriytokman@gmail.com                                    |
//| ICQ#    481-971-287                                              |
//| Skype:  yuriy.g.t                                                |
//+------------------------------------------------------------------+
 void RECTANGLE(string labe,datetime time1,double price1,datetime time2,
                double price2,color colir)
  {
   if (ObjectFind(labe)!=-1) ObjectDelete(labe);
   ObjectCreate(labe, OBJ_RECTANGLE, 0,time1,price1,time2,price2);
   ObjectSet(labe, OBJPROP_COLOR, colir);
   ObjectSet(labe, OBJPROP_BACK, true);
  }
//+------------------------------------------------------------------+
//| Функция отображения ценовой метки                                |
//| автор: Юрий Токмань                                              |
//| e-mail: yuriytokman@gmail.com                                    |
//| ICQ#    481-971-287                                              |
//| Skype:  yuriy.g.t                                                |
//+------------------------------------------------------------------+
 void RICE_ARROW(string label,datetime time1,double price1,color colir,int WIDTH )
  {
   if (ObjectFind(label)!=-1) ObjectDelete(label);
   ObjectCreate(label,OBJ_ARROW, 0,time1,price1);
   ObjectSet(label,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
   ObjectSet(label, OBJPROP_COLOR, colir);
   ObjectSet(label, OBJPROP_WIDTH,WIDTH);
   ObjectSet(label, OBJPROP_BACK, true);
  }
//+------------------------------------------------------------------+