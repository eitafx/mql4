//+------------------------------------------------------------------+
//|                                                       EEA_03.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Description: This EA is compatible with EI_03.                   |
//+------------------------------------------------------------------+

#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.00"
#property strict

//--- input parameters
input double prm_Lots     = 0.1;
input int    prm_LossCut  = 150;

input bool   prm_CCI_Up_Enable = False;
input bool   prm_CCI_Down_Enable = False;
input bool   prm_ADX_Up_Enable = False;
input bool   prm_ADX_Down_Enable = False;
input bool   prm_MAvsMA_Up_Enable = False;
input bool   prm_MAvsMA_Down_Enable = False;

//--- import function
#include <EA_MAvsMA.mqh>
#include <EA_ADX.mqh>
#include <EA_CCI.mqh>

//--- My magic number
int MyMagicNumber = 45414903;

// global variable
datetime ChartTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   ChartTime = 0;
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
/*   if ( ChartTime == Time[0] ) {
      return;
   }
   else {
      ChartTime = Time[0];
   }*/

   // calcrate position
   int buypos=0;
   int sellpos=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MyMagicNumber)
      {
         switch ( OrderType())
         {
         case OP_BUY:
            buypos++;
            break;
         case OP_SELL:
            sellpos++;
            break;
         default:
            break; 
         }
      }
   }
   
   // event check
   bool upTrigger = judgeUpTrigger();
   bool downTrigger = judgeDownTrigger();
      
   // clearing position
   if( buypos != 0 ) {
      if ( upTrigger != True ) {
         for( int i=0;i<OrdersTotal();i++ ) {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
            if(OrderMagicNumber()!=MyMagicNumber || OrderSymbol()!=Symbol()) continue;
            if(OrderType()==OP_BUY) {
               bool res = OrderClose(OrderTicket(),OrderLots(),Bid,3,LightPink);
            }
         }
      }
   }
   
   if( sellpos != 0 ) {
      if ( downTrigger != True ) {
         for(int i=0;i<OrdersTotal();i++) {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
            if(OrderMagicNumber()!=MyMagicNumber || OrderSymbol()!=Symbol()) continue;
            if(OrderType()==OP_SELL)
            {
               bool res = OrderClose(OrderTicket(),OrderLots(),Ask,3,AliceBlue);
            }
         }
      }
   }

   // Judge get position
   if( buypos == 0 ) {
      if ( upTrigger == True ) {
         bool res = OrderSend(Symbol(),OP_BUY,prm_Lots,Ask,3,Ask-(prm_LossCut*Point),Ask+1000*Point,"",MyMagicNumber,0,Red);
      }
   }
   
   if ( sellpos == 0 ) {
      if ( downTrigger == True ) {
         bool res = OrderSend(Symbol(),OP_SELL,prm_Lots,Bid,3,Bid+(prm_LossCut*Point),Bid-1000*Point,"",MyMagicNumber,0,Blue);
      }
   }   
}

//+------------------------------------------------------------------+
//| Judge up trigger                                                 |
//+------------------------------------------------------------------+
bool judgeUpTrigger ()
{
   bool CCIFlag = False;
   bool ADXFlag = False;
   bool MAvsMAFlag = False;

// Checking that all flags are disenable
   if ( (prm_CCI_Up_Enable == False) &&
        (prm_ADX_Up_Enable == False) &&
        (prm_MAvsMA_Up_Enable == False) ) {
        return False;
   }

// Checking trend
   if ( prm_CCI_Up_Enable == True ) {
      int cciTrend = EA_getTrendOfCCI( 0 );
      if ( cciTrend == EA_TREND_UP ) {
         CCIFlag = True;
      }
      else {
         CCIFlag = False;
      }
   }
   else {
      CCIFlag = True;
   }

   if ( prm_ADX_Up_Enable == True ) {
      int adxTrend = EA_getTrendOfADX( 0 );
      if ( adxTrend == EA_TREND_UP ) {
         ADXFlag = True;
      }
      else {
         ADXFlag = False;
      }
   }
   else {
      ADXFlag = True;
   }

   if ( prm_MAvsMA_Up_Enable == True ) {
      int mavsmaTrend = EA_getTrendOfMAvsMA( 0 );
      if ( mavsmaTrend == EA_TREND_UP ) {
         MAvsMAFlag = True;
      }
      else {
         MAvsMAFlag = False;
      }
   }
   else {
      MAvsMAFlag = True;
   }

   bool result = False;
   if ( (CCIFlag == True) &&
        (ADXFlag == True) &&
        (MAvsMAFlag == True) ) {
        result = True;
   }
   else {
      result = False;
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Judge down trigger                                               |
//+------------------------------------------------------------------+
bool judgeDownTrigger ()
{
   bool CCIFlag = False;
   bool ADXFlag = False;
   bool MAvsMAFlag = False;

// Checking that all flags are disenable
   if ( (prm_CCI_Down_Enable == False) &&
        (prm_ADX_Down_Enable == False) &&
        (prm_MAvsMA_Down_Enable == False) ) {
        return False;
   }

// Checking trend
   if ( prm_CCI_Down_Enable == True ) {
      int cciTrend = EA_getTrendOfCCI( 0 );
      if ( cciTrend == EA_TREND_DOWN ) {
         CCIFlag = True;
      }
      else {
         CCIFlag = False;
      }
   }
   else {
      CCIFlag = True;
   }

   if ( prm_ADX_Down_Enable == True ) {
      int adxTrend = EA_getTrendOfADX( 0 );
      if ( adxTrend == EA_TREND_DOWN ) {
         ADXFlag = True;
      }
      else {
         ADXFlag = False;
      }
   }
   else {
      ADXFlag = True;
   }

   if ( prm_MAvsMA_Down_Enable == True ) {
      int mavsmaTrend = EA_getTrendOfMAvsMA( 0 );
      if ( mavsmaTrend == EA_TREND_DOWN ) {
         MAvsMAFlag = True;
      }
      else {
         MAvsMAFlag = False;
      }
   }
   else {
      MAvsMAFlag = True;
   }

   bool result = False;
   if ( (CCIFlag == True) &&
        (ADXFlag == True) &&
        (MAvsMAFlag == True) ) {
        result = True;
   }
   else {
      result = False;
   }
   
   return result;
}

//+------------------------------------------------------------------+
