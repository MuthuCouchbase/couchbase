package couch;

import java.net.URI;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import com.couchbase.client.CouchbaseClient;

import net.spy.memcached.CASValue;
import net.spy.memcached.internal.GetFuture;
import net.spy.memcached.internal.OperationFuture;

public class Couch {
  public static final String KEY = "Muthu";
  public static final String VALUE = "10";
  public static final int ttl          = 0;
  public static final int size         = 5;
  

public static void main(String args[]) throws InterruptedException, ExecutionException {
    // Set the URIs and get a client
    List<URI> uris = new LinkedList<URI>();
    int option    = Integer.parseInt(args[0]);
        //String KEY       = args[1];
        
    Boolean do_delete = true;

    // Connect to localhost or to the appropriate URI
    uris.add(URI.create("http://192.168.50.3:8091/pools"));

    CouchbaseClient client = null;
    try {
      client = new CouchbaseClient(uris, "default", "");
    } catch (Exception e) {
      System.err.println("Error connecting to Couchbase: "
        + e.getMessage());
      System.exit(0);
    }
    // Do a synchronous get
    Object getObject = client.get(KEY);
    switch(option) {
    
    case 0:
      //  Print the value from synchronous get
       if (getObject.toString() != null) {
          System.out.println("Synchronous Get Suceeded: "
           + (String) getObject);
       } else {
          System.err.println("Synchronous Get failed");
       }
       // Check to see if asyncGet succeeded
       break;

    case 1:
       // Do an asynchronous set
       OperationFuture<Boolean> setOp = client.set(KEY, ttl, VALUE);
       GetFuture<Object> getOp = client.asyncGet(KEY);
       // Do an asynchronous get
       //GetFuture<Object> getOp = client.asyncGet(KEY);
              // Check to see if our set succeeded
       if (getObject != null) {
          try {
             if (setOp.get().booleanValue()) {
                System.out.println("Set Succeeded");
             }  else {
                System.err.println("Set failed: "
                + setOp.getStatus().getMessage());
             }
          }  catch (Exception e) {
             System.err.println("Exception while doing set: "
             + e.getMessage());
          }
       }
/*       try {
           if (getOp.toString() != null) {
              System.out.println("Asynchronous Get Succeeded: with key"
              +getOp.toString() + "and value being "+getOp.get().toString());
           } else {
              System.err.println("Asynchronous Get failed: ");
           }
        } catch (Exception e) {
           System.err.println("Exception while doing Asynchronous Get: "
           + e.getMessage());
        } */
       break;

    case 2:
       // Do an asynchronous delete
       OperationFuture<Boolean> delOp = null;
       //KEY       = args[1];
       //GetFuture getObject = client.asyncGet(KEY);
      
       if (getObject != null) {
         delOp = client.delete(KEY);
       }
       // Check to see if our delete succeeded
       if (do_delete) {
          try {
             if (delOp.get().booleanValue()) {
                System.out.println("Delete Succeeded");
             } else {
                System.err.println("Delete failed: " +
                delOp.getStatus().getMessage());
             }
          } catch (Exception e) {
                System.err.println("Exception while doing delete: "
                + e.getMessage());
          }
       }
       break;
           // ADD
       case 3:
          try {
             if (getObject != null) {
            
                client.add(KEY, ttl, VALUE);
                System.out.println("Key Added");
             } else {
                System.err.println("Add failed: ");
             }
           } catch (Exception e) {
                System.err.println("Exception while doing Add:"
                + e.getMessage());
          }
       break;
       case 4:
           //Replace
          try {
             if (getObject != null) {
                client.replace(KEY, ttl, new String("ABCDEF"));
                System.out.println("Key Replaced");
             } else {
                System.err.println("Replace failed: ");
             }
           } catch (Exception e) {
                System.err.println("Exception while doing Replace:"
                + e.getMessage());
          }
       break;
    case 5:
        //Increment
       //KEY       = args[1];
       try {
             if (getObject != null) {
                client.incr(KEY, 5,5);
                System.out.println("Key incremented");
             } else {
                System.err.println("Increment failed: ");
             }
           } catch (Exception e) {
                System.err.println("Exception while doing increment: "
                + e.getMessage());
          }
       break;

    case 6:
        //Decrement
       //KEY       = args[1];
       try {
             if (getObject != null) {
                client.decr(KEY, 5, 5);
                System.out.println("Key decremented");
             } else {
                System.err.println("Decrement failed: ");
             }
           } catch (Exception e) {
                System.err.println("Exception while doing decrement: "
                + e.getMessage());
          }
       break;
 
    case 7:
        //Append
       String datatoappend = new String(" abcde");
       CASValue<Object> casv = client.gets(KEY);
       //System.out.println("The CAS is " +casv.getCas());
       //System.out.println("The CAS Value is " +casv.getValue());
       try {
             if (getObject != null) {
                                client.append(client.gets(KEY).getCas(),KEY, datatoappend);
                System.out.println("Data Value Appended");
                System.out.println("The Value is appended as "+getObject);
             } else {
                System.err.println("Append failed: ");
             }
           } catch (Exception e) {
                System.err.println("Exception while doing Append:"
                + e.getMessage());
          }
       break;

    case 8:
        //Prepend
       String datatoprepend = new String(" abcde pqrst uvwxyz ");
       CASValue<Object> casv1 = client.gets(KEY);
       //System.out.println("The CAS is " +casv1.getCas());
       //System.out.println("The CAS Value is " +casv1.getValue());
       try {
    	     
             if (getObject != null) {          	 
            	int counter = 0; 
            	while(counter != 1) {
            		System.out.println("The counter is "+counter);
            		// To Note if you use client.prepend(casv1.getCas(),KEY, datatoprepend);
            		// Prepend can't be run in a loop as it would return false after the
            		// the first instance.
            		OperationFuture<Boolean> prependOp = client.prepend(client.gets(KEY).getCas(),KEY, datatoprepend);
            	    if (prependOp.get().booleanValue()) { 
                       System.out.println("The Value is prepended as "+client.get(KEY));
                    }   
                    else {
                       System.out.println("Prepend failed: ");
                    }
            	++counter;
            	}
             }
           } catch (Exception e) {
                System.err.println("Exception while doing Prepend:"
                + e.getMessage());
          }
       break;

    case 9:
        //Shutdown
       // Shutdown the client
       client.shutdown(3, TimeUnit.SECONDS);
       break;

    default:
       System.out.println("Hi, Do Nothing");
       break;  
      
    }
  }
}
