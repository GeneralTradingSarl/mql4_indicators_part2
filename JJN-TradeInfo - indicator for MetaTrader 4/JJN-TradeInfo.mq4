//+------------------------------------------------------------------+
//|                                                JJN-TradeInfo.mq4 |
//|                                      Copyright © 2011, JJ Newark |
//|                                           http://jjnewark.atw.hu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, JJ Newark"
#property link      "http://jjnewark.atw.hu"


#property indicator_chart_window

   
extern string   _Copyright_                 = "http://jjnewark.atw.hu";
extern color    UpColor                     = Green;
extern color    DownColor                   = OrangeRed;
extern color    TextColor                   = DarkSlateGray;
extern color    SeparatorColor              = DimGray;
extern int      PosX                        = 20;
extern int      PosY                        = 20;

string Pairs[];
string TradeType[];
double DataVal[][2];
int NumberOfOrders;
 
string q="a";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   for(int j=0;j<100;j++)
     for(int k=0;k<2;k++)
     ObjectDelete("IndVal"+j+k);
   for(k=0; k<100; k++)
     ObjectDelete("OrderString"+k); 
      
   ObjectCreate("Title",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("Title",OBJPROP_CORNER,0);
   ObjectSet("Title",OBJPROP_XDISTANCE,PosX);
   ObjectSet("Title",OBJPROP_YDISTANCE,PosY+15);
   ObjectSetText("Title",CharToStr(169)+"JJN               Pips   Profit($)",8,"Lucida Sans Unicode",TextColor);
   
   ObjectCreate("LineTitle",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("LineTitle",OBJPROP_CORNER,0);
   ObjectSet("LineTitle",OBJPROP_XDISTANCE,PosX);
   ObjectSet("LineTitle",OBJPROP_YDISTANCE,PosY+24);
   ObjectSetText("LineTitle","----------------------------------",8,"Tahoma",SeparatorColor);
     
         
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
   for(int j=0;j<100;j++)
     for(int k=0;k<2;k++)
     ObjectDelete("IndVal"+j+k);
   for(k=0; k<100; k++)
     ObjectDelete("OrderString"+k);
   
   ObjectDelete("Title");
   ObjectDelete("LineTitle");
   ObjectDelete("BottomLine");
      
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
//----
   
   for(int j=0;j<100;j++)
     for(int k=0;k<2;k++)
     ObjectDelete("IndVal"+j+k);
   for(k=0; k<100; k++)
     ObjectDelete("OrderString"+k);
   
   ////////////////////////

   NumberOfOrders=OrdersTotal();
   ArrayResize(Pairs,NumberOfOrders);
   ArrayResize(TradeType,NumberOfOrders);
   ArrayResize(DataVal,NumberOfOrders);
   
   for(int h=0;h<NumberOfOrders;h++)
      {
      if (OrderSelect(h,SELECT_BY_POS))
         {
         Pairs[h]=OrderSymbol();  
         }
      }
   
   double CurrentPrice;   
   for(h=0;h<NumberOfOrders;h++)
      {
      if (OrderSelect(h,SELECT_BY_POS))
         {
         int ordertype=OrderType();
         if(ordertype==0) 
         {
         CurrentPrice=MarketInfo(Pairs[h],MODE_BID);
         TradeType[h]=" [B]";
         }
         else if(ordertype==1) 
         {
         CurrentPrice=MarketInfo(Pairs[h],MODE_ASK);
         TradeType[h]=" [S]";
         }
         double Faktor;
         int Is_JPY=StringFind(Pairs[h],"JPY",0);
         if(Is_JPY==-1) Faktor=Point*10;
         else Faktor=Point*1000;
         if(ordertype==0) DataVal[h][0]=(CurrentPrice-OrderOpenPrice())/Faktor;
         else if(ordertype==1) DataVal[h][0]=(OrderOpenPrice()-CurrentPrice)/Faktor;
         DataVal[h][1]=MathRound(OrderProfit());
         }
      }
   
   
   for(j=0;j<NumberOfOrders+1;j++)
     for(k=0;k<2;k++)
     ObjectDelete("IndVal"+j+k);
   for(k=0; k<NumberOfOrders+1; k++)
     ObjectDelete("OrderString"+k);
   ObjectDelete("BottomLine");
  
   for(h=0;h<NumberOfOrders;h++)
      {
         ObjectCreate("OrderString"+h,OBJ_LABEL,0,0,0,0,0);
         ObjectSet("OrderString"+h,OBJPROP_CORNER,0);
         ObjectSet("OrderString"+h,OBJPROP_XDISTANCE,PosX);
         ObjectSet("OrderString"+h,OBJPROP_YDISTANCE,(h)*12+PosY+32);
         ObjectSetText("OrderString"+h,Pairs[h]+TradeType[h],8,"Lucida Sans Unicode",TextColor);
      }
   
      
   for(j=0;j<NumberOfOrders;j++)
     for(k=0;k<2;k++)
      {
         ObjectCreate("IndVal"+j+k,OBJ_LABEL,0,0,0,0,0);
         ObjectSet("IndVal"+j+k,OBJPROP_CORNER,0);
         ObjectSet("IndVal"+j+k,OBJPROP_XDISTANCE,(k)*32+PosX+65);
         ObjectSet("IndVal"+j+k,OBJPROP_YDISTANCE,(j)*12+PosY+32);
         if(DataVal[j][1]>=0) ObjectSetText("IndVal"+j+k,"+"+DoubleToStr(DataVal[j][k],0),8,"Lucida Sans Unicode",UpColor);
         else if(DataVal[j][1]<0) ObjectSetText("IndVal"+j+k,DoubleToStr(DataVal[j][k],0),8,"Lucida Sans Unicode",DownColor);
      }   
   
   
   ObjectCreate("BottomLine",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("BottomLine",OBJPROP_CORNER,0);
   ObjectSet("BottomLine",OBJPROP_XDISTANCE,PosX);
   ObjectSet("BottomLine",OBJPROP_YDISTANCE,NumberOfOrders*12+PosY+29);
   ObjectSetText("BottomLine","----------------------------------",8,"Tahoma",SeparatorColor);          
         
//----
   return(0);
  }
//+------------------------------------------------------------------+


