//+------------------------------------------------------------------+
//|                                             KeyLevels

//|                                   Facebook ID vishal koli Fx  
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "mishanya"
#property link      "mishanya_fx@yahoo.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- input parameters
extern int       barn=300;
extern int       Length=6;
extern color    color1=OrangeRed;
extern color    color2=RoyalBlue;
//---- buffers
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexEmptyValue(0,0.0);
//SetIndexDrawBegin(0, barn);
//SetIndexStyle(0,DRAW_SECTION);
//SetIndexBuffer(0,ExtMapBuffer1);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   ObjectDelete("Target2 line");

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int shift,Swing,Swing_n,uzl,i,zu,zd;
   double PointA,PointB,PointC,Target2,Target3;
   double LL,HH,BH,BL;
   double Uzel[10000][3];
   string text;

   if(Bars<barn) return(-1);
   if(barn>=ArraySize(Uzel)/3) return(-1);

// loop from first bar to current bar (with shift=0) 
   Swing_n=0;Swing=0;uzl=0;
   BH=High[barn];BL=Low[barn];zu=barn;zd=barn;

   for(shift=barn;shift>=0;shift--) 
     {
      LL=10000000;HH=-100000000;
      for(i=shift+Length;i>=shift+1;i--) 
        {
         if(Low[i]< LL) {LL=Low[i];}
         if(High[i]>HH) {HH=High[i];}
        }

      if(Low[shift]<LL && High[shift]>HH)
        {
         Swing=2;
         if(Swing_n==1) {zu=shift+1;}
         if(Swing_n==-1) {zd=shift+1;}
           } else {
         if(Low[shift]<LL) {Swing=-1;}
         if(High[shift]>HH) {Swing=1;}
        }

      if(Swing!=Swing_n && Swing_n!=0) 
        {
         if(Swing==2) 
           {
            Swing=-Swing_n;BH = High[shift];BL = Low[shift];
           }
         uzl=uzl+1;
         if(Swing==1) 
           {
            Uzel[uzl][1]=zd;
            Uzel[uzl][2]=BL;
           }
         if(Swing==-1) 
           {
            Uzel[uzl][1]=zu;
            Uzel[uzl][2]=BH;
           }
         BH = High[shift];
         BL = Low[shift];
        }

      if(Swing==1) 
        {
         if(High[shift]>=BH) {BH=High[shift];zu=shift;}
        }
      if(Swing==-1) 
        {
         if(Low[shift]<=BL) {BL=Low[shift]; zd=shift;}
        }
      Swing_n=Swing;
     }
   for(i=1;i<=uzl;i++) 
     {
      //text=DoubleToStr(Uzel[i][1],0);
      //text=;
      //mv=StrToInteger(DoubleToStr(Uzel[i][1],0));
      //ExtMapBuffer1[mv]=Uzel[i][2];
     }

   PointA = Uzel[uzl-2][2];
   PointB = Uzel[uzl-1][2];
   PointC = Uzel[uzl][2];

   Target2=PointB-PointA+PointC;
   Target3=NormalizeDouble((PointB-PointA)*2.618+PointC,4);
   int L=10;


   ObjectCreate("Target2 Line",OBJ_TREND,0,iTime(NULL,0,Target2),Target2,
                iTime(NULL,0,Target2)+1000*60*L,Target2);
   ObjectSet("Target2 line",OBJPROP_COLOR,color1);
   ObjectSet("Target2 line",OBJPROP_WIDTH,2);
   ObjectSet("Target2 line",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("Target2 line",OBJPROP_RAY,true);


   ObjectCreate("Target3 Line",OBJ_TREND,0,iTime(NULL,0,Target3),Target3,
                iTime(NULL,0,Target3)+1000*60*L,Target3);
   ObjectSet("Target3 line",OBJPROP_COLOR,color2);
   ObjectSet("Target3 line",OBJPROP_WIDTH,2);
   ObjectSet("Target3 line",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("Target3 line",OBJPROP_RAY,true);

   return(0);
  }
//+------------------------------------------------------------------+
