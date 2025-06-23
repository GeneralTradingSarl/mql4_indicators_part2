//+------------+-----------------------------------------------------+
//| v.05.01.08 |                                       SZZReader.mq4 |
//|            |              Bookkeeper, 2008, yuzefovich@gmail.com |
//+------------+-----------------------------------------------------+
//  Необходимо наличие SZZ_without_ZZ.mq4 v.05.01.08
//  Presence SZZ_without_ZZ.mq4 v.05.01.08 is necessary 
//+------------+-----------------------------------------------------+
#property copyright ""
#property link      ""
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  Blue
#property indicator_color2  Blue
//----
extern int SeniorTF=60; // ТФ расcчета узлов ЗигЗага ( >=Period() ! )
extern int NUnits=10;  // считать количество узлов ЗигЗага ( =20 max)
//----                                      
double SnakeZZ[];
double ZZRubberString[];
//----
double NumBars[21];
double UpAndDn[21];
//----
bool first=true,firstAlert=true;
datetime StartTime;
int NDel=0;
//----
//+------------------------------------------------------------------+
void deinit()
  {
   return;
  }
//---------------------------------------------------------------------
int init()
  {
   IndicatorBuffers(2);
   SetIndexBuffer(0,SnakeZZ);
   SetIndexStyle(0,DRAW_SECTION,EMPTY,2);
   SetIndexEmptyValue(0,0.0);
   SetIndexBuffer(1,ZZRubberString);
   SetIndexStyle(1,DRAW_SECTION,STYLE_DOT);
   SetIndexEmptyValue(1,0.0);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
   */
//---------------------------------------------------------------------
int start()
  {
   int Nmax;
   if(first==true)
     {
      Nmax=NUnits;
      if(Nmax>20) Nmax=20;
      if(Nmax<5) Nmax=5;
      if(SeniorTF<Period()) SeniorTF=Period();
      first=false;
     }
   else Nmax=4;
   for(int k=0;k<21;k++)
     {
      NumBars[k]=0;
      UpAndDn[k]=0;
     }
   for(int i=0;i<=Nmax;i++)
     {
      NumBars[i]=iCustom(Symbol(),SeniorTF,"SZZ_without_ZZ",Time[0],Nmax+1,0,i);
      UpAndDn[i]=iCustom(Symbol(),SeniorTF,"SZZ_without_ZZ",Time[0],Nmax+1,1,i);
     }
   if(NDel>0) for(i=0;i<=NDel;i++) { SnakeZZ[i]=0; ZZRubberString[i]=0; }
   int j=0;
   int n;
   int n2;
   int nu=0;
   while(nu<Nmax)
     {
      nu++;
      i=(int)NumBars[nu];
      n=iBarShift(Symbol(),Period(),iTime(Symbol(),SeniorTF,i-1))+1;
      n2=iBarShift(Symbol(),Period(),iTime(Symbol(),SeniorTF,i));
      if(UpAndDn[nu]>0)
        {
         k=iHighest(Symbol(),Period(),MODE_HIGH,n2-n+1,n);
         SnakeZZ[k]=High[k];
         ZZRubberString[k]=SnakeZZ[k];
        }
      else
        {
         k=iLowest(Symbol(),Period(),MODE_LOW,n2-n+1,n);
         SnakeZZ[k]=Low[k];
         ZZRubberString[k]=SnakeZZ[k];
        }
      if(nu==1)
        {
         if(UpAndDn[0]>0)
           {
            j=iHighest(Symbol(),Period(),MODE_HIGH,k,0);
            SnakeZZ[0]=High[j];
            ZZRubberString[j]=High[j];
            if(j!=0)
               ZZRubberString[0]=Low[iLowest(Symbol(),Period(),MODE_LOW,j,0)];
            else ZZRubberString[0]=High[0];
           }
         else
           {
            j=iLowest(Symbol(),Period(),MODE_LOW,k,0);
            SnakeZZ[0]=Low[j];
            ZZRubberString[j]=Low[j];
            if(j!=0)
               ZZRubberString[0]=High[iHighest(Symbol(),Period(),MODE_HIGH,j,0)];
            else ZZRubberString[0]=Low[0];
           }
        }
      if(nu==3) j=k;
     }
   NDel=j;
/*
   */
   return(0);
  }
//---------------------------------------------------------------------
