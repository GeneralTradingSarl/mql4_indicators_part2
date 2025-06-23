#property indicator_chart_window
#property indicator_buffers 6

/// keycodes for manual chart movement
#define VK_LEFT 0x25
#define VK_RIGHT 0x27
#define VK_UP 0x26
#define VK_DOWN 0x28
#define VK_PRIOR 0x21
#define VK_NEXT 0x22  

extern string SymbolSpread = "";  // Symbol B name to be overlayed
extern double SpreadFactor = 1.0; // Spread = Symbol A price - spreadfactor x Symbol B price
extern color ColorSpread=Aqua;
extern int IndicatorWidthThick= 2;
extern int IndicatorWidthThin = 1;
extern bool PriceLabel=true;
extern color ColorUp=Blue;
extern color ColorDown = Tomato;
extern bool AlertPopup = false;
extern bool Sound=false;
extern bool EmailAlert=false;

//--- buffers
double SpreadLowHighBuffer[];
double SpreadHighLowBuffer[];
double SpreadOpenBuffer[];
double SpreadCloseBuffer[];
double SpreadUpBuffer[];
double SpreadDnBuffer[];

int Fontsize=20;

datetime dtLasttime=0;
double dChartMax=0.0,dChartMin=0.0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

/// color down; lower value; open value
/// color up; higher value; close value 

   ChartSetInteger(0,CHART_SCALEFIX,0);

   IndicatorShortName("SpreadChart");
   IndicatorDigits(Digits);

   SetIndexStyle(0,DRAW_HISTOGRAM,0,IndicatorWidthThin,ColorSpread);
   SetIndexBuffer(0,SpreadLowHighBuffer);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,IndicatorWidthThin,ColorSpread);
   SetIndexBuffer(1,SpreadHighLowBuffer);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,IndicatorWidthThick,ColorSpread);
   SetIndexBuffer(2,SpreadOpenBuffer);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,IndicatorWidthThick,ColorSpread);
   SetIndexBuffer(3,SpreadCloseBuffer);

   SetIndexStyle(4,DRAW_ARROW,EMPTY,1,ColorUp);
   SetIndexArrow(4,174);
   SetIndexBuffer(4,SpreadUpBuffer);
   SetIndexStyle(5,DRAW_ARROW,EMPTY,1,ColorDown);
   SetIndexArrow(5,174);
   SetIndexBuffer(5,SpreadDnBuffer);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   ObjectDelete("QuoteMain");
   ObjectDelete("SymbolMain");
   ObjectDelete("QuoteSpread");
   ObjectDelete("SymbolSpread");
   ObjectDelete("Time");
   ObjectDelete("SpreadLabel");
   ObjectDelete("SpreadValue");

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

   if(PriceLabel) DisplaySpotPrice();

   if( SymbolSpread=="" || iClose(SymbolSpread,Period(),0)==0 ) return(0);

   DrawSpreadChart();


