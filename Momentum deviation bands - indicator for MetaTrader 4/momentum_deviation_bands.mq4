//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "Momentum deviation bands"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers  3
#property indicator_plots    3
#property indicator_label1   "Upper band"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrLimeGreen
#property indicator_style1   STYLE_DASHDOTDOT
#property indicator_label2   "Average"
#property indicator_type2    DRAW_LINE
#property indicator_color2   clrDarkGray
#property indicator_label3   "Lower band"
#property indicator_type3    DRAW_LINE
#property indicator_color3   clrCoral
#property indicator_style3   STYLE_DASHDOTDOT
#property strict

//
//
//

input int                inpPeriod     = 14;          // Period
input double             inpMultiplier = 2.0;         // Bands multiplier
input int                inpMomPeriod  = 2;           // Momentum period
input ENUM_APPLIED_PRICE inpMomPrice   = PRICE_CLOSE; // Momentum price

//
//
//

double val[],bandup[],banddn[];
struct sGlobalStruct
{
   int period;
   int periodMomentum;
};
sGlobalStruct global;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,bandup,INDICATOR_DATA);
   SetIndexBuffer(1,val   ,INDICATOR_DATA);
   SetIndexBuffer(2,banddn,INDICATOR_DATA);
   
      //
      //
      //

      global.period         = MathMax(inpPeriod,1);
      global.periodMomentum = MathMax(inpMomPeriod,1);
      
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Deviation variation bands (%i,%.2f,%i)",global.period,inpMultiplier,global.periodMomentum));            
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int &spread[])
{
   int _limit = (prev_calculated>0) ? rates_total-prev_calculated : rates_total-1;

   //
   //
   //

      struct sWorkStruct
            {
               double price;
               double momentum;
               double momentumSum;
               double sum;
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      for (int i=_limit, r=rates_total-i-1; i>=0; i--, r++)
         {
            m_work[r].price    = iGetPrice(inpMomPrice,open[i],high[i],low[i],close[i]);
            m_work[r].momentum = (r>global.periodMomentum) ? m_work[r].price - m_work[r-global.periodMomentum].price : m_work[r].price - m_work[0].price;
            
               //
               //
               //
               
                  #define _square(_arg) (_arg*_arg)
                     if (r>global.period)
                           { 
                              m_work[r].sum         = m_work[r-1].sum         +         m_work[r].price     -         m_work[r-global.period].price;
                              m_work[r].momentumSum = m_work[r-1].momentumSum + _square(m_work[r].momentum) - _square(m_work[r-global.period].momentum);
                           } 
                     else  { 
                              m_work[r].sum         =         m_work[r].price;     
                              m_work[r].momentumSum = _square(m_work[r].momentum);
                              for (int k=1; k<global.period && r>=k; k++) 
                                 {
                                       m_work[r].sum         +=         m_work[r-k].price; 
                                       m_work[r].momentumSum += _square(m_work[r-k].momentum); 
                                 }
                           } 
                  #undef _square                  

               //
               //
               //

            double _deviation = (m_work[r].momentumSum) ? MathSqrt(m_work[r].momentumSum/(double)global.period) : 0;
                     val[i]    = m_work[r].sum/(double)global.period;
                     bandup[i] = val[i] + _deviation*inpMultiplier;
                     banddn[i] = val[i] - _deviation*inpMultiplier;
         }

   //
   //
   //

   return(rates_total);
}

//--------------------------------------------------------------------------------------------------
//                                                                  
//--------------------------------------------------------------------------------------------------
//
//
//

double iGetPrice(ENUM_APPLIED_PRICE price,double open, double high, double low, double close)
{
   switch (price)
   {
      case PRICE_CLOSE:     return(close);
      case PRICE_OPEN:      return(open);
      case PRICE_HIGH:      return(high);
      case PRICE_LOW:       return(low);
      case PRICE_MEDIAN:    return((high+low)/2.0);
      case PRICE_TYPICAL:   return((high+low+close)/3.0);
      case PRICE_WEIGHTED:  return((high+low+close+close)/4.0);
   }
   return(0);
}
