//+------------------------------------------------------------------+
//|                                                    Ichimoku2.mq4 |
//|                                     Copyright 2019 Dwaine Hinds. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2020. D.Hinds"
#property link        "http://www.mql4.com"
#property description "Ichimoku Kinko Hyo version 2"
#property strict

#include <multipairsfunctions.mqh>
#include <BreakPoint.mqh>
#include <io_arrays.mqh>

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Red          // Tenkan-sen
#property indicator_color2 Blue         // Kijun-sen
#property indicator_color3 SandyBrown   // Up Kumo
#property indicator_color4 Thistle      // Down Kumo
#property indicator_color5 clrViolet//Lime         // Chikou Span
#property indicator_color6 SandyBrown   // Up Kumo bounding line
#property indicator_color7 Thistle      // Down Kumo bounding line


//--- input parameters
input string               aSymbol = NULL;
input ENUM_TIMEFRAMES      ChartTimeframe=0;
input int KumoDepthPeriod=5;//the number of bars to use to calculate kumo implied volatility
extern double Result_Tenkan=0;
extern double Result_Kijun=0;
extern double Result_Chikou=0;
extern double Result_SpanA=0;
extern double Result_SpanB=0;
extern string ResultKumoThickness=""; 
extern string ResultKumoShape="";
extern string ResultKumoSentiment="";
input string aUserID="";//the user's id number
extern int ResultShift=0;//0 means the most recent indicator values. 1 means the previous indicator values to the recent.
input string economy_mode="no";
input string display_summary="no";//this display a brief summary of the interpretation of the indicator values.
input int InpTenkan=9;   // Tenkan-sen
input int InpKijun=26;   // Kijun-sen
input int InpSenkou=52;  // Senkou Span B
 
int KumoIV=0,KumoShape=0,KumoSentiment=0,Shift=1,ExtBegin;  
string all_kumo_descriptions[][11];//will contain symbols' 200 kumo depth measurements and a symbols' kumo descriptors...
string stack_delimiter_token="&";//used by StackDepthString to separate elements of the stack

//--- buffers
double ExtTenkanBuffer[];
double ExtKijunBuffer[];
double ExtSpanA_Buffer[];
double ExtSpanB_Buffer[];
double ExtChikouBuffer[];
double ExtSpanA2_Buffer[];
double ExtSpanB2_Buffer[];
double Current_SpanA=0,Current_SpanB=0;
string indicatorfilename;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  { 
   IndicatorDigits(Digits);
//---
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtTenkanBuffer);
   SetIndexDrawBegin(0,InpTenkan-1);
   SetIndexLabel(0,"Tenkan Sen");
//---
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtKijunBuffer);
   SetIndexDrawBegin(1,InpKijun-1);
   SetIndexLabel(1,"Kijun Sen");
//---
   ExtBegin=InpKijun;
   if(ExtBegin<InpTenkan)
      ExtBegin=InpTenkan;
//---
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_DOT);
   SetIndexBuffer(2,ExtSpanA_Buffer);
   SetIndexDrawBegin(2,InpKijun+ExtBegin-1);
   SetIndexShift(2,InpKijun);
   SetIndexLabel(2,NULL);
   SetIndexStyle(5,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(5,ExtSpanA2_Buffer);
   SetIndexDrawBegin(5,InpKijun+ExtBegin-1);
   SetIndexShift(5,InpKijun);
   SetIndexLabel(5,"Senkou Span A");
//---
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_DOT);
   SetIndexBuffer(3,ExtSpanB_Buffer);
   SetIndexDrawBegin(3,InpKijun+InpSenkou-1);
   SetIndexShift(3,InpKijun);
   SetIndexLabel(3,NULL);
   SetIndexStyle(6,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(6,ExtSpanB2_Buffer);
   SetIndexDrawBegin(6,InpKijun+InpSenkou-1);
   SetIndexShift(6,InpKijun);
   SetIndexLabel(6,"Senkou Span B");
//---
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtChikouBuffer);
   SetIndexShift(4,-InpKijun);
   SetIndexLabel(4,"Chikou Span");
  
