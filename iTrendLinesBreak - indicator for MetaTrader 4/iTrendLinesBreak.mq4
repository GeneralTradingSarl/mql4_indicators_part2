//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "http://dmffx.com"
#property link      "http://dmffx.com"

#property indicator_chart_window
#property indicator_buffers 5
//#property indicator_color1 CLR_NONE
#property indicator_color1 White
#property indicator_color2 Maroon
#property indicator_color3 MediumBlue
#property indicator_color4 DodgerBlue
#property indicator_color5 Red

#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1

/*
   HLPeriod - Параметр зигзага аналогичный параметру ExtDepth индикатора ZigZag
   MinHeight - Минимальная высота отрезка зигзага по вертикали (в пунктах)
   OneCross - Только одно пересечение на одну линию. После пересечения отображается стрелка, а линия перестает отображаться.
   AngFrom - Минимальный наклон линий в пунктах на бар (для поддержу, для сопротивленй будет наоборот симметрично).
   Cone - Диапазон допустимого наклона (ширина конуса в который может попадать линия)
*/

extern   int      HLPeriod             =  20;         // Параметр зигзага аналогичный параметру ExtDepth индикатора ZigZag
extern   int      MinHeight            =  0;          // Минимальная высота колена зигзага по вертикали (в пунктах)
extern   bool     OneCross             =  true;       // Только одно пересечение на одну линию. После пересечения отображается стрелка, а линия перестает отображаться.
extern   double   AngFrom              =  -0.01;      // Минимальный наклон линий в пунктах на бар (для поддержу, для сопротивленй будет наоборот симметрично).
extern   double   Cone                 =  1;          // Диапазон допустимого наклона (ширина конуса в который может попадать линия)


double AngTo;

//---- buffers
double zz[];
double sup[];
double res[];

