//+------------------------------------------------------------------+
//|                                                  MA Segments.mq4 |
//|                                         Copyright © 2011, bdeyes |
//|                                              bdeyes357@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "bdeyes"
#property link "bdeyes357@yahoo.com"

/////////////////////////////////////////////////////////
// This indicator places a short segment line on the   //
// right side of the chart at the current level of the //
// moving average. For example if you had a  moving    //
// average line showing the D1 10 EMA on the chart,    //
// this indicator will show the level that line        //
// would be at under the current bar by placing a      //
// short line in the open area (chart shift) to the    //
// right of the curent candle. I use this to keep      //
// my charts from becoming too cluttered by many MA's. //
//                                                     //
//    DOES NOT WORK ON WEEKLY OR MONTHLY CHART!!!!!    //
//                                                     //
/////////////////////////////////////////////////////////


#property indicator_chart_window
#property indicator_buffers 0

// exported variables
extern string note1 = "----Select MA----";
extern string help1 = "set to true to add MA to chart";

extern bool MA_D1_200_SMA = true; // set true to display MA's
extern bool MA_D1_100_EMA = true; // set true to display
extern bool MA_D1_50_EMA = true; // set true to display
extern bool MA_D1_21_EMA = true; // set true to display
extern bool MA_D1_10_EMA = true; // set true to display
extern bool MA_H4_200_SMA = false; // set true to display (false)
extern bool MA_H4_100_EMA = false; // set true to display (false)
extern bool MA_H4_50_EMA = false; // set true to display (false)
extern bool MA_H1_200_SMA = false; // set true to display (false)
extern bool MA_H1_100_EMA = false; // set true to display (false)
extern bool MA_H1_50_EMA = false; // set true to display (false)
extern bool MA_M30_200_SMA = false; // set true to display (false)
extern bool MA_M30_100_EMA = false; // set true to display false)
extern bool MA_M30_50_EMA = false; // set true to display (false)
extern bool MA_M15_200_SMA = true; // set true to display
extern bool MA_M15_100_EMA = true; // set true to display
extern bool MA_M15_50_EMA = true; // set true to display
extern bool MA_M5_200_SMA = true; // set true to display
extern bool MA_M5_100_EMA = true; // set true to display
extern bool MA_M5_50_EMA = true; // set true to display
extern bool MA_M5_20_SMA = true; // set true to display
extern bool MA_M1_200_SMA = false; // set true to display (false)
extern bool MA_M1_100_EMA = false; // set true to display (false)
extern bool MA_M1_50_EMA = false; // set true to display (false)

extern string note2 = "line & text settings";
extern string help2 = "amount to shift text to the right";
extern int text_shift = 10; // amount to shift text to the right of bar[0]
extern string help3 = "lenght of line to display";
extern int line_length = 10; // amount to extend line to the right of bar[0]
extern string help4 = "font size of bar label";
extern int font_size = 9; // font size of bar label

