#define INDICATOR_BUFFERS 3

#property version   "1.00"
#property description "MCD Hot money"
#property strict
#property indicator_separate_window

#property indicator_buffers INDICATOR_BUFFERS
#property indicator_color1  Green
#property indicator_width1  2
#property indicator_color2  Yellow
#property indicator_width2  2
#property indicator_color3  Red
#property indicator_width3  2
#property indicator_minimum 0
#property indicator_maximum 20

input double hot_money_sensitivity = 0.7;
input int hot_money_period = 40;
input double hot_money_base = 30;
input double banker_sensitivity = 1.5;
input int banker_period = 50;
input double banker_base = 50;

double retailer[], hot_money[], banker[];

int OnInit() {
	IndicatorBuffers(INDICATOR_BUFFERS);
   IndicatorDigits(2);
	SetIndexBuffer(0, retailer);
	SetIndexBuffer(1, hot_money);
	SetIndexBuffer(2, banker);
	SetIndexStyle(0, DRAW_HISTOGRAM);
	SetIndexStyle(1, DRAW_HISTOGRAM);
	SetIndexStyle(2, DRAW_HISTOGRAM);
	SetIndexLabel(0, "Retailer");
	SetIndexLabel(1, "Hot Money");
	SetIndexLabel(2, "Banker");

	IndicatorShortName("MCD Hot Money");

   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], 
                const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {
   
	int pos = Bars;
   int counted_bars = IndicatorCounted();
   pos = pos-counted_bars-1;
     
	while(pos>=0) {
	   retailer[pos] = 20;
	   hot_money[pos] = rsi(hot_money_sensitivity, hot_money_period, hot_money_base, pos);
	   banker[pos] = rsi(banker_sensitivity, banker_period, banker_base, pos);
	   
	   pos--;
	}
   
   
   return(rates_total);
}

double rsi(double sensitivity, int period, double base, int pos) {
   double rsi = sensitivity * (iRSI(NULL, 0, period, PRICE_CLOSE, pos)-base);
   if (rsi > 20) { rsi = 20; }
   if (rsi < 0) { rsi = 0; }
   
   return rsi;
}