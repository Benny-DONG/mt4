function GmailCheck() { 
  
  
  var zefx=GmailApp.getUserLabelByName("z-efx");
  var enews=GmailApp.getUserLabelByName("1-News");
  //var forecast=GmailApp.getUserLabelByName("7-forecast");
  
  var threads = zefx.getThreads();
  for (var i = threads.length-1; i > -1; i--) 
  //for (var i = 0; i < threads.length; i++) 
  {
    if (threads[i].getFirstMessageSubject().search("/")>=0)//threads[i].isUnread()&&
    {
      var msg=threads[i].getMessages();
      var body=msg[0].getBody();
      Logger.log("Body ="+body);
      var message = clean(body);

      //Logger.log("Message ="+message);
//       if(message.match(/\w{3}\/\w{3}/i))
//      {      
      //Logger.log("Body Organial ="+body);
      var time=msg[0].getDate();
      
      
      //Logger.log("Body after clean ="+message);
      
      var order=decode(time,message);
      //Logger.log("Pair is ="+order[4]);
      Logger.log("Order is ="+order);
      //var start1 = new Date().getTime();      
      //var end1 = new Date().getTime();
      //var time1 = end1 - start1;
     // Logger.log("Time1: "+time1);
      
       saveDrive(time,order);
      //writeTabel(body);
      
      threads[i].addLabel(enews);
      threads[i].removeLabel(zefx); 
      //GmailApp.markThreadRead(threads[i]);
      threads[i].moveToArchive();
//      }
//      else if(message.match(/Forecast/i))
//      {
//        threads[i].addLabel(forecast);
//        threads[i].removeLabel(zefx); 
//        GmailApp.markThreadRead(threads[i]);
//        threads[i].moveToArchive();
//      }
    }
  }
}


function clean(body)
{
      //subject = subject.replace(/"Fwd: "/i,"");
      body = body.replace(/<[^>]+>/g,"");        //去除html标签
      
      body = body.replace(/© 2015.*Unsubscribe/gi,"");   
      //Logger.log("Body ="+body);
      body = body.replace(/,/g,"");       //去除所有,
      body = body.replace(/\n|\r|\|/g,"");       //去除所有换行符
      body = body.replace(/.*\w*–/,"");          //去除所有前面的时间和-号
      body = body.replace(/(^\s*)|(\s*$)/g,""); //去除前后空格
      body = body.toLowerCase();
      return body;
}

function saveDrive(time,order) {
  var time = Utilities.formatDate(time, "GMT+11", "yy.MM.dd_HH.mm.ss_");
  var name1 = "pepp01todo";
  var name2 = "1iang";
      

  if(!DriveApp.getFoldersByName("mt4").hasNext())
  {
    DriveApp.createFolder("mt4");
  }

  
  var fdRecordsAll=DriveApp.getFoldersByName("mt4");
  var fdRecords=fdRecordsAll.next();
  
  var fdNames=fdRecords.getFoldersByName(name1);  
  
  if(fdNames.hasNext())
  {//eg: 15.02.12_01.57.21_c26AUDUSDomo
    var fdName=fdNames.next();
    fdName.createFile(time+order[1]+order[4]+order[2]+".txt",order,"text");
  }
  else
  {
    var newfolder=fdRecords.createFolder(name1);
    newfolder.createFile(time+order[1]+order[4]+order[2]+".txt",order,"text");
  }  
  //======================================================
    if(!DriveApp.getFoldersByName("efx").hasNext())
  {
    DriveApp.createFolder("efx");
  }
  
  var fdRecordsAll2=DriveApp.getFoldersByName("efx");
  var fdRecords2=fdRecordsAll2.next();
  
  var fdNames2=fdRecords2.getFoldersByName(name2);  
  
  if(fdNames2.hasNext())
  {//eg: 15.02.12_01.57.21_c26AUDUSDomo
    var fdName2=fdNames2.next();
    fdName2.createFile(time+order[1]+order[4]+order[2]+".txt",order,"text");
  }
    else
  {
    var newfolder=fdRecords.createFolder(name1);
    newfolder.createFile(time+order[1]+order[4]+order[2]+".txt",order,"text");
  }  
  
}