// local variables
int current = 0; // variable points to current bar
int line_adjustment;
int text_adjustment;
int line_leader; 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
    IndicatorShortName("MA Segments");
    if (Period()==10080 || Period()==43200)
    Alert ("MA Segments indi will not work on this timeframe!!");
    return;
    
    return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
    ObjectDelete("D1_200_SMA");
    ObjectDelete("D1_200_SMA_label");
    ObjectDelete("D1_100_EMA");
    ObjectDelete("D1_100_EMA_label");
    ObjectDelete("D1_50_EMA");
    ObjectDelete("D1_50_EMA_label");
    ObjectDelete("D1_21_EMA");
    ObjectDelete("D1_21_EMA_label");
    ObjectDelete("D1_10_EMA");
    ObjectDelete("D1_10_EMA_label");
    ObjectDelete("H4_200_SMA");
    ObjectDelete("H4_200_SMA_label");
    ObjectDelete("H4_100_EMA");
    ObjectDelete("H4_100_EMA_label");
    ObjectDelete("H4_50_EMA");
    ObjectDelete("H4_50_EMA_label");
    ObjectDelete("H1_200_SMA");
    ObjectDelete("H1_200_SMA_label");
    ObjectDelete("H1_100_EMA");
    ObjectDelete("H1_100_EMA_label");
    ObjectDelete("H1_50_EMA");
    ObjectDelete("H1_50_EMA_label");
    ObjectDelete("M30_200_SMA");
    ObjectDelete("M30_200_SMA_label");
    ObjectDelete("M30_100_EMA");
    ObjectDelete("M30_100_EMA_label");
    ObjectDelete("M30_50_EMA");
    ObjectDelete("M30_50_EMA_label");
    ObjectDelete("M15_200_SMA");
    ObjectDelete("M15_200_SMA_label");
    ObjectDelete("M15_100_EMA");
    ObjectDelete("M15_100_EMA_label");
    ObjectDelete("M15_50_EMA");
    ObjectDelete("M15_50_EMA_label");
    ObjectDelete("M5_200_SMA");
    ObjectDelete("M5_200_SMA_label");
    ObjectDelete("M5_100_EMA");
    ObjectDelete("M5_100_EMA_label");
    ObjectDelete("M5_50_EMA");
    ObjectDelete("M5_50_EMA_label");
    ObjectDelete("M5_20_SMA");
    ObjectDelete("M5_20_SMA_label");
    ObjectDelete("M1_200_SMA");
    ObjectDelete("M1_200_SMA_label");
    ObjectDelete("M1_100_EMA");
    ObjectDelete("M1_100_EMA_label");
    ObjectDelete("M1_50_EMA");
    ObjectDelete("M1_50_EMA_label");    
    
    return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator start function                                  |