//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void OnChartEvent(const int id,         // Event identifier  
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
  {

   if(id==CHARTEVENT_KEYDOWN)
     {
      switch(int(lparam))
        {
         case VK_LEFT: DrawSpreadChart(); break;
         case VK_RIGHT: DrawSpreadChart(); break;
         case VK_PRIOR: DrawSpreadChart(); break;
         case VK_NEXT:  DrawSpreadChart(); break;
         case VK_UP: DrawSpreadChart(); break;
         case VK_DOWN:  DrawSpreadChart(); break;
         default:         break;
        }

     }

   if(id==CHARTEVENT_CHART_CHANGE && (dChartMax!=WindowPriceMax(0) || dChartMin!=WindowPriceMin(0)))
      DrawSpreadChart();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSpreadChart()
  {

   int iWindowFirstVisibleBar=WindowFirstVisibleBar();
   int iWindowBarsPerChart=WindowBarsPerChart();

   if(iWindowBarsPerChart>iWindowFirstVisibleBar) iWindowBarsPerChart=iWindowFirstVisibleBar;
   int i=0,iSymbolSpreadShift=0;
   double dClose,dOpen,dHigh,dLow,dMaxMax=0.0,dMinMin=999999.0;
   double dFixedSpreadFactor=0.0;
   datetime dtCurrentBar=0;

   if(SymbolSpread=="") return;

   ArrayInitialize(SpreadCloseBuffer,0.0);
   ArrayInitialize(SpreadHighLowBuffer,0.0);
   ArrayInitialize(SpreadLowHighBuffer,0.0);
   ArrayInitialize(SpreadOpenBuffer,0.0);
   ArrayInitialize(SpreadUpBuffer,0.0);
   ArrayInitialize(SpreadDnBuffer,0.0);

   for(i=iWindowFirstVisibleBar;i>=iWindowFirstVisibleBar-iWindowBarsPerChart;i--)
     {

      dtCurrentBar=iTime(Symbol(),Period(),i);

      iSymbolSpreadShift=iBarShift(SymbolSpread,Period(),dtCurrentBar,true);

      if(iSymbolSpreadShift!=-1)
        {

         dClose= iClose(SymbolSpread,Period(),iSymbolSpreadShift);
         dHigh = iHigh(SymbolSpread,Period(),iSymbolSpreadShift);
         dLow=iLow(SymbolSpread,Period(),iSymbolSpreadShift);
         dOpen=iOpen(SymbolSpread,Period(),iSymbolSpreadShift);

         if((i==iWindowFirstVisibleBar || dFixedSpreadFactor==0.0) && dClose!=0.0)
           {
            dFixedSpreadFactor=iClose(Symbol(),Period(),i)/dClose;

           }

         if(iHigh(Symbol(),Period(),i)>dMaxMax) dMaxMax= iHigh(Symbol(),Period(),i);
         if(iLow(Symbol(),Period(),i)<dMinMin) dMinMin = iLow(Symbol(),Period(),i);

         dLow*=dFixedSpreadFactor;
         dHigh*=dFixedSpreadFactor;
         dClose*=dFixedSpreadFactor;
         dOpen *=dFixedSpreadFactor;


         SpreadLowHighBuffer[i] = dLow;
         SpreadHighLowBuffer[i] = dHigh;
         SpreadCloseBuffer[i]= dClose;
         SpreadOpenBuffer[i] = dOpen;

         if(dHigh>dMaxMax) dMaxMax= dHigh;
         if(dLow<dMinMin) dMinMin = dLow;
        }
     }

   double dScale=(dMaxMax-dMinMin)/dMinMin;

   dChartMax = dMaxMax*(1+dScale*0.05);
   dChartMin = dMinMin*(1-dScale*0.05);

   ChartSetInteger(0,CHART_SCALEFIX,true);
   ChartSetDouble(0,CHART_FIXED_MAX,dChartMax);
   ChartSetDouble(0,CHART_FIXED_MIN,dChartMin);

   for(i=iWindowFirstVisibleBar;i>=iWindowFirstVisibleBar-iWindowBarsPerChart;i--)
     {

      if(SpreadCloseBuffer[i]>=iClose(Symbol(),Period(),i))
         SpreadUpBuffer[i]=dChartMin;
      if(SpreadCloseBuffer[i]<iClose(Symbol(),Period(),i) && SpreadCloseBuffer[i]!=0.0)
         SpreadDnBuffer[i]=dChartMin;
     }

   if((SpreadUpBuffer[1]!=0 || SpreadDnBuffer[1]!=0) && 
      (SpreadUpBuffer[1]!=SpreadUpBuffer[2] && SpreadDnBuffer[1]!=SpreadDnBuffer[2])
      && dtLasttime!=Time[0])
     {
      string strSpreadAlert="";

      if(SpreadUpBuffer[1]>0.0) strSpreadAlert = ">";
      if(SpreadDnBuffer[1]>0.0) strSpreadAlert = "<";

      if(AlertPopup)
         Alert("Spread Alert - ",PeriodToString(Period())," ",SymbolSpread," ",strSpreadAlert," ",Symbol());

      if(Sound)
         PlaySound("alert.wav");

      if(EmailAlert)
         SendMail("Spread Alert - "+PeriodToString(Period())+" "+SymbolSpread+" "+strSpreadAlert+" "+Symbol(),
                  SymbolSpread+": "+DoubleToStr(iClose(SymbolSpread,Period(),1),MarketInfo(SymbolSpread,MODE_DIGITS))+
                  "\n"+Symbol()+": "+DoubleToStr(iClose(Symbol(),Period(),1),Digits)+
                  "\nServer Time: "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));

      dtLasttime=Time[0];
     }

   ChartRedraw();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PeriodToString(int imin)
  {

   string strprd;

   switch(imin)
     {

      case(1):
         strprd="M1";
         break;
      case(2):
         strprd="M2";
         break;
      case(3):
         strprd="M3";
         break;
      case(5):
         strprd="M5";
         break;
      case(15):
         strprd="M15";
         break;
      case(30):
         strprd="M30";
         break;
      case(60):
         strprd="H1";
         break;
      case(60*4):
         strprd="H4";
         break;
      case(60*24):
         strprd="D1";
         break;
      case(60*24*7):
         strprd="W1";
         break;
     }

   return (strprd);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLabel(string nm,string tx,int xd,int yd,string fn,int fs,color ct)
  {

   if(ObjectFind(nm)<0)
      ObjectCreate(nm,OBJ_LABEL,0,0,0);  //--- create the Label object

   ObjectSet(nm,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(nm,OBJPROP_XDISTANCE,xd);
   ObjectSet(nm,OBJPROP_YDISTANCE,yd);
   ObjectSet(nm,OBJPROP_COLOR,ct);
   ObjectSetText(nm,tx,fs,fn,ct);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplaySpotPrice()
  {

   int x=50;
   int y=50;
   int fz=Fontsize;
//color cr;
   double dSymbolPrice=0.0,dSymbolSpreadPrice;
   string strTime="";

   string strpd=PeriodToString(Period());

   strTime=TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);

   dSymbolPrice=Bid;

   int iSymbolLen=StringLen(Symbol());
   if(iSymbolLen<StringLen(SymbolSpread)) iSymbolLen=StringLen(SymbolSpread);

   SetLabel("Time",strpd+"  "+strTime,x,y,"Arial",fz-5,White);
   SetLabel("SymbolMain",Symbol(),x,y+(Fontsize+2)*1.2,"Arial",fz,White);
   SetLabel("QuoteMain",DoubleToStr(dSymbolPrice,Digits),x+iSymbolLen*fz,y+(fz+2)*1.2,"Arial Bold",fz,Lime);

   if(SymbolSpread!="")
     {
      SetLabel("SymbolSpread",SymbolSpread,x,y+(fz+2)*1.2*2,"Arial",fz,White);
      dSymbolSpreadPrice=iClose(SymbolSpread,Period(),0);
      SetLabel("QuoteSpread",DoubleToStr(dSymbolSpreadPrice,MarketInfo(SymbolSpread,MODE_DIGITS)),x+iSymbolLen*fz,y+(fz+2)*1.2*2,"Arial Bold",fz,ColorSpread);

      if(SpreadFactor!=0.0)
        {
         SetLabel("SpreadLabel","Spread",x,y+(fz+3)*1.2*3,"Arial",fz*0.9,White);
         SetLabel("SpreadValue",DoubleToStr(dSymbolPrice-dSymbolSpreadPrice*SpreadFactor,Digits),x+iSymbolLen*fz,y+(fz+3)*1.2*3,"Arial Bold",fz*0.9,MintCream);
        }
     }

  }
//+------------------------------------------------------------------+
