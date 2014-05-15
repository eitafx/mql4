//+------------------------------------------------------------------+
//|                                          EI_TrendCoefficient.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      ""
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot mt_5min
#property indicator_label1  "5min"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Tomato
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot mt_15min
#property indicator_label2  "15min"
#property indicator_type2   DRAW_LINE
#property indicator_color2  MediumPurple
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot mt_30min
#property indicator_label3  "30min"
#property indicator_type3   DRAW_LINE
#property indicator_color3  CornflowerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot mt_1hour
#property indicator_label4  "1hour"
#property indicator_type4   DRAW_LINE
#property indicator_color4  SandyBrown
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot mt_4hour
#property indicator_label5  "4hour"
#property indicator_type5   DRAW_LINE
#property indicator_color5  HotPink
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot mt_1day
#property indicator_label6  "1day"
#property indicator_type6   DRAW_LINE
#property indicator_color6  LightGreen
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

//--- input parameters
input int      prm_Period_5min = 0;
input int      prm_Depth_5min = 1;
input int      prm_Period_15min = 21;
input int      prm_Depth_15min = 1;
input int      prm_Period_30min = 21;
input int      prm_Depth_30min = 1;
input int      prm_Period_1h = 21;
input int      prm_Depth_1h = 1;
input int      prm_Period_4h = 0;
input int      prm_Depth_4h = 1;
input int      prm_Period_1d = 0;
input int      prm_Depth_1d = 1;

//--- indicator buffers
double         mt5minBuffer[];
double         mt15minBuffer[];
double         mt30minBuffer[];
double         mt1hourBuffer[];
double         mt4hourBuffer[];
double         mt1dayBuffer[];

#include <EA_lib.mqh>
#include <EA_TrendCoefficient.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,mt5minBuffer);
   SetIndexBuffer(1,mt15minBuffer);
   SetIndexBuffer(2,mt30minBuffer);
   SetIndexBuffer(3,mt1hourBuffer);
   SetIndexBuffer(4,mt4hourBuffer);
   SetIndexBuffer(5,mt1dayBuffer);

//---
   return(INIT_SUCCEEDED);
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
    int counted_bars=IndicatorCounted();
    if(counted_bars<0) return(-1);
    if(counted_bars>0) counted_bars--;
    int limit=Bars-counted_bars;
    
    int idx_5min = 0;
    int idx_15min = 0;
    int idx_30min = 0;
    int idx_1hour = 0;
    int idx_4hour = 0;
    int idx_1day = 0;

    for(int i=0; i<(limit-1); i++) {

        idx_5min = EA_convertIndexForMT( PERIOD_M5, i, idx_5min );
        if ( (prm_Period_5min != 0) && (idx_5min >= 0) ) {
            mt5minBuffer[i] = calcCoefficient( PERIOD_M5, prm_Period_5min, prm_Depth_5min, idx_5min );
        }
        else {
            mt5minBuffer[i] = EMPTY_VALUE;
        }

        idx_15min = EA_convertIndexForMT( PERIOD_M15, i, idx_15min );
        if ( (prm_Period_15min != 0) && (idx_15min >= 0) ) {
            mt15minBuffer[i] = calcCoefficient( PERIOD_M15, prm_Period_15min, prm_Depth_15min, idx_15min );
        }
        else {
            mt15minBuffer[i] = EMPTY_VALUE;
        }

        idx_30min = EA_convertIndexForMT( PERIOD_M30, i, idx_30min );
        if ( (prm_Period_30min != 0) && (idx_1hour >= 0) ) {
            mt30minBuffer[i] = calcCoefficient( PERIOD_M30, prm_Period_30min, prm_Depth_30min, idx_30min );
        }
        else {
            mt30minBuffer[i] = EMPTY_VALUE;
        }

        idx_1hour = EA_convertIndexForMT( PERIOD_H1, i, idx_1hour );
        if ( (prm_Period_1h != 0) && (idx_1hour >= 0) ) {
            mt1hourBuffer[i] = calcCoefficient( PERIOD_H1, prm_Period_1h, prm_Depth_1h, idx_1hour );
        }
        else {
            mt1hourBuffer[i] = EMPTY_VALUE;
        }

        idx_4hour = EA_convertIndexForMT( PERIOD_H4, i, idx_4hour );
        if ( (prm_Period_4h != 0) && (idx_4hour >= 0) ) {
            mt4hourBuffer[i] = calcCoefficient( PERIOD_H4, prm_Period_4h, prm_Depth_4h, idx_4hour );
        }
        else {
            mt4hourBuffer[i] = EMPTY_VALUE;
        }

        idx_1day = EA_convertIndexForMT( PERIOD_D1, i, idx_1day );
        if ( (prm_Period_1d != 0) && (idx_1day >= 0) ) {
            mt1dayBuffer[i] = calcCoefficient( PERIOD_D1, prm_Period_1d, prm_Depth_1d, idx_1day );
        }
        else {
            mt1dayBuffer[i] = EMPTY_VALUE;
        }      

    }

//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
