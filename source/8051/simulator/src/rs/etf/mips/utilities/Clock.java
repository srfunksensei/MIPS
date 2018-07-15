/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package rs.etf.mips.utilities;

import java.util.Calendar;
import rs.etf.mips.gui.MainWindow;

/**
 *
 * @author MB
 */
public class Clock implements Runnable{
    Thread runner; //declare global objects
    private MainWindow parent;

     public Clock(MainWindow parent)
     {
         this.parent = parent;
         start();                                         //start thread running
     }

     //get current time
     public String timeNow()
     {
       Calendar now = Calendar.getInstance();
       int hrs = now.get(Calendar.HOUR_OF_DAY);
       int min = now.get(Calendar.MINUTE);
       int sec = now.get(Calendar.SECOND);

       String time = zero(hrs)+":"+zero(min)+":"+zero(sec);

       return time;
     }



     public String zero(int num)
     {
       String number=( num < 10) ? ("0"+num) : (""+num);
       return number;                                    //Add leading zero if needed

     }


     public void start()
     {
       if(runner == null) runner = new Thread(this);
       runner.start();
                                                             //method to start thread
     }


     public void run()
     {
       while (runner == Thread.currentThread() )
       {                                                 //define thread task
           try
             {
               Thread.sleep(1000);
               if(parent.isTime_show()){
                   parent.setDisplayText(timeNow());
               }
             }
              catch(InterruptedException e)
                  {
                    System.out.println("Thread failed");
                  }

       }
     }
}
