//+--------------------------------------------------------------------+
//|                         Copyright 2015, MetaQuotes Software Corp.  |
//|                                             https://www.mql5.com   |
//| Indicator : File45 - Kijun Sen and Envelopes                       |                                                                  |
//| Author: file45 - https://www.mql5.com/en/users/file45/publications |
//+--------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "3.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 3
#property indicator_width1 0
#property indicator_width2 0
#property indicator_width3 0
#property indicator_style1 0
#property indicator_style2 0
#property indicator_style3 0
#property indicator_color1 LimeGreen
#property indicator_color2 DodgerBlue
#property indicator_color3 Red

input int Kijun_Sen_Period = 50; // Kijun Sen Period
int ShiftKijun = 0; 
input int Envelope_Deviation = 300;  // Envelope Deviation
input string a = " * * * * * "; // Kijun Sen and Envelope colors - See Colors Tab
input bool Show_Kijun_Sen = true; // Show Kijun Sen
input bool Show_Top_Envelope_Band = true; // Show Top Envelope
input bool Show_Bottom_Envelope_Band = true; // Show Bottom Envelope
input bool Show_Labels = false; // Show Price
input color Envelope_Top_Label_Color = LimeGreen; // Top Envelope Price Color
input color Kijun_Sen_Label_Color = DodgerBlue; // Kijun Sen Price Color
input color Envelope_Bottom_Label_Color = Red; // Bottom Envelope Price Color
input int Text_Size = 12; // Price Font Size
input bool Make_Text_Bold = false; // Price Font Bold
input int Move_Text_Right = 25; // Move Price    < - - - - >

double Kijun_Buffer_1[];
double Kijun_Buffer_2[];
double Kijun_Buffer_3[];

string Font_Type;

string ObjKijun="Kijun";
string ObjEnvET="EnvET";
string ObjEnvEB="EnvEB";

int a_begin;

/////////////////////////////// Testing code
string textks  = "";
string textet  = "";
string texteb  = "";
string KEB, KET, KS;
/////////////////////////////// Testing code

int OnInit()
{
  
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Kijun_Buffer_1);
   SetIndexDrawBegin(0,Kijun_Sen_Period+ShiftKijun-1);
   SetIndexShift(0,ShiftKijun);
   SetIndexLabel(0,"Top Env Band");
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Kijun_Buffer_2);
   SetIndexDrawBegin(1,Kijun_Sen_Period+ShiftKijun-1);
   SetIndexShift(1,ShiftKijun);
   SetIndexLabel(1,"Kijun Sen");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Kijun_Buffer_3);
   SetIndexDrawBegin(2,Kijun_Sen_Period+ShiftKijun-1);
   SetIndexShift(2,ShiftKijun);
   SetIndexLabel(2,"Bottom Env");
   
   if(Make_Text_Bold == true)
   {
     Font_Type = "Arial Bold";
   }
   else
   {
      Font_Type ="Arial";
   }  
   

/////////////////////////////// Testing code   
   if (Show_Labels == false)
   {
      textks  = "";
      textet  = "";
      texteb  = "";     
   }
/////////////////////////////// Testing code 
   return(INIT_SUCCEEDED);
}

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
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double highx,lowx,pricex;

   if(Bars<=Kijun_Sen_Period) return(0);

   if(counted_bars<1)
   {
      for(i=1;i<=Kijun_Sen_Period;i++)   
      Kijun_Buffer_1[Bars-i]=0;
      Kijun_Buffer_2[Bars-i]=0;
      Kijun_Buffer_3[Bars-i]=0;
   }
   //---- Kijun Sen + Envelopes
   i=Bars-Kijun_Sen_Period;
   if(counted_bars>Kijun_Sen_Period) i=Bars-counted_bars-1;
   while(i>=0)
   {
      highx=High[i]; lowx=Low[i]; k=i-1+Kijun_Sen_Period;
      while(k>=i)
      {
         pricex=High[k];
         if(highx<pricex) highx=pricex;
         pricex=Low[k];
         if(lowx>pricex) lowx=pricex;
         k--;
      }
      
      if(Show_Top_Envelope_Band == true)
      {
         Kijun_Buffer_1[i+ShiftKijun]=((highx+lowx)/2)+Envelope_Deviation*Point;
         if(Show_Labels==true)
         {
            KET = DoubleToStr(Kijun_Buffer_1[0],Digits);
         }
         ObjectCreate(ObjEnvET,OBJ_TEXT,0,0,0);
         ObjectSetText(ObjEnvET,textet + KET,Text_Size, Font_Type,Envelope_Top_Label_Color);
         ObjectMove(ObjEnvET,0,Time[0]+Period()*Move_Text_Right*Text_Size,Kijun_Buffer_1[0]);
      }
      
      if(Show_Kijun_Sen==true)
      {
         Kijun_Buffer_2[i+ShiftKijun]=((highx+lowx)/2);
         if(Show_Labels == true)
         {
            KS = DoubleToStr(Kijun_Buffer_2[0],Digits);
         }
         ObjectCreate(ObjKijun,OBJ_TEXT,0,0,0);
         ObjectSetText(ObjKijun,textks + KS,Text_Size,Font_Type, Kijun_Sen_Label_Color);
         ObjectMove(ObjKijun,0,Time[0]+Period()*Move_Text_Right*Text_Size,Kijun_Buffer_2[0]);
      }
      
      if(Show_Bottom_Envelope_Band == true)
      {
         Kijun_Buffer_3[i+ShiftKijun]=((highx+lowx)/2)-Envelope_Deviation*Point;
         if (Show_Labels == true)
         {      
            KEB = DoubleToStr(Kijun_Buffer_3[0],Digits);
         }
         ObjectCreate(ObjEnvEB,OBJ_TEXT,0,Time[0],highx);
         ObjectSetText(ObjEnvEB,texteb + KEB,Text_Size,Font_Type,Envelope_Bottom_Label_Color);
         ObjectMove(ObjEnvEB,0,Time[0]+Period()*Move_Text_Right*Text_Size,Kijun_Buffer_3[0]);
      }
      i--;
   } 
   i=ShiftKijun-1;
   
   return(rates_total);
}
 
int deinit()
{
   ObjectDelete(0,"Kijun");
   ObjectDelete(0,"EnvET");
   ObjectDelete(0,"EnvEB");
   
   return(0);

}   

 