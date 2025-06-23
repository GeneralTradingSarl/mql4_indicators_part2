//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "http://dmffx.com"
#property link      "http://dmffx.com"

#property indicator_separate_window




#property indicator_buffers 2
#property indicator_color1 Gray
#property indicator_color2 Gray



//---- input parameters
extern int FFTPower=8;  // Размер анализируемого окна степень двойки. При значении 8 анализируется 256 баров.
extern int ShowBars=500;   // Количество баров для которых выполняется анализ.
extern int Shift=1;  // Сдвиг баров для которых выполняется анализ
extern int From_T=4; // Минимальный отображаемый период (значение периода на нижней границе диаграммы)
extern int To_T=50;  // Максимальный отображаемый период (значение периода на верхней границе диаграммы) 
extern color MaxColor=Yellow; // Цвет максимальной амплитуды
extern color MinColor=Navy;   // Цвет минимальной амплитуды

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double Counter[];
double Signal[];

#define Pi 3.14159265358979323846
#define TwoPi 6.28318530717958647692

int FFTPeriod;
double FFTTmpOutput_1[];
double FFTSpectr[][3];
double FFTTmpOutput_2[];
double FFTPprocessedData[];
double FFTDC,FFTStartVShift;

double FFTFilterK[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+



int init()
  {

   fFFTInit(FFTPower,FFTPeriod,FFTTmpOutput_1,FFTSpectr,FFTTmpOutput_2,FFTPprocessedData);

//---- indicators

   IndicatorBuffers(8);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);

   SetIndexBuffer(2,Counter);
   SetIndexBuffer(3,Signal);

   SetIndexEmptyValue(2,0);

   IndicatorDigits(0);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   fObjDeleteByPrefix(WindowExpertName());
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=2;

   for(int i=limit;i>=0;i--)
     {
      Signal[i]=Close[i];
      Counter[i]=Counter[i+1]+1;
      ExtMapBuffer1[i]=From_T-2;
      ExtMapBuffer2[i]=MathMin(FFTPeriod/2-1,To_T)+2;
     }
   limit=MathMin(limit,ShowBars-1);
   limit+=Shift;
   for(i=limit;i>=Shift;i--)
     {
      fFFTDirectMain(Signal,i,FFTPeriod,FFTTmpOutput_1);
      fFFTDirectConvertToSpectr(FFTTmpOutput_1,FFTPeriod,FFTSpectr,FFTDC,FFTStartVShift);
      double Max=0;
      for(int j=From_T;j<=MathMin(FFTPeriod/2-1,To_T);j++)
        {
         Max=MathMax(Max,FFTSpectr[j][0]);
        }
      for(j=From_T;j<=MathMin(FFTPeriod/2-1,To_T);j++)
        {
         string ObjName=WindowExpertName()+"_"+fInt(Counter[i])+"_"+j;
         fObjTrendLine(ObjName,Time[i],j,Time[i+1],j,false,GetColor(FFTSpectr[j][0]/Max,MinColor,MaxColor),2,WindowFind(WindowExpertName()),0,false);
         ObjectSetText(ObjName,""+DoubleToStr(1.0*FFTPeriod/j,1));
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+

void fObjTrendLine(
                   string aObjectName,  // 1 имя
                   datetime aTime_1,    // 2 время 1
                   double aPrice_1,     // 3 цена 1
                   datetime aTime_2,    // 4 время 2
                   double aPrice_2,     // 5 цена 2
                   bool aRay=false,     // 6 луч
                   color aColor=Red,    // 7 цвет
                   int aWidth=1,        // 8 толщина
                   int aWindowNumber=0, // 9 окно
                   int aStyle=0,        // 10 0-STYLE_SOLID, 1-STYLE_DASH, 2-STYLE_DOT, 3-STYLE_DASHDOT, 4-STYLE_DASHDOTDOT
                   bool aBack=false     // 11 фон
                   )
  {
   if(ObjectFind(aObjectName)!=aWindowNumber)
     {
      ObjectCreate(aObjectName,OBJ_TREND,aWindowNumber,aTime_1,aPrice_1,aTime_2,aPrice_2);
     }
   ObjectSet(aObjectName,OBJPROP_TIME1,aTime_1);
   ObjectSet(aObjectName,OBJPROP_PRICE1,aPrice_1);
   ObjectSet(aObjectName,OBJPROP_TIME2,aTime_2);
   ObjectSet(aObjectName,OBJPROP_PRICE2,aPrice_2);
   ObjectSet(aObjectName,OBJPROP_RAY,aRay);
   ObjectSet(aObjectName,OBJPROP_COLOR,aColor);
   ObjectSet(aObjectName,OBJPROP_WIDTH,aWidth);
   ObjectSet(aObjectName,OBJPROP_BACK,aBack);
   ObjectSet(aObjectName,OBJPROP_STYLE,aStyle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fInt(double aArg)
  {
   return(aArg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fObjDeleteByPrefix(string aPrefix)
  {

//fObjDeleteByPrefix("");

   for(int i=ObjectsTotal()-1;i>=0;i--)
     {
      if(StringFind(ObjectName(i),aPrefix,0)==0)
        {
         ObjectDelete(ObjectName(i));
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetColor(double aK,int Col1,double Col2)
  {
   int R1,G1,B1,R2,G2,B2;
   fGetRGB(R1,G1,B1,Col1);
   fGetRGB(R2,G2,B2,Col2);
   return(fRGB(R1+aK*(R2-R1),G1+aK*(G2-G1),B1+aK*(B2-B1)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fGetRGB(int  &aR,int  &aG,int  &aB,int aCol)
  {
   aB=aCol/65536;
   aCol-=aB*65536;
   aG=aCol/256;
   aCol-=aG*256;
   aR=aCol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color fRGB(int aR,int aG,int aB)
  {
   return(aR+256*aG+65536*aB);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fFFTInit(int aFFTPower,int  &aPeriod,double  &aTmpOutput_1[],double  &aSpectr[][2],double  &aTmpOutput_2[],double  &aFFTPprocessedData[])
  {
   aPeriod=MathPow(2,FFTPower);
   ArrayResize(aTmpOutput_1,aPeriod);
   ArrayResize(aSpectr,aPeriod/2);
   ArrayResize(aTmpOutput_2,aPeriod);
   ArrayResize(FFTPprocessedData,aPeriod);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fFFTDirectMain(double aInput[],int aInputStart,int aPeriod,double  &aTmpOutput[])
  {

   double twr; double twi; double twpr; double twpi; double twtemp; double ttheta; int i; int i1; int i2; int i3; int i4;
   double c1; double c2; double h1r; double h1i; double h2r; double h2i; double wrs; double wis; int HalfPeriod; int ii;
   int jj; int n; int mmax; int m; int j; int istep; int isign; double wtemp; double wr; double wpr; double wpi; double wi;
   double theta; double tempr; double tempi;

   ttheta=2.0*Pi/aPeriod;
   c1=0.5;
   c2=-0.5;
   isign=1;
   n=aPeriod;
   HalfPeriod=aPeriod/2;
   j=1;
   ArrayCopy(aTmpOutput,aInput,0,aInputStart,aPeriod);
   for(ii=1;ii<=HalfPeriod;ii++)
     {
      i=2*ii-1;
      if(j>i)
        {
         tempr=aTmpOutput[j-1];
         tempi=aTmpOutput[j];
         aTmpOutput[j-1]=aTmpOutput[i-1];
         aTmpOutput[j]=aTmpOutput[i];
         aTmpOutput[i-1]=tempr;
         aTmpOutput[i]=tempi;
        }
      m=n/2;
      while(m>=2 && j>m)
        {
         j=j-m;
         m=m/2;
        }
      j=j+m;
     }
   mmax=2;
   while(n>mmax)
     {
      istep=2*mmax;
      theta=2.0*Pi/(isign*mmax);
      wpr=-2.0*MathPow(MathSin(0.5*theta),2);
      wpi=MathSin(theta);
      wr=1.0;
      wi=0.0;
      for(ii=1;ii<=mmax/2;ii++)
        {
         m=2*ii-1;
         for(jj=0;jj<=(n-m)/istep;jj++)
           {
            i=m+jj*istep;
            j=i+mmax;
            tempr=wr*aTmpOutput[j-1]-wi*aTmpOutput[j];
            tempi=wr*aTmpOutput[j]+wi*aTmpOutput[j-1];
            aTmpOutput[j-1]=aTmpOutput[i-1]-tempr;
            aTmpOutput[j]=aTmpOutput[i]-tempi;
            aTmpOutput[i-1]=aTmpOutput[i-1]+tempr;
            aTmpOutput[i]=aTmpOutput[i]+tempi;
           }
         wtemp=wr;
         wr=wr*wpr-wi*wpi+wr;
         wi=wi*wpr+wtemp*wpi+wi;
        }
      mmax=istep;
     }
   twpr=-2.0*MathPow(MathSin(0.5*ttheta),2);
   twpi=MathSin(ttheta);
   twr=1.0+twpr;
   twi=twpi;
   for(i=2;i<=aPeriod/4+1;i++)
     {
      i1=i+i-2;
      i2=i1+1;
      i3=aPeriod+1-i2;
      i4=i3+1;
      wrs=twr;
      wis=twi;
      h1r=c1*(aTmpOutput[i1]+aTmpOutput[i3]);
      h1i=c1*(aTmpOutput[i2]-aTmpOutput[i4]);
      h2r=-c2*(aTmpOutput[i2]+aTmpOutput[i4]);
      h2i=c2*(aTmpOutput[i1]-aTmpOutput[i3]);
      aTmpOutput[i1]=h1r+wrs*h2r-wis*h2i;
      aTmpOutput[i2]=h1i+wrs*h2i+wis*h2r;
      aTmpOutput[i3]=h1r-wrs*h2r+wis*h2i;
      aTmpOutput[i4]=-h1i+wrs*h2i+wis*h2r;
      twtemp=twr;
      twr=twr*twpr-twi*twpi+twr;
      twi=twi*twpr+twtemp*twpi+twi;
     }
   h1r=aTmpOutput[0];
   aTmpOutput[0]=h1r+aTmpOutput[1];
   aTmpOutput[1]=h1r-aTmpOutput[1];
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fFFTDirectConvertToSpectr(double aInput[],int aPeriod,double  &aOutput[][2],double  &aDCValue,double  &aStartVShift)
  {
   int i,j,HalfPeriod;
   HalfPeriod=aPeriod/2;
   for(i=2,j=1;i<aPeriod;i+=2,j++)
     {
      aOutput[j][0]=MathSqrt(aInput[i]*aInput[i]+aInput[i+1]*aInput[i+1])/HalfPeriod;
      aOutput[j][1]=fMyArcTan2(aInput[i+1],aInput[i]);
     }
   aDCValue=aInput[0]/aPeriod;
   aStartVShift=aInput[1];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fMyArcTan2(double aY,double aX)
  { // в обе стороны
   if(aY==0)
     {
      if(aX==0)
        {
         return(0);
        }
      if(aX>0)
        {
         return(0);
        }
      if(aX<0)
        {
         return(MathArctan(1)*4);
        }
     }
   if(aX==0)
     {
      if(aY>0)
        {
         return(MathArctan(1)*2);
        }
      else
        {
         if(aY<0)
           {
            return(-MathArctan(1)*2);
           }
        }
     }
   else
     {
      if(aY>0)
        {
         if(aX>0)
           {
            return(MathArctan(aY/aX));
           }
         else
           {
            return(MathArctan(aY/aX)+MathArctan(1)*4);
           }
        }
      else
        {
         if(aX>0)
           {
            return(MathArctan(aY/aX));
           }
         else
           {
            return(MathArctan(aY/aX)-MathArctan(1)*4);
           }
        }
     }
  }
//+------------------------------------------------------------------+
