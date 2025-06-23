//==================================================================================================
//                                                                      Canal_Linear_Sinus_FT.mq4 //
//                                                                             buldakov_a@mail.ru //
//                                                                                        USD/JPY //
//                                                                                     03.11.2009 //
//==================================================================================================
#property indicator_chart_window                                                                  //
//#property indicator_separate_window                                                             //
#property indicator_buffers 8                                                                     //
#property indicator_color1 Blue                                                                   //
#property indicator_color2 OrangeRed                                                              //
#property indicator_color3 Red                                                                    //
#property indicator_color4 Red                                                                    //
#property indicator_color5 Gold                                                                   //
#property indicator_color6 Gold                                                                   //
#property indicator_color7 Green                                                                  //
#property indicator_color8 Green                                                                  //
//+++ начало блок 1 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//=== Внешние переменные ===========================================================================
extern int Hours=600;                                                                             //
//+++ конец блок 1 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++ начало блок 2 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//=== Внутренние переменные ========================================================================
int limit;                                                                                        //
int j,i,n,t;                                                                                      //
double pi=3.14159265,Num,Den;                                                                     //
double syi,syti,stti,stttti,sOuti,si,sOutti,sOuttti,a,b,c;                                        //
double Alfa,dAlfa,sum_up,sum_dn;                                                                  //
double temp1,temp2,temp3,temp4,temp5,temp6,temp7;                                                 //
//+++ конец блок 2 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++ начало блок 3 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//=== Буффер вывода графика ========================================================================
double Sinus[],Out[],Up1[],Dn1[],Up2[],Dn2[],Up3[],Dn3[];                                         //
//+++ конец блок 3 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//=== Функция инициализации ========================================================================
int init()                                                                                        //
{                                                                                                 //
//=== Установка смещения линии индикатора относительно начала графика ==============================
SetIndexShift(0,0);                                                                               //
SetIndexShift(1,0);                                                                               //
SetIndexShift(2,0);                                                                               //
SetIndexShift(3,0);                                                                               //
SetIndexShift(4,0);                                                                               //
SetIndexShift(5,0);                                                                               //
SetIndexShift(6,0);                                                                               //
SetIndexShift(7,0);                                                                               //
//=== Установка порядкового номера бара от начала данных ===========================================
SetIndexDrawBegin(0,0);                                                                           //
SetIndexDrawBegin(1,0);                                                                           //
SetIndexDrawBegin(2,0);                                                                           //
SetIndexDrawBegin(3,0);                                                                           //
SetIndexDrawBegin(4,0);                                                                           //
SetIndexDrawBegin(5,0);                                                                           //
SetIndexDrawBegin(6,0);                                                                           //
SetIndexDrawBegin(7,0);                                                                           //
//=== 8 буферов пользовательского индикатора =======================================================
SetIndexBuffer(0,Sinus);                                                                          //
SetIndexBuffer(1,Out);                                                                            //
SetIndexBuffer(2,Up1);                                                                            //
SetIndexBuffer(3,Dn1);                                                                            //
SetIndexBuffer(4,Up2);                                                                            //
SetIndexBuffer(5,Dn2);                                                                            //
SetIndexBuffer(6,Up3);                                                                            //
SetIndexBuffer(7,Dn3);                                                                            //
//=== Устанавливает тип для указанной линии индикатора =============================================
SetIndexStyle(0,DRAW_NONE,EMPTY,1);                                                               //
SetIndexStyle(1,DRAW_LINE,EMPTY,4);                                                               //
SetIndexStyle(2,DRAW_LINE,EMPTY,3);                                                               //
SetIndexStyle(3,DRAW_LINE,EMPTY,3);                                                               //
SetIndexStyle(4,DRAW_LINE,EMPTY,2);                                                               //
SetIndexStyle(5,DRAW_LINE,EMPTY,2);                                                               //
SetIndexStyle(6,DRAW_LINE,EMPTY,1);                                                               //
SetIndexStyle(7,DRAW_LINE,EMPTY,1);                                                               //
//=== Установка имени линии индикатора =============================================================
SetIndexLabel(0,NULL);                                                                            //
SetIndexLabel(1,NULL);                                                                            //
SetIndexLabel(2,NULL);                                                                            //
SetIndexLabel(3,NULL);                                                                            //
SetIndexLabel(4,NULL);                                                                            //
SetIndexLabel(5,NULL);                                                                            //
SetIndexLabel(6,NULL);                                                                            //
SetIndexLabel(7,NULL);                                                                            //
//==================================================================================================
return(0);                                                                                        //
}                                                                                                 //
//=== Функция деинициализации ======================================================================
int deinit()                                                                                      //
{ return(0); }                                                                                    //
//=== функция будет запущена только после прихода очередной новой котировки ========================
int start()                                                                                       //
{                                                                                                 //
//==================================================================================================
int counted_bars=IndicatorCounted();                                                              //
if(counted_bars<0) return(-1);                                                                    //
//=== Последний посчитанный бар будет пересчитан                                                  //
if(counted_bars>0) counted_bars--;                                                                //
limit=Bars-counted_bars;                                                                          //
//+++ начало блок 4 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//=== Fast начало ==================================================================================
if (Hours<=2) Hours=2;                                                                            //
n=((Hours*60)/Period())/2;                                                                        //
//=== Быстрое Преобразование Фурье =================================================================
    for(j=(2*n); j>=0; j--)                                                                       //
    {                                                                                             //
       Num=0;Den=0;                                                                               //
       for(i=(n+n); i>=0; i--)                                                                    //
       {                                                                                          //
         Num=Num+MathSin(i*pi/(n+n))*Close[j+i];                                                  //
         Den=Den+MathSin(i*pi/(n+n));                                                             //
       }                                                                                          //
     Sinus[j+n]=Num/Den;                                                                          //
       for(i=n; i>=0; i--)                                                                        //
       {                                                                                          //
     Sinus[i]=Sinus[n+0]+(Sinus[n+0]-Sinus[n+1])*(n-i);                                           //
       }                                                                                          //
    }                                                                                             //
//==================================================================================================
//=== Апроксимация полиномом второй степени ========================================================
t=2*n+1;                                                                                          //
stti=(t*t*t-t)/12;                                                                                //
stttti=(3*t*t*t*t*t-10*t*t*t+7*t)/240;                                                            //
sOuti=0.0;si=0.0;sOutti=0.0;sOuttti=0.0;                                                          //
  for(i=(n*2); i>=0; i--)                                                                         //
  {                                                                                               //
  sOuti=sOuti+Sinus[i];                                                                           //
  si=si+(-i+(t/2));                                                                               //
  sOutti=sOutti+(Sinus[i]*(-i+(t/2)));                                                            //
  sOuttti=sOuttti+(Sinus[i]*(-i+(t/2))*(-i+(t/2)));                                               //
  }                                                                                               //
b=sOutti/stti;                                                                                    //
c=-((sOuti/t)-(sOuttti/stti))/MathAbs((stti/t)-(stttti/stti));                                    //
a=(sOuti-stti*c)/t;                                                                               //
  for(i=(2*n); i>=0; i--)                                                                         //
  {                                                                                               //
  Out[i]=a+b*(-i+(t/2))+c*(-i+(t/2))*(-i+(t/2));                                                  //
  }                                                                                               //
//==================================================================================================
sum_up=0;sum_dn=0;                                                                                //
  for(i=(2*n); i>=0; i--)                                                                         //
  {                                                                                               //
  if (High[i]>Out[i]) sum_up=sum_up+MathAbs(High[i]-Out[i]);                                      //
  if (Low[i] <Out[i]) sum_dn=sum_dn+MathAbs(Low[i]-Out[i]);                                       //
  }                                                                                               //
sum_up=sum_up/(2*n);                                                                              //
sum_dn=sum_dn/(2*n);                                                                              //
  for(i=(2*n); i>=0; i--)                                                                         //
  {                                                                                               //
//==================================================================================================
Up3[i]=Out[i]+3.6*sum_up;                                                                         //
Up2[i]=Out[i]+2.4*sum_up;                                                                         //
Up1[i]=Out[i]+1.2*sum_up;                                                                         //
Dn1[i]=Out[i]-1.2*sum_dn;                                                                         //
Dn2[i]=Out[i]-2.4*sum_dn;                                                                         //
Dn3[i]=Out[i]-3.6*sum_dn;                                                                         //
//==================================================================================================
temp1=Out[i]+3.6*sum_up;                                                                          //
temp2=Out[i]+2.4*sum_up;                                                                          //
temp3=Out[i]+1.2*sum_up;                                                                          //
temp4=Out[i]+0.0*sum_up;                                                                          //
temp5=Out[i]-1.2*sum_dn;                                                                          //
temp6=Out[i]-2.4*sum_dn;                                                                          //
temp7=Out[i]-3.6*sum_dn;                                                                          //
//==================================================================================================
if (Low[0]>(Out[0]+1.2*sum_up))  Up3[i]=Out[i]+4.8*sum_up;                                        //
if (Low[0]>(Out[0]+1.2*sum_up))  Dn3[i]=Out[i]+3.6*sum_up;                                        //
if (Low[0]>(Out[0]+1.2*sum_up))  Up2[i]=Out[i]+2.4*sum_up;                                        //
if (Low[0]>(Out[0]+1.2*sum_up))  Up1[i]=Out[i]+1.2*sum_up;                                        //
if (Low[0]>(Out[0]+1.2*sum_up))  Dn1[i]=Out[i]-1.2*sum_dn;                                        //
if (Low[0]>(Out[0]+1.2*sum_up))  Dn2[i]=Out[i]-2.4*sum_dn;                                        //
//==================================================================================================
if (Low[0]>(Out[0]+1.2*sum_up))  temp1=Out[i]+4.8*sum_up;                                         //
if (Low[0]>(Out[0]+1.2*sum_up))  temp2=Out[i]+3.6*sum_up;                                         //
if (Low[0]>(Out[0]+1.2*sum_up))  temp3=Out[i]+2.4*sum_up;                                         //
if (Low[0]>(Out[0]+1.2*sum_up))  temp4=Out[i]+1.2*sum_up;                                         //
if (Low[0]>(Out[0]+1.2*sum_up))  temp5=Out[i]+0.0*sum_up;                                         //
if (Low[0]>(Out[0]+1.2*sum_up))  temp6=Out[i]-1.2*sum_dn;                                         //
if (Low[0]>(Out[0]+1.2*sum_up))  temp7=Out[i]-2.4*sum_dn;                                         //
//==================================================================================================
if (High[0]<(Out[0]-1.2*sum_dn))  Up2[i]=Out[i]+2.4*sum_up;                                       //
if (High[0]<(Out[0]-1.2*sum_dn))  Up1[i]=Out[i]+1.2*sum_up;                                       //
if (High[0]<(Out[0]-1.2*sum_dn))  Dn1[i]=Out[i]-1.2*sum_dn;                                       //
if (High[0]<(Out[0]-1.2*sum_dn))  Dn2[i]=Out[i]-2.4*sum_dn;                                       //
if (High[0]<(Out[0]-1.2*sum_dn))  Up3[i]=Out[i]-3.6*sum_dn;                                       //
if (High[0]<(Out[0]-1.2*sum_dn))  Dn3[i]=Out[i]-4.8*sum_dn;                                       //
//==================================================================================================
if (High[0]<(Out[0]-1.2*sum_dn))  temp1=Out[i]+2.4*sum_up;                                        //
if (High[0]<(Out[0]-1.2*sum_dn))  temp2=Out[i]+1.2*sum_up;                                        //
if (High[0]<(Out[0]-1.2*sum_dn))  temp3=Out[i]-0.0*sum_dn;                                        //
if (High[0]<(Out[0]-1.2*sum_dn))  temp4=Out[i]-1.2*sum_dn;                                        //
if (High[0]<(Out[0]-1.2*sum_dn))  temp5=Out[i]-2.4*sum_dn;                                        //
if (High[0]<(Out[0]-1.2*sum_dn))  temp6=Out[i]-3.6*sum_dn;                                        //
if (High[0]<(Out[0]-1.2*sum_dn))  temp7=Out[i]-4.8*sum_dn;                                        //
//==================================================================================================
  }                                                                                               //
//==================================================================================================
dAlfa=0;                                                                                          //
Alfa=((Out[0]-Out[60/Period()]))/Point;                                                           //
if (Alfa>0) dAlfa=(((Out[0]-Out[60/Period()])-(Out[60/Period()]-Out[120/Period()])))/Point;       //
if (Alfa<0) dAlfa=(((Out[120/Period()]-Out[60/Period()])-(Out[60/Period()]-Out[0])))/Point;       //
//==================================================================================================
Comment(                                                                                          //
"Дата и Время ",TimeToStr(CurTime()),"\n",                                                        //
         "Периуд       ",DoubleToStr(Hours,0)," час","\n",                                        //
        "Угол наклона ",DoubleToStr(Alfa,1)," Пт/час",                                            //
        "  Изменение угла наклона ",DoubleToStr(dAlfa,3)," Пт/час","\n",                          //
        "  ",DoubleToStr(temp1,2)," Пт","\n",                                                     //
        "  ",DoubleToStr(temp2,2)," Пт","\n",                                                     //
        "  ",DoubleToStr(temp3,2)," Пт","\n",                                                     //
        "  ",DoubleToStr(temp4,2)," Пт","\n",                                                     //
        "  ",DoubleToStr(temp5,2)," Пт","\n",                                                     //
        "  ",DoubleToStr(temp6,2)," Пт","\n",                                                     //
        "  ",DoubleToStr(temp7,2)," Пт");                                                         //
return(0);                                                                                        //
}                                                                                                 //
//==================================================================================================

