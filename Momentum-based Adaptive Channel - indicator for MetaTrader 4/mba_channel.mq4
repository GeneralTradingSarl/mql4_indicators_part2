//+------------------------------------------------------------------+
//|                                                  mba_channel.mq4 |
//|                                     Copyright 2021, Yossy Nakata |
//|                                  https://yossy-nakata.hateblo.jp |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Yossy Nakata"
#property link      "https://yossy-nakata.hateblo.jp"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers    2
#property indicator_plots   2

#property indicator_label1  "upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1 clrRed
#property indicator_width1  1

#property indicator_label2  "lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2 clrDodgerBlue
#property indicator_width2  1


const int FAST = 3; // Minimum Channel Period;
//--- input parameter
input int InpPeriod=20; // Channel Period
input double InpVFactor=0.5; // Volatility Factor
input int InpVEmaPeriod=200; // Volatility Smoothing
//--- buffers
double g_high[];
double g_low[];
double g_upper[];
double g_lower[];
double g_upper_i[];
double g_lower_i[];
double g_volat[];
static datetime g_start_time=0;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   IndicatorBuffers(7);
//--- indicator buffers mapping
   SetIndexBuffer(0,g_upper);
   SetIndexBuffer(1,g_lower);
   SetIndexBuffer(2,g_high);
   SetIndexBuffer(3,g_low);
   SetIndexBuffer(4,g_volat);
   SetIndexBuffer(5,g_upper_i);
   SetIndexBuffer(6,g_lower_i);


   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexEmptyValue(4, EMPTY_VALUE);
   SetIndexEmptyValue(5, EMPTY_VALUE);
   SetIndexEmptyValue(6, EMPTY_VALUE);

   ArrayInitialize(g_upper,EMPTY_VALUE);
   ArrayInitialize(g_lower,EMPTY_VALUE);
   ArrayInitialize(g_upper_i,EMPTY_VALUE);
   ArrayInitialize(g_lower_i,EMPTY_VALUE);
   ArrayInitialize(g_high,EMPTY_VALUE);
   ArrayInitialize(g_low,EMPTY_VALUE);
   ArrayInitialize(g_volat,EMPTY_VALUE);

   m_msv.init(InpVEmaPeriod);
   g_start_time=0;

///---
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
   int    i,pos;
//---
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(g_upper,false);
   ArraySetAsSeries(g_lower,false);
   ArraySetAsSeries(g_upper_i,false);
   ArraySetAsSeries(g_lower_i,false);
   ArraySetAsSeries(g_high,false);
   ArraySetAsSeries(g_low,false);
   ArraySetAsSeries(g_volat,false);

   pos=(int)MathMax(prev_calculated-1,0);

   if(prev_calculated==0 || (rates_total>0 && g_start_time != time[0]))
     {
      ArrayInitialize(g_upper,EMPTY_VALUE);
      ArrayInitialize(g_lower,EMPTY_VALUE);
      ArrayInitialize(g_upper_i,EMPTY_VALUE);
      ArrayInitialize(g_lower_i,EMPTY_VALUE);
      ArrayInitialize(g_high,EMPTY_VALUE);
      ArrayInitialize(g_low,EMPTY_VALUE);
      ArrayInitialize(g_volat,EMPTY_VALUE);
      g_start_time=time[0];
      pos=0;
     }

//--- preliminary calculations

   double v;
