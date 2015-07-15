#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//#property strict


int OnInit()
  {

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

  }

void OnTick()
  {
   string InpFilter="*";
   string from_folder = "Google/mt4/pepp01todo/";
   string file_name;
   long search_handle=FileFindFirst(from_folder+InpFilter,file_name,FILE_COMMON);
   if(search_handle!=INVALID_HANDLE)
     {     
     FileIsExist(file_name);
     //Print("File name is = "+file_name);
     //===========
     string to_pepp = "Google/mt4/pepp02demo/";
     string to_1iang3000 = "Google/mt4/1iang3000/";
     string to_oanda = "Google/mt4/oanda/";
    if(FileCopy(from_folder+file_name,FILE_COMMON,to_1iang3000+file_name,FILE_COMMON|FILE_REWRITE) && FileCopy(from_folder+file_name,FILE_COMMON,to_oanda+file_name,FILE_COMMON|FILE_REWRITE) && FileCopy(from_folder+file_name,FILE_COMMON,to_pepp+file_name,FILE_COMMON|FILE_REWRITE))
    {//PrintFormat("%s file copied to"+to_pepp,file_name); }
    //==========
     FileFindClose(search_handle);
     }
   else
      string to_exit="怎么退出 不执行下面程序";
      //Print("Files not found!");
      
   //Put the data into the records array
   string records[14];   //from_folder+file_name
   int handle=FileOpen(from_folder+file_name,FILE_CSV|FILE_WRITE|FILE_READ|FILE_COMMON,',');
   if(handle>0)
   {         
             for(int i = 0; i<ArraySize(records);i++)
               {
                  records[i]=FileReadString(handle);
                  if(FileIsLineEnding(handle) == true )
                  break;
               }               
      }
    //Print("The records is = "+records[1]+"-"+records[2]+"-"+records[3]+"-"+records[4]+"-"+records[5]+"-"+records[6]+"-"+records[7]+"-"+records[8]+"-"+records[9]+"-"+records[10]+"-"+records[11]+"-"+records[12]+"-"+records[13]);
 //===========================================================================================   
         int magic=0;
         int slippage = 30;
         double lot = 0;
         string action = records[2];
         string order_type = records[3];
         //Print("order type is ="+order_type);
         string pair = records[4];
         string period=records[5];
         double old_entry = records[8];
         double old_stop_loss = records[9];
         double old_take_profit = records[10];
         double new_entry = records[11];
         double new_stop_loss = records[12];
         double new_take_profit = records[13]; 
         //order_type+pair+name+period       
         string comment = records[3]+records[4]+records[1]+records[5];
         //Print("Comment is ="+comment);
         double bid = MarketInfo(pair,MODE_BID);
         double ask = MarketInfo(pair,MODE_ASK);
         
	      int mypoint = 20;
	      //changed 两个银行的短线 和 不跟某个银行特定货币 cooment格式 pair+bank+period
		   //if (StringFind(comment,"c02S",5)>0 && StringFind(comment,"GBPUSDc02",0)<0)
		   if (StringFind(comment,"c01S",5)>0 && StringFind(comment,"c02S",5)>0 && StringFind(comment,"GBPUSDc02",0)<0)
	     
			{  
			//calculate lotSize
			//if(period=="S"){lot=0.4;}else {lot=0.2;}
   double freemargin	= AccountFreeMargin();
   double RISK[] = { 0, 2, 2.5, 3, 5, 7, 10, 25 };	 int SELECTED_RISK = 1;
   double stop_loss_in_pips;
   if(period=="S") 
      {stop_loss_in_pips = 100;} 
   else 
      {stop_loss_in_pips = 200;}
   
   double point=Point;
   if((Digits==3) || (Digits==5))
     {
      point*=10;
     }
//Number of Lots = [(Account Balance, in dollars) x (Risk %)] / [(Stop Loss, in pips) x (Pip Value, in dollars)]
   double pipValue=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*1);
   if ( RISK[SELECTED_RISK] > 0 ) { lot = NormalizeDouble((freemargin*RISK[SELECTED_RISK] / 100.0)/(stop_loss_in_pips*pipValue),2); }
			//Ending calculate lotSize
		         //5.市价单成交 open_market_order  omo 1.挂单 place_pending_order(buy_limit, sell_limit)  ppo
	      
 
						 if(action=="omo")    
	            
			          {
      			      if(order_type == "L")
      			      {//如果市价单差距在1.8pips之内 就即时开 不然开挂单
      			          int omol = OrderSend(pair,OP_BUY,lot,ask,18,old_stop_loss,old_take_profit,comment,magic,0,White);
      			          if(omol<0)
      			          {
            		          if(ask>old_entry)
            		          {int omo_lbl = OrderSend(pair,OP_BUYLIMIT,lot,old_entry+mypoint*MarketInfo(pair,MODE_POINT),30,old_stop_loss,old_take_profit,comment,magic,0,White);}
            		          else 
            		          {int omo_lbs = OrderSend(pair,OP_BUYSTOP,lot,old_entry,30,old_stop_loss,old_take_profit,comment,magic,0,White);}			               
      			          }			               
      			      }
			            else if(order_type == "S")
			            {
			               int omos = OrderSend(pair,OP_SELL,lot,bid,18,old_stop_loss,old_take_profit,comment,magic,0,White);
			               if(omos<0)
			               {
      		            	if(bid<old_entry)
      		               {int omo_ssl = OrderSend(pair,OP_SELLLIMIT,lot,old_entry-mypoint*MarketInfo(pair,MODE_POINT),30,old_stop_loss,old_take_profit,comment,magic,0,White);}
      		               else
      		               {int omo_sss = OrderSend(pair,OP_SELLSTOP,lot,old_entry,30,old_stop_loss,old_take_profit,comment,magic,0,White);}			               
			               }
			            }
			            else
			               Alert("********Error in OMO************"+file_name+"**********");
			         }
			         else if(action=="ppo")                   
			         {            
				            if(order_type == "L")
				            {
				            	if(ask>old_entry)
				               {int ppo_lbl = OrderSend(pair,OP_BUYLIMIT,lot,old_entry+mypoint*MarketInfo(pair,MODE_POINT),30,old_stop_loss,old_take_profit,comment,magic,0,White);}
				              else 
				               {int ppo_lbs = OrderSend(pair,OP_BUYSTOP,lot,old_entry,30,old_stop_loss,old_take_profit,comment,magic,0,White);}   
				            }
				            else if(order_type == "S")
				            {
				            	if(bid<old_entry)
				               {int ppo_ssl = OrderSend(pair,OP_SELLLIMIT,lot,old_entry-mypoint*MarketInfo(pair,MODE_POINT),30,old_stop_loss,old_take_profit,comment,magic,0,White);}
				              else
				               {int ppo_sss = OrderSend(pair,OP_SELLSTOP,lot,old_entry,30,old_stop_loss,old_take_profit,comment,magic,0,White);}
				       	    }
				            else
				               {Alert("******代码错误: 开市价单 或 挂单************"+file_name+"**********");}
		         }
			         //4.挂单成交 fill_pending_order fpo
		         else if(action=="fpo")
		         	{string noaction ="no action need";
		         	}
		          //7.止损平仓 close_by_stop_loss     csl OR 8.止盈平仓 close_by_target_profit ctp OR 9.获利平仓 close_by_profit_stop   cps
		          else if(action=="csl" || action=="ctp" || action=="cps")
		          {        
		          	
		          	//delete pending order when its not opened when filled in pending order before bcoz difference price in different terminal
		          			   for (int del_p=0;del_p<OrdersTotal(); del_p++)
		                  {
		                        if(OrderSelect(del_p,SELECT_BY_POS,MODE_TRADES)==True)
		                        {
		                           if(OrderComment() == comment && ((OrderType()==OP_BUYLIMIT)||(OrderType()==OP_BUYSTOP)||(OrderType()==OP_SELLLIMIT)||(OrderType()==OP_SELLSTOP)))
		                           {int close_pend = OrderDelete(OrderTicket());break;}
		                              
		                        }
		                  }                     
		          }
		         //10.手动平仓 3.挂单取消 6.修改市价单 2.修改挂单
		         else if (action=="mco" || action=="cpo" || action=="mmo" || action == "mpo")
		         {        //搜索所有的持仓单子 找是不是又符合的
		                  for (int j=0;j<OrdersTotal(); j++)
		                  {
		                        if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==True)
		                        {
		                           if(OrderComment() == comment)
		                           {         
		                              //10.手动平仓 close_order  mco OR 3.挂单取消 cancel_pending_order   cpo
		                              if(action=="mco" || action=="cpo")
		                              {
		                                       if(OrderType() == OP_BUY)
		                                             int mcob = OrderClose(OrderTicket(),OrderLots(),Bid,slippage,Blue); 
		                                       else if(OrderType()==OP_SELL)
		                                             int mcos =OrderClose(OrderTicket(),OrderLots(),Ask,slippage,Blue);
		                                       else if((OrderType()==OP_BUYLIMIT)||(OrderType()==OP_BUYSTOP)||(OrderType()==OP_SELLLIMIT)||(OrderType()==OP_SELLSTOP))
		                                             int cpo = OrderDelete(OrderTicket());
		                                       else
		                                          Alert("*******Error in MCO and CPO************"+file_name+"**********");
		                              }
		                              else if(action=="mmo" || action == "mpo")
		                              {//6.修改市价单 modify_market_order  mmo  OR 2.修改挂单 modify_pending_order   mpo                                    
		                                    //modify market order need to select first
		                                    //new entry,new st,new tp need to update
		                                    if(records[11] != 0 && records[12] != 0 && records[13] != 0)
		                                    {//int mo_e_s_t = OrderModify(OrderTicket(),new_entry,new_stop_loss,new_take_profit,0,Blue);
		                                     	if(order_type == "L")
                           		            {//Print("OMO  or PPO Long");
                           		            	if(ask>new_entry)
                           		               {int mo_e_s_t_1 = OrderModify(OrderTicket(),new_entry+mypoint*MarketInfo(pair,MODE_POINT),new_stop_loss,new_take_profit-mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
                           		              else 
                           		               {int mo_e_s_t_2 = OrderModify(OrderTicket(),new_entry,new_stop_loss,new_take_profit-mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
                           		            }
                           		            else if(order_type == "S")
                           		            {//Print("OMO  or PPO Short");
                                               if(bid<new_entry)
                           		               {int mo_e_s_t_3 = OrderModify(OrderTicket(),new_entry-mypoint*MarketInfo(pair,MODE_POINT),new_stop_loss,new_take_profit+mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
                           		              else 
                           		               {int mo_e_s_t_4 = OrderModify(OrderTicket(),new_entry,new_stop_loss,new_take_profit+mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
                           		            }
		                                    }
		                                     //new st,new tp need to update
		                                    else if(records[12] != 0 && records[13] != 0)
		                                    {
		                                       if(order_type == "L")
		                                        {int mo_s_tl = OrderModify(OrderTicket(),OrderOpenPrice(),new_stop_loss,new_take_profit-mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
		                                       else if(order_type == "S")
		                                       {int mo_s_ts = OrderModify(OrderTicket(),OrderOpenPrice(),new_stop_loss,new_take_profit+mypoint*MarketInfo(pair,MODE_POINT),0,Blue);} 
		                                    }
		                                     //new entry, new sl need to update
		                                     else if(records[11]!=0 && records[12]!=0)
		                                     
			                                 {//int mo_e_s = OrderModify(OrderTicket(),new_entry,new_stop_loss,OrderTakeProfit(),0,Blue);
		                                     	if(order_type == "L")
                           		            {//Print("OMO  or PPO Long");
                           		            	if(ask>new_entry)
                           		               {int mo_e_s_1 = OrderModify(OrderTicket(),new_entry+mypoint*MarketInfo(pair,MODE_POINT),new_stop_loss,OrderTakeProfit(),0,Blue);}
                           		              else 
                           		               {int mo_e_s_2 = OrderModify(OrderTicket(),new_entry,new_stop_loss,OrderTakeProfit(),0,Blue);}
                           		            }
                           		            else if(order_type == "S")
                           		            {//Print("OMO  or PPO Short");
                                               if(bid<new_entry)
                           		               {int mo_e_s_3 = OrderModify(OrderTicket(),new_entry-mypoint*MarketInfo(pair,MODE_POINT),new_stop_loss,OrderTakeProfit(),0,Blue);}
                           		              else 
                           		               {int mo_e_s_4 = OrderModify(OrderTicket(),new_entry,new_stop_loss,OrderTakeProfit(),0,Blue);}
                           		            }
		                                    }	                                     
		                                     //new entry,new tp need to update
		                                     else if(records[11]!=0 && records[13]!=0)
		                                     	                                     
		                                    {//int mo_e_t = OrderModify(OrderTicket(),new_entry,OrderStopLoss(),new_take_profit,0,Blue);	
		                                     	if(order_type == "L")
                           		            {//Print("OMO  or PPO Long");
                           		            	if(ask>new_entry)
                           		               {int mo_e_t_1 = OrderModify(OrderTicket(),new_entry+mypoint*MarketInfo(pair,MODE_POINT),OrderStopLoss(),new_take_profit-mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
                           		              else 
                           		               {int mo_e_t_2 = OrderModify(OrderTicket(),new_entry,OrderStopLoss(),new_take_profit-mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
                           		            }
                           		            else if(order_type == "S")
                           		            {//Print("OMO  or PPO Short");
                                               if(bid<new_entry)
                           		               {int mo_e_t_3 = OrderModify(OrderTicket(),new_entry-mypoint*MarketInfo(pair,MODE_POINT),OrderStopLoss(),new_take_profit+mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
                           		              else 
                           		               {int mo_e_t_4 = OrderModify(OrderTicket(),new_entry,OrderStopLoss(),new_take_profit+mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
                           		            }
		                                    }
		                                     //new tp need to update
		                                    else if(records[13] != 0)
		                                    {
		                                       if(order_type == "L")
		                                       {int mo_tpl = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),new_take_profit-mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
		                                       else if(order_type == "S")
		                                       {int mo_tps = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),new_take_profit+mypoint*MarketInfo(pair,MODE_POINT),0,Blue);}
		                                    }
		                                     //new st need to update
		                                    else if(records[12] != 0)
		                                     int mo_sl = OrderModify(OrderTicket(),OrderOpenPrice(),new_stop_loss,OrderTakeProfit(),0,Blue);
			                                 else if(records[11] != 0)
		                                     //int mo_entry = OrderModify(OrderTicket(),new_entry,OrderStopLoss(),OrderTakeProfit(),0,Blue);	                                     
		                                     //new entry need to update     old_entry-mypoint*MarketInfo(pair,MODE_POINT)
		                                     //************************
		                                     	if(order_type == "L")
                           		            	{//Print("OMO  or PPO Long");
                           		            	if(ask>new_entry)
                           		               {int mo_entry1 = OrderModify(OrderTicket(),new_entry+mypoint*MarketInfo(pair,MODE_POINT),OrderStopLoss(),OrderTakeProfit(),0,Blue);}
                           		              else 
                           		               {int mo_entry2 = OrderModify(OrderTicket(),new_entry,OrderStopLoss(),OrderTakeProfit(),0,Blue);}
                           		              }
                           		            else if(order_type == "S")
                           		            	{//Print("OMO  or PPO Short");
                                               if(bid<new_entry)
                           		               {int mo_entry3 = OrderModify(OrderTicket(),new_entry-mypoint*MarketInfo(pair,MODE_POINT),OrderStopLoss(),OrderTakeProfit(),0,Blue);}
                           		              else 
                           		               {int mo_entry4 = OrderModify(OrderTicket(),new_entry,OrderStopLoss(),OrderTakeProfit(),0,Blue);}
                                                }
		                                     //************************

		                                    else //
		                                       Alert("*********Error in MMP and MPO: issues in ENTRY or ST or TP************"+file_name+"**********");
		                              }
		                            break;
		                           }
		                        }
		                         
		                         
		                  }
		         }
		      }
 		//===========================================dreal==================================================== 
    FileClose(handle);
    string to_folder = "Google/mt4/pepp1done/";
    //要研究怎么目标文件夹有文件也覆盖
    if(FileMove(from_folder+file_name,FILE_COMMON,to_folder+file_name,FILE_COMMON|FILE_REWRITE))
    
    {
     PrintFormat("%s file moved to"+to_folder,file_name);   
    }
}
}
