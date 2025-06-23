//+--------------------------------------------------------------------------------------+
//|                                                                   BPNN Predictor.mq4 |
//|                                                               Copyright © 2009, gpwr |
//|                                                                   vlad1004@yahoo.com |
//+--------------------------------------------------------------------------------------+
#property copyright "Copyright © 2009, gpwr"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_width1 2
#property indicator_color2 Blue
#property indicator_width2 2
#property indicator_color3 Black
#property indicator_width3 2

//Global constants
#define pi 3.141592653589793238462643383279502884197169399375105820974944592

//======================================= DLL ============================================
#import "BPNN.dll"
string Train(
   double inpTrain[], // Input training data (1D array carrying 2D data, old first)
   double outTarget[],// Output target data for training (2D data as 1D array, oldest 1st)
   double outTrain[], // Output 1D array to hold net outputs from training
   int    ntr,        // # of training sets
   int    UEW,        // Use Ext. Weights for initialization (1=use extInitWt, 0=use rnd)
   double extInitWt[],// Input 1D array to hold 3D array of external initial weights
   double trainedWt[],// Output 1D array to hold 3D array of trained weights
	int    numLayers,  // # of layers including input, hidden and output
	int    lSz[],      // # of neurons in layers. lSz[0] is # of net inputs
	int    AFT,        // Type of neuron activation function (0:sigm, 1:tanh, 2:x/(1+x))
	int    OAF,        // 1 enables activation function for output layer; 0 disables
	int    nep,        // Max # of training epochs
	double maxMSE      // Max MSE; training stops once maxMSE is reached
	);

string Test(
   double inpTest[],  // Input test data (2D data as 1D array, oldest first)
   double outTest[],  // Output 1D array to hold net outputs from training (oldest first)
   int    ntt,        // # of test sets
   double extInitWt[],// Input 1D array to hold 3D array of external initial weights
	int    numLayers,  // # of layers including input, hidden and output
	int    lSz[],      // # of neurons in layers. lSz[0] is # of net inputs
   int    AFT,        // Type of neuron activation function (0:sigm, 1:tanh, 2:x/(1+x))
	int    OAF         // 1 enables activation function for output layer; 0 disables
	);
#import

//===================================== INPUTS ===========================================

extern int    lastBar     =0;     // Last bar in the past data
extern int    futBars     =10;    // # of future bars to predict
extern int    smoothPer   =6;     // Smoothing period
extern int    numLayers   =3;     // # of layers including input, hidden & output (2..6)
extern int    numInputs   =12;    // # of inputs
extern int    numNeurons1 =5;     // # of neurons in the first hidden or output layer
extern int    numNeurons2 =1;     // # of neurons in the second hidden or output layer
extern int    numNeurons3 =0;     // # of neurons in the third hidden or output layer
extern int    numNeurons4 =0;     // # of neurons in the fourth hidden or output layer
extern int    numNeurons5 =0;     // # of neurons in the fifth hidden or output layer
extern int    ntr         =500;   // # of training sets
extern int    nep         =1000;  // Max # of epochs
extern int    maxMSEpwr   =-20;   // sets maxMSE=10^maxMSEpwr; training stops < maxMSE
extern int    AFT         =2;     // Type of activ. function (0:sigm, 1:tanh, 2:x/(1+x))

//======================================= INIT ===========================================
//Indicator buffers
double pred[],trainedOut[],targetOut[];

//Global variables
int lb,nf,nin,nout,lSz[],prevBars,fdMax;
double maxMSE;

int init()
{
// Create 1D array describing NN --------------------------------------------------------+
   ArrayResize(lSz,numLayers);
   lSz[0]=numInputs;
   lSz[1]=numNeurons1;
   if(numLayers>2)
   {
      lSz[2]=numNeurons2;
      if(numLayers>3)
      {
         lSz[3]=numNeurons3;
         if(numLayers>4)
         {
            lSz[4]=numNeurons4;
            if(numLayers>5) lSz[5]=numNeurons5;
         }
      }
   }
   
// Use shorter names for some external inputs -------------------------------------------+
   lb=lastBar;
   nf=futBars;
   nin=numInputs;
   nout=lSz[numLayers-1];
   maxMSE=MathPow(10.0,maxMSEpwr);
   prevBars=Bars-1;
   
// Find maximum Fibonacci delay ---------------------------------------------------------+
   int fd2=0;
   int fd1=1;
   for(int j=0;j<nin;j++)
   {
      int fd=fd1+fd2;
      fd2=fd1;
      fd1=fd;
   }
   fdMax=fd1;

// Set indicator properties -------------------------------------------------------------+
   IndicatorBuffers(3);
   SetIndexBuffer(0,pred);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(1,trainedOut);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(2,targetOut);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2);
   SetIndexShift(0,nf-lb); // future data vector i=0..nf; nf corresponds to bar=lb
   IndicatorShortName("BPNN");  
   return(0);
}

//===================================== DEINIT ===========================================
int deinit(){return(0);}