double lht[];
double llt[];
double buy[];
double sell[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

   AngTo=AngFrom+Cone;

//---- indicators
   IndicatorBuffers(7);

   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,zz);
   SetIndexEmptyValue(0,0.0);

   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,sup);
   SetIndexArrow(1,158);
   SetIndexEmptyValue(1,0.0);

   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2,res);
   SetIndexArrow(2,158);
   SetIndexEmptyValue(2,0.0);

   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3,buy);
   SetIndexArrow(3,233);
   SetIndexEmptyValue(3,0.0);

   SetIndexStyle(4,DRAW_ARROW);
   SetIndexBuffer(4,sell);
   SetIndexArrow(4,234);
   SetIndexEmptyValue(4,0.0);

   SetIndexBuffer(5,lht);
   SetIndexBuffer(6,llt);

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
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;

   if(counted_bars==0)
     {
      ArrayInitialize(lht,0);
      ArrayInitialize(llt,0);
     }

   static datetime LastTime=0;
   static int cDir=0;
   static int pDir=0;

   static double cSX1=0;
   static double cSY1=0;
   static double cSX2=0;
   static double cSY2=0;

   static double pSX1=0;
   static double pSY1=0;
   static double pSX2=0;
   static double pSY2=0;

   static double cRX1=0;
   static double cRY1=0;
   static double cRX2=0;
   static double cRY2=0;

   static double pRX1=0;
   static double pRY1=0;
   static double pRX2=0;
   static double pRY2=0;


   if(counted_bars==0)
     {
      LastTime=0;
      cDir=0;
      pDir=0;

      cSX1=0;
      cSY1=0;
      cSX2=0;
      cSY2=0;

      pSX1=0;
      pSY1=0;
      pSX2=0;
      pSY2=0;

      cRX1=0;
      cRY1=0;
      cRX2=0;
      cRY2=0;

      pRX1=0;
      pRY1=0;
      pRX2=0;
      pRY2=0;
     }

   for(int i=limit;i>=0;i--)
     {

      if(Time[i]>LastTime)
        {
         LastTime=Time[i];
         pDir=cDir;

         pSX1=cSX1;
         pSY1=cSY1;
         pSX2=cSX2;
         pSY2=cSY2;

         pRX1=cRX1;
         pRY1=cRY1;
         pRX2=cRX2;
         pRY2=cRY2;
        }
      else
        {
         cDir=pDir;

         cSX1=pSX1;
         cSY1=pSY1;
         cSX2=pSX2;
         cSY2=pSY2;

         cRX1=pRX1;
         cRY1=pRY1;
         cRX2=pRX2;
         cRY2=pRY2;
        }

      lht[i]=lht[i+1];
      llt[i]=llt[i+1];
      zz[i]=0;
      int lhb;
      int llb;
      int hb=iHighest(NULL,0,MODE_HIGH,HLPeriod,i);
      int lb=iLowest(NULL,0,MODE_LOW,HLPeriod,i);

      if(hb>-1 && lb>-1)
        {
         lhb=Bars-lht[i]-1;
         llb=Bars-llt[i]-1;

         if(llb>lhb)
           {
            zz[lhb]=High[lhb];
           }
         else
           {
            zz[llb]=Low[llb];
           }
         if(hb==lb)
           {
            if(hb==i)
              {
               switch(cDir)
                 {
                  case 1:
                     if(High[i]>zz[lhb])
                       {
                        zz[lhb]=0;
                        zz[i]=High[i];
                        lht[i]=Bars-i-1;
                       }
                     else
                       {
                        if(Low[i]<=zz[lhb]-Point*MinHeight)
                          {
                           zz[i]=Low[i];
                           llt[i]=Bars-i-1;
                           cDir=-1;
                          }
                       }
                     break;
                  case -1:
                     if(Low[i]<zz[llb])
                       {
                        zz[llb]=0;
                        zz[i]=Low[i];
                        llt[i]=Bars-i-1;
                       }
                     else
                       {
                        if(High[i]>=zz[llb]+Point*MinHeight)
                          {
                           zz[i]=High[i];
                           lht[i]=Bars-i-1;
                           cDir=1;
                          }
                       }
                     break;
                 }
              }

           }
         else if(lb>hb)
           {
            if(hb==i)
              {
               if(cDir==1)
                 {
                  if(High[i]>zz[lhb])
                    {
                     zz[lhb]=0;
                     zz[i]=High[i];
                     lht[i]=Bars-i-1;
                    }
                 }
               else
                 {
                  if(High[i]>=zz[llb]+Point*MinHeight)
                    {
                     zz[i]=High[i];
                     lht[i]=Bars-i-1;
                     cDir=1;
                    }
                 }
              }
           }
         else if(hb>lb)
           {
            if(lb==i)
              {
               if(cDir==-1)
                 {
                  if(Low[i]<zz[llb])
                    {
                     zz[llb]=0;
                     zz[i]=Low[i];
                     llt[i]=Bars-i-1;
                    }
                 }
               else
                 {
                  if(Low[i]<=zz[lhb]-Point*MinHeight)
                    {
                     zz[i]=Low[i];
                     llt[i]=Bars-i-1;
                     cDir=-1;
                    }
                 }
              }
           }

         sup[i]=sup[i+1];
         res[i]=res[i+1];
         if(cDir==1)
           {
            if(pDir==-1)
              {
               int z0=Bars-llt[i]-1;
               int z1=Bars-lht[z0]-1;
               int z2=Bars-llt[z1]-1;
               double Ang=(zz[z0]-zz[z2])/(llt[i]-llt[z1]);
               if(Ang>=Point*AngFrom && Ang<=Point*AngTo)
                 {
                  cSX1=llt[z1];
                  cSY1=zz[z2];
                  cSX2=llt[i];
                  cSY2=zz[z0];
                  sup[i]=fGetLineValue_y3(Bars-cSX1,cSY1,Bars-cSX2,cSY2,i);
                 }
              }
           }
         if(cDir==-1)
           {
            if(pDir==1)
              {
               z0=Bars-lht[i]-1;
               z1=Bars-llt[z0]-1;
               z2=Bars-lht[z1]-1;
               Ang=(zz[z0]-zz[z2])/(lht[i]-lht[z1]);
               if(Ang<=-Point*AngFrom && Ang>=-Point*AngTo)
                 {
                  cRX1=lht[z1];
                  cRY1=zz[z2];
                  cRX2=lht[i];
                  cRY2=zz[z0];
                  res[i]=fGetLineValue_y3(Bars-cRX1,cRY1,Bars-cRX2,cRY2,i);
                 }

              }
           }
         if(sup[i]!=0)
            sup[i]=fGetLineValue_y3(Bars-cSX1,cSY1,Bars-cSX2,cSY2,i);
         if(res[i]!=0)
            res[i]=fGetLineValue_y3(Bars-cRX1,cRY1,Bars-cRX2,cRY2,i);

         sell[i]=0;
         if(sup[i]!=0)
           {
            if(sup[i+1]!=0)
              {
               if(Close[i]<sup[i])
                 {
                  if(Close[i+1]>=sup[i+1])
                    {
                     sell[i]=High[i]+Point*5;
                     if(OneCross)sup[i]=0;
                    }
                 }
              }
           }
         buy[i]=0;
         if(res[i]!=0)
           {
            if(res[i+1]!=0)
              {
               if(Close[i]>res[i])
                 {
                  if(Close[i+1]<=res[i+1])
                    {
                     buy[i]=Low[i]-Point*5;
                     if(OneCross)res[i]=0;
                    }
                 }
              }
           }
        }

     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fGetLineValue_y3(double x1,double y1,double x2,double y2,double x3)
  {
   double d=x2-x1;
   if(d==0)return(0);
   return(y1+(x3-x1)*(y2-y1)/d);
  }
//+------------------------------------------------------------------+
