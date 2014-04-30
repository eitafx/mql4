//+------------------------------------------------------------------+
//|                                          EI_MAvsMADifference.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.01"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- plot difference
#property indicator_label1  "wait"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Yellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  OrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  RoyalBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2


input int prmCurrentMAPeriod = 5;
input int prmBaseMAPeriod = 6;
input string Description_about_method = "0:SMA 1:EMA 2:SMMA 3:LWMA";
input int prmMAMethod = 0;
input double prm_UP_LowerLimit = 0.001;
input double prm_UP_UpperLimit = 0.01;
input double prm_Down_LowerLimit = -0.001;
input double prm_Down_UpperLimit = -0.01;
input bool prmAlert = False;

//--- indicator buffers
double         differenceRateWaitBuffer[];
double         differenceRateUpBuffer[];
double         differenceRateDownBuffer[];

#define     LINETYPE_WAIT      (0)
#define     LINETYPE_UP        (1)
#define     LINETYPE_DOWN      (2)
#define     LINETYPE_NONE      (-1)

string objectName_UpLowerLimit = "obj_up_lower_limit";
string objectName_UpUpperLimit = "obj_up_upper_limit";
string objectName_DownLowerLimit = "obj_down_lower_limit";
string objectName_DownUpperLimit = "obj_down_upper_limit";

bool alertFlag = true;
datetime TimeOld;
int  TrendState;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  // parameters check
  if ( (prm_UP_LowerLimit >= prm_UP_UpperLimit) ||
       (prm_Down_LowerLimit <= prm_Down_UpperLimit) ||
       (prm_UP_LowerLimit < prm_Down_LowerLimit) ) {
       
       Alert( WindowExpertName(), ": The parameter is incorrect." );
       return(INIT_PARAMETERS_INCORRECT);
  }
  
   //--- indicator buffers mapping
   SetIndexBuffer(0,differenceRateWaitBuffer);
   SetIndexBuffer(1,differenceRateUpBuffer);
   SetIndexBuffer(2,differenceRateDownBuffer);

   alertFlag = true;
   TimeOld = Time[0];
   TrendState = LINETYPE_NONE;
