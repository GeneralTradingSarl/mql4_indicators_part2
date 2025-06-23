//+------------------------------------------------------------------+
//|                                                      Pivots2.mq4 |
//|                                                    Diego Vallejo |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Diego Vallejo"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 OrangeRed
#property indicator_color2 Red
#property indicator_color3 Violet
#property indicator_color4 Lime
#property indicator_color5 MediumSpringGreen
//---- input parameters
extern bool      Resistencia2=true;
extern color     ColorR2 = OrangeRed;
extern bool      Resistencia1=true;
extern color     ColorR1 = Red;
extern bool      Pivote=true;
extern color     ColorP = Violet;
extern bool      Soporte1=true;
extern color     ColorS1 = Lime;
extern bool      Soporte2=true;
extern color     ColorS2 = MediumSpringGreen;
extern bool      Lineas=true;
extern bool      Horizontal=true;
extern bool      Texto=true;
extern bool      Valores=true;
extern int       Ultima=1;
extern int       Tiempo=0;


int T = 0; 
double rates [][6];


//---- buffers
double ExtMapBufferR2[];
double ExtMapBufferR1[];
double ExtMapBufferPiv[];
double ExtMapBufferS1[];
double ExtMapBufferS2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBufferR2);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBufferR1);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBufferPiv);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBufferS1);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBufferS2);
   
   IndicatorShortName("Pivot!! :)");
   SetIndexLabel(0,"R2");
   SetIndexLabel(1,"R1");
   SetIndexLabel(2,"P");
   SetIndexLabel(3,"S1");
   SetIndexLabel(4,"S2");

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

ObjectDelete("R1 Label"); 
ObjectDelete("R1 Line");
ObjectDelete("R1 valor"); 
ObjectDelete("R2 Label");
ObjectDelete("R2 Line");
ObjectDelete("R2 valor");
ObjectDelete("S1 Label");
ObjectDelete("S1 Line");
ObjectDelete("S1 valor");
ObjectDelete("S2 Label");
ObjectDelete("S2 Line");
ObjectDelete("S2 valor");
ObjectDelete("P Label");
ObjectDelete("P Line");
ObjectDelete("P valor");


//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   int    i,j;
   int    C,D;
   int    posi,inij,finj;
   
   double R2 = 0;
   double R1 = 0; 
   double P = 0;
   double S1 = 0; 
   double S2 = 0; 
   if (Ultima < 1) Ultima = 1;
   if (Tiempo<0 || Tiempo > 8) Tiempo = 0;

   if (Tiempo == 0 ) T=Period();
   if (Tiempo == 1 ) T=1;
   if (Tiempo == 2 ) T=5;
   if (Tiempo == 3 ) T=15;
   if (Tiempo == 4 ) T=30;
   if (Tiempo == 5 ) T=60;
   if (Tiempo == 6 ) T=240;
   if (Tiempo == 7 ) T=1440;
   if (Tiempo == 8 ) T=10080;
   if (T == Period()) Tiempo=0;
   if (T < Period()){
      Print("Error - Tiempo no aplicable.");
      return(-1); // then exit
      }

   D = (T/Period());
   if (D>0) {
      posi=(Bars/D)+1;
      }else {
      posi=Bars;
      }
   if (D==0) D=1;

