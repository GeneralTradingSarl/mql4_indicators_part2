//+------------------------------------------------------------------+
//|                                              +OPTIONS_VOLUME.mq4 |
//|                                Copyright © 2009, Xrust Solution. |
//|                                         http://www.xrust.uco.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Xrust Solution."
#property link      "http://www.xrust.uco.net"
#import "user32.dll"
   int GetWindowDC(int dc);
   int ReleaseDC(int h, int dc);
  bool GetWindowRect(int h, int& pos[4]);
#import
#import "gdi32.dll"
   int GetPixel(int dc, int x, int y);
#import
#import "wininet.dll"
int InternetAttemptConnect (int x);
  int InternetOpenA(string sAgent, int lAccessType, string sProxyName = "", string sProxyBypass = "", int lFlags = 0);
  int InternetOpenUrlA(int hInternetSession, string sUrl, string sHeaders = "", int lHeadersLength = 0,int lFlags = 0, int lContext = 0);
  int InternetReadFile(int hFile, int& sBuffer[], int lNumBytesToRead,int& lNumberOfBytesRead[]);
  int InternetCloseHandle(int hInet);
#import
extern  string              префикс   = "";
extern  string              суффикс   = "";
extern  bool             близжайшие   = true;
extern  bool       Показывать_текст   = true;
extern  bool       Показывать_фоном   = true;
extern  bool     Показывать_историю   = true;
extern  int         Глубина_истории   = 10;
extern  int                 яркость   = 0;
extern  int           размер_шрифта   = 9;
extern  string           имя_шрифта   = "Arial";
color    Цв_смещение ;
double in[15][3];
double hist[1000][61];
double prom[61];
double mno=1;
int Win_color;
int prewtime;
string inetpacth="http://xrust.land.ru//";
string name="";
#property indicator_chart_window
//+------------------------------------------------------------------+
void init(){
int len=0,strlen=0;
if(префикс!=""){len=StringLen(префикс)-1;name=StringSubstr(Symbol(),len,0);}
if(суффикс!=""){len=StringLen(суффикс);strlen=StringLen(Symbol());name=StringSubstr(Symbol(),0,(strlen-len+1));}
prewtime=0;
if(!ReadFile()){ReadFile();}
IndicatorShortName("Open Interest indicatorXR © ");
return;}
//+------------------------------------------------------------------+
void deinit(){
if(UninitializeReason()==REASON_REMOVE||
   UninitializeReason()==REASON_CHARTCLOSE||
   UninitializeReason()==REASON_PARAMETERS){delgr();}
return;}
//+------------------------------------------------------------------+
void start(){static int prewmno,bpch;
   int indco=IndicatorCounted();
   if(indco-Bars<-1){return;}
//----
   if(prewtime>TimeCurrent()){
     prewtime=TimeCurrent()+3600;
     if(!IsVisualMode()||!IsTesting()||!IsOptimization()){
       readinet(name);
       ReadFile();
     }  
   }
   if(GetWndColor(Symbol())>0){color txcol=Black;}else{txcol=White;}
   int x=ArrayRange(hist,0);
   for(int a=0;a<x-1;a++){int t;
     if(a==x-2){
       t=Time[0]+(Period()*360);
     }else{
       t=hist[a+1][0];
     }
     int summa=0,summb=0;
     for(int b=1;b<43;b=b+3){
       if(summa<hist[a][b]){summa=hist[a][b];}
       if(summb<hist[a][b+2]){summb=hist[a][b+2];}
     }      
     for(b=1;b<43;b=b+3){ 
       if(Показывать_историю){
       if(hist[a][0]>iTime(Symbol(),1440,Глубина_истории)){
       if(близжайшие){
         if(hist[a][b+1]<iHigh(Symbol(),1440,iBarShift(Symbol(),1440,t))+(hist[a][b+4]-hist[a][b+1])&&
            hist[a][b+4]> iLow(Symbol(),1440,iBarShift(Symbol(),1440,t))-(hist[a][b+4]-hist[a][b+1])){
           SetRestangle(цвет(hist[a][b],hist[a][b+2],summa,summb),b+"/"+a,t,hist[a][b+1],hist[a][0],hist[a][b+4],DoubleToStr(hist[a][b+0],0)+"/"+DoubleToStr(hist[a][b+2],0));
           if(Показывать_текст)SetText("",txcol,t-(t-hist[a][0])/2,hist[a][b+4],DoubleToStr(hist[a][b+0],0)+"/"+DoubleToStr(hist[a][b+2],0),размер_шрифта);
         }
         if(a==x-2){
           SetRestangle(цвет(hist[a][b],hist[a][b+2],summa,summb),b+"/"+a,t,hist[a][b+1],hist[a][0],hist[a][b+4],DoubleToStr(hist[a][b+0],0)+"/"+DoubleToStr(hist[a][b+2],0));
           if(Показывать_текст)SetText("",txcol,t-(t-hist[a][0])/2,hist[a][b+4],DoubleToStr(hist[a][b+0],0)+"/"+DoubleToStr(hist[a][b+2],0),размер_шрифта);                  
         }
       }else{
         SetRestangle(цвет(hist[a][b],hist[a][b+2],summa,summb),b+"/"+a,t,hist[a][b+1],hist[a][0],hist[a][b+4],DoubleToStr(hist[a][b+0],0)+"/"+DoubleToStr(hist[a][b+2],0));
         if(Показывать_текст)SetText("",txcol,t-(t-hist[a][0])/2,hist[a][b+4],DoubleToStr(hist[a][b+0],0)+"/"+DoubleToStr(hist[a][b+2],0),размер_шрифта);         
       }
       }
       }else{
         if(a==x-2){
           SetRestangle(цвет(hist[a][b],hist[a][b+2],summa,summb),b+"/"+a,t,hist[a][b+1],hist[a][0],hist[a][b+4],DoubleToStr(hist[a][b+0],0)+"/"+DoubleToStr(hist[a][b+2],0));
           if(Показывать_текст)SetText("",txcol,t-(t-hist[a][0])/2,hist[a][b+4],DoubleToStr(hist[a][b+0],0)+"/"+DoubleToStr(hist[a][b+2],0),размер_шрифта);                  
         }       
       }
     }
   }  
   string copyrite="Open Interest indicatorXR ©  ";
   SetLabel("Times new roman","cp",copyrite,txcol,1,1,1,9);
//----
return;}
color цвет(double c,double p,double suma,double sumb)
{ int BB=0,RR=0,GG=0;double x,y;
  c=c+1;p=p+1;suma=suma+1;sumb=sumb+1;
  if(suma>5000){suma=5000;}
  if(sumb>5000){sumb=5000;}
  if(c>5000){c=5000;}
  if(p>5000){p=5000;} 
  if(яркость>255){яркость=255;}   
  if(яркость<0){яркость=0;}    
  if(c>p){
   if(GetWndColor(Symbol())<=0){
   x=(MathSqrt(c/suma))*255;
   BB=яркость;
   GG=яркость;
   RR=x;
   }else{
   x=(MathSqrt(c/suma))*255-яркость;
   if(x>255){x=255;}
   BB=255-x;
   GG=255-x;
   RR=255;
   }   
  return((BB<<16)^(GG<<8)^(RR));
  }
  if(p>c){
   if(GetWndColor(Symbol())<=0){
     y=(MathSqrt(p/sumb))*255;
     BB=y;
     GG=яркость;
     RR=яркость; 
   }else{
     y=(MathSqrt(p/sumb))*255-яркость;
     BB=255;
     GG=255-y;
     RR=255-y; 
   }     
  return((BB<<16)^(GG<<8)^(RR)); 
  }
  return((BB<<16)^(GG<<8)^(RR));
}