//---
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
{
   ObjectDelete(objectName_UpLowerLimit);
   ObjectDelete(objectName_UpUpperLimit);
   ObjectDelete(objectName_DownLowerLimit);
   ObjectDelete(objectName_DownUpperLimit);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   createLimitLine();

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;

   for( int i=0; i<(limit-1); i++ ) {

      double currentMA[2];
      double baceMA[2];
      double diffRate[2];

      currentMA[0] = iMA( NULL, 0, prmCurrentMAPeriod, 0, prmMAMethod, PRICE_CLOSE, i );
      currentMA[1] = iMA( NULL, 0, prmCurrentMAPeriod, 0, prmMAMethod, PRICE_CLOSE, (i+1) );
      baceMA[0] = iMA( NULL, 0, prmBaseMAPeriod, 0, prmMAMethod, PRICE_CLOSE, i );
      baceMA[1] = iMA( NULL, 0, prmBaseMAPeriod, 0, prmMAMethod, PRICE_CLOSE, (i+1) );

      if ( (baceMA[0] > 0.0) && (baceMA[1] > 0.0) ) {

         diffRate[0] = ((currentMA[0] - baceMA[0]) / baceMA[0]) * 100.0;
         diffRate[1] = ((currentMA[1] - baceMA[1]) / baceMA[1]) * 100.0;
        
         int judge = judgeTrend( diffRate[0] );
         
         switch (judge)
         {
            case LINETYPE_WAIT:
            case LINETYPE_UP:
            case LINETYPE_DOWN:
               setLineBuffer( judge, diffRate[0], i );
               setLineBuffer( judge, diffRate[1], i+1 );
               break;
            case LINETYPE_NONE:
            default:
               setLineBuffer( LINETYPE_NONE, 0, i );
               break;
         }
      }
      else {
         setLineBuffer( LINETYPE_NONE, 0, i );
      }
   }
   
   if ( prmAlert == True ) {
      checkAlert();
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Judge trend                                                      |
//+------------------------------------------------------------------+
int judgeTrend( double diffRate )
{
   int result = LINETYPE_NONE;

   if ( (diffRate < prm_UP_LowerLimit) && (diffRate > prm_Down_LowerLimit) ) {  // lower limit check
      result = LINETYPE_WAIT;
   }
   else {
      if ( (diffRate >= prm_UP_LowerLimit) && (diffRate <= prm_UP_UpperLimit) ) { // up trend check
         result = LINETYPE_UP;         
      }
      else if ( (diffRate <= prm_Down_LowerLimit) && (diffRate >= prm_Down_UpperLimit) ) {   // down trend check
         result = LINETYPE_DOWN;
      }
      else {   // wait trend check
         result = LINETYPE_WAIT;
      }
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Fixing of guidelines                                             |
//+------------------------------------------------------------------+
void setLineBuffer( int type, double rate, int shift )
{
   // Overflow check
   if ( (ArraySize(differenceRateWaitBuffer)-1) < shift  ) {
      return;
   }

   // Set value to buffer
   switch ( type )
   {
      case LINETYPE_WAIT:
         differenceRateWaitBuffer[shift] = rate;
         differenceRateUpBuffer[shift] = EMPTY_VALUE;
         differenceRateDownBuffer[shift] = EMPTY_VALUE;
         break;
      case LINETYPE_UP:
         differenceRateWaitBuffer[shift] = rate;
         differenceRateUpBuffer[shift] = rate;
         differenceRateDownBuffer[shift] = EMPTY_VALUE;
         break;
      case LINETYPE_DOWN:
         differenceRateWaitBuffer[shift] = rate;
         differenceRateUpBuffer[shift] = EMPTY_VALUE;
         differenceRateDownBuffer[shift] = rate;
         break;
      case LINETYPE_NONE:
      default:
         differenceRateWaitBuffer[shift] = EMPTY_VALUE;
         differenceRateUpBuffer[shift] = EMPTY_VALUE;
         differenceRateDownBuffer[shift] = EMPTY_VALUE;
         break;
   }
}

//+------------------------------------------------------------------+
//| Event function                                                   |
//+------------------------------------------------------------------+
void OnChartEvent( const int id,
                   const long& lparam,
                   const double& dparama,
                   const string& sparam )
{

   if ( id == 1 ) {
      ObjectSet( objectName_UpLowerLimit, OBJPROP_PRICE1, prm_UP_LowerLimit );
      ObjectSet( objectName_UpUpperLimit, OBJPROP_PRICE1, prm_UP_UpperLimit );
      ObjectSet( objectName_DownLowerLimit, OBJPROP_PRICE1, prm_Down_LowerLimit );
      ObjectSet( objectName_DownUpperLimit, OBJPROP_PRICE1, prm_Down_UpperLimit );
   }

}

//+------------------------------------------------------------------+
//| Create line object                                               |
//+------------------------------------------------------------------+
void createLimitLine()
{
   if ( ObjectFind(objectName_UpLowerLimit) < 0 ) {
      ObjectCreate(objectName_UpLowerLimit, OBJ_HLINE, WindowOnDropped(), 0, prm_UP_LowerLimit );
      ObjectSet(objectName_UpLowerLimit, OBJPROP_COLOR, LightPink);
   }
   
    if ( ObjectFind(objectName_UpUpperLimit) < 0 ) {   
      ObjectCreate(objectName_UpUpperLimit, OBJ_HLINE, WindowOnDropped(), 0, prm_UP_UpperLimit );
      ObjectSet(objectName_UpUpperLimit, OBJPROP_COLOR, OrangeRed);
    }
    
     if ( ObjectFind(objectName_DownLowerLimit) < 0 ) {  
      ObjectCreate(objectName_DownLowerLimit, OBJ_HLINE, WindowOnDropped(), 0,prm_Down_LowerLimit  );
      ObjectSet(objectName_DownLowerLimit, OBJPROP_COLOR, LightSkyBlue);
     }
     if ( ObjectFind(objectName_DownUpperLimit) < 0 ) { 
      ObjectCreate(objectName_DownUpperLimit, OBJ_HLINE, WindowOnDropped(), 0, prm_Down_UpperLimit );
      ObjectSet(objectName_DownUpperLimit, OBJPROP_COLOR, RoyalBlue);
     }
}

void checkAlert()
{
   if (Time[0] != TimeOld)
   {
      alertFlag = true;
      TimeOld = Time[0];
   }

   if (alertFlag)
   {

      double currentMA = iMA( NULL, 0, prmCurrentMAPeriod, 0, prmMAMethod, PRICE_CLOSE, 0 );
      double baceMA = iMA( NULL, 0, prmBaseMAPeriod, 0, prmMAMethod, PRICE_CLOSE, 0 );

      if ( baceMA > 0.0 ) {
         double diffRate = ((currentMA - baceMA) / baceMA) * 100.0;
         
         int judge = judgeTrend( diffRate );
         if ( TrendState != LINETYPE_NONE ) {
            if ( TrendState != judge ) {
            
               string msg = "";
               
               switch (TrendState)
               {
                  case LINETYPE_WAIT:msg = "[Wait]->";break;
                  case LINETYPE_UP:msg = "[Up]->";break;
                  case LINETYPE_DOWN: msg = "[Down]->";break;
                  default:msg = "[?]->";break;
               }
               
               switch (judge)
               {
                  case LINETYPE_WAIT:msg += "[Wait]";break;
                  case LINETYPE_UP:msg += "[Up]";break;
                  case LINETYPE_DOWN: msg += "[Down]";break;
                  default:msg += "[?]";break;
               }
               
               Alert("EI_MADiff:", msg, " - ", Symbol(), "(", Period(), ")" );
               alertFlag = false;
               TrendState = judge;
            }
            else {
               // nothing
            }
            
         }
         else {
            TrendState = judge;
         }
      }
   }
   
}

//+------------------------------------------------------------------+
