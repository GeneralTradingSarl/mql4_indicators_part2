//+---------------------------------------------------------------------+
//|                                     LOCSignal-MACDDoublePike.mq4    |
//| For more EXPERTS, INDICATORS, TRAILING EAs and SUPPORT Please visit:|
//|                                      http://www.landofcash.net      |
//|           Our forum is at:   http://forex-forum.landofcash.net      |
//+---------------------------------------------------------------------+
#property copyright "Mikhail LandOfCash"
#property link      "http://www.landofcash.net"

#property indicator_chart_window
#property indicator_buffers 3
//Buy signal
#property indicator_color1 OrangeRed 
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
//Sell signal
#property indicator_color2 OrangeRed
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID
//Lot size
#property indicator_color3 CLR_NONE
#property indicator_width3 0

string _name = "LOCSignal-MACDDoublePike";
string _ver="v1.0";
//---------------------------------------------
//indicator parameters
int _fastEmaPeriod=24;
int _slowEmaPeriod=52;
int _signalPeriod =9;
int _appliedPrice =PRICE_CLOSE;
//lot size is constant
double _lotSizeDefault=0;
//---------------------------------------------
double _buySignal[];
double _sellSignal[];
double _lotSize[];

double _pipsMultiplyer=1;


int init()
{
   Print(_name+" - " + _ver);
   IndicatorShortName(_name+" - " + _ver);
   Comment(_name+" " + _ver+" @ "+"http://www.landofcash.net");
  
  _lotSizeDefault=MarketInfo(Symbol(),MODE_MINLOT);  
//init buffers
   IndicatorBuffers(3);    
   SetIndexBuffer(0,_buySignal);
   SetIndexBuffer(1,_sellSignal);
   SetIndexBuffer(2,_lotSize);   
//set draw style   
   SetIndexStyle(0,DRAW_ARROW); 
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_NONE);

   SetIndexLabel(0,"Buy");
   SetIndexLabel(1,"Sell");
   SetIndexLabel(2,"Lot");

   
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   //get pip value
   if(Digits == 2 || Digits == 4) {
      _pipsMultiplyer = 1;
   } else {
      if(Digits == 3 || Digits == 5) {
         _pipsMultiplyer = 10;
      }
   }
   return(0);
}

int deinit()
{
   return(0);
}

int start()
  {
   double visualAddition= 3*_pipsMultiplyer*Point;
   int    counted_bars=IndicatorCounted();
   if(Bars<=100) {return(0);}
   int i=Bars-counted_bars-1;
   while(i>=0)
   {
      _buySignal[i]=EMPTY_VALUE;
      _sellSignal[i]=EMPTY_VALUE;
      _lotSize[i]=_lotSizeDefault;

      double macdMain=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_MAIN,i);     
      double macdMainP1=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_MAIN,i+1);     
      double macdMainP2=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_MAIN,i+2);   
      double macdMainP3=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_MAIN,i+3);   
      double macdMainP4=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_MAIN,i+4);   
      double macdSignal=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_SIGNAL,i);      
      double pikeP=0;
      //macd neg pike
      if( macdMain>macdMainP1 && macdMainP2>macdMainP1 && macdMain<0){         
         if(macdMainP1<macdMainP2 && macdMainP2<macdMainP3 && macdMainP3<macdMainP4){         
            pikeP=PikeDetect(i+4);
            if(pikeP<0/* && pikeP<macdMainP1*/){
               _buySignal[i]=iLow(Symbol(),Period(),i)-visualAddition;  
            }
         }
      }
      //macd pike
      if( macdMain<macdMainP1 && macdMainP2<macdMainP1 && macdMain>0){
         if(macdMainP1>macdMainP2 && macdMainP2>macdMainP3 && macdMainP3>macdMainP4){     
            pikeP=PikeDetect(i+4);
            if(pikeP>0 /*&& pikeP>macdMainP1*/){
               _sellSignal[i]=iHigh(Symbol(),Period(),i)+visualAddition;         
            }        
         }
      }
      i--;
   }   
   return(0);
  }
double PikeDetect(int i){
   bool signalGood=false;
   double macdLast=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_MAIN,i);  
   while(i<=Bars-2)
   {
      double macdMain=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_MAIN,i);     
      double macdMainP1=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_MAIN,i+1);     
      double macdMainP2=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_MAIN,i+2);   
      double macdSignal=iMACD(Symbol(),Period(),_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_SIGNAL,i);      
      if((macdMain>0 && macdLast<0)||(macdMain<0 && macdLast>0)){
         return(0);
      }
      if(macdLast<0 && macdSignal<macdMain){
         signalGood=true;
      }
      if(macdLast>0 && macdSignal>macdMain){
         signalGood=true;
      }
      if(macdLast<0 && macdMain>macdMainP1 && macdMainP2>macdMainP1 && macdMain<0 && signalGood){
         return (macdMainP1);
      }
      if(macdLast>0 && macdMain<macdMainP1 && macdMainP2<macdMainP1 && macdMain>0 && signalGood){
         return (macdMainP1);
      }
      i++;
   }
   return (0);
}