//===================================== START ============================================
int start()
{
   if(prevBars<Bars){
   prevBars=Bars;
// Check NN and find the total number of weights ----------------------------------------+
   if(numLayers>6)
   {
      Print("The maximum number of layers is 6");
      return;
   }
   for(int i=0;i<numLayers;i++)
   {
      if(lSz[i]<=0)
      {
         Print("No neurons in layer # "+DoubleToStr(i,0)+
            ". Either reduce # of layers or add neurons to this layer");
         return;
      }
   }
   int nw=0; // total number of weights
   for(i=1;i<numLayers;i++)			   // for each layer except input
      for(int j=0;j<lSz[i];j++)			// for each neuron in current layer
         for(int k=0;k<=lSz[i-1];k++)	// for each input of current neuron including bias
				nw++;
      
// Prepare input data for training ------------------------------------------------------+
   double x[],inpTrain[],outTarget[],extInitWt[];
   int n=ntr+fdMax+1;
   ArrayResize(x,n);
   ArrayResize(inpTrain,ntr*nin);
   ArrayResize(outTarget,ntr*nout);
   ArrayResize(extInitWt,nw);
   
	// The input data is arranged as follows:
	//
	// inpTrain[i*nin+j]
	//------------------
	//      j= 0...nin-1
	//            |
	// i=0     <inputs>
	// ...     <inputs>
	// i=ntr-1 <inputs> 
	//
	// outTarget[i*nout+j]
	//--------------------
	//      j= 0...nout-1
	//             |
	// i=0     <targets>
	// ...     <targets>
	// i=ntr-1 <targets> 
   //
	// <inputs> start with the oldest value first
	
   // First smooth prices
   for(i=0;i<n;i++) x[i]=iMA(NULL,0,smoothPer,0,MODE_EMA,PRICE_MEDIAN,lb+i);
	
	// Fill in the input arrays with data; in this example nout=1 
   for(i=ntr-1;i>=0;i--)
   {
      outTarget[i]=(x[ntr-1-i]/x[ntr-i]-1.0);
      int fd2=0;
      int fd1=1;
      for(j=nin-1;j>=0;j--)
      {
         int fd=fd1+fd2; // use Fibonacci delays: 1,2,3,5,8,13,21,34,55,89,144...
         fd2=fd1;
         fd1=fd;
         inpTrain[i*nin+j]=x[ntr-i]/x[ntr-i+fd]-1.0;
      }
   }

// Train NN -----------------------------------------------------------------------------+
   double outTrain[],trainedWt[];
   ArrayResize(outTrain,ntr*nout);
   ArrayResize(trainedWt,nw);
   
   // The output data is arranged as follows:
	//
	// outTrain[i*nout+j]
	//      j= 0...nout-1
	//             |
	// i=0     <outputs>
	// ...     <outputs>
	// i=ntr-1 <outputs>  
   
   string status=Train(inpTrain,outTarget,outTrain,ntr,0,extInitWt,trainedWt,numLayers,
      lSz,AFT,0,nep,maxMSE);
   Print(status);
   // Store trainedWt[] as extInitWt[] for next training
   int iw=0;
   for(i=1;i<numLayers;i++)			// for each layer except input
      for(j=0;j<lSz[i];j++)			// for each neuron in current layer
         for(k=0;k<=lSz[i-1];k++)	// for each input of current neuron including bias
         {
				extInitWt[iw]=trainedWt[iw];
				//Print("w = "+DoubleToStr(extInitWt[iw],5));
				iw++;
		   }
		   
   // Show how individual net outputs match targets
   for(i=0;i<ntr;i++)
   {
      targetOut[lb+i]=x[i];
      trainedOut[lb+i]=(1.0+outTrain[ntr-1-i])*x[i+1];
      //Print("Net output: "+DoubleToStr(outTrain[i],5)
         //+", target: "+DoubleToStr(outTarget[i],5));
   }
      

// Test NN ------------------------------------------------------------------------------+
   double inpTest[],outTest[];
   ArrayResize(inpTest,nin);
   ArrayResize(outTest,nout);
   
   // The input data is arranged as follows:
	//
   // inpTest[i*nin+j]
	//-----------------
	//      j= 0...nin-1
	//            |
	// i=0     <inputs>
	// ...     <inputs>
	// i=ntt-1 <inputs>
	//
	// <inputs> start with the oldest value first
	//
   // The output data is arranged as follows:
	//
	// outTest[i*nout+j]
	//------------------
	//      j= 0...nout-1
	//             |
	// i=0     <outputs>
	// ...     <outputs>
	// i=ntt-1 <outputs> 
	
	pred[nf]=x[0];
	for(i=0;i<nf;i++)
	{
      fd2=0;
      fd1=1;
      for(j=nin-1;j>=0;j--)
      {
         fd=fd1+fd2; // use Fibonacci delays: 1,2,3,5,8,13,21,34,55,89,144...
         fd2=fd1;
         fd1=fd;
         double o,od;
         if(i>0) o=pred[nf-i];
         else o=x[0];
         if(i-fd>0) od=pred[nf-i+fd];
         else od=x[fd-i];
         inpTest[j]=o/od-1.0;
      }
      status=Test(inpTest,outTest,1,extInitWt,numLayers,lSz,AFT,0);
      pred[nf-i-1]=pred[nf-i]*(outTest[0]+1.0); // predicted next open
   }
   }
   return;
}