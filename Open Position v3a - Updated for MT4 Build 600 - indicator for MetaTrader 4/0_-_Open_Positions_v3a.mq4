//+------------------------------------------------------------------+
//|                                                    iExposure.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                                                  |
//| Modifications : Open Positions v2 copyleft File45 (Phylo)        |
//| http://www.forexfactory.com/showthread.php?t=280525              |
//| http://codebase.mql4.com/en/author/file45                        |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_minimum 0.0
#property indicator_maximum 0.1

#define SYMBOLS_MAX 1024
#define DEALS          0
#define BUY_LOTS       1
#define BUY_PRICE      2
#define SELL_LOTS      3
#define SELL_PRICE     4
#define NET_LOTS       5
#define PROFIT         6

color Menu_0 = Black;
extern color Symbols = LightSlateGray;
//color Deals_2 = Red;
//color Buy_Label = DarkOrange;
//color Sell_Label = DarkOrange;
//extern string Currency_Symbol = "£";
//extern color Points = DarkOrange;
extern color Buy_Lots = LimeGreen;
extern color Sell_Lots = Red;
extern color Profit_Color = LimeGreen;
extern color Loss_Color = Red;
int Labels_Corner = 1;
extern int Font_Size = 10;
extern bool Fonts_Bold = false;
int Up_Down = 1;
extern string For_finer_spacing = "use_decimal_adjustents_eg 1.2,1.3";
extern double Column_Spacer = 1.0;

//color Pips_ = DarkOrange;

//int Prof = 320;

//ADDED
//extern color font_color = LightSlateGray;

string font_face;
 
bool normalize = false; //If true

double Poin;
int n_digits = 0;
double divider = 1;
//ADDED

//string ExtName="Exposure";
//int ExtNamee =0;
string ExtSymbols[SYMBOLS_MAX];
int    ExtSymbolsTotal=0;
double ExtSymbolsSummaries[SYMBOLS_MAX][10];
int    ExtLines=-1;
string ExtCols[]={".",// Dots Removed
                //  ".",
                //  ".",
                  ".",
                //  ".",
                  ".",
                  ".",
                  "."};
//int    ExtShifts[8]={ 10, 130, 190, 270, 360, 440, 530, 610 };
//int    ExtShifts[8]={ 10, 150, 220, 270, 360, 410, 500, 570 };
//int    ExtShifts[8]={ 22,,,,,,180,250 };
//ADDED
//int    ExtShifts[8]= { 15,0,0,0,0,230,140,330 };
//int    ExtShifts[8]= { 330,0,0,0,0,110,200,15 };
int    ExtShifts[4]= { 330,110,200,15 };
int    ExtVertShift=18;

double ExtMapBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init()
{
	//IndicatorShortName(ExtName);
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexStyle(0,DRAW_NONE);
   IndicatorDigits(0);
	SetIndexEmptyValue(0,0.0);
   
   if(Fonts_Bold == true)
   {
      font_face = "Arial Bold";
   }
   else if (Fonts_Bold == false)
   {
      font_face = "Arial";
   }        

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   int windex=WindowIsVisible(0);
   if(windex>0) ObjectsDeleteAll(windex);
  // string name;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start()
  {
   string name;
   int    i,col,line,windex=WindowIsVisible(0);
//----
   if(windex<0) return;
//---- header line
   if(ExtLines<0)
     {
      for(col=0; col<4; col++)
        {
         //name="Head_"+col;
        // if(ObjectCreate(name,OBJ_LABEL,windex,0,0))
          // {
           // ObjectSet(name,OBJPROP_XDISTANCE,ExtShifts[col]);
           // ObjectSet(name,OBJPROP_YDISTANCE,ExtVertShift);
           // ObjectSet(name,OBJPROP_YDISTANCE,Up_Down);
           // ObjectSetText(name,ExtCols[col],Font_Size,font_face,Menu_0);
           // ObjectSetText(name,ExtCols[col],Font_Size,font_face,NULL);
          // }
        }
      ExtLines=0;
     }
//----
   ArrayInitialize(ExtSymbolsSummaries,0.0);
   int total=Analyze();
   if(total>0)
     {
      line=0;
      for(i=0; i<ExtSymbolsTotal; i++)
        {
         if(ExtSymbolsSummaries[i][DEALS]<=0) continue;
         line++;
         //---- add line
         if(line>ExtLines)
           {
          // int y_dist=ExtVertShift*(line+1)-34;
          //int y_dist=line*Font_Size*1.5;
          int y_dist=Font_Size*1.5*(line)-Font_Size;
            for(col=0; col<4; col++)
              {
               name="Line_"+line+"_"+col;
               if(ObjectCreate(name,OBJ_LABEL,windex,0,0))
              
                {ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
                //ObjectSet(name,OBJPROP_XDISTANCE,ExtShifts[col]);
                ObjectSet( name, OBJPROP_XDISTANCE, ExtShifts[col] * Column_Spacer);
                ObjectSet(name,OBJPROP_YDISTANCE,y_dist);
                ObjectSet(name, OBJPROP_CORNER, Labels_Corner);
                
                 }
              }
              
            ExtLines++;
             
           }
         //---- set line
         int    digits=MarketInfo(ExtSymbols[i],MODE_DIGITS);
         double buy_lots=ExtSymbolsSummaries[i][BUY_LOTS];
         double sell_lots=ExtSymbolsSummaries[i][SELL_LOTS];
         double buy_price=0.0;
         double sell_price=0.0;
         if(buy_lots!=0)  buy_price=ExtSymbolsSummaries[i][BUY_PRICE]/buy_lots;
         if(sell_lots!=0) sell_price=ExtSymbolsSummaries[i][SELL_PRICE]/sell_lots;
        
         name="Line_"+line+"_0";
         ObjectSetText(name,ExtSymbols[i],Font_Size,font_face,Symbols);
         
        // name="Line_"+line+"_1";
        // ObjectSetText(name,DoubleToStr(ExtSymbolsSummaries[i][DEALS],2),Font_Size,font_face, Deals_2);
         
        // name="Line_"+line+" _2";
        // ObjectSetText(name,DoubleToStr(buy_lots,2),Font_Size,font_face, Buy_Label);
         
         //MOD FOR BUY COLUMN
        // name="Line_"+line+"_2";
         //ObjectSetText(name,DoubleToStr(buy_price,digits),Font_Size,font_face, Buy_Label);
       //  ObjectSetText(name,DoubleToStr(NormalizeDouble(buy_price/divider,1),n_digits),Font_Size,font_face,Points);
       //  if(sell_lots!=0) 
      //   ObjectSetText(name,DoubleToStr(NormalizeDouble(buy_price/divider,1),n_digits),1,font_face,BlueViolet); 
        
        // name="Line_"+line+"_4";
        // ObjectSetText(name,DoubleToStr(sell_lots,2),Font_Size,font_face, Sell_Label);
        
         //MOD FOR SELL COLUMN
         name="Line_"+line+"_1";
         
         double SP = NormalizeDouble(sell_price/divider,1);
         double BP = NormalizeDouble(buy_price/divider,1);
         
         if(sell_lots>0)
         {
             if(SP > 0)
             {
                 ObjectSetText(name,DoubleToStr(NormalizeDouble(sell_price/divider,1),n_digits)+ " p",Font_Size,font_face,Profit_Color);
             }
             else if(SP < 0)
             {    
                 ObjectSetText(name,DoubleToStr(NormalizeDouble(sell_price/divider,1),n_digits)+ " p",Font_Size,font_face,Loss_Color);
             }    
         }
         
         if(buy_lots>0)
         {
             if(BP > 0)
             {
                 ObjectSetText(name,DoubleToStr(NormalizeDouble(buy_price/divider,1),n_digits)+ " p",Font_Size,font_face,Profit_Color);
             }
             else if(BP < 0)
             {    
                 ObjectSetText(name,DoubleToStr(NormalizeDouble(buy_price/divider,1),n_digits)+ " p",Font_Size,font_face,Loss_Color);
             }    
         }
      
         
         /*if(sell_lots>0)
         ObjectSetText(name,DoubleToStr(NormalizeDouble(sell_price/divider,1),n_digits)+ " p",10,font_face,Pips_);
         if (buy_lots>0)
         ObjectSetText(name,DoubleToStr(NormalizeDouble(buy_price/divider,1),n_digits)+ " p",10,font_face,Pips_); */
        
         name="Line_"+line+"_2";
         //ObjectSetText(name,DoubleToStr(buy_lots-sell_lots,2)+" buy",Font_Size,font_face, Buy_Lots);
         ObjectSetText(name, DoubleToStr(buy_lots-sell_lots,2)+ " buy" ,Font_Size,font_face, Buy_Lots);
         if(buy_lots-sell_lots<0)
         //ObjectSetText(name,DoubleToStr(MathAbs((buy_lots-sell_lots)/1),2)+" sell",Font_Size,font_face, Sell_Lots);
         ObjectSetText(name,DoubleToStr(MathAbs((buy_lots-sell_lots)/1),2)+ " sell",Font_Size,font_face, Sell_Lots);
         
         name="Line_"+line+"_3";
         //ObjectSetText(name,Currency_Symbol+" "+formatDouble(ExtSymbolsSummaries[i][PROFIT],2),Font_Size,font_face, Profit_Color);
         ObjectSetText(name,formatDouble(ExtSymbolsSummaries[i][PROFIT],2),Font_Size,font_face, Profit_Color);
         if(ExtSymbolsSummaries[i][PROFIT]<0)
         //ObjectSetText(name,Currency_Symbol+" "+formatDouble(ExtSymbolsSummaries[i][PROFIT],2),Font_Size,font_face, Loss_Color);
         ObjectSetText(name,formatDouble(ExtSymbolsSummaries[i][PROFIT],2),Font_Size,font_face, Loss_Color);
       
        }
     }
//---- remove lines
   if(total<ExtLines)
     {
      for(line=ExtLines; line>total; line--)
        {
         name="Line_"+line+"_0";        
         //ObjectSetText(name," ");        
         //name="Line_"+line+"_1";
         //ObjectSetText(name," ");
        // name="Line_"+line+"_2";
         ObjectSetText(name," ");
         name="Line_"+line+"_1";
         ObjectSetText(name," ");
         //name="Line_"+line+"_4";
         //(name," ");
         name="Line_"+line+"_2";
         ObjectSetText(name," ");
         name="Line_"+line+"_3";
         ObjectSetText(name," ");
       //  name="Line_"+line+"_7";
       //  ObjectSetText(name," ");
         
        }
     }
//---- to avoid minimum==maximum
   ExtMapBuffer[Bars-1]=-1;
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Analyze()
  {
   double profit;
   int    i,index,type,total=OrdersTotal();
//----
   for(i=0; i<total; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      type=OrderType();
      if(type!=OP_BUY && type!=OP_SELL) continue;
      index=SymbolsIndex(OrderSymbol());
      if(index<0 || index>=SYMBOLS_MAX) continue;
      //----
      ExtSymbolsSummaries[index][DEALS]++;
      profit=OrderProfit()+OrderCommission()+OrderSwap();
      
      ExtSymbolsSummaries[index][PROFIT]+=profit;
      if(type==OP_BUY)
        {
         ExtSymbolsSummaries[index][BUY_LOTS]+=OrderLots();
        // ExtSymbolsSummaries[index][BUY_PRICE]+=OrderOpenPrice()*OrderLots();
         ExtSymbolsSummaries[index][BUY_PRICE]+= ((OrderClosePrice()-OrderOpenPrice())*OrderLots())/ MarketInfo( OrderSymbol(), MODE_POINT);
        }
     else
     //  if(type==OP_SELL)
     
        {
         ExtSymbolsSummaries[index][SELL_LOTS]+=OrderLots();
         //ExtSymbolsSummaries[index][SELL_PRICE]+=OrderOpenPrice()*OrderLots();
         // ExtSymbolsSummaries[index][SELL_PRICE]+=((OrderOpenPrice()-OrderClosePrice())*OrderLots())/ MarketInfo( OrderSymbol(), MODE_POINT);
          ExtSymbolsSummaries[index][SELL_PRICE]+=((OrderOpenPrice()-OrderClosePrice())*OrderLots())/ MarketInfo( OrderSymbol(), MODE_POINT);
        }
     }
//----
   total=0;
   for(i=0; i<ExtSymbolsTotal; i++)
     {
      if(ExtSymbolsSummaries[i][DEALS]>0) total++;
     }
//----
   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SymbolsIndex(string SymbolName)
  {
   bool found=false;
//----
   for(int i=0; i<ExtSymbolsTotal; i++)
     {
      if(SymbolName==ExtSymbols[i])
        {
         found=true;
         break;
        }
     }
//----
   if(found) return(i);
   if(ExtSymbolsTotal>=SYMBOLS_MAX) return(-1);
//----
   i=ExtSymbolsTotal;
   ExtSymbolsTotal++;
   ExtSymbols[i]=SymbolName;
   ExtSymbolsSummaries[i][DEALS]=0;
   ExtSymbolsSummaries[i][BUY_LOTS]=0;
   ExtSymbolsSummaries[i][BUY_PRICE]=0;
   ExtSymbolsSummaries[i][SELL_LOTS]=0;
   ExtSymbolsSummaries[i][SELL_PRICE]=0;
   ExtSymbolsSummaries[i][NET_LOTS]=0;
   ExtSymbolsSummaries[i][PROFIT]=0;
  
//----
   return(i);
  }
//+------------------------------------------------------------------+

string formatDouble(double number, int precision, string pcomma = ",", string ppoint = ".")
{
    string snum     = DoubleToStr(number, precision);
    int    decp     = StringFind(snum, ".", 0);
    string sright   = StringSubstr(snum, decp + 1, precision);
    string sleft    = StringSubstr(snum, 0, decp);
    string formated = "";
    string comma    = "";

    while (StringLen(sleft) > 3)
    {
        int    length = StringLen(sleft);
        string part   = StringSubstr(sleft, length - 3, 0);
        formated = part + comma + formated;
        comma    = pcomma;
        sleft    = StringSubstr(sleft, 0, length - 3);
    }
    if (sleft == "-")
        comma = "";              // this line missing previously
    if (sleft != "")
        formated = sleft + comma + formated;
    if (precision > 0)
        formated = formated + ppoint + sright;
    return(formated);
}

