function decode(time,message) {
  var time = Utilities.formatDate(time, "GMT+2", "yyyy-MM-dd HH:mm:ss");
  var body = message;
  var action = -1;
  var name = -1;
  
    var order_type = /\slong\s|\sshort\s/i.exec(body).toString().substring(1,2).toUpperCase();
    var period = /\w+-Term/i.exec(body).toString().substring(0,1).toUpperCase();
    var pair = /\w{3}\/\w{3}/i.exec(body).toString().toUpperCase().replace(/\//, "");
  
  var banks = new Array("morgan stanley","credit suisse","citi","société générale","nomura","jp morgan","bnz","bofa merrill","goldman sachs","bnp paribas","btmu","barclays","cibc","commerzbank","crédit agricole","credit agricole","danske","deutsche bank","nab","nordea","seb","scotiabank","societe generale","ubs","westpac","anz");
  var anames = new Array("c01","c02","c03","c04","c05","c06","c07","c08","c09","c10","c11","c12","c13","c14","c15","c16","c17","c18","c19","c20","c21","c22","c23","c24","c25","c26");
  //var anames = new Array("喊单账号1","喊单账号1","喊单账号1","喊单账号1","喊单账号1","喊单账号2","喊单账号2","喊单账号2","喊单账号2","喊单账号2","喊单账号3","喊单账号3","喊单账号3","喊单账号3","喊单账号3","喊单账号4","喊单账号4","喊单账号4","喊单账号4","喊单账号4","喊单账号5","喊单账号5","喊单账号5","喊单账号5","喊单账号5");
  for(var i in banks)
  {
    if(body.indexOf(banks[i]) !== -1)
    {
      name = anames[i];
    }
  }
  
  var operations = new Array("placed a limit order","on its limit order","got canceled","via filling","long from","short from","stopped out","hit target","hit profit-stop","closed");
  var aoperations = new Array("ppo","mpo","cpo","fpo","omo","omo","csl","ctp","cps","mco");
  //var aoperations = new Array("挂单","修改挂单","挂单取消","挂单成交","市价单成交","市价单成交","止损平仓","止盈平仓","获利平仓","手动平仓");
  for(var i in operations)
  {
    if(body.indexOf(operations[i]) !== -1)
    {
      action = aoperations[i];
    }
  }
  if (body.match(/adjusted.*on\sits\s\w{3}\/\w{3}/i)) action = "mmo";
  //if (body.match(/adjusted.*on\sits\s\w{3}\/\w{3}/i)) action = "修改市价单";
  
  if (body.match(/delay/i)) var delay = "1"; else delay = "0";
  var keyword;
  var price = [0,0,0,0,0,0,0];
  body = body.split(/\s+/);
//get price
switch(action)
{
   //==========NEED ACTION===========
  case "ppo":  
      if((keyword = body.indexOf("to")) !== -1) { price[1] = body[keyword+4];} 
      if((keyword = body.indexOf("stop")) !== -1) { price[2] = body[keyword+2];}
      if((keyword = body.indexOf("target")) !== -1) { price[3] = body[keyword+2];}
      break;  
  case "mpo":
      if((keyword=body.indexOf("entry")) !== -1) { price[1] = body[keyword+2]; price[4] = body[keyword+4];}
      if((keyword=body.indexOf("stop")) !== -1) { price[2] = body[keyword+2]; price[5] = body[keyword+4];}
      if((keyword=body.indexOf("target")) !== -1) { price[3] = body[keyword+2]; price[6] = body[keyword+4];}
          break;          
  case "omo":
      if((keyword = body.indexOf("entered")) !== -1) { price[1] = body[keyword+4];}
      if((keyword = body.indexOf("stop")) !== -1) { price[2] = body[keyword+2];}
      if((keyword = body.indexOf("target")) !== -1) { price[3] = body[keyword+2];}
          break;          
  case "mmo":
      if((keyword = body.indexOf("stop")) !== -1) { price[2] = body[keyword+2]; price[5] = body[keyword+4];}
      if((keyword = body.indexOf("target")) !== -1) { price[3] = body[keyword+2]; price[6] = body[keyword+4];}  
          break;    
  //==========ONLY NEED DELETE or CLOSE===========
  case "cpo":
      break;
  case "mco":
    if((keyword = body.indexOf("profit")) !== -1) price[0] = body[keyword+2];
    else if((keyword = body.indexOf("loss")) !== -1) price[0] = body[keyword+2];
      break;      
  //==========NO NEED ACTION==========    
  case "fpo":
      break;
  case "csl":
    if((keyword = body.indexOf("profit")) !== -1) price[0] = body[keyword+2];
    else if((keyword = body.indexOf("loss")) !== -1) price[0] = body[keyword+2];
      break;
  case "ctp":
    if((keyword = body.indexOf("profit")) !== -1) price[0] = body[keyword+2];
    else if((keyword = body.indexOf("loss")) !== -1) price[0] = body[keyword+2];
     break;
  case "cps":
    if((keyword = body.indexOf("profit")) !== -1) price[0] = body[keyword+2];
    else if((keyword = body.indexOf("loss")) !== -1) price[0] = body[keyword+2];
      break;
}
  return ([time,name,action,order_type,pair,period,delay,price]); 
  }
