//+---------------------------------------------------------------------+
//|                                                  LOC-KijunSen.mq4   |
//| For more EXPERTS, INDICATORS, TRAILING EAs and SUPPORT Please visit:|
//|                                      http://www.landofcash.net      |
//|           Our forum is at:   http://forex-forum.landofcash.net      |
//+---------------------------------------------------------------------+
#property copyright "Mikhail"
#property link      "http://www.landofcash.net"

#property indicator_chart_window
#property indicator_buffers 3
//Line
#property indicator_color1 OrangeRed 
#property indicator_width1 2
#property indicator_style1 STYLE_SOLID

#property indicator_color2 OrangeRed 
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID

#property indicator_color3 OrangeRed 
#property indicator_width3 1
#property indicator_style3 STYLE_SOLID


string _name = "LOC-RKijunSen";
string _ver="v1.2";
//---------------------------------------------
//indicator parameters
extern int _period=61;
extern int _timeframe=0;
//---------------------------------------------
double _line[];
double _topLine[];
double _bottomLine[];
double _pipsMultiplyer=1;

int init()
{
   Print(_name+" - " + _ver);
   IndicatorShortName(_name+" - " + _ver);
   Comment(_name+" " + _ver+" @ "+"http://www.landofcash.net");
//init buffers
   IndicatorBuffers(3);    
   SetIndexBuffer(0,_line);
   SetIndexBuffer(1,_topLine);
   SetIndexBuffer(2,_bottomLine);

//set draw style   
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexLabel(0,"KijunSen");
    SetIndexStyle(1,DRAW_LINE); 
   SetIndexLabel(1,"Bottom KijunSen");
   SetIndexStyle(2,DRAW_LINE); 
   SetIndexLabel(2,"Bottom KijunSen");
   

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
   int    counted_bars=IndicatorCounted();
   if(Bars<=_period) {return(0);}
   int i=Bars-counted_bars-1;
   while(i>=0)
   {
      int barShift=iBarShift(Symbol(),_timeframe,iTime(Symbol(),Period(),i),false);
      double max=iHigh(Symbol(),_timeframe,iHighest(Symbol(),_timeframe,MODE_HIGH,_period,barShift));
      double min=iLow(Symbol(),_timeframe,iLowest(Symbol(),_timeframe,MODE_LOW,_period,barShift));
      double minMax=iHigh(Symbol(),_timeframe,iLowest(Symbol(),_timeframe,MODE_HIGH,_period,barShift));
      double maxMin=iLow(Symbol(),_timeframe,iHighest(Symbol(),_timeframe,MODE_LOW,_period,barShift));
       _line[i]=(max+min)/2;
       _topLine[i]=minMax;
       _bottomLine[i]=maxMin;
      i--;
   }
   return(0);
  }