//+------------------------------------------------------------------+
void readinet(string nm="")
  {if(nm==""){nm=Symbol()+"_hist_OI.csv";}else{nm=nm+"_OI.csv";}
   if(!IsDllsAllowed()){
     Alert("Необходимо в настройках разрешить использование DLL");
     return(0);
   }
   int rv = InternetAttemptConnect(0);
   if(rv != 0){
     Print("Ошибка при вызове InternetAttemptConnect()");
     return(0);
   }
   
   int hInternetSession = InternetOpenA("Microsoft Internet Explorer",0, "", "", 0);
   if(hInternetSession <= 0){
     Print("Ошибка при вызове InternetOpenA()");
     return(0);         
   }
   int hURL = InternetOpenUrlA(hInternetSession,inetpacth+nm, "", 0, 0, 0);
   if(hURL <= 0){
     Print("Ошибка при вызове InternetOpenUrlA()");
     InternetCloseHandle(hInternetSession);
     return;
   }  
   int cBuffer[256];
   ArrayInitialize(cBuffer,0);
   int dwBytesRead[1]; 
   ArrayInitialize(dwBytesRead,0);
   string TXT = "";
   while(!IsStopped()){
       bool bResult = InternetReadFile(hURL, cBuffer, 1024, dwBytesRead);
       if(dwBytesRead[0] == 0)break;
       string text = "";   
       for(int i = 0; i < 256; i++){
           text = text + CharToStr(cBuffer[i] & 0x000000FF);
        	  if(StringLen(text) == dwBytesRead[0])break;
        	  text = text + CharToStr(cBuffer[i] >> 8 & 0x000000FF);
        	  if(StringLen(text) == dwBytesRead[0])break;
           text = text + CharToStr(cBuffer[i] >> 16 & 0x000000FF);
           if(StringLen(text) == dwBytesRead[0])break;
           text = text + CharToStr(cBuffer[i] >> 24 & 0x000000FF);
           if(StringLen(text) == dwBytesRead[0])break;
         }
       TXT = TXT + text;
       Sleep(1);
     }
   if(TXT != ""){
       int h = FileOpen(nm, FILE_CSV|FILE_WRITE);
       if(h>0){
           FileWrite(h,TXT);
           FileClose(h);
         }else{
           int err=GetLastError();
           Print("Ошибка при вызове FileOpen()  № ",err);
         }
     }else{Print("Нет считанных данных");}
   InternetCloseHandle(hInternetSession);
   return;}
