//+------------------------------------------------------------------+
//|                                                       EA_ADX.mqh |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property strict

#include "EA_stdval.mqh"

input int      prm_EA_ADX_trend_period = 14;

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get the trend of ADX                                             |
//+------------------------------------------------------------------+
int EA_getTrendOfADX( int timeframe, int depth, int shift=0 )
{   
   int idx;
   int checkPos = shift;
   bool trendFlag = false;
   for ( idx=0; idx<(depth-1); idx++ ) {
   
      double curADX =  iADX( NULL, timeframe, prm_EA_ADX_trend_period, PRICE_CLOSE, MODE_MAIN, checkPos );
      double preADX =  iADX( NULL, timeframe, prm_EA_ADX_trend_period, PRICE_CLOSE, MODE_MAIN, (checkPos+1) );
      if (curADX > preADX ) {
         trendFlag = true;
      }
      else {
         trendFlag = false;
         break;
      }
      
      checkPos++;
   }

   int resTrend = EA_TREND_STAY;

   if ( trendFlag == true ) {

      double plus =  iADX( NULL, timeframe, prm_EA_ADX_trend_period, PRICE_CLOSE, MODE_PLUSDI, shift );
      double minus =  iADX( NULL, timeframe, prm_EA_ADX_trend_period, PRICE_CLOSE, MODE_MINUSDI, shift );
      
      if ( plus >= minus ) {
         resTrend = EA_TREND_UP;
      }
      else {
         resTrend = EA_TREND_DOWN;
      }
   }
   else {
      resTrend = EA_TREND_STAY;
   }

   

 
   return (resTrend);
}

//+------------------------------------------------------------------+