//--- the main loop of calculations
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      //---  volatility calculation
      if(!m_msv.calculate(close,i,rates_total,v))
         continue;
      g_volat[i]=v;

      if(i<InpPeriod+3)
        {

         g_high[i]=high[i];
         g_low[i]=low[i];
         g_upper[i]=high[i];
         g_lower[i]=low[i];
         g_upper_i[i]=i;
         g_lower_i[i]=i;
         continue;
        }

      //---  minimum channel calculation

      g_high[i]=(g_high[i-1] <= high[i]) ? high[i] :high[ArrayMaximum(high,FAST,i-(FAST-1))];
      g_low[i] =(g_low[i-1] >= low[i]) ? low[i] :low[ArrayMinimum(low,FAST,i-(FAST-1))];


      //---  upper side calculation

      double width = g_volat[i] * InpVFactor;

      if(g_upper[i-1]<=high[i])
        {
         g_upper[i]=high[i];
         g_upper_i[i] = i;

        }
      else
        {
         int h_pos= (int) g_upper_i[i-1];
         int lookback= 1+i-h_pos;

         // Euclidean distance
         double dist= distance(width, h_pos, i, g_high[h_pos],g_high[i]);
         if(InpPeriod * width < dist)
           {
            int len=MathMax(1,lookback-1);
            int max_i=ArrayMaximum(high,len,i-(len-1));
            g_upper[i]=high[max_i];
            g_upper_i[i] = max_i;

           }
         else
           {
            g_upper[i]=g_upper[i-1];
            g_upper_i[i] = g_upper_i[i-1];
           }
        }

      //---  lower side calculation
      if(g_lower[i-1] >= low[i])
        {
         g_lower[i]=low[i];
         g_lower_i[i]= i;

        }
      else
        {
         int l_pos= (int)g_lower_i[i-1];
         int lookback=1+i-l_pos;
         // Euclidean distance
         double dist= distance(width, l_pos, i, g_low[l_pos], g_low[i]);
         if(InpPeriod*width < dist)
           {
            int len=MathMax(1,lookback-1);
            int min_i=ArrayMinimum(low,len,i-(len-1));
            g_lower[i]=low[min_i];
            g_lower_i[i]= min_i;

           }
         else
           {
            g_lower[i]=g_lower[i-1];
            g_lower_i[i]= g_lower_i[i-1];

           }
        }

     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
double            distance(const double v,const double x1,const double x2,const double y1,const double y2)
  {
   return MathSqrt(MathPow(v*(x2-x1),2)+MathPow(y2-y1,2));
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
struct MsVolatItem
  {
   double            main;
   double            adf;
   double            df3;
   double            df4;
   double            df5;
   double            df6;
   double            df8;
   double            df10;
   double            df13;
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MsVolat
  {
private :
   int               _begin_plot;
   double            _alpha;
   double            _sq3;
   double            _sq4;
   double            _sq5;
   double            _sq6;
   double            _sq8;
   double            _sq10;
   double            _sq13;

   MsVolatItem       _buf[];
   int               _buf_size;
public :

                     MsVolat():
                     _begin_plot(0),
                     _alpha(0.),
                     _sq3(sqrt(3)),
                     _sq4(sqrt(4)),
                     _sq5(sqrt(5)),
                     _sq6(sqrt(6)),
                     _sq8(sqrt(8)),
                     _sq10(sqrt(10)),
                     _sq13(sqrt(13)) { return; }

                    ~MsVolat() { return; }

   void              init(int period)
     {
      //---
      _begin_plot = period+1+13;
      _alpha= 2.0/(period+1.0);

     }

   double            diff(const int lag,const double w, const double &value[],const int i)
     {
      return MathAbs(value[i-lag]-value[i])/w;
     }

   //+------------------------------------------------------------------+
   bool              calculate(const double &value[], int i, int bars,double &rslt)
     {
      if(_buf_size<bars)
         _buf_size=ArrayResize(_buf,bars+500,2000);

      if(_buf_size==-1)
         return false;

      if(i<=13)
        {
         _buf[i].main = EMPTY_VALUE;
         return false;
        }
      _buf[i].df3=MsVolat::diff(3,_sq3,value,i);
      _buf[i].df4=MsVolat::diff(4,_sq4,value,i);
      _buf[i].df5=MsVolat::diff(5,_sq5,value,i);
      _buf[i].df6=MsVolat::diff(6,_sq6,value,i);
      _buf[i].df8=MsVolat::diff(8,_sq8,value,i);
      _buf[i].df10=MsVolat::diff(10,_sq10,value,i);
      _buf[i].df13=MsVolat::diff(13,_sq13,value,i);

      _buf[i].adf=(_buf[i].df3+ _buf[i].df4+ _buf[i].df5+ _buf[i].df6
                   + _buf[i].df8+_buf[i].df10+ _buf[i].df13)/7.0;


      if(i<=14)
        {
         _buf[i].main = _buf[i].adf;
         return false;
        }

      _buf[i].main = _alpha * _buf[i].adf + (1.0-_alpha)*_buf[i-1].main;

      rslt=_buf[i].main;
      return (true);
     }


  };

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
MsVolat m_msv;
//+------------------------------------------------------------------+
