//+------------------------------------------------------------------+
//|                               _HPCS_IntThird_MT4_Indi_V01_EA.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double gd_Arr_Uparrow1[],gd_Arr_downarrow1[],gd_Arr_Uparrow2[],gd_Arr_downarrow2[],gd_Arr_Uparrow3[],gd_Arr_downarrow3[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   SetIndexBuffer(0,gd_Arr_Uparrow1);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,4,clrBlue);
   SetIndexArrow(0,217);

   SetIndexBuffer(1,gd_Arr_downarrow1);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,4,clrMagenta);
   SetIndexArrow(1,218);

   SetIndexBuffer(2,gd_Arr_Uparrow2);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,4,clrAqua);
   SetIndexArrow(2,221);

   SetIndexBuffer(3,gd_Arr_downarrow2);
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,4,clrBeige);
   SetIndexArrow(3,222);

   SetIndexBuffer(4,gd_Arr_Uparrow3);
   SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID,4,clrGreen);
   SetIndexArrow(4,233);

   SetIndexBuffer(5,gd_Arr_downarrow3);
   SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID,4,clrRed);
   SetIndexArrow(5,234);


   if(!ObjectCreate(0,"Values",OBJ_LABEL,0,0,0))
     {
      Print("Object Not Created");
     }
   ObjectSetInteger(0,"Values",OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,"Values",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,"Values",OBJPROP_YDISTANCE,15);
   ObjectSetInteger(0,"Values",OBJPROP_FONTSIZE,8);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
/// --- (A) --- ///
   if(prev_calculated == 0)
     {
      for(int i = Bars - 4; i>0 ; i--)
        {

         /// --- a part --- ///


         if(iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_MAIN,i)>0 && iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_MAIN,i+1)<0)
           {
            gd_Arr_Uparrow1[i] = High[i] + 3*Point();
            SendMail("Sell","Value Increased");
           }
         if(iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_MAIN,i)<0 &&  iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_MAIN,i+1)>0)
           {
            gd_Arr_downarrow1[i] = Low[i] + 3*Point();
            SendMail("Buy","Value Decreased");
           }

         /// --- c part --- ///


         if(iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_MAIN,i)>iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_SIGNAL,i)  && iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_MAIN,i+1)<iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_SIGNAL,i+1))
           {
            gd_Arr_Uparrow2[i] = High[i] + 3*Point();
           }
         if(iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_MAIN,i)<iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_SIGNAL,i) && iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_MAIN,i+1)>iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_SIGNAL,i+1))
           {
            gd_Arr_downarrow2[i] = High[i] + 3*Point();
           }

         /// --- d part --- ///
         
         if(iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_MAIN,i)>0  &&  Close[i+2] > Close[i+1] && Close[i+1] > Close[i])
           {
            gd_Arr_downarrow3[i] = High[i] + 3*Point();
           }
         if(iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_HIGH,MODE_MAIN,i)<0  &&  Close[i+2] < Close[i+1] && Close[i+1] < Close[i])
           {
            gd_Arr_Uparrow3[i] = Low[i] + 3*Point();
           }
           
      /// ---- b part ---- ///     
         double li_OPenPrice = iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_OPEN,MODE_MAIN,i);
         double li_ClosePrice = iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_MAIN,i);
         
         string li_values = "Open Price: "+DoubleToStr(li_OPenPrice)+" Close Price: "+DoubleToStr(li_ClosePrice);
         ObjectSetString(0,"Values",OBJPROP_TEXT,li_values);
        }
         
     }



//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
