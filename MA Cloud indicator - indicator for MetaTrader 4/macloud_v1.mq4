//+------------------------------------------------------------------+
//|                                                   maCloud_v1.mq4 |
//+------------------------------------------------------------------+
#property copyright "ChertAutoTrading"
#property link "https://www.mql5.com/en/users/alexchert/seller#products"
#property version   "1.0"
#property strict
#property indicator_chart_window

#property indicator_buffers 8
#property indicator_color1 clrRoyalBlue
#property indicator_color2 clrRoyalBlue
#property indicator_color3 clrSkyBlue
#property indicator_color4 clrSkyBlue
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1

#property indicator_color5 clrCrimson
#property indicator_color6 clrCrimson
#property indicator_color7 clrPink
#property indicator_color8 clrPink
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_width8 1

extern string note1; //[] ||||||||||||||||||||||||||||||||||
extern string note2; //[] Indicator Settings
extern int countBack=200;
extern string note3; //[] ||||||||||||||||||||||||||||||||||
extern int maBluePeriod=50;
extern int maRedPeriod=200;

int prevCalculated;

double pointHigh[];
double pointLow[];
double pointHigh2[];
double pointLow2[];

double point_High[];
double point_Low[];
double point_High2[];
double point_Low2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,pointHigh);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   
   SetIndexBuffer(1,pointLow);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   
   SetIndexBuffer(2,pointHigh2);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   
   SetIndexBuffer(3,pointLow2);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   
   SetIndexBuffer(4,point_High);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   
   SetIndexBuffer(5,point_Low);
   SetIndexStyle(5,DRAW_HISTOGRAM);
   
   SetIndexBuffer(6,point_High2);
   SetIndexStyle(6,DRAW_HISTOGRAM);
   
   SetIndexBuffer(7,point_Low2);
   SetIndexStyle(7,DRAW_HISTOGRAM);

  
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                           deinit                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll();   
  }
//+------------------------------------------------------------------+
//+-------------------------on calculate-----------------------------+
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
   prevCalculated=prev_calculated;
   
   maDraw();
  
   return rates_total-1;
  }
//+------------------------------------------------------------------+
void maDraw()
  {
   for(int i = Bars-1-MathMax(countBack, prevCalculated); i >= 0; --i)
   {
    double maBlue=iMA(NULL,0,maBluePeriod,0,0,PRICE_CLOSE,i);
    double maBlue2=iMA(NULL,0,maBluePeriod,0,1,PRICE_CLOSE,i);
    double maRed=iMA(NULL,0,maRedPeriod,0,0,PRICE_CLOSE,i);
    double maRed2=iMA(NULL,0,maRedPeriod,0,1,PRICE_CLOSE,i);
    
    if(maBlue>maBlue2)
    {
     pointHigh[i]=maBlue;
     pointLow[i]=maBlue2;
    }
    
    if(maBlue<maBlue2)
    {
     pointHigh2[i]=maBlue;
     pointLow2[i]=maBlue2;
    }
    
    if(maRed>maRed2)
    {
     point_High[i]=maRed;
     point_Low[i]=maRed2;
    }
    
    if(maRed<maRed2)
    {
     point_High2[i]=maRed;
     point_Low2[i]=maRed2;
    }
             
   }
   
  }
//+------------------------------------------------------------------+
