#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_HISTOGRAM
#property indicator_type4 DRAW_HISTOGRAM
#property indicator_color1 clrDimGray
#property indicator_color2 clrDimGray
#property indicator_color3 clrDeepSkyBlue
#property indicator_color4 clrTomato
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 1
#property indicator_width4 1
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_DASH
#property indicator_style4 STYLE_DASH

input    int                  inp_ma_1_period      = 7;           // MA 1 period
input    ENUM_MA_METHOD       inp_ma_1_method      = MODE_EMA;    // MA 1 method
input    ENUM_APPLIED_PRICE   inp_ma_1_price       = PRICE_CLOSE; // MA 1 price

input    int                  inp_ma_2_period      = 21;          // MA 2 period
input    ENUM_MA_METHOD       inp_ma_2_method      = MODE_SMA;    // MA 2 method
input    ENUM_APPLIED_PRICE   inp_ma_2_price       = PRICE_CLOSE; // MA 2 price

double ext_ma_1[];
double ext_ma_2[];
double ext_cloud_1[];
double ext_cloud_2[];
//+------------------------------------------------------------------+
int OnInit() {

   SetIndexBuffer(0,ext_ma_1);
   SetIndexBuffer(1,ext_ma_2);
   SetIndexBuffer(2,ext_cloud_1);
   SetIndexBuffer(3,ext_cloud_2);

   return(INIT_SUCCEEDED);
}
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
                const int &spread[]) {
                
   int limit = prev_calculated>0 ? rates_total - prev_calculated + 1 : rates_total - MathMax(inp_ma_1_period, inp_ma_2_period) -1;
   
   for(int i=limit; i>=0; i--) {
      ext_ma_1[i] = iMA(NULL,PERIOD_CURRENT, inp_ma_1_period, 0, inp_ma_1_method, inp_ma_1_price, i);
      ext_ma_2[i] = iMA(NULL,PERIOD_CURRENT, inp_ma_2_period, 0, inp_ma_2_method, inp_ma_2_price, i);
      if(ext_ma_1[i] > ext_ma_2[i]) {
         ext_cloud_1[i] = ext_ma_1[i];
         ext_cloud_2[i] = ext_ma_2[i];
      }else{
         ext_cloud_1[i] = ext_ma_1[i];
         ext_cloud_2[i] = ext_ma_2[i];
      }
   }
                
   return(rates_total);
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
                  
}
//+------------------------------------------------------------------+
