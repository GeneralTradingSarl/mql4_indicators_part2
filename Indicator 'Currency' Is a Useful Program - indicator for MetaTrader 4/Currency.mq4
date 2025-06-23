//+------------------------------------------------------------------+
//|                                                     Currency.mq4 |
//|                                         Copyright © 2008, Kharko |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Kharko"
#property link      ""
 
#property indicator_chart_window
//---- input parameters
extern string Zametki1="ЗАПИСЬ В ФАЙЛ ПРОИЗВОДИТСЯ В МОМЕНТ НАБРАСЫВАНИЯ НА ГРАФИК. ФАЙЛ НАХОДИТСЯ experts\files"; 
extern bool      All_Pairs=true;
extern double    Procent=20.0;
 
string      FileName;
string      Para[]={"EURUSD","EURGBP","EURCHF","EURJPY","EURAUD","EURCAD","EURNZD",
                    "GBPUSD","USDCHF","USDJPY","AUDUSD","USDCAD","NZDUSD","GBPCHF",
                    "GBPJPY","GBPAUD","GBPCAD","GBPNZD","CHFJPY","AUDCHF","CADCHF",
                    "NZDCHF","AUDJPY","CADJPY","NZDJPY","AUDCAD","AUDNZD","NZDCAD"};
int         KolPara  = 28,count=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   if(!IsConnected())return(0);
 
   if(MarketInfo(Symbol(),MODE_TRADEALLOWED) != 1)return(0);
 
   if(count!=1)
   {
      FileName="Currency.csv";
 
      int handle=FileOpen(FileName,FILE_CSV|FILE_WRITE,';');
      if(handle<1)
      {
         handle=FileOpen(FileName,FILE_CSV|FILE_WRITE,';');
      }
      else
      {
         FileClose(handle);
         FileDelete(FileName);
         handle=FileOpen(FileName,FILE_CSV|FILE_WRITE,';');
      }
   
      FileWrite(handle,"Пара","Стоимость лота","Размер лота");
 
      if(All_Pairs)
      {
         for(int i=0;i<KolPara;i++)
         {
            if(MarketInfo(Para[i],MODE_TRADEALLOWED) != 1)
               continue;
 
            FileWrite(handle,Para[i],MarketInfo(Para[i],MODE_MARGINREQUIRED),value(i));
            Print(Para[i]," : ",MarketInfo(Para[i],MODE_MARGINREQUIRED)," : ",value(i));
 
         }
         Print("Пара | Стоимость лота | Размер лота");
      }
      else
      {
         FileWrite(handle,Symbol(),MarketInfo(Symbol(),MODE_MARGINREQUIRED),value1());
         Print(Symbol()," : ",MarketInfo(Symbol(),MODE_MARGINREQUIRED)," : ",value1());
         Print("Пара | Стоимость лота | Размер лота");
      }
 
      FileClose(handle);
      if(MarketInfo(Symbol(),MODE_MARGINREQUIRED)>0)
         count=1;
   }
   Comment("\n",Symbol()," : ",value1()," лот при ",Procent,"% залога от баланса");
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
double value(int i)
  {
  int j=1;
  double summa, Lots;
  
  Lots=MarketInfo(Para[i],MODE_LOTSTEP);
//----
   while(j>0)
   {
      summa=0;
      summa=j*Lots*(MarketInfo(Para[i],MODE_MARGINREQUIRED)+MarketInfo(Para[i],MODE_TICKVALUE)*MarketInfo(Para[i],MODE_SPREAD));
      
      if(summa>Procent*AccountFreeMargin()/100)
      {
         j--;
         if(j<1)j=1;
         return(j*Lots);
      }
      j++;
   }
//----
  }
//+------------------------------------------------------------------+
double value1()
  {
  int j=1;
  double summa, Lots;
  
  Lots=MarketInfo(Symbol(),MODE_LOTSTEP);
//----
   while(j>0)
   {
      summa=0;
      summa+=j*Lots*(MarketInfo(Symbol(),MODE_MARGINREQUIRED)+MarketInfo(Symbol(),MODE_TICKVALUE)*MarketInfo(Symbol(),MODE_SPREAD));
      
      if(summa>Procent*AccountFreeMargin()/100)
      {
         j--;
         if(j<1)j=1;
         return(j*Lots);
      }
      j++;
   }
//----
  }