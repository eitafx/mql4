//+------------------------------------------------------------------+
//|                                          EA_TrendCoefficient.mqh |
//|                                             Copyright 2014, eita |
//|                                                         Ver:1.01 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property strict

input double prm_TrendCoefficien_threshold = 0.00;

#include <EA_stdval.mqh>

//+------------------------------------------------------------------+
//| get the value for drawing line                                   |
//+------------------------------------------------------------------+
double EA_getTrendCoefficien( const int timeframe,
                              const int period,
                              const int depth,
                              const int mt_shift )
{
    double calcValue = EMPTY_VALUE;

    if ( (period != 0) && (mt_shift >= 0) ) {
        calcValue = calcCoefficient( timeframe, period, depth, mt_shift );
    }
    else {
        calcValue = EMPTY_VALUE;
    }

    return calcValue;
}

//+------------------------------------------------------------------+
//| judge the terend                                                 |
//+------------------------------------------------------------------+
int EA_judgeTrenfForTrendCoefficien ( double value )
{
    int result = EA_TREND_STAY;

    if ( value == EMPTY_VALUE ) {
        result = EA_TREND_STAY;
    }
    else {
    
        if ( MathAbs(value) < prm_TrendCoefficien_threshold ) {
            result = EA_TREND_STAY;
        }
        else if ( value >= 0.0 ) {
            result = EA_TREND_UP;
        }
        else {
            result = EA_TREND_DOWN;
        }
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| calculate coefficient                                            |
//+------------------------------------------------------------------+
double calcCoefficient(const int timeframe,
                         const int period,
                         const int depth,
                         const int shift)
{
    double calcValue = EMPTY_VALUE;
    
    double preMAValue = iMA( NULL, timeframe, period, 0, MODE_SMA, PRICE_CLOSE, (depth+shift) );
    double curMAValue = iMA( NULL, timeframe, period, 0, MODE_SMA, PRICE_CLOSE, shift );
    
    if ( depth == 0 ) {
        calcValue = 0;
    }
    else {
        calcValue = (curMAValue -preMAValue ) / (double)(depth);
    }

    return calcValue;
}


//+------------------------------------------------------------------+