//--- initialization done
   return(INIT_SUCCEEDED);
  }
  void OnDeinit(const int reason)
  {
   GlobalVariableDel("ichiGlobalTenkan"+"_"+aUserID);
   GlobalVariableDel("ichiGlobalKijun"+"_"+aUserID);
   GlobalVariableDel("ichiGlobalChikou"+"_"+aUserID);
   GlobalVariableDel("ichiGlobalSpanA"+"_"+aUserID);   
   GlobalVariableDel("ichiGlobalSpanB"+"_"+aUserID); 
   GlobalVariableDel("ichiGlobalKumoThickness"+"_"+aUserID);
   GlobalVariableDel("ichiGlobalKumoShape"+"_"+aUserID);
   GlobalVariableDel("ichiGlobalKumoSentiment"+"_"+aUserID);  
  }
   
//+------------------------------------------------------------------+
//| Ichimoku Kinko Hyo                                               |
//+------------------------------------------------------------------+
  int start()              
  {
   bool fnd=false,is_spana_flat=false,is_spanb_flat=false;
   ENUM_TIMEFRAMES achart=-1,CurrentChart=-1;
   int sz=0,i=0,gsfnd=-1,sfnd=-1,countedbars=0;
   int ksz=0,si=0;
   string symbol,iname,CurrentSymbol; 
   datetime lastbartime=0,currentbartime=0; 
   ENUM_TIMEFRAMES CurrentChartTimeframe=0;  
   int count_total=0,prev_count_total=0;
   int    k=0,pos=0,min=0,tenkan_buffer_sz=0,kijun_buffer_sz=0,chikou_buffer_sz=0,span_a_buffer_sz=0,span_b_buffer_sz=0;
   int tenkan_shift=ResultShift,kijun_shift=ResultShift,chikou_shift=ResultShift;//the shift of the wanted value. 0 is latest value.
   int span_a_shift=ResultShift;//1;//the shift candlestick inline with the wanted span a value.   
   int span_b_shift=ResultShift;//1;//the shift candlestick inline with the wanted span b value.   
   double highs[],lows[],closes[];
   double high_value,low_value;
  
  //set the file resources names
  indicatorfilename = __FILE__+aUserID;  
  kumotempfile="ichimoku2_kumo_data"+aUserID+".txt";  
  
 count_total = iBars(aSymbol,ChartTimeframe);// available bars
 prev_count_total = IndicatorCounted2(aSymbol,ChartTimeframe,indicatorfilename); // Number of counted bars
   if(count_total<=InpTenkan || count_total<=InpKijun || count_total<=InpSenkou)
      return(0);
//--- counting from 0 to count_total
   ArraySetAsSeries(ExtTenkanBuffer,false);
   ArraySetAsSeries(ExtKijunBuffer,false);
   ArraySetAsSeries(ExtSpanA_Buffer,false);
   ArraySetAsSeries(ExtSpanB_Buffer,false);
   ArraySetAsSeries(ExtChikouBuffer,false);
   ArraySetAsSeries(ExtSpanA2_Buffer,false);
   ArraySetAsSeries(ExtSpanB2_Buffer,false);

   //default value must be 0
   Result_Tenkan=0;
   Result_Kijun=0;
   Result_Chikou=0;
   Result_SpanA=0;
   Result_SpanB=0;  

//--- initial zero
      if(prev_count_total<1)
        {
         for(i=0; i<InpTenkan; i++)
            ExtTenkanBuffer[i]=0.0;
         for(i=0; i<InpKijun; i++)
            ExtKijunBuffer[i]=0.0;
         for(i=0; i<ExtBegin; i++)
           {
            ExtSpanA_Buffer[i]=0.0;
            ExtSpanA2_Buffer[i]=0.0;
           }
         for(i=0; i<InpSenkou; i++)
           {
            ExtSpanB_Buffer[i]=0.0;
            ExtSpanB2_Buffer[i]=0.0;
           }
        }
   gsfnd=-1;
   sfnd=-1;
       if(FileIsExist(kumotempfile))//if the kumo file exists then it must contain the arrays values so load up them from here.
       {
        ArrayResize(all_kumo_descriptions,0);
        ArrayResize(indicator_counted_bars,0);
        LoadArrayFromFilePosition(all_kumo_descriptions,kumofilepos);//prepare array
        LoadArrayFromFilePosition(indicator_counted_bars,multipairsfilepos);//prepare array      
       }

   //search for symbol here
   CurrentChart = ChartTimeframe; 
      if(ChartTimeframe == 0)CurrentChart = (ENUM_TIMEFRAMES)Period();
   CurrentSymbol = aSymbol;  
      if(aSymbol == "" || aSymbol == NULL)CurrentSymbol = Symbol(); 
   ksz=ArrayRange(indicator_counted_bars,0);     
    
       //check if symbol already exists in multipairs sections
       while(ksz>0 && sfnd<0)
       {
        ksz--;
        symbol=indicator_counted_bars[ksz][0];
        iname = indicator_counted_bars[ksz][1];//indicator's name
        achart=(ENUM_TIMEFRAMES)StrToInteger(indicator_counted_bars[ksz][3]);
           if(StringCompare(symbol,CurrentSymbol,false)==0 && achart == (CurrentChart) && iname == indicatorfilename )
           {
            sfnd = ksz;
            lastbartime = StrToTime(indicator_counted_bars[sfnd][4]);
           }
       }         
   ksz = ArrayRange(all_kumo_descriptions,0); 
   si = ksz;           

       //check if symbol already exists in all_kumo_descriptions arrys
       while(ksz>0 && gsfnd<0)
       {
        ksz--;
        symbol=all_kumo_descriptions[ksz][1];
        achart=(ENUM_TIMEFRAMES)StrToInteger(all_kumo_descriptions[ksz][5]);
           if(StringCompare(symbol,CurrentSymbol,false)==0 && achart == (CurrentChart) )
           {
            gsfnd = ksz;
           }
       } 
       
       //if symbol does not exists in array then increase and add it to all_kumo_descriptions array
       if(gsfnd<0)
       {     
        ArrayResize(all_kumo_descriptions,si+1);
        all_kumo_descriptions[si][1] = CurrentSymbol;  
        all_kumo_descriptions[si][5] = IntegerToString(CurrentChart);
        gsfnd = si;    
       }

   currentbartime = iTime(aSymbol,ChartTimeframe,Shift);
  //if(IsExpertEnabled()==true)Print("stopped currentbartime",TimeToStr(currentbartime)," lastbartime",TimeToStr(lastbartime));  
      if( (currentbartime > lastbartime) || (economy_mode == "no") )//proceed when newbar is made
      {     
           
        //transfer data in correct order  
       i = count_total; 
       k = 0;
       ArrayResize(highs,count_total);
       ArrayResize(lows,count_total);
       ArrayResize(closes,count_total);
          while(i>0)
          {
           i--;
           highs[k] = iHigh(aSymbol,ChartTimeframe,i);
           lows[k] = iLow(aSymbol,ChartTimeframe,i);
           closes[k] = iClose(aSymbol,ChartTimeframe,i);
           k++;
          }           
      //--- Tenkan Sen
       pos=InpTenkan-1;
          if(prev_count_total>InpTenkan)
            pos=prev_count_total-1;
          for(i=pos; i<count_total; i++)
          {
           high_value=highs[i];
           low_value=lows[i];
           k=i+1-InpTenkan;
              while(k<=i)
              {
                  if(high_value<highs[k])
                  high_value=highs[k];
                  if(low_value>lows[k])
                  low_value=lows[k];
               k++;
              }
           ExtTenkanBuffer[i]=(high_value+low_value)/2;
          }
      //--- Kijun Sen
       pos=InpKijun-1;
          if(prev_count_total>InpKijun)
            pos=prev_count_total-1;
          for(i=pos; i<count_total; i++)
          {
           high_value=highs[i];
           low_value=lows[i];
           k=i+1-InpKijun;
              while(k<=i)
              {
                  if(high_value<highs[k])
                  high_value=highs[k];
                  if(low_value>lows[k])
                  low_value=lows[k];
               k++;
              }
           ExtKijunBuffer[i]=(high_value+low_value)/2;
          }
      //--- Senkou Span A
       pos=ExtBegin-1;
          if(prev_count_total>ExtBegin)
            pos=prev_count_total-1;
          for(i=pos; i<count_total; i++)
          {
           ExtSpanA_Buffer[i]=(ExtKijunBuffer[i]+ExtTenkanBuffer[i])/2;
           ExtSpanA2_Buffer[i]=ExtSpanA_Buffer[i];
          }
       span_a_buffer_sz = ArrayRange(ExtSpanA_Buffer,0);
          if( span_a_buffer_sz > (span_a_shift+26) )Current_SpanA = ExtSpanA_Buffer[span_a_buffer_sz-26-1-span_a_shift];//this give the SpanA value at a specific candlestick shift.     
          if( span_a_buffer_sz > (span_a_shift+26+2) )
          {
              if( (ExtSpanA_Buffer[span_a_buffer_sz-26-1-span_a_shift] == ExtSpanA_Buffer[span_a_buffer_sz-26-1-span_a_shift+1] && ExtSpanA_Buffer[span_a_buffer_sz-26-1-span_a_shift] == ExtSpanA_Buffer[span_a_buffer_sz-26-1-span_a_shift+2]) )is_spana_flat = true;
          }    
    
      //--- Senkou Span B
       pos=InpSenkou-1;
          if(prev_count_total>InpSenkou)
            pos=prev_count_total-1;
          for(i=pos; i<count_total; i++)
          {
           high_value=highs[i];
           low_value=lows[i];
           k=i+1-InpSenkou;
              while(k<=i)
              {
                  if(high_value<highs[k])
                   high_value=highs[k];
                  if(low_value>lows[k])
                   low_value=lows[k];
               k++;
              }
           ExtSpanB_Buffer[i]=(high_value+low_value)/2;
           ExtSpanB2_Buffer[i]=ExtSpanB_Buffer[i];
          }   
       span_b_buffer_sz = ArrayRange(ExtSpanB_Buffer,0);
          if( span_b_buffer_sz > (span_b_shift+26) )Current_SpanB = ExtSpanB_Buffer[span_b_buffer_sz-26-1-span_b_shift];//this give the SpanB value at a specific candlestick shift.        

          if(gsfnd>=0 && (currentbartime > lastbartime))GetKumoRelativeSize(all_kumo_descriptions,gsfnd,Current_SpanA,Current_SpanB);           

          if( span_b_buffer_sz > (span_b_shift+26+2) )
          {
              if( (ExtSpanB_Buffer[span_b_buffer_sz-26-1-span_b_shift] == ExtSpanB_Buffer[span_b_buffer_sz-26-1-span_b_shift+1] && ExtSpanB_Buffer[span_b_buffer_sz-26-1-span_b_shift] == ExtSpanB_Buffer[span_b_buffer_sz-26-1-span_b_shift+2]) )is_spanb_flat = true;
          }

          //here we get the kumo shape at the shift          
          if( (Current_SpanA > Current_SpanB && is_spana_flat) || (Current_SpanB > Current_SpanA && is_spanb_flat) )KumoShape=1;
          else if( (Current_SpanA < Current_SpanB && is_spana_flat) || (Current_SpanB < Current_SpanA && is_spanb_flat) )KumoShape=2;
          else KumoShape=0;
          
          //get the kumo sentiment
          if(Current_SpanA > Current_SpanB)KumoSentiment=1;
          else if(Current_SpanB > Current_SpanA)KumoSentiment=2;
          else KumoSentiment=0;

       //--- Chikou Span
       pos=0;
          if(prev_count_total>1)
            pos=prev_count_total-1;
          for(i=pos; i<count_total; i++)
            ExtChikouBuffer[i]=closes[i];
 

       //--- buffers sizes
       tenkan_buffer_sz = ArrayRange(ExtTenkanBuffer,0);
       kijun_buffer_sz = ArrayRange(ExtKijunBuffer,0);
       chikou_buffer_sz = ArrayRange(ExtChikouBuffer,0);
          if(count_total > 52)
          {
              if(tenkan_buffer_sz > tenkan_shift)Result_Tenkan=ExtTenkanBuffer[tenkan_buffer_sz-1-tenkan_shift];//this give the tenkansen value at a specific shift.
              if(kijun_buffer_sz > kijun_shift)Result_Kijun=ExtKijunBuffer[kijun_buffer_sz-1-kijun_shift];//this give the kijunsen value at a specific shift.
              if(chikou_buffer_sz > chikou_shift)Result_Chikou=ExtChikouBuffer[chikou_buffer_sz-1-chikou_shift];//this give the chikou span value at a specific shift.
           Result_SpanA=Current_SpanA;
           Result_SpanB=Current_SpanB;
          }  
           
          //update descriptions in array
          if(gsfnd>=0)
          {       
           all_kumo_descriptions[gsfnd][3] = IntegerToString(KumoShape);    
           all_kumo_descriptions[gsfnd][4] = IntegerToString(KumoSentiment);
           
           all_kumo_descriptions[gsfnd][6] = DoubleToStr(Result_Tenkan);           
           all_kumo_descriptions[gsfnd][7] = DoubleToStr(Result_Kijun);
           all_kumo_descriptions[gsfnd][8] = DoubleToStr(Result_Chikou);
           all_kumo_descriptions[gsfnd][9] = DoubleToStr(Result_SpanA);
           all_kumo_descriptions[gsfnd][10] = DoubleToStr(Result_SpanB);
           SaveArrayToFilePosition(all_kumo_descriptions,kumofilepos);                                 
          }    
       updateIndicatorCounted2( aSymbol,ChartTimeframe,currentbartime,indicatorfilename,(count_total-limit),sfnd );// 2(limit) is for the last 2 indicators values because we do not want to calculate the entire bars collection each time a new bar arrives.
       SaveArrayToFilePosition(indicator_counted_bars,multipairsfilepos);
      }//end process   

      if(gsfnd>=0)
      {
       Result_Tenkan = StrToDouble(all_kumo_descriptions[gsfnd][6]);
       Result_Kijun = StrToDouble(all_kumo_descriptions[gsfnd][7]);
       Result_Chikou = StrToDouble(all_kumo_descriptions[gsfnd][8]);
       Result_SpanA = StrToDouble(all_kumo_descriptions[gsfnd][9]);
       Result_SpanB = StrToDouble(all_kumo_descriptions[gsfnd][10]);
       
       KumoIV = StrToInteger(all_kumo_descriptions[gsfnd][2]); 
       KumoShape = StrToInteger(all_kumo_descriptions[gsfnd][3]);    
       KumoSentiment = StrToInteger(all_kumo_descriptions[gsfnd][4]);     
      }

    GlobalVariableSet("ichiGlobalTenkan"+"_"+aUserID,Result_Tenkan);
    GlobalVariableSet("ichiGlobalKijun"+"_"+aUserID,Result_Kijun);
    GlobalVariableSet("ichiGlobalChikou"+"_"+aUserID,Result_Chikou);
    GlobalVariableSet("ichiGlobalSpanA"+"_"+aUserID,Result_SpanA);
    GlobalVariableSet("ichiGlobalSpanB"+"_"+aUserID,Result_SpanB);
    GlobalVariableSet("ichiGlobalKumoThickness"+"_"+aUserID,KumoIV);
    GlobalVariableSet("ichiGlobalKumoShape"+"_"+aUserID,KumoShape);
    GlobalVariableSet("ichiGlobalKumoSentiment"+"_"+aUserID,KumoSentiment);
       if(display_summary=="yes")DisplayOnDashboard(CurrentSymbol,Result_Tenkan,Result_Kijun,Result_Chikou,Result_SpanA,Result_SpanB,KumoIV,KumoShape,KumoSentiment);    
       if(economy_mode == "yes")Comment("Warning: Economy mode is set to '"+economy_mode+"'.");     
   return(count_total);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| GetKumoRelativeSize                                                |
//+------------------------------------------------------------------+
/*
 this will get the position of a symbol's Implied Volatility via Kumo's relative size. This is an authorative function that will increase TwoDimensionArray array as it sees fit.
 implied volatility is either:
 -1  Thin(oversold).
  0  Normal.
  1  Thick(overbought).
*/
void GetKumoRelativeSize(string& TwoDimensionArray[][6], int SymbolPos, double SpanA, double SpanB)
  {
   
   ENUM_MA_METHOD MA_MODE = MODE_SMA;//MODE_EMA;//this sets the moving average method to use for calculation of moving average
   double Overbought_threshold = 100;
   double Oversold_threshold = 20;

   double data_arr1[];
   double Kumodepth=0,stdv_kumo_depth=0,average_kumo_depth=0,UpperBand=0,LowerBand=0,NormalizedVolatilityIndicator=0;

   int kumo_depth_count=KumoDepthPeriod,elements_count=0,tcnt=0,kumo_description_value=0,kpos=-1;
   string Kumodepth_str;
   string tmpstr;
   string str_arr[];
   string sep=stack_delimiter_token;
   //string sep=",";
   //ushort u_sep=0;

             
   //get kumo depth for new bar
   Kumodepth = MathAbs(SpanA - SpanB);
   Kumodepth_str=DoubleToString(Kumodepth);               

       if(SymbolPos>=0)
       {
        tmpstr=TwoDimensionArray[SymbolPos][0];
        kpos = StringFind(tmpstr,Kumodepth_str,0);
           if(kpos == -1)//stack kumodepth only if it is unique
           {
            //stack its kumo depth numbers
            StackDepthString(tmpstr,(kumo_depth_count+1),Kumodepth_str);//kumo_depthstr is stacked up to kumo_depth_count+1 but only kumo_depth_count will be used in calculations.
            TwoDimensionArray[SymbolPos][0]=tmpstr;
           }
       }
    //--- Split the string to substrings
    //--- Get the separator code 
    //u_sep=StringGetCharacter(sep,0);   
    //elements_count=StringSplit(tmpstr,u_sep,str_arr);
    elements_count=BreakString(tmpstr,sep,str_arr);
        //BreakPoint("","","",true,"kumo_depth_count",IntegerToString(kumo_depth_count),"elements_count",IntegerToString(elements_count),"tmpstr",tmpstr);   
       //use data collected data only when it is sufficient
       if(elements_count>=kumo_depth_count+1)
       {
        ArrayResize(data_arr1,elements_count);
        tcnt=0;
           while(tcnt<elements_count)
           {
            //convert string array to double array 
            data_arr1[tcnt] = StrToDouble(str_arr[tcnt]);      
            tcnt++;
           }        
            
        //calculate SMA on value
        average_kumo_depth = iMAOnArray(data_arr1,elements_count,kumo_depth_count,0,MA_MODE,Shift);//current Kumodepth value is not included in this calculation,hence Shift 1 is used.
   
        //calculate standard deviation
        stdv_kumo_depth = iStdDevOnArray(data_arr1,elements_count,kumo_depth_count,0,MA_MODE,Shift);//current Kumodepth value is not included in this calculation,hence Shift 1 is used.   
       
        UpperBand = average_kumo_depth + (2 * stdv_kumo_depth);  
        LowerBand = average_kumo_depth - (2 * stdv_kumo_depth);
           if( (UpperBand - LowerBand)!=0 )NormalizedVolatilityIndicator  = ((Kumodepth - LowerBand) / (UpperBand - LowerBand)) * 100;
           if(NormalizedVolatilityIndicator>=Overbought_threshold)//kumo is fat
           {
            kumo_description_value = 1;
           }
           else if(NormalizedVolatilityIndicator<Overbought_threshold && NormalizedVolatilityIndicator>Oversold_threshold)//kumo is normal
           {
            kumo_description_value = 0;
           }
           else if(NormalizedVolatilityIndicator<=Oversold_threshold)//kumo is thin
           {
            kumo_description_value = -1;
           }   
        //Print("stdv_kumo_depth",DoubleToStr(stdv_kumo_depth));  
      }
   TwoDimensionArray[SymbolPos][2]=IntegerToString(kumo_description_value);//store new kumo_description_value in array                      
   //return(SymbolPos);   
  }
//+------------------------------------------------------------------+
//| End of GetKumoRelativeSize                                         |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| StackDepthString                                              |
//+------------------------------------------------------------------+
/*
This pushes new string into a stack of X strings.
*/
void StackDepthString(string& the_stack_of_strings,int stack_size,string string_to_add_to_stack)
  {
   bool res=false;
   int c=1,elements_count=0;
   string sep=stack_delimiter_token;
   //string sep=",";                // A separator as a character 
   ushort u_sep=0;                  // The code of the separator character 
   string str_arr[];

//split string into array of strings
//--- Get the separator code 
   u_sep=StringGetCharacter(sep,0);
//--- Split the string to substrings 
   //elements_count=StringSplit(the_stack_of_strings,u_sep,str_arr);
   elements_count=BreakString(the_stack_of_strings,sep,str_arr);
      if(elements_count==0)
      {
       elements_count=1;
       ArrayResize(str_arr,elements_count);
       str_arr[0] = the_stack_of_strings;
      }   
   if(the_stack_of_strings==NULL || elements_count<1)//this maybe unecessary
     {
      the_stack_of_strings=string_to_add_to_stack;
     }
   else if(elements_count>=1 && elements_count<stack_size)
     {
      the_stack_of_strings=StringConcatenate(the_stack_of_strings,sep,string_to_add_to_stack);
     }
   else if(elements_count>=stack_size)
     {
      //re-assemble string
      StringReplace(the_stack_of_strings,str_arr[0]+sep,NULL);
      the_stack_of_strings=StringConcatenate(the_stack_of_strings,sep,string_to_add_to_stack);
     }
  }
//+------------------------------------------------------------------+
//| End of StackDepthString                                              |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| DisplayOnDashboard 
//+------------------------------------------------------------------+
// This will display text on the current chart.
void DisplayOnDashboard(string CurrentSymbol, double Tenkansen, double Kijunsen, double Chikouspan, double SenkouSpanA, double SenkouSpanB, int aKumoIV, int aKumoShape, int aKumoSentiment)
  {
   string displaytxt, KumoIV_value, KumoShape_value, KumoSentiment_value;

    if(aKumoIV == 1)KumoIV_value = "thick";
    else if(aKumoIV == -1)KumoIV_value = "thin"; 
    else KumoIV_value = "normal";
                      
    if(aKumoShape == 1)KumoShape_value = "flat-top";
    else if(aKumoShape == 2)KumoShape_value = "flat-bottom"; 
    else KumoShape_value = "abstract";
    
    if(aKumoSentiment == 1)KumoSentiment_value = "bullish";
    else if(aKumoSentiment == 2)KumoSentiment_value = "bearish"; 

   displaytxt = "Time = "+TimeToString(TimeCurrent());
   displaytxt = displaytxt+"\n"+"Current Symbol = "+CurrentSymbol;   
   displaytxt = displaytxt+"\n"+"Tenkansen = "+DoubleToStr(Tenkansen);
   displaytxt = displaytxt+"\n"+"Kijunsen = "+DoubleToStr(Kijunsen);
   displaytxt = displaytxt+"\n"+"Chikou Span = "+DoubleToStr(Chikouspan);
   displaytxt = displaytxt+"\n"+"Senkou SpanA = "+DoubleToStr(SenkouSpanA);
   displaytxt = displaytxt+"\n"+"Senkou SpanB = "+DoubleToStr(SenkouSpanB);
   displaytxt = displaytxt+"\n"+"Implied Volatility = "+KumoIV_value;
   displaytxt = displaytxt+"\n"+"Shape = "+KumoShape_value;
   displaytxt = displaytxt+"\n"+"Sentiment = "+KumoSentiment_value;         

   Comment(displaytxt);
  }
//+------------------------------------------------------------------+
//| End of DisplayOnDashboard 
//+------------------------------------------------------------------+




