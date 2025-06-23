//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "MyRsi with Noise Elimination Technology"
#property description "Based on work published by John Ehlers"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  2
#property indicator_plots    2
#property indicator_label1   "MyRsi"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrDeepSkyBlue
#property indicator_label2   "NET"
#property indicator_type2    DRAW_LINE
#property indicator_color2   clrDarkGray
#property strict

//
//
//

input int                inpRsiPeriod = 14;          // MyRsi period
input int                inpNetPeriod = 14;          // NET period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price

//
//
//

double val[],net[];
struct sGlobalStruct
{
   int    periodNet;
   int    periodRsi;
   double netDenom;
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
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,net,INDICATOR_DATA);
   
      //
      //
      //
      
         global.periodRsi = MathMax(inpRsiPeriod,1);
         global.periodNet = MathMax(inpNetPeriod,2);
         global.netDenom  = 0.5 * global.periodNet * (global.periodNet - 1);

      //
      //
      //
            
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("MyRsi (%i) with (%i) NET",global.periodRsi,global.periodNet));            
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
               double diffUp;
               double diffDn;
               double diffUpSum;
               double diffDnSum;
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      for (int i=_limit, r=rates_total-i-1; i>=0; i--, r++)
         {
            m_work[r].price  = iGetPrice(inpPrice,open,high,low,close,i);
            
               //
               //
               //
               
                  double _diff = (r>0) ? (m_work[r].price-m_work[r-1].price) : 0;
                     m_work[r].diffUp = (_diff>0) ?  _diff : 0;
                     m_work[r].diffDn = (_diff<0) ? -_diff : 0;
                  
                     if (r>global.periodRsi) 
                        {
                              m_work[r].diffUpSum = m_work[r-1].diffUpSum + m_work[r].diffUp - m_work[r-global.periodRsi].diffUp;
                              m_work[r].diffDnSum = m_work[r-1].diffDnSum + m_work[r].diffDn - m_work[r-global.periodRsi].diffDn;
                        }
                     else
                        {
                              m_work[r].diffUpSum = m_work[r].diffUp;
                              m_work[r].diffDnSum = m_work[r].diffDn;
                                 for (int k=1; k<global.periodRsi && r>=k; k++)
                                    {
                                       m_work[r].diffUpSum += m_work[r-k].diffUp;
                                       m_work[r].diffDnSum += m_work[r-k].diffDn;
                                    }
                        }      
                  
                  double _diffSum = m_work[r].diffUpSum + m_work[r].diffDnSum;
                     val[i] = (_diffSum) ? (m_work[r].diffUpSum - m_work[r].diffDnSum)/_diffSum : 0;
               
               //
               //
               //
               
                  double _netNum = 0;
                  for (int k=1; k<global.periodNet && r>k; k++)
                  for (int j=0; j<k; j++)
                     {
                        _diff    = val[i+k+1]-val[i+j+1];
                        _netNum -= (_diff>0) ? 1  : (_diff<0) ? -1 : 0;
                     }
                                    
                  net[i] = _netNum/global.netDenom;
         }

   //
   //
   //

   return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//

double iGetPrice(ENUM_APPLIED_PRICE price,const double& open[], const double& high[], const double& low[], const double& close[], int i)
{
   switch (price)
   {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
   }
   return(0);
}