//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*------------------------------------------------------------------+
 |                                              Nik_PSAR_2B_Nov.mq4 |
 |                                                 Copyright © 2012 |
 |                                             basisforex@gmail.com |
 +------------------------------------------------------------------*/
#property copyright "Copyright © 2010, basisforex@gmail.com"
#property link      "basisforex@gmail.com"
//-----
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 White
#property indicator_color2 Yellow
#property indicator_color3 Orange
#property indicator_color4 Red
#property indicator_color5 Aqua
#property indicator_color6 Green
#property indicator_color7 Blue
//-----
extern int        BarsShow=1000;
extern bool       bM1             = true;
extern bool       bM5             = true;
extern bool       bM15            = true;
extern bool       bM30            = true;
extern bool       bH1             = true;
extern bool       bH4             = true;
extern bool       bD1             = true;
//-----
extern double     Step           = 0.02;
extern double     Maximum        = 0.2;
//-----
double s1[];
double s2[];
double s3[];
double s4[];
double s5[];
double s6[];
double s7[];
//---------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,s1);
   SetIndexBuffer(1,s2);
   SetIndexBuffer(2,s3);
   SetIndexBuffer(3,s4);
   SetIndexBuffer(4,s5);
   SetIndexBuffer(5,s6);
   SetIndexBuffer(6,s7);
//-----
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,159);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,159);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,159);
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,159);
//-----
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit--;
//-----
   for(int i=limit-1; i>=0; i--)
     {
      int v1=PERIOD_M5 / Period();
      int v2=PERIOD_M15 / Period();
      int v3=PERIOD_M30 / Period();
      int v4=PERIOD_H1 / Period();
      int v5=PERIOD_H4 / Period();
      int v6=PERIOD_D1 / Period();

      if(bM1==true) s1[i]=iSAR(NULL,Period(),Step,Maximum,i);

      if(bM5==true)

        {
         if(v1!=0)
            s2[i]=iSAR(NULL,PERIOD_M5,Step,Maximum,i/(v1));
         else s2[i]=EMPTY_VALUE;
        }

      if(bM15==true)

        {
         if(v2!=0)
            s3[i]=iSAR(NULL,PERIOD_M15,Step,Maximum,i/(v2));
         else s3[i]=EMPTY_VALUE;
        }

      if(bM30==true)

        {
         if(v3!=0)
            s4[i]=iSAR(NULL,PERIOD_M30,Step,Maximum,i/(v3));
         else s4[i]=EMPTY_VALUE;
        }

      if(bH1==true)

        {
         if(v4!=0)
            s5[i]=iSAR(NULL,PERIOD_H1,Step,Maximum,i/(v4));
         else s5[i]=EMPTY_VALUE;
        }

      if(bH4==true)

        {
         if(v5!=0)
            s6[i]=iSAR(NULL,PERIOD_H4,Step,Maximum,i/(v5));
         else s6[i]=EMPTY_VALUE;
        }

      if(bD1==true)

        {
         if(v6!=0)
            s7[i]=iSAR(NULL,PERIOD_D1,Step,Maximum,i/(v6));
         else s7[i]=EMPTY_VALUE;
        }

     }
//=======
   return(0);
  }
//+------------------------------------------------------------------+
