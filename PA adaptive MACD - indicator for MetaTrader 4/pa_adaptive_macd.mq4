//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, www.mql5.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrPaleVioletRed
#property indicator_color3  clrDimGray
#property indicator_color4  clrSilver
#property indicator_color5  clrDeepSkyBlue
#property indicator_color6  clrDeepSkyBlue
#property indicator_color7  clrPaleVioletRed
#property indicator_color8  clrPaleVioletRed
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  2
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property strict

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
enum enColorOn
{
   cc_onSlope,   // Change color on slope change
   cc_onMiddle,  // Change color on middle line cross
   cc_onLevels   // Change color on outer levels cross
};
enum enLevelType
{
   lev_float, // Floating levels
   lev_quan   // Quantile levels
};

extern ENUM_TIMEFRAMES TimeFrame              = PERIOD_CURRENT; // Time frame to use
extern string          ForSymbol              = "";             // Symbol to use (empty for current symbol)
extern double          FastCycles             = 1.5;            // Fast phase accumulation cycles
extern int             FastFilter             = 1.0;            // Fast phase accumulation filter
extern double          SlowCycles             = 3.0;            // Slow phase accumulation cycles
extern int             SlowFilter             = 1.0;            // Slow phase accumulation filter
extern enPrices        AppliedPrice           = pr_close;       // Price to use
extern int             FlPeriod               = 35;             // Levels period
extern double          FlUp                   = 90;             // Upper level %
extern double          FlDown                 = 10;             // Lower level %
extern enLevelType     FlType                 = lev_quan;       // Levels type
extern enColorOn       ColorOn                = cc_onSlope;     // Color on
extern bool            arrowsVisible          = false;          // Display arrows?
extern bool            arrowsOnFirst          = false;          // Arrows on first bar (mtf mode)?
extern bool            arrowsShowBreakOut     = true;           // Show breakout arrow?s
extern bool            arrowsShowRetrace      = true;           // Show retrace arrows?
extern string          arrowsIdentifier       = "pa macd arrows"; // Arros unique ID
extern double          arrowsUpperGap         = 0.5;            // Upper gap for arrows
extern double          arrowsLowerGap         = 0.5;            // Lower gap for arrows
extern color           arrowsUpColor          = clrLimeGreen;   // Up arrow color
extern color           arrowsDnColor          = clrRed;         // Down arrow color
extern int             arrowsUpCode           = 241;            // Up arrow code
extern int             arrowsDnCode           = 242;            // Down arrow code
extern bool            alertsOn               = false;          // Turn alert on?
extern bool            alertsOnCurrent        = false;          // Alerts on still opened bar?
extern bool            alertsMessage          = true;           // Alerts should display a message?
extern bool            alertsSound            = false;          // Alerts should play a sound? 
extern bool            alertsNotify           = false;          // Alerts should send a notification?
extern bool            alertsEmail            = false;          // Alerts should send an email?
extern string          soundFile              = "alert2.wav";   // Alerts sound file
extern bool            Interpolate            = true;           // Interpolate in multi time frame mode

//
//
//
//
//

