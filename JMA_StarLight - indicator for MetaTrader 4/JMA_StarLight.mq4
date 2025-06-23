//+------------------------------------------------------------------+
//|                                          JMA_StarLight           |
//|                 Copyright © 2000-2007, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property copyright "Weld"
#property link "http://weld.torguem.net"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrRed
//---- input parameters 
extern int Length=5; // глубина сглаживания 
extern int Phase =5; // параметр, изменяющийся в пределах -150 ... +150, влияет на качество переходного процесса; 
extern int Shift =0; // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs=0;//Выбор цен, по которым производится расчёт индикатора (0-"Close", 1-"Open", 2-"(High+Low)/2", 3-"High", 4-"Low") 
//---- indicator buffers 
double JMA_Buf[];
double MEMORY1[9];
int    MEMORY2[12];
double MEMORY3[128];
//---- temporary double buffers 
double list[128],ring1[128],ring2[11],buffer[62];
//---- double vars 
double f8,f60,f20,f28,f30,f40,f48,f58,f68,f70,f90,f78,f88,f98;
double Kg,Dr,Ds,Dl,Pf,JMA,series,vv,v1,v2,v3,v4,s20,s10,fB0,fD0;
//---- integer vars 
int ii,jj,s28,s30,f0,v5,v6,fE0,fD8,fE8,val,s48,s58,s60,s68,T0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,Shift);
//---- 1 indicator buffers mapping 
   IndicatorBuffers(1);
   SetIndexBuffer(0,JMA_Buf);
   SetIndexEmptyValue(0,0.0);
