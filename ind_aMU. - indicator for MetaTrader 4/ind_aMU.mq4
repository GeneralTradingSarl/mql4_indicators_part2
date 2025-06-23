//+------------------------------------------------------------------+
//|                                                      ind_aMU.mq4 |
//|                                               Yuriy Tokman (YTG) |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman (YTG)"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

extern int period_fast = 12;
extern int period_slow = 21;
extern int ma_shift = 0;
extern int ma_method = 0;
extern int applied_price = 0;

extern string Advisers_free_of_charge = "ytg.com.ua";//  EA FREE - ytg.com.ua

double B0[];
double B1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, 4);
   SetIndexBuffer(0, B0);
   SetIndexStyle(1, 4);
   SetIndexBuffer(1, B1);
   GetAvtor(); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   int limit , i;GetYTG();
   int counted_bars=IndicatorCounted();   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=0; i<limit; i++){
   B0[i] = iMA(Symbol(),0,period_fast,ma_shift,ma_method,applied_price,i); 
   B1[i] = iMA(Symbol(),0,period_slow,ma_shift,ma_method,applied_price,i);   
   }    
//----
   return(0);
  }
//+------------------------------------------------------------------+
//----+
 void Label(string name_label,string text_label,int corner = 2,int x = 3,int y = 15,int font_size = 10,string font_name = "Arial",color text_color = Lime, bool fon = false )
  {
   if (ObjectFind(name_label)!=-1) ObjectDelete(name_label);
       ObjectCreate(name_label,OBJ_LABEL,0,0,0,0,0);         
       ObjectSet(name_label,OBJPROP_CORNER,corner);
       ObjectSet(name_label,OBJPROP_XDISTANCE,x);
       ObjectSet(name_label,OBJPROP_YDISTANCE,y);
       ObjectSetText(name_label,text_label,font_size,font_name,text_color);//OBJPROP_BACK
       ObjectSet(name_label,OBJPROP_BACK,fon);
  }
//----+
void GetAvtor()
 {
  string char1[256]; int i;
  for (i = 0; i < 256; i++) char1[i] = CharToStr(i);   
  string txtt =
  /* EA FREE - ytg.com.ua */ 
  char1[69]+char1[65]+char1[32]+char1[70]+char1[82]+char1[69]+char1[69]+char1[32]
  +char1[45]+char1[32]+char1[121]+char1[116]+char1[103]+char1[46]+char1[99]+char1[111]
  +char1[109]+char1[46]+char1[117]+char1[97]
  ; Label("label",txtt,2,10,15,15);    
 }
//----+
 void GetYTG()
  {
   static int count = 0;
   count++;if(count>2)count = 0;   
   color color_Y = Red;
   color color_T = Lime;   
   color color_G = Blue;
   if(count==1){color_Y = Crimson;color_T = LimeGreen;color_G = DodgerBlue;}
   if(count==2){color_Y = OrangeRed;color_T = ForestGreen;color_G = RoyalBlue;}
                     
   Label("ytg_Y","Y" ,3,40,20,25,"Arial Black",color_Y);
   Label("ytg_T","T" ,3,25,5,25,"Arial Black",color_T);   
   Label("ytg_G","G" ,3,13,32,25,"Arial Black",color_G);       
  }
//----+