double buffer1[],buffer2[],buffer3[],buffer4[],buffer5[],buffer6[],buffer7[],bbMacd[],trendSlope[];
string indicatorFileName;
bool   returnBars;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
{
   IndicatorBuffers(9);
   SetIndexBuffer(0, buffer1);
   SetIndexBuffer(1, buffer2);
   SetIndexBuffer(2, buffer3);
   SetIndexBuffer(3, bbMacd);
   SetIndexBuffer(4, buffer4);
   SetIndexBuffer(5, buffer5);
   SetIndexBuffer(6, buffer6);
   SetIndexBuffer(7, buffer7);
   SetIndexBuffer(8, trendSlope);

            indicatorFileName = WindowExpertName();
            returnBars        = TimeFrame==-99;
            TimeFrame         = MathMax(TimeFrame,_Period);
            if (ForSymbol=="") ForSymbol = Symbol();
   IndicatorShortName(ForSymbol+" "+timeFrameToString(TimeFrame)+" PA Macd ("+(string)FastCycles+","+(string)SlowCycles+","+(string)FlPeriod+")");
   return(0);
}
int deinit() { ObjectsDeleteAll(0,arrowsIdentifier+":");  return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars - counted_bars,Bars-1);
         if (returnBars) { buffer1[0] = limit+1; return(0); }
         if (ForSymbol != _Symbol || TimeFrame != _Period) 
         {
            #define _mtfCall(_buff) iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",FastCycles,FastFilter,SlowCycles,SlowFilter,AppliedPrice,FlPeriod,FlUp,FlDown,FlType,ColorOn,arrowsVisible,arrowsOnFirst,arrowsShowBreakOut,arrowsShowRetrace,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,_buff,y)
            limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(ForSymbol,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
            if (trendSlope[limit]== 1) CleanPoint(limit,buffer4,buffer5);
            if (trendSlope[limit]==-1) CleanPoint(limit,buffer6,buffer7);
            for(int i=limit; i>=0; i--)
            {
               int y = iBarShift(ForSymbol,TimeFrame,Time[i]);
                  buffer1[i]    = _mtfCall(0);
                  buffer2[i]    = _mtfCall(1);
                  buffer3[i]    = _mtfCall(2);
                  bbMacd[i]     = _mtfCall(3);
                  trendSlope[i] = _mtfCall(8);
                  buffer4[i]    = EMPTY_VALUE;
                  buffer5[i]    = EMPTY_VALUE;
                  buffer6[i]    = EMPTY_VALUE;
                  buffer7[i]    = EMPTY_VALUE;
            
                  //
                  //
                  //
                  //
                  //
      
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                     #define _interpolate(_buff) _buff[i+k] = _buff[i]+(_buff[i+n]-_buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                        {
                           _interpolate(bbMacd);
                           _interpolate(buffer1);
                           _interpolate(buffer2);
                           _interpolate(buffer3);
                     }                           
            }
            for (int i=limit;i>=0;i--)
            {
               if (trendSlope[i]== 1) PlotPoint(i,buffer4,buffer5,bbMacd);
               if (trendSlope[i]==-1) PlotPoint(i,buffer6,buffer7,bbMacd);
            }               
            return(0);
         }

   //
   //
   //
   //
   //

   if (trendSlope[limit]== 1) CleanPoint(limit,buffer4,buffer5);
   if (trendSlope[limit]==-1) CleanPoint(limit,buffer6,buffer7);
   for(int i = limit; i >= 0 ; i--)
   {
      double price = getPrice(AppliedPrice,Open,Close,High,Low,i);
         bbMacd[i] = iEma(price,iHilbertPhase(price,FastFilter,FastCycles,i,0),i,0)-iEma(price,iHilbertPhase(price,SlowFilter,SlowCycles,i,1),i,1);
            if (FlType==lev_float)
            {
               double min   = bbMacd[ArrayMinimum(bbMacd,FlPeriod,i)];
               double max   = bbMacd[ArrayMaximum(bbMacd,FlPeriod,i)];
               double range = max-min;
                  buffer1[i] = min+FlUp  *range/100.0;
                  buffer2[i] = min+FlDown*range/100.0;
                  buffer3[i] = min+0.5*range;
            }
            else
            {
                  buffer1[i] = iQuantile(bbMacd[i],FlPeriod, FlUp            ,i,Bars);
                  buffer2[i] = iQuantile(bbMacd[i],FlPeriod, FlDown          ,i,Bars);
                  buffer3[i] = iQuantile(bbMacd[i],FlPeriod,(FlUp+FlDown)/2.0,i,Bars);
            }
            switch(ColorOn)
            {
               case cc_onLevels:         trendSlope[i] = (bbMacd[i]>buffer1[i])  ? 1 : (bbMacd[i]<buffer2[i])  ? -1 : 0; break;
               case cc_onMiddle:         trendSlope[i] = (bbMacd[i]>buffer3[i])  ? 1 : (bbMacd[i]<buffer3[i])  ? -1 : 0; break;
               default :  if (i<Bars-1)  trendSlope[i] = (bbMacd[i]>bbMacd[i+1]) ? 1 : (bbMacd[i]<bbMacd[i+1]) ? -1 : trendSlope[i+1];
            }                  
            buffer4[i] = EMPTY_VALUE;
            buffer5[i] = EMPTY_VALUE;
            buffer6[i] = EMPTY_VALUE;
            buffer7[i] = EMPTY_VALUE;
            if (trendSlope[i]== 1) PlotPoint(i,buffer4,buffer5,bbMacd);
            if (trendSlope[i]==-1) PlotPoint(i,buffer6,buffer7,bbMacd);
            
            //
            //
            //
            //
            //
            
            if (arrowsVisible && ForSymbol==Symbol())
            {
               ObjectDelete(arrowsIdentifier+":"+(string)Time[i]);
               if ((i<Bars-1) && trendSlope[i]!=trendSlope[i+1])
               {
                  if (arrowsShowBreakOut && trendSlope[i] == 1)                        drawArrow(i,arrowsUpColor,arrowsUpCode,false);
                  if (arrowsShowBreakOut && trendSlope[i] ==-1)                        drawArrow(i,arrowsDnColor,arrowsDnCode,true);
                  if (arrowsShowRetrace  && trendSlope[i] == 0 && trendSlope[i+1]== 1) drawArrow(i,arrowsDnColor,arrowsDnCode,true);
                  if (arrowsShowRetrace  && trendSlope[i] == 0 && trendSlope[i+1]==-1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
               }
            }
   }
   if (alertsOn)
   {
     int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
     if (trendSlope[whichBar] != trendSlope[whichBar+1])
     {
           if (trendSlope[whichBar] == 1)                               doAlert(whichBar,"up");
           if (trendSlope[whichBar] ==-1)                               doAlert(whichBar,"down");
           if (trendSlope[whichBar] == 0 && trendSlope[whichBar+1]== 1) doAlert(whichBar,"back from up into zone");
           if (trendSlope[whichBar] ==-0 && trendSlope[whichBar+1]==-1) doAlert(whichBar,"back from down into zone");
     }         
   }
   return(0);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define _quantileInstances 1
double _sortQuant[];
double _workQuant[][_quantileInstances];

double iQuantile(double value, int period, double qp, int i, int bars, int instanceNo=0)
{
   if (period<1) return(value);
   if (ArrayRange(_workQuant,0)!=bars) ArrayResize(_workQuant,bars); 
   if (ArraySize(_sortQuant)!=period)  ArrayResize(_sortQuant,period); 
            i=bars-i-1; _workQuant[i][instanceNo]=value;
            int k=0; for (; k<period && (i-k)>=0; k++) _sortQuant[k] = _workQuant[i-k][instanceNo];
                     for (; k<period            ; k++) _sortQuant[k] = 0;
                     ArraySort(_sortQuant);

   //
   //
   //
   //
   //
   
   double index = (period-1.0)*qp/100.00;
   int    ind   = (int)index;
   double delta = index - ind;
   if (ind == NormalizeDouble(index,5))
         return(            _sortQuant[ind]);
   else  return((1.0-delta)*_sortQuant[ind]+delta*_sortQuant[ind+1]);
}   

//
//
//
//
//

double workEma[][3];
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars); r = Bars-r-1;

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0 / (1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _hilInstances    2
#define _hilInstanceSize 9
double  workHil[][_hilInstances*_hilInstanceSize];
#define _price      0
#define _smooth     1
#define _detrender  2
#define _period     3
#define _instPeriod 4
#define _phase      5
#define _deltaPhase 6
#define _Q1         7
#define _I1         8

double iHilbertPhase(double price, double filter, double cyclesToReach, int i, int s=0)
{
   if (ArrayRange(workHil,0)!=Bars) ArrayResize(workHil,Bars);
   int r = Bars-i-1; s = s*_hilInstanceSize;
      
   //
   //
   //
   //
   //

   #define _calcComp(_ind) ((0.0962*workHil[r][s+_ind] + 0.5769*workHil[r-2][s+_ind] - 0.5769*workHil[r-4][s+_ind] - 0.0962*workHil[r-6][s+_ind]) * (0.075*workHil[r-1][s+_period] + 0.54))

      workHil[r][s+_price]      = price; 
      if (r<6) { workHil[r][s+_smooth]=price; return(0); }
      workHil[r][s+_smooth]     = (4.0*workHil[r][s+_price]+3.0*workHil[r-1][s+_price]+2.0*workHil[r-2][s+_price]+workHil[r-3][s+_price])/10.0;
      workHil[r][s+_detrender]  = _calcComp(_smooth);
      workHil[r][s+_Q1]         = 0.15*_calcComp(_detrender)     +0.85*workHil[r-1][s+_Q1];
      workHil[r][s+_I1]         = 0.15*workHil[r-3][s+_detrender]+0.85*workHil[r-1][s+_I1];
      workHil[r][s+_phase]      = workHil[r-1][s+_phase];
      workHil[r][s+_instPeriod] = workHil[r-1][s+_instPeriod];

      //
      //
      //
      //
      //
           
         if (MathAbs(workHil[r][s+_I1])>0)
                     workHil[r][s+_phase] = 180.0/M_PI*MathArctan(MathAbs(workHil[r][s+_Q1]/workHil[r][s+_I1]));
           
         if (workHil[r][s+_I1]<0 && workHil[r][s+_Q1]>0) workHil[r][s+_phase] = 180.0-workHil[r][s+_phase];
         if (workHil[r][s+_I1]<0 && workHil[r][s+_Q1]<0) workHil[r][s+_phase] = 180.0+workHil[r][s+_phase];
         if (workHil[r][s+_I1]>0 && workHil[r][s+_Q1]<0) workHil[r][s+_phase] = 360.0-workHil[r][s+_phase];

      //
      //
      //
      //
      //
                        
      workHil[r][s+_deltaPhase] = workHil[r-1][s+_phase]-workHil[r][s+_phase];

         if (workHil[r-1][s+_phase]<90.0 && workHil[r][s+_phase]>270.0)
             workHil[r][s+_deltaPhase] = 360.0+workHil[r-1][s+_phase]-workHil[r][s+_phase];
             workHil[r][s+_deltaPhase] = MathMax(MathMin(workHil[r][s+_deltaPhase],60),7);
      
            //
            //
            //
            //
            //
                  
            double phaseSum = 0; int k=0; for (; phaseSum<cyclesToReach*360.0 && (r-k)>0; k++) phaseSum += workHil[r-k][s+_deltaPhase];
            if (k>0) workHil[r][s+_instPeriod]= k;
                     workHil[r][s+_period] = iEma(workHil[r][s+_instPeriod],filter,i,2);
   return (workHil[r][s+_period]);
}

//
//
//
//
//

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
         int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}   

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   int    add  = 0; if (!arrowsOnFirst) add = _Period*60-1;
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i]+add,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+ arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] - arrowsLowerGap * gap);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," pa Macd ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," pa Macd "),message);
             if (alertsNotify)  SendNotification(message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}