//---- inicio
	ArrayCopyRates(rates, Symbol(), T);
   
   for(i=0;i<=D*Ultima;i++){
      if (iTime(NULL,0,i)== iTime(NULL,T,0)) C=i+1;
      }
   
   for(i=posi;i>=Ultima;i--){
      P= ( rates[i][3] + rates[i][2] + rates[i][4]) / 3;
      R1= ( 2 * P ) - rates[i][2];
      R2= P + ( rates[i][3] - rates[i][2] );
      S1= ( 2 * P ) - rates[i][3];
      S2= P - ( rates[i][3] - rates[i][2] );
      if (Lineas) {
         inij = (i-1)*D-D+C;
         if (inij<0) inij=0;
         finj = (i-1)*D + C -1;
         for (j=inij;j<=finj;j++) {
               if (Resistencia2) ExtMapBufferR2[j]=R2;
               if (Resistencia1) ExtMapBufferR1[j]=R1;
               if (Pivote) ExtMapBufferPiv[j]=P;
               if (Soporte1) ExtMapBufferS1[j]=S1;
               if (Soporte2) ExtMapBufferS2[j]=S2;
               }
            }
	      }
	   
	


	
	
	
   if (Horizontal) {
      if (Resistencia2) {
         if(ObjectFind("R2 line") != 0){
            ObjectCreate("R2 line", OBJ_HLINE, 0, Time[1], R2);
            ObjectSet("R2 line", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet("R2 line", OBJPROP_COLOR, ColorR2);
            } else ObjectMove("R2 line", 0, Time[40], R2);
      }
      
      if (Resistencia1) {
         if(ObjectFind("R1 line") != 0){
            ObjectCreate("R1 line", OBJ_HLINE, 0, Time[1], R1);
            ObjectSet("R1 line", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet("R1 line", OBJPROP_COLOR, ColorR1);
            } else ObjectMove("R1 line", 0, Time[40], R1);
      }

      if (Pivote) {
         if(ObjectFind("P line") != 0){
            ObjectCreate("P line", OBJ_HLINE, 0, Time[1], P);
            ObjectSet("P line", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet("P line", OBJPROP_COLOR, ColorP);
            } else ObjectMove("P line", 0, Time[40], P);
      }

      if (Soporte1) {
         if(ObjectFind("S1 line") != 0){
            ObjectCreate("S1 line", OBJ_HLINE, 0, Time[1], S1);
            ObjectSet("S1 line", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet("S1 line", OBJPROP_COLOR, ColorS1);
            } else ObjectMove("S1 line", 0, Time[40], S1);
      }

      if (Soporte2) {
         if(ObjectFind("S2 line") != 0){
            ObjectCreate("S2 line", OBJ_HLINE, 0, Time[1], S2);
            ObjectSet("S2 line", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet("S2 line", OBJPROP_COLOR,ColorS2 );
            } else ObjectMove("S2 line", 0, Time[40], S2);
      }
   }

   if (Texto) {
      if (Resistencia2) {
         if(ObjectFind("R2 label") != 0){
            ObjectCreate("R2 label", OBJ_TEXT, 0, Time[1], R2);
            ObjectSetText("R2 label", " R2", 8, "Arial", White);
            } else ObjectMove("R2 label", 0, Time[1], R2);
         }

      if (Resistencia1) {
         if(ObjectFind("R1 label") != 0){
            ObjectCreate("R1 label", OBJ_TEXT, 0, Time[1], R1);
            ObjectSetText("R1 label", " R1", 8, "Arial", White);
            } else ObjectMove("R1 label", 0, Time[1], R1);
         }

      if (Pivote) {
         if(ObjectFind("P label") != 0){
            ObjectCreate("P label", OBJ_TEXT, 0, Time[1], P);
            ObjectSetText("P label", " P", 8, "Arial", White);
            } else ObjectMove("P label", 0, Time[1], P);
         }

      if (Soporte1) {
         if(ObjectFind("S1 label") != 0){
            ObjectCreate("S1 label", OBJ_TEXT, 0, Time[1], S1);
            ObjectSetText("S1 label", " S1", 8, "Arial", White);
            } else ObjectMove("S1 label", 0, Time[1], S1);
         }

      if (Soporte2) {
         if(ObjectFind("S2 label") != 0){
            ObjectCreate("S2 label", OBJ_TEXT, 0, Time[1], S2);
            ObjectSetText("S2 label", " S2", 8, "Arial", White);
            } else ObjectMove("S2 label", 0, Time[1], S2);
         }
      }
string V;
   if (Valores) {
      if (Resistencia2) {
         if(ObjectFind("R2 valor") != 0){
            ObjectCreate("R2 valor", OBJ_ARROW, 0, Time[0], R2);
            ObjectSet("R2 valor",14,6);
            ObjectSet("R2 valor",6,ColorR2);
            } else ObjectMove("R2 valor", 0, Time[0], R2);
         }

      if (Resistencia1) {
         if(ObjectFind("R1 valor") != 0){
            ObjectCreate("R1 valor", OBJ_ARROW, 0, Time[0], R1);
            ObjectSet("R1 valor",14,6);
            ObjectSet("R1 valor",6,ColorR1);
            } else ObjectMove("R1 valor", 0, Time[0], R1);
         }

      if (Pivote) {
         if(ObjectFind("P valor") != 0){
            ObjectCreate("P valor", OBJ_ARROW, 0, Time[0], P);
            ObjectSet("P valor",14,6);
            ObjectSet("P valor",6,ColorP);
            } else ObjectMove("P valor", 0, Time[0], P);
         }

      if (Soporte1) {
         if(ObjectFind("S1 valor") != 0){
            ObjectCreate("S1 valor", OBJ_ARROW, 0, Time[0], S1);
            ObjectSet("S1 valor",14,6);
            ObjectSet("S1 valor",6,ColorS1);
            } else ObjectMove("S1 valor", 0, Time[0], S1);
         }

      if (Soporte2) {
         if(ObjectFind("S2 valor") != 0){
            ObjectCreate("S2 valor", OBJ_ARROW, 0, Time[0], S2);
            ObjectSet("S2 valor",14,6);
            ObjectSet("S2 valor",6,ColorS2);
            } else ObjectMove("S2 valor", 0, Time[0], S2);
         }
      }

   return(0);
  }
//+------------------------------------------------------------------+