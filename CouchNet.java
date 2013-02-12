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
  public static final int ttl = 0;
  public static final int size = 5;
  
public static void main(String args[]) throws InterruptedException, ExecutionException {
    // Set the URIs and get a client
    List<URI> uris = new LinkedList<URI>();
        //String KEY = args[1];
        
    Boolean do_delete = true;

    // Connect to localhost or to the appropriate URI
    uris.add(URI.create("http://ec2-184-169-239-89.us-west-1.compute.amazonaws.com:8091/pools"));

    CouchbaseClient client = null;
    try {
      client = new CouchbaseClient(uris, "default", "");
    } catch (Exception e) {
      System.err.println("Error connecting to Couchbase: "
        + e.getMessage());
      System.exit(0);
    }
     while (true) {
        int misses = 0;
        int deletes = 0;
        int storefailures =0;
        for (int i = 0; i < 10; i++) {
           try {
//            Object getObject = client.get(KEY+i);
                 
//            if (getObject.toString() != null) {
//                System.out.println("H");
//             }
//             else {
                  OperationFuture<Boolean> setOp = client.set(KEY+i, ttl, VALUE);
                  if(setOp.get().booleanValue()) {
                      misses++;
                  } 
                  else {
                      storefailures++;
                  }
//             }
               Object getObject = client.get(KEY+i);
               OperationFuture<Boolean> delOp = null;
               if (getObject != null) {
                   delOp = client.delete(KEY+i);
               }
               if (delOp.get().booleanValue()) {
                    deletes++;
               } else {
                    //delOp.getStatus().getMessage());
               }
            }
            catch(Exception ex) {
               ex.printStackTrace();
            }
         }
         System.out.println("The misses, deletes and storeFailures are "+misses+" "+" "+deletes+" "+storefailures);
      }
   }   
}
