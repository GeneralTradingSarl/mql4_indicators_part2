//+------------------------------------------------------------------+
//|                                                  i-Breakeven.mq4 |
//|                                          Copyright © 2007, RickD |
//|                                                   www.e2e-fx.net |
//+------------------------------------------------------------------+
#property copyright "© 2007 RickD"
#property link      "www.e2e-fx.net"
//----
#define major   1
#define minor   0
//----
#property indicator_chart_window
#property indicator_buffers 0
//----
extern int Corner=0;
extern int dy=20;
extern color _Header=OrangeRed;
extern color _Text = RoyalBlue;
extern color _Data = CadetBlue;
extern color _Separator=MediumPurple;
//----
string prefix="capital_";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   Comment("");
   clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   Comment("");
   clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void clear()
  {
   string name;
   int obj_total=ObjectsTotal();
//----
   for(int i=obj_total-1; i>=0; i--)
     {
      name=ObjectName(i);
      if(StringFind(name,prefix)==0)
         ObjectDelete(name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   clear();
   string Sym[];
   double Equity[];
   double Lots[];
   ArrayResize(Sym,0);
   ArrayResize(Equity,0);
   ArrayResize(Lots,0);
   int cnt=OrdersTotal();
//----
   for(int i=0; i<cnt; i++)
     {
      //----
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      int type=OrderType();
      //----
      if(type!=OP_BUY && type!=OP_SELL)
         continue;
      bool found=false;
      int size=ArraySize(Sym);
      //----
      for(int k=0; k<size; k++)
        {
         //----
         if(Sym[k]==OrderSymbol())
           {
            Equity[k]+=OrderProfit()+OrderCommission()+OrderSwap();
            //----
            if(type==OP_BUY)
               Lots[k]+=OrderLots();
            //----
            if(type==OP_SELL)
               Lots[k]-=OrderLots();
            found=true;
            break;
           }
        }
      //----
      if(found)
         continue;
      int ind=ArraySize(Sym);
      ArrayResize(Sym,ind+1);
      Sym[ind]=OrderSymbol();
      ArrayResize(Equity,ind+1);
      Equity[ind]=OrderProfit()+OrderCommission()+OrderSwap();
      ArrayResize(Lots,ind+1);
      //----
      if(type==OP_BUY)
         Lots[k]=OrderLots();
      //----
      if(type==OP_SELL)
         Lots[k]=-OrderLots();
     }
     if(ArraySize(Equity)==0)
       {
        Print("Orders not found. Remove the indicator from chart!");
        return;
       }
   string name=prefix+"symbols";
//----
   if(ObjectFind(name)==-1)
     {
      ObjectCreate(name,OBJ_LABEL,0,0,0);
     }
   ObjectSet(name,OBJPROP_XDISTANCE,30);
   ObjectSet(name,OBJPROP_YDISTANCE,35);
   ObjectSetText(name,"Symbol",10,"Tahoma",_Header);
   ObjectSet(name,OBJPROP_CORNER,Corner);
   name=prefix+"equity";
//----
   if(ObjectFind(name)==-1)
      ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_XDISTANCE,130);
   ObjectSet(name,OBJPROP_YDISTANCE,35);
   ObjectSetText(name,"Equity",10,"Tahoma",_Header);
   ObjectSet(name,OBJPROP_CORNER,Corner);
   name=prefix+"breakeven";
//----
   if(ObjectFind(name)==-1)
      ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_XDISTANCE,220);
   ObjectSet(name,OBJPROP_YDISTANCE,35);
   ObjectSetText(name,"Breakeven",10,"Tahoma",_Header);
   ObjectSet(name,OBJPROP_CORNER,Corner);
   name=prefix+"tmp1";
//----
   if(ObjectFind(name)==-1)
      ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_XDISTANCE,20);
   ObjectSet(name,OBJPROP_YDISTANCE,35+dy);
   ObjectSetText(name,"-----------------------------------------------------",
                 10,"Tahoma",_Separator);
   ObjectSet(name,OBJPROP_CORNER,Corner);
   double sum=0;
   string level0="";
   size=ArraySize(Sym);
//----
   for(i=0; i<size; i++)
     {
      //----
      if(Lots[i]==0)
        {
         level0="Lock";
        }
      else
        {
         int dig=MarketInfo(Sym[i],MODE_DIGITS);
         double point=MarketInfo(Sym[i],MODE_POINT);
         double COP = Lots[i]*MarketInfo(Sym[i], MODE_TICKVALUE);
         double val = MarketInfo(Sym[i], MODE_BID) - point*Equity[i] / COP;
         level0=DoubleToStr(val,dig);
        }
      name=prefix+"symbol"+i;
      //----
      if(ObjectFind(name)==-1)
         ObjectCreate(name,OBJ_LABEL,0,0,0);
      ObjectSet(name,OBJPROP_XDISTANCE,30);
      ObjectSet(name,OBJPROP_YDISTANCE,35+dy*(i+2));
      ObjectSetText(name,Sym[i],10,"Tahoma",_Text);
      ObjectSet(name,OBJPROP_CORNER,Corner);
      name=prefix+"equity"+i;
      //----
      if(ObjectFind(name)==-1)
         ObjectCreate(name,OBJ_LABEL,0,0,0);
      ObjectSet(name,OBJPROP_XDISTANCE,120);
      ObjectSet(name,OBJPROP_YDISTANCE,35+dy*(i+2));
      string eq=DoubleToStr(Equity[i],2);
      //----
      if(Equity[i]>0) eq="+"+eq;
      eq="$"+eq;
      ObjectSetText(name,eq,10,"Tahoma",_Data);
      ObjectSet(name,OBJPROP_CORNER,Corner);
      name=prefix+"breakeven"+i;
      //----
      if(ObjectFind(name)==-1)
         ObjectCreate(name,OBJ_LABEL,0,0,0);
      ObjectSet(name,OBJPROP_XDISTANCE,230);
      ObjectSet(name,OBJPROP_YDISTANCE,35+dy*(i+2));
      ObjectSetText(name,level0,10,"Tahoma",_Data);
      ObjectSet(name,OBJPROP_CORNER,Corner);
      sum+=Equity[i];
     }
   name=prefix+"tmp2";
//----
   if(ObjectFind(name)==-1)
      ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_XDISTANCE,20);
   ObjectSet(name,OBJPROP_YDISTANCE,35+dy*(i+2));
   ObjectSetText(name,"-----------------------------------------------------",
                 10,"Tahoma",_Separator);
   ObjectSet(name,OBJPROP_CORNER,Corner);
   name=prefix+"total";
//----
   if(ObjectFind(name)==-1)
      ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_XDISTANCE,30);
   ObjectSet(name,OBJPROP_YDISTANCE,35+dy*(i+3));
   ObjectSetText(name,"Total",10,"Tahoma",_Text);
   ObjectSet(name,OBJPROP_CORNER,Corner);
   name=prefix+"equity_total";
//----
   if(ObjectFind(name)==-1)
      ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_XDISTANCE,120);
   ObjectSet(name,OBJPROP_YDISTANCE,35+dy*(i+3));
   eq=DoubleToStr(sum,2);
//----
   if(Equity[i]>0)
      eq="+"+eq;
   eq="$"+eq;
   ObjectSetText(name,eq,10,"Tahoma",_Data);
   ObjectSet(name,OBJPROP_CORNER,Corner);
  }
//+------------------------------------------------------------------+
--------+