//+------------------------------------------------------------------+
int GetWndColor(string sy)
   { 
     int hWnd = WindowHandle(sy, Period());
     int hDC = GetWindowDC(hWnd);
     int rect[4];
     GetWindowRect(hWnd, rect);
     int wW = rect[2] - rect[0];         // ширина окна
     int wH = rect[3] - rect[1];         // высота окна
     
     int col = GetPixel(hDC, 2, 2);
     if(col==-1)                         // левый верхний угол не виден
     {
       col = GetPixel(hDC, wW-3, wH-3); 
       if(col==-1)                       // правый нижний угол не виден
       col = GetPixel(hDC, 2, wH-3); 
       if(col==-1)                       // левый нижний угол не виден
       col = GetPixel(hDC, wW-3, 2);     
       if(col==-1)                       // правый верхний угол не виден
       {
         ReleaseDC(hWnd, hDC);
         return(Win_color);
       }
      }
     ReleaseDC(hWnd, hDC);
     return(col);
   }
//+------------------------------------------------------------------+
void SetLabel(string fn,string nm, string tx, color cl, int xd, int yd, int cr=0, int fs=9) {
  if (ObjectFind(nm)<0) ObjectCreate(nm, OBJ_LABEL, 0, 0,0);
  ObjectSetText(nm, tx,fs,fn, cl);
  ObjectSet(nm, OBJPROP_COLOR    , cl);
  ObjectSet(nm, OBJPROP_XDISTANCE, xd);
  ObjectSet(nm, OBJPROP_YDISTANCE, yd);
  ObjectSet(nm, OBJPROP_CORNER   , cr);
  ObjectSet(nm, OBJPROP_FONTSIZE , fs);
  ObjectSet(nm, OBJPROP_BACK , false);
}
//+------------------------------------------------------------------+ 
void delgr(){
   for(int i=ObjectsTotal();i>=0;i--){
     if("sumoi"==StringSubstr(ObjectName(i),0,5)){ObjectDelete(ObjectName(i));}
     if("opint"==StringSubstr(ObjectName(i),0,5)){ObjectDelete(ObjectName(i));}
   }
   ObjectDelete("oi");
   ObjectDelete("cp");
return;
}
//+------------------------------------------------------------------+   
void SetText(string op,color cl,int t1,double p1,string tx="",int razm=8){
  string nm="sumoi"+op+DoubleToStr(p1,Digits)+tx;
  if(ObjectFind(nm)<0)ObjectCreate(nm, OBJ_TEXT, 0, 0,0, 0,0);
  ObjectSet(nm, OBJPROP_TIME1 , t1);
  ObjectSet(nm, OBJPROP_PRICE1, p1);
  ObjectSetText(nm,tx,razm,имя_шрифта,cl);
  ObjectSet(nm, OBJPROP_BACK , Показывать_фоном);
return;
}   
//+------------------------------------------------------------------+
void SetRestangle(color cl, string nm="",datetime t1=0, double p1=0, 
                  datetime t2=0, double p2=0,string vol=""){
  nm="opint "+nm;
  if(ObjectFind(nm)<0)ObjectCreate(nm, OBJ_RECTANGLE, 0, 0,0, 0,0);
  ObjectSet(nm, OBJPROP_TIME1 , t2);
  ObjectSet(nm, OBJPROP_PRICE1, p1);
  ObjectSet(nm, OBJPROP_TIME2 , t1);
  ObjectSet(nm, OBJPROP_PRICE2, p2);
  ObjectSet(nm, OBJPROP_COLOR , cl);
  ObjectSet(nm, OBJPROP_RAY   , false);
  ObjectSet(nm, OBJPROP_STYLE , 0);
  ObjectSet(nm, OBJPROP_WIDTH , 1);
  ObjectSetText(nm,vol,3,"Arial",White);
  ObjectSet(nm, OBJPROP_BACK , Показывать_фоном);
}     
//+------------------------------------------------------------------+  
bool ReadFile(){int i,x,y;int hd;
   string fn=Symbol()+"_hist_OI.csv";
   double spr=MarketInfo(Symbol(),MODE_SPREAD)*Point;  
   hd=FileOpen(fn,FILE_CSV|FILE_READ); 
   if(hd<0){
     Print(GetLastError(),"  ",fn,"  File not found",hd);   
     readinet();
     return(false);
   }else{//x=0;y=0;
   for(i=0;i<50;i++){
     string out=FileReadString(hd);
     for(x=0;x<61;x++){
     int pos=StringFind(out,",",0);
     hist[i][x]=StrToDouble(StringSubstr(out,0,pos+1));
     out=StringSubstr(out,pos+1,0);
     }
     if(FileIsEnding(hd)){break;}
   }
   ArrayResize(hist,i);
   FileClose(hd);
   return(true);
   }
   return(true);
}

