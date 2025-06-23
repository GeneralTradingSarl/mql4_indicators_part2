#property indicator_separate_window

#property indicator_buffers 8
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 Black
#property indicator_color4 Black
#property indicator_color5 Black
#property indicator_color6 Black
#property indicator_color7 Black
#property indicator_color8 Black

extern string paire  = "EURGBP";
extern int Time_frime= 0;

extern bool      Show_SAR=1;
extern double    Step=0.02;
extern double    Maximum=0.2;
extern color color_SAR=Red;

extern bool      Show_BB=1;
extern int       BandsPeriod=20;
extern double    BandsDeviations=2.0;
extern color color_BB=Black;

extern bool      Show_MA_1=1;
extern int       PRD_1=34;
extern string price="CLOSE";
extern string ma_style ="EMA";
extern color color_MA1 = Black;

extern bool      Show_MA_2=1;
extern int       PRD_2=34;
extern string price_ma2="HIGH";
extern string ma_style_ma2="EMA";
extern color color_MA2=Black;

extern bool      Show_MA_3=1;
extern int       PRD_3=34;
extern string price_ma3="LOW";
extern string ma_style_ma3="EMA";
extern color color_MA3=Black;

extern color     Up=Green;
extern color     Down=Red;
extern color     ligne_prix=Black;
extern int Corps=3;
extern int Meches=1;
double ind_1[];
double ind_2[];
double ind_3[];
double ind_4[];
double ind_5[];
double ind_6[];
double ind_7[];
double ind_8[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName(paire);
   SetIndexStyle(0,DRAW_LINE,0,1,color_BB);
   SetIndexBuffer(0,ind_1);
   SetIndexStyle(1,DRAW_LINE,0,1,color_BB);
   SetIndexBuffer(1,ind_2);
   SetIndexStyle(2,DRAW_LINE,0,1,color_BB);
   SetIndexBuffer(2,ind_3);
   SetIndexStyle(3,DRAW_ARROW,0,0,color_SAR);
   SetIndexArrow(3,159);
   SetIndexBuffer(3,ind_4);
   SetIndexStyle(4,DRAW_LINE,0,1,color_MA1);
   SetIndexBuffer(4,ind_5);
   SetIndexStyle(5,DRAW_LINE,0,1,color_MA2);
   SetIndexBuffer(5,ind_6);
   SetIndexStyle(6,DRAW_LINE,0,1,color_MA3);
   SetIndexBuffer(6,ind_7);
   SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(7,ind_8);
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {

   string TimingHL;
   string TimingOC;

   int window=WindowFind(paire);
   double prix,mode;
   double prix2,mode2;
   double prix3,mode3;

   for(int i=0; i<Bars; i++)
     {
      for(int k=i; k<10+i; k++)
         for(k=i; k<10+i; k++)
           {
            // Définition du prix pour la moyenne 1
            if(price == "CLOSE")                  prix= PRICE_CLOSE;
            if(price == "TYPICAL")                prix= PRICE_TYPICAL;
            if(price == "HIGH")                   prix= PRICE_HIGH;
            if(price == "LOW")                    prix= PRICE_LOW;
            if(price == "OPEN")                   prix= PRICE_OPEN;
            if(price == "MEDIAN")                 prix= PRICE_MEDIAN;
            if(price == "WEIGHTED")               prix= PRICE_WEIGHTED;
            // Définition du style moving average pour la moyenne 1

            if(ma_style == "SMA")                 mode= MODE_SMA;
            if(ma_style == "EMA")                 mode= MODE_EMA;
            if(ma_style == "LWMA")                mode= MODE_LWMA;
            if(ma_style == "SMOOT")               mode= MODE_SMMA;
            if(Show_MA_1== 1) ind_5[i]= iMA(paire,Time_frime,PRD_1,0,mode,prix,i);
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // Définition du prix pour la moyenne 2
            if(price_ma2 == "CLOSE")                  prix2= PRICE_CLOSE;
            if(price_ma2 == "TYPICAL")                prix2= PRICE_TYPICAL;
            if(price_ma2 == "HIGH")                   prix2= PRICE_HIGH;
            if(price_ma2 == "LOW")                    prix2= PRICE_LOW;
            if(price_ma2 == "OPEN")                   prix2= PRICE_OPEN;
            if(price_ma2 == "MEDIAN")                 prix2= PRICE_MEDIAN;
            if(price_ma2 == "WEIGHTED")               prix2= PRICE_WEIGHTED;
            // Définition du style moving average pour la moyenne 2

            if(ma_style_ma2 == "SMA")                 mode2= MODE_SMA;
            if(ma_style_ma2 == "EMA")                 mode2= MODE_EMA;
            if(ma_style_ma2 == "LWMA")                mode2= MODE_LWMA;
            if(ma_style_ma2 == "SMOOT")               mode2= MODE_SMMA;
            if(Show_MA_2==1) ind_6[i]=iMA(paire,Time_frime,PRD_2,0,mode2,prix2,i);
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // Définition du prix pour la moyenne 3
            if(price_ma3 == "CLOSE")                  prix3= PRICE_CLOSE;
            if(price_ma3 == "TYPICAL")                prix3= PRICE_TYPICAL;
            if(price_ma3 == "HIGH")                   prix3= PRICE_HIGH;
            if(price_ma3 == "LOW")                    prix3= PRICE_LOW;
            if(price_ma3 == "OPEN")                   prix3= PRICE_OPEN;
            if(price_ma3 == "MEDIAN")                 prix3= PRICE_MEDIAN;
            if(price_ma3 == "WEIGHTED")               prix3= PRICE_WEIGHTED;
            // Définition du style moving average pour la moyenne 3

            if(ma_style_ma3 == "SMA")                 mode3= MODE_SMA;
            if(ma_style_ma3 == "EMA")                 mode3= MODE_EMA;
            if(ma_style_ma3 == "LWMA")                mode3= MODE_LWMA;
            if(ma_style_ma3 == "SMOOT")               mode3= MODE_SMMA;
            if(Show_MA_3==1) ind_7[i]=iMA(paire,Time_frime,PRD_3,0,mode3,prix3,i);

            ind_8[i]=iMA(paire,Time_frime,1,0,MODE_SMA,PRICE_CLOSE,i);

            if(Show_BB == 1)    ind_1[i]= iMA(paire,Time_frime,BandsPeriod,0,MODE_SMA,PRICE_CLOSE,i);
            if(Show_BB == 1)    ind_2[i]= iBands(paire,Time_frime,BandsPeriod,BandsDeviations,0,PRICE_CLOSE,MODE_LOWER,i);
            if(Show_BB == 1)    ind_3[i]= iBands(paire,Time_frime,BandsPeriod,BandsDeviations,0,PRICE_CLOSE,MODE_UPPER,i);
            if(Show_SAR== 1) ind_4[i]= iSAR(paire,Time_frime,Step,Maximum,i);
           }
     }
   Sleep(1000);
   ObjectsDeleteAll(window);
   for(k=0; k<Bars; k++)
     {
      TimingHL="TimingHL"+k;
      ObjectCreate(TimingHL,OBJ_TREND,window,Time[k],iHigh(paire,Time_frime,k),Time[k],iLow(paire,Time_frime,k));
      ObjectSet(TimingHL,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(TimingHL,OBJPROP_RAY,FALSE);
      ObjectSet(TimingHL,OBJPROP_WIDTH,Meches);
      TimingOC="TimingOC"+k;
      ObjectCreate(TimingOC,OBJ_TREND,window,Time[k],iOpen(paire,Time_frime,k),Time[k],iClose(paire,Time_frime,k));
      ObjectSet(TimingOC,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(TimingOC,OBJPROP_RAY,FALSE);
      ObjectSet(TimingOC,OBJPROP_WIDTH,Corps);
      if(iOpen(paire,Time_frime,k)<=iClose(paire,Time_frime,k))
        {
         ObjectSet(TimingHL,OBJPROP_COLOR,Up);
         ObjectSet(TimingOC,OBJPROP_COLOR,Up);
           } else {
         ObjectSet(TimingHL,OBJPROP_COLOR,Down);
         ObjectSet(TimingOC,OBJPROP_COLOR,Down);
        }
     }
   ObjectCreate("actuel_price",OBJ_HLINE,window,0,iClose(paire,Time_frime,0));
   ObjectSet("actuel_price",OBJPROP_COLOR,ligne_prix);
   return (0);
  }
//+------------------------------------------------------------------+