//---- 
   IndicatorShortName("JMA Star Light( Length="+Length+", Phase="+Phase+", Shift="+Shift+")");
   SetIndexLabel(0,"JMA Star Light");
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- initial part 
   if(Phase<-100){Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " + Phase+ " будет использовано -100");}
   if(Phase> 100){Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " + Phase+ " будет использовано  100");}
   if(Length<  1){Alert("Параметр Length должен не менее 1" + " Вы ввели недопустимое " + Length+ " будет использовано  1");}
   if(Input_Price_Customs<0){Alert("Параметр Input_Price_Customs должен не менее 0" + " Вы ввели недопустимое " + Input_Price_Customs+ " будет использовано 0");}
   if(Input_Price_Customs>4){Alert("Параметр Input_Price_Customs должен не более 4" + " Вы ввели недопустимое " + Input_Price_Customs+ " будет использовано 0");}
   if(Length<1.0000000002) Dr=0.0000000001; //{1.0e-10} 
   else Dr=(Length-1.0)/2.0;
   if(Phase >   100) Pf=2.5;
   if(Phase <  -100) Pf=0.5;
   if((Phase>=-100) && (Phase<=100)) Pf=Phase/100.0+1.5;
   Dr=Dr * 0.9; Kg=Dr/(Dr + 2.0);
   Ds=MathSqrt(Dr); Dl=MathLog(Ds);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
//---- get already counted bars 
   int counted_bars=IndicatorCounted();
//---- check for possible errors 
   if(counted_bars<0) return(-1);
   int limit=Bars-counted_bars-1;

//----
   if(limit==Bars-1)
     {
      //---- Повторное объявление переменных и их инициализация
      ArrayInitialize (MEMORY1, 0.0);ArrayInitialize (MEMORY2, 0  );
      ArrayInitialize (MEMORY3, 0.0);
      ArrayInitialize (buffer,  0.0);ArrayInitialize (ring1,   0.0);
      ArrayInitialize (ring2,   0.0);ArrayInitialize (list,    0.0);
      //----
      double f18=0.0,f38=0.0,fA0=0.0,fA8=0.0,fC0=0.0,fC8=0.0,s8=0.0,s18=0.0;
      int    s38=0,  s40=0,  s50=0,  s70=0,  LP2=0,  LP1=0;
      //----
      f0=1; s28=63; s30=64;
      for(ii=0;   ii<=s28; ii++)list[ii]=-1000000.0;
      for(ii=s30; ii<=127; ii++)list[ii]= 1000000.0;
      //----
     }
   if(limit<Bars-1)
     {
      //---- инициализация переменных  инициализация
      ArrayInitialize (buffer,  0.0);ArrayInitialize (ring1,   0.0);
      ArrayInitialize (list,    0.0);ArrayInitialize (ring2,   0.0);
      //----
      f8 =0.0;f60=0.0;f20=0.0;f28=0.0;f30=0.0;f40=0.0;f48=0.0;f58=0.0;f68=0.0;
      f70=0.0;f90=0.0;f78=0.0;f88=0.0;f98=0.0;vv =0.0;v1 =0.0;v2 =0.0;v3 =0.0;
      v4 =0.0;fB0=0.0;fD0=0.0;v5 =0;  v6 =0;  fE0=0;  fD8=0;  fE8=0;  val=0;
      //----
      if(Time[limit+1]!=T0)
        {
         //--- Восстановение переменных
         if(Time[limit+1]!=MEMORY2[0])return(-1);
         fC0=MEMORY1[00];
         fC8=MEMORY1[01];
         fA8=MEMORY1[02];
         s8 =MEMORY1[03];
         f18=MEMORY1[04];
         f38=MEMORY1[05];
         s18=MEMORY1[06];
         s20=MEMORY1[07];
         s10=MEMORY1[08];
         //----
         s38=MEMORY2[01];
         s48=MEMORY2[02];
         s50=MEMORY2[03];
         LP1=MEMORY2[04];
         LP2=MEMORY2[05];
         s28=MEMORY2[06];
         s30=MEMORY2[07];
         s48=MEMORY2[08];
         s58=MEMORY2[09];
         s60=MEMORY2[10];
         s68=MEMORY2[11];
         JMA=JMA_Buf[limit+1];
         for(ii=0;ii<=127;ii++)list[ii]=MEMORY3[ii];
         //----
        }
     }
   if(counted_bars==0) limit-=3;
   for(int bar=limit; bar>=0; bar--)
     {
      //---- main cycle
      if((Input_Price_Customs<=0) || Input_Price_Customs>4)series=Close[bar];
      if(Input_Price_Customs==1)series= Open[bar];
      if(Input_Price_Customs==2)series=(High[bar]+Low[bar])/2;
      if(Input_Price_Customs==3)series= High[bar];
      if(Input_Price_Customs==4)series= Low [bar];
      //---- 
      if(LP1<61){LP1++; buffer[LP1]=series;}
      if(LP1>30)
        {
         v1=Dl; v2=v1;
         if((v1/MathLog(2.0))+2.0<0.0) v3=0.0; else v3=(v2/MathLog(2.0))+2.0;
         f98=v3;
         if(f98>=2.5)f88=f98-2.0; else f88=0.5;
         f78=Ds*f98; f90=f78/(f78+1.0);
         if(f0!=0)
           {
            f0=0; v5=0;
            for(ii=0; ii<=29; ii++) {if(buffer[ii+1]!=buffer[ii]) v5=1; break; }
            fD8=v5*30;
            if(fD8==0) f38=series; else f38=buffer[1];
            f18=f38;
            if(fD8>29) fD8=29;
           }
         else fD8=0;
         for(ii=fD8; ii>=0; ii--)
           {
            val=31-ii;
            if(ii==0) f8=series; else f8=buffer[val];
            f28=f8-f18; f48=f8-f38;
            if(MathAbs(f28)>MathAbs(f48)) v2=MathAbs(f28); else v2=MathAbs(f48);
            fA0=v2; vv=fA0+0.0000000001; //{1.0e-10;} 
            if(s48<=1) s48=127; else s48=s48 - 1;
            if(s50<=1) s50=10;  else s50=s50 - 1;
            if(s70<128) s70=s70+1;
            s8=s8+vv-ring2[s50]; ring2[s50]=vv;
            if(s70>10) s20=s8/10.0; else s20=s8/s70;
            if(s70>127)
              {
               s10=ring1[s48]; ring1[s48]=s20; s68=64; s58=s68;
               while(s68>1)
                 {
                  if(list[s58]<s10){s68=s68 *0.5; s58=s58+s68;}
                  else if(list[s58]<=s10) s68=1; else{s68=s68 *0.5; s58=s58-s68;}
                 }
              }
            else
              {
               ring1[s48]=s20;
               if(s28+s30>127){s30=s30-1; s58=s30;}
               else {s28=s28+1; s58=s28;}
               if(s28 > 96) s38=96; else s38=s28;
               if(s30 < 32) s40=32; else s40=s30;
              }
            s68=64; s60=s68;
            while(s68>1)
              {
               if(list[s60]>=s20)
                 {
                  if(list[s60-1]<=s20) s68=1; else {s68=s68 *0.5; s60=s60-s68; }
                 }
               else{s68=s68 *0.5; s60=s60+s68;}
               if((s60==127) && (s20>list[127])) s60=128;
              }
            if(s70>127)
              {
               if(s58>=s60)
                 {
                  if((s38+1>s60) && (s40-1<s60)) s18=s18+s20;
                  else if((s40+0>s60) && (s40-1<s58)) s18=s18+list[s40-1];
                 }
               else
               if(s40>=s60) {if((s38+1<s60) && (s38+1>s58)) s18=s18+list[s38+1]; }
               else if(s38+2>s60) s18=s18+s20; else if((s38+1<s60) && (s38+1>s58)) s18=s18+list[s38+1];
               if(s58>s60)
                 {
                  if((s40-1<s58) && (s38+1>s58)) s18=s18-list[s58];
                  else if((s38<s58) && (s38+1>s60)) s18=s18-list[s38];
                 }
               else
                 {
                  if((s38+1>s58) && (s40-1<s58)) s18=s18-list[s58];
                  else
                     if((s40+0>s58) && (s40-0<s60)) s18=s18-list[s40];
                 }
              }
            if(s58<=s60)
              {
               if((s58>=s60) && s60<ArraySize(list)-1) list[s60]=s20;
               else
                 {
                  for(jj=s58+1;(jj<=s60-1) && (jj>0);jj++)list[jj-1]=list[jj];
                  list[s60-1]=s20;
                 }
              }
            else
              {
               for(jj=s58-1;(jj>=s60) && (jj<ArraySize(list)-1);jj--) list[jj+1]=list[jj];
               list[s60]=s20;
              }
            if(s70<=127)
              {
               s18=0;
               for(jj=s40;jj<=s38;jj++) s18=s18+list[jj];
              }
            f60=s18/(s38-s40+1.0);
            if(LP2+1>31) LP2=31; else LP2=LP2+1;
            if(LP2<=30)
              {
               if(f28 > 0.0) f18=f8; else f18=f8 - f28 * f90;
               if(f48 < 0.0) f38=f8; else f38=f8 - f48 * f90;
               JMA=series;
               if(LP2!=30) continue;
               if(LP2==30)
                 {
                  fC0=series;
                  if(MathCeil(f78)>=1) v4=MathCeil(f78); else v4=1.0;
                  fE8=IntPortion(v4);
                  if(MathFloor(f78)>=1) v2=MathFloor(f78); else v2=1.0;
                  fE0=IntPortion(v2);
                  if(fE8==fE0) f68=1.0; else {v4=fE8-fE0; f68=(f78-fE0)/v4;}
                  if(fE0<=29) v5=fE0; else v5=29;
                  if(fE8<=29) v6=fE8; else v6=29;
                  fA8=(series-buffer[LP1-v5]) *(1.0-f68)/fE0+(series-buffer[LP1-v6])*f68/fE8;
                 }
              }
            else
              {
               if(f98>=MathPow(fA0/f60, f88)) v1=MathPow(fA0/f60, f88);
               else v1=f98;
               if(v1<1.0) v2=1.0;
               else
                 {
                  if(f98>=MathPow(fA0/f60,f88)) v3=MathPow(fA0/f60,f88);
                  else v3=f98; v2=v3;
                 }
               f58=v2; f70=MathPow(f90,MathSqrt(f58));
               if(f28 > 0.0) f18=f8; else f18=f8 - f28 * f70;
               if(f48 < 0.0) f38=f8; else f38=f8 - f48 * f70;
              }
           }
         if(LP2>30)
           {
            f30=MathPow(Kg,f58);
            fC0 =(1.0 - f30) * series + f30 * fC0;
            fC8 =(series - fC0) * (1.0 - Kg) + Kg * fC8;
            fD0=Pf * fC8 + fC0;
            f20=f30 *(-2.0);
            f40=f30 * f30;
            fB0=f20 + f40 + 1.0;
            fA8=(fD0-JMA) * fB0+f40 * fA8;
            JMA=JMA+fA8;
           }
        }
      if(LP1<=30)JMA=0.0;
      JMA_Buf[bar]=JMA;

      if(bar==1)
        {
         MEMORY1[00]=fC0;
         MEMORY1[01]=fC8;
         MEMORY1[02]=fA8;
         MEMORY1[03]= s8;
         MEMORY1[04]=f18;
         MEMORY1[05]=f38;
         MEMORY1[06]=s18;
         MEMORY1[07]=s20;
         MEMORY1[08]=s10;
         //----
         MEMORY2[01]=s38;
         MEMORY2[02]=s48;
         MEMORY2[03]=s50;
         MEMORY2[04]=LP1;
         MEMORY2[05]=LP2;
         MEMORY2[06]=s28;
         MEMORY2[07]=s30;
         MEMORY2[08]=s48;
         MEMORY2[09]=s58;
         MEMORY2[10]=s60;
         MEMORY2[11]=s68;
         MEMORY2[00]=Time[1];
         for(ii=0; ii<=127; ii++)
            MEMORY3[ii]=list[ii];
         T0=Time[0];
        }
     }
//---- main cycle done 
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IntPortion(double param)
  {
   if(param > 0) return(MathFloor (param));
   if(param < 0) return(MathCeil  (param));
   return(0.0);
  }
//+------------------------------------------------------------------+