//+------------------------------------------------------------------+
int start()
{
    int i;
    int counted_bars = IndicatorCounted();
    if(counted_bars < 0) return(-1);
    if(counted_bars > 0) counted_bars--;
    i = Bars - counted_bars;
    // main calculation loop
    while (i >= 0)
    {
        current = i;
                
        i--;
    }
    // to adjust the text location and line length
    // to accomodate different timeframe charts.
    switch(Period())
	{
		case PERIOD_M1: 
		line_adjustment=950; 
		text_adjustment=750;
		line_leader=250; 
		break;
		case PERIOD_M5: 
		line_adjustment=7500; 
		text_adjustment=6500;
		line_leader=1000; 
		break;
		case PERIOD_M15: 
		line_adjustment=15000; 
		text_adjustment=10000;
		line_leader=2000; 
		break;
		case PERIOD_M30: 
		line_adjustment=20000; 
		text_adjustment=16500;
		line_leader=4000; 
		break;
		case PERIOD_H1: 
		line_adjustment=40000; 
		text_adjustment=35000;
		line_leader=8000; 
		break;
		case PERIOD_H4: 
		line_adjustment=125000; 
		text_adjustment=100000;
		line_leader=20000; 
		break;
		case PERIOD_D1: 
		line_adjustment=1000000;
		text_adjustment=850000;
		line_leader=200000; 
		break;
		default: 
		line_adjustment=7500;
		text_adjustment=6500;
		line_leader=1000; 
		break;
	}        
                
    // Daily 200 SMA line
    if (MA_D1_200_SMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("D1_200_SMA") != -1) ObjectDelete("D1_200_SMA");
    // and draw a new one.
    ObjectCreate("D1_200_SMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_D1,200,0,MODE_SMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_D1,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("D1_200_SMA", OBJPROP_RAY, false);
    ObjectSet("D1_200_SMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("D1_200_SMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("D1_200_SMA", OBJPROP_COLOR, Lime);
    }
    
    // Daily 200 SMA text label
    if (MA_D1_200_SMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("D1_200_SMA_label") != -1) ObjectDelete("D1_200_SMA_label");
    // and draw new one.
    ObjectCreate("D1_200_SMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_D1,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("D1_200_SMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("D1_200_SMA_label", OBJPROP_COLOR, Lime);
    ObjectSetText("D1_200_SMA_label", "D1 200 SMA", font_size, "Arial", Lime); 
    }
    
    // Daily 100 EMA line
    if (MA_D1_100_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("D1_100_EMA") != -1) ObjectDelete("D1_100_EMA");
    // and draw a new one.
    ObjectCreate("D1_100_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_D1,100,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_D1,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("D1_100_EMA", OBJPROP_RAY, false);
    ObjectSet("D1_100_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("D1_100_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("D1_100_EMA", OBJPROP_COLOR, Lime);
    }
    
    // Daily 100 EMA text label
    if (MA_D1_100_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("D1_100_EMA_label") != -1) ObjectDelete("D1_100_EMA_label");
    // and draw new one.
    ObjectCreate("D1_100_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_D1,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("D1_100_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("D1_100_EMA_label", OBJPROP_COLOR, Lime);
    ObjectSetText("D1_100_EMA_label", "D1 100 EMA", font_size, "Arial", Lime); 
    }
    
    // Daily 50 EMA line
    if (MA_D1_50_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("D1_50_EMA") != -1) ObjectDelete("D1_50_EMA");
    // and draw a new one.
    ObjectCreate("D1_50_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_D1,50,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_D1,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("D1_50_EMA", OBJPROP_RAY, false);
    ObjectSet("D1_50_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("D1_50_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("D1_50_EMA", OBJPROP_COLOR, Lime);
    }
    
    // Daily 50 EMA text label
    if (MA_D1_50_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("D1_50_EMA_label") != -1) ObjectDelete("D1_50_EMA_label");
    // and draw new one.
    ObjectCreate("D1_50_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_D1,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("D1_50_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("D1_50_EMA_label", OBJPROP_COLOR, Lime);
    ObjectSetText("D1_50_EMA_label", "D1 50 EMA", font_size, "Arial", Lime); 
    }
    
    // Daily 21 EMA line
    if (MA_D1_21_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("D1_21_EMA") != -1) ObjectDelete("D1_21_EMA");
    // and draw a new one.
    ObjectCreate("D1_21_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_D1,21,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_D1,21,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("D1_21_EMA", OBJPROP_RAY, false);
    ObjectSet("D1_21_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("D1_21_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("D1_21_EMA", OBJPROP_COLOR, Lime);
    }
    
    // Daily 21 EMA text label
    if (MA_D1_21_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("D1_21_EMA_label") != -1) ObjectDelete("D1_21_EMA_label");
    // and draw new one.
    ObjectCreate("D1_21_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_D1,21,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("D1_21_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("D1_21_EMA_label", OBJPROP_COLOR, Lime);
    ObjectSetText("D1_21_EMA_label", "D1 21 EMA", font_size, "Arial", Lime); 
    }
    
    // Daily 10 EMA line
    if (MA_D1_10_EMA) // draw if true
    // if there is an old line delete it...
    if (ObjectFind("D1_10_EMA") != -1) ObjectDelete("D1_10_EMA");
    // and draw a new one.
    ObjectCreate("D1_10_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_D1,10,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_D1,10,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("D1_10_EMA", OBJPROP_RAY, false);
    ObjectSet("D1_10_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("D1_10_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("D1_10_EMA", OBJPROP_COLOR, Lime);
    
    // Daily 10 EMA text label
    if (MA_D1_10_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("D1_10_EMA_label") != -1) ObjectDelete("D1_10_EMA_label");
    // and draw new one.
    ObjectCreate("D1_10_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_D1,10,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("D1_10_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("D1_10_EMA_label", OBJPROP_COLOR, Lime);
    ObjectSetText("D1_10_EMA_label", "D1 10 EMA", font_size, "Arial", Lime); 
    }
    
    // H4 200 SMA line
    if (MA_H4_200_SMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("H4_200_SMA") != -1) ObjectDelete("H4_200_SMA");
    // and draw a new one.
    ObjectCreate("H4_200_SMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_H4,200,0,MODE_SMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_H4,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("H4_200_SMA", OBJPROP_RAY, false);
    ObjectSet("H4_200_SMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("H4_200_SMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("H4_200_SMA", OBJPROP_COLOR, Red);
    }
    
    // H4 200 SMA text label
    if (MA_H4_200_SMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("H4_200_SMA_label") != -1) ObjectDelete("H4_200_SMA_label");
    // and draw new one.
    ObjectCreate("H4_200_SMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_H4,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("H4_200_SMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("H4_200_SMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("H4_200_SMA_label", "H4 200 SMA", font_size, "Arial", Red); 
    }
    
    // H4 100 EMA line
    if (MA_H4_100_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("H4_100_EMA") != -1) ObjectDelete("H4_100_EMA");
    // and draw a new one.
    ObjectCreate("H4_100_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("H4_100_EMA", OBJPROP_RAY, false);
    ObjectSet("H4_100_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("H4_100_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("H4_100_EMA", OBJPROP_COLOR, Red);
    }
    
    // H4 100 EMA text label
    if (MA_H4_100_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("H4_100_EMA_label") != -1) ObjectDelete("H4_100_EMA_label");
    // and draw new one.
    ObjectCreate("H4_100_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("H4_100_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("H4_100_EMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("H4_100_EMA_label", "H4 100 EMA", font_size, "Arial", Red); 
    }
    
    // H4 50 EMA line
    if (MA_H4_50_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("H4_50_EMA") != -1) ObjectDelete("H4_50_EMA");
    // and draw a new one.
    ObjectCreate("H4_50_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_H4,50,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_H4,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("H4_50_EMA", OBJPROP_RAY, false);
    ObjectSet("H4_50_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("H4_50_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("H4_50_EMA", OBJPROP_COLOR, Red);
    }
    
    // H4 50 EMA text label
    if (MA_H4_50_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("H4_50_EMA_label") != -1) ObjectDelete("H4_50_EMA_label");
    // and draw new one.
    ObjectCreate("H4_50_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_H4,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("H4_50_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("H4_50_EMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("H4_50_EMA_label", "H4 50 EMA", font_size, "Arial", Red); 
    }
    
    // H1 200 SMA line
    if (MA_H1_200_SMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("H1_200_SMA") != -1) ObjectDelete("H1_200_SMA");
    // and draw a new one.
    ObjectCreate("H1_200_SMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_H1,200,0,MODE_SMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_H1,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("H1_200_SMA", OBJPROP_RAY, false);
    ObjectSet("H1_200_SMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("H1_200_SMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("H1_200_SMA", OBJPROP_COLOR, Magenta);
    }
    
    // H1 200 SMA text label
    if (MA_H1_200_SMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("H1_200_SMA_label") != -1) ObjectDelete("H1_200_SMA_label");
    // and draw new one.
    ObjectCreate("H1_200_SMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_H1,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("H1_200_SMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("H1_200_SMA_label", OBJPROP_COLOR, Magenta);
    ObjectSetText("H1_200_SMA_label", "H1 200 SMA", font_size, "Arial", Magenta); 
    }
    
    // H1 100 EMA line
    if (MA_H1_100_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("H1_100_EMA") != -1) ObjectDelete("H1_100_EMA");
    // and draw a new one.
    ObjectCreate("H1_100_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_H1,100,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_H1,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("H1_100_EMA", OBJPROP_RAY, false);
    ObjectSet("H1_100_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("H1_100_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("H1_100_EMA", OBJPROP_COLOR, Magenta);
    }
    
    // H1 100 EMA text label
    if (MA_H1_100_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("H1_100_EMA_label") != -1) ObjectDelete("H1_100_EMA_label");
    // and draw new one.
    ObjectCreate("H1_100_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_H1,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("H1_100_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("H1_100_EMA_label", OBJPROP_COLOR, Magenta);
    ObjectSetText("H1_100_EMA_label", "H1 100 EMA", font_size, "Arial", Magenta); 
    }
    
    // H1 50 EMA line
    if (MA_H1_50_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("H1_50_EMA") != -1) ObjectDelete("H1_50_EMA");
    // and draw a new one.
    ObjectCreate("H1_50_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_H1,50,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_H1,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("H1_50_EMA", OBJPROP_RAY, false);
    ObjectSet("H1_50_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("H1_50_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("H1_50_EMA", OBJPROP_COLOR, Magenta);
    }
    
    // H1 50 EMA text label
    if (MA_H1_50_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("H1_50_EMA_label") != -1) ObjectDelete("H1_50_EMA_label");
    // and draw new one.
    ObjectCreate("H1_50_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_H1,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("H1_50_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("H1_50_EMA_label", OBJPROP_COLOR, Magenta);
    ObjectSetText("H1_50_EMA_label", "H1 50 EMA", font_size, "Arial", Magenta);    
    }

    // M30 200 SMA line
    if (MA_M30_200_SMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M30_200_SMA") != -1) ObjectDelete("M30_200_SMA");
    // and draw a new one.
    ObjectCreate("M30_200_SMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M30,200,0,MODE_SMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M30,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("M30_200_SMA", OBJPROP_RAY, false);
    ObjectSet("M30_200_SMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M30_200_SMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M30_200_SMA", OBJPROP_COLOR, PaleGreen);
    }
    
    // M30 200 SMA text label
    if (MA_M30_200_SMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M30_200_SMA_label") != -1) ObjectDelete("M30_200_SMA_label");
    // and draw new one.
    ObjectCreate("M30_200_SMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M30,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("M30_200_SMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M30_200_SMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("M30_200_SMA_label", "M30 200 SMA", font_size, "Arial", PaleGreen); 
    }
    
    // M30 100 EMA line
    if (MA_M30_100_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M30_100_EMA") != -1) ObjectDelete("M30_100_EMA");
    // and draw a new one.
    ObjectCreate("M30_100_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M30,100,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M30,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M30_100_EMA", OBJPROP_RAY, false);
    ObjectSet("M30_100_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M30_100_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M30_100_EMA", OBJPROP_COLOR, PaleGreen);
    }
    
    // M30 100 EMA text label
    if (MA_M30_100_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M30_100_EMA_label") != -1) ObjectDelete("M30_100_EMA_label");
    // and draw new one.
    ObjectCreate("M30_100_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M30,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M30_100_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M30_100_EMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("M30_100_EMA_label", "M30 100 EMA", font_size, "Arial", PaleGreen); 
    }
    
    // M30 50 EMA line
    if (MA_M30_50_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M30_50_EMA") != -1) ObjectDelete("M30_50_EMA");
    // and draw a new one.
    ObjectCreate("M30_50_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M30,50,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M30,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M30_50_EMA", OBJPROP_RAY, false);
    ObjectSet("M30_50_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M30_50_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M30_50_EMA", OBJPROP_COLOR, PaleGreen);
    }
    
    // M30 50 EMA text label
    if (MA_M30_50_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M30_50_EMA_label") != -1) ObjectDelete("M30_50_EMA_label");
    // and draw new one.
    ObjectCreate("M30_50_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M30,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M30_50_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M30_50_EMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("M30_50_EMA_label", "M30 50 EMA", font_size, "Arial", PaleGreen); 
    }
    
    // 15M 200 SMA line
    if (MA_M15_200_SMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M15_200_SMA") != -1) ObjectDelete("M15_200_SMA");
    // and draw a new one.
    ObjectCreate("M15_200_SMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M15,200,0,MODE_SMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M15,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("M15_200_SMA", OBJPROP_RAY, false);
    ObjectSet("M15_200_SMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M15_200_SMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M15_200_SMA", OBJPROP_COLOR, Blue);
    }
    
    // 15M 200 SMA text label
    if (MA_M15_200_SMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M15_200_SMA_label") != -1) ObjectDelete("M15_200_SMA_label");
    // and draw new one.
    ObjectCreate("M15_200_SMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M15,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("M15_200_SMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M15_200_SMA_label", OBJPROP_COLOR, Blue);
    ObjectSetText("M15_200_SMA_label", "M15 200 SMA", font_size, "Arial", Blue); 
    }
    
    // 15M 100 EMA line
    if (MA_M15_100_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M15_100_EMA") != -1) ObjectDelete("M15_100_EMA");
    // and draw a new one.
    ObjectCreate("M15_100_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M15,100,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M15,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M15_100_EMA", OBJPROP_RAY, false);
    ObjectSet("M15_100_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M15_100_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M15_100_EMA", OBJPROP_COLOR, Blue);
    }
    
    // 15M 100 EMA text label
    if (MA_M15_100_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M15_100_EMA_label") != -1) ObjectDelete("M15_100_EMA_label");
    // and draw new one.
    ObjectCreate("M15_100_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M15,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M15_100_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M15_100_EMA_label", OBJPROP_COLOR, Blue);
    ObjectSetText("M15_100_EMA_label", "M15 100 EMA", font_size, "Arial", Blue); 
    }
    
    // 15M 50 EMA line
    if (MA_M15_50_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M15_50_EMA") != -1) ObjectDelete("M15_50_EMA");
    // and draw a new one.
    ObjectCreate("M15_50_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M15,50,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M15,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M15_50_EMA", OBJPROP_RAY, false);
    ObjectSet("M15_50_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M15_50_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M15_50_EMA", OBJPROP_COLOR, Blue);
    }
    
    // 15M 50 EMA text label
    if (MA_M15_50_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M15_50_EMA_label") != -1) ObjectDelete("M15_50_EMA_label");
    // and draw new one.
    ObjectCreate("M15_50_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M15,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M15_50_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M15_50_EMA_label", OBJPROP_COLOR, Blue);
    ObjectSetText("M15_50_EMA_label", "M15 50 EMA", font_size, "Arial", Blue); 
    }

    // M5 200 SMA line
    if (MA_M5_200_SMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M5_200_SMA") != -1) ObjectDelete("M5_200_SMA");
    // and draw a new one.
    ObjectCreate("M5_200_SMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M5,200,0,MODE_SMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M5,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("M5_200_SMA", OBJPROP_RAY, false);
    ObjectSet("M5_200_SMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M5_200_SMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M5_200_SMA", OBJPROP_COLOR, Gold);
    }
    
    // M5 200 SMA text label
    if (MA_M5_200_SMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M5_200_SMA_label") != -1) ObjectDelete("M5_200_SMA_label");
    // and draw new one.
    ObjectCreate("M5_200_SMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M5,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("M5_200_SMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M5_200_SMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("M5_200_SMA_label", "M5 200 SMA", font_size, "Arial", Gold); 
    }
    
    // M5 100 EMA line
    if (MA_M5_100_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M5_100_EMA") != -1) ObjectDelete("M5_100_EMA");
    // and draw a new one.
    ObjectCreate("M5_100_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M5,100,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M5,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M5_100_EMA", OBJPROP_RAY, false);
    ObjectSet("M5_100_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M5_100_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M5_100_EMA", OBJPROP_COLOR, Gold);
    }
    
    // M5 100 EMA text label
    if (MA_M5_100_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M5_100_EMA_label") != -1) ObjectDelete("M5_100_EMA_label");
    // and draw new one.
    ObjectCreate("M5_100_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M5,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M5_100_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M5_100_EMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("M5_100_EMA_label", "M5 100 EMA", font_size, "Arial", Gold); 
    }
    
    // M5 50 EMA line
    if (MA_M5_50_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M5_50_EMA") != -1) ObjectDelete("M5_50_EMA");
    // and draw a new one.
    ObjectCreate("M5_50_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M5,50,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M5,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M5_50_EMA", OBJPROP_RAY, false);
    ObjectSet("M5_50_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M5_50_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M5_50_EMA", OBJPROP_COLOR, Gold);
    }
    
    // M5 50 EMA text label
    if (MA_M5_50_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M5_50_EMA_label") != -1) ObjectDelete("M5_50_EMA_label");
    // and draw new one.
    ObjectCreate("M5_50_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M5,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M5_50_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M5_50_EMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("M5_50_EMA_label", "M5 50 EMA", font_size, "Arial", Gold); 
    }
    
    // 5M 20 SMA line
    if (MA_M5_20_SMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M5_20_SMA") != -1) ObjectDelete("M5_20_SMA");
    // and draw a new one.
    ObjectCreate("M5_20_SMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M5,20,0,MODE_SMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M5,20,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("M5_20_SMA", OBJPROP_RAY, false);
    ObjectSet("M5_20_SMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M5_20_SMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M5_20_SMA", OBJPROP_COLOR, Gold);
    }

    
    // 5M 20 SMA text label
    if (MA_M5_20_SMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M5_20_SMA_label") != -1) ObjectDelete("M5_20_SMA_label");
    // and draw new one.
    ObjectCreate("M5_20_SMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M5,20,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("M5_20_SMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M5_20_SMA_label", OBJPROP_COLOR, Orange);
    ObjectSetText("M5_20_SMA_label", "M5 20 SMA", font_size, "Arial", Gold); 
    }

    // M1 200 SMA line
    if (MA_M1_200_SMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M1_200_SMA") != -1) ObjectDelete("M1_200_SMA");
    // and draw a new one.
    ObjectCreate("M1_200_SMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M1,200,0,MODE_SMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M1,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("M1_200_SMA", OBJPROP_RAY, false);
    ObjectSet("M1_200_SMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M1_200_SMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M1_200_SMA", OBJPROP_COLOR, Aqua);
    }
    
    // M1 200 SMA text label
    if (MA_M1_200_SMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M1_200_SMA_label") != -1) ObjectDelete("M1_200_SMA_label");
    // and draw new one.
    ObjectCreate("M1_200_SMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M1,200,0,MODE_SMA,PRICE_CLOSE,0));
    ObjectSet("M1_200_SMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M1_200_SMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("M1_200_SMA_label", "M1 200 SMA", font_size, "Arial", Aqua); 
    }
    
    // M1 100 EMA line
    if (MA_M1_100_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M1_100_EMA") != -1) ObjectDelete("M1_100_EMA");
    // and draw a new one.
    ObjectCreate("M1_100_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M1,100,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M1,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M1_100_EMA", OBJPROP_RAY, false);
    ObjectSet("M1_100_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M1_100_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M1_100_EMA", OBJPROP_COLOR, Aqua);
    }
    
    // M1 100 EMA text label
    if (MA_M1_100_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M1_100_EMA_label") != -1) ObjectDelete("M1_100_EMA_label");
    // and draw new one.
    ObjectCreate("M1_100_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M1,100,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M1_100_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M1_100_EMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("M1_100_EMA_label", "M1 100 EMA", font_size, "Arial", Aqua); 
    }
    
    // M1 50 EMA line
    if (MA_M1_50_EMA) // draw if true
    {
    // if there is an old line delete it...
    if (ObjectFind("M1_50_EMA") != -1) ObjectDelete("M1_50_EMA");
    // and draw a new one.
    ObjectCreate("M1_50_EMA", OBJ_TREND, 0, Time[0]+line_leader, iMA(NULL, PERIOD_M1,50,0,MODE_EMA,PRICE_CLOSE,0), (Time[0]+line_length+line_adjustment), iMA(NULL, PERIOD_M1,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M1_50_EMA", OBJPROP_RAY, false);
    ObjectSet("M1_50_EMA", OBJPROP_TIME1, Time[0]+line_leader);
    ObjectSet("M1_50_EMA", OBJPROP_TIME2, (Time[0]+line_length+line_adjustment));
    ObjectSet("M1_50_EMA", OBJPROP_COLOR, Aqua);
    }
    
    // M1 50 EMA text label
    if (MA_M1_50_EMA) // draw if true
    {
    // if there is an old label delete it...
    if (ObjectFind("M1_50_EMA_label") != -1) ObjectDelete("M1_50_EMA_label");
    // and draw new one.
    ObjectCreate("M1_50_EMA_label", OBJ_TEXT, 0, (Time[0]+text_shift+text_adjustment), iMA(NULL, PERIOD_M1,50,0,MODE_EMA,PRICE_CLOSE,0));
    ObjectSet("M1_50_EMA_label", OBJPROP_TIME1, (Time[0]+text_shift+text_adjustment));
    ObjectSet("M1_50_EMA_label", OBJPROP_COLOR, Red);
    ObjectSetText("M1_50_EMA_label", "M1 50 EMA", font_size, "Arial", Aqua); 
    }
    
    return(0);
}

//+------------------------------------------------------------------+

