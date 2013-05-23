<?php
// adjust these parameters to match your installation
$cb = new Couchbase("54.215.110.211:8091", "", "", "default");
$booksHash = array();
while(true) {                                                                                                                                                           
   for($i=1;$i < 5001;$i++) {
      $booksHash["CouchbaseKey".$i] = "Hi Buddy this is Couchbase";
   }
   $cb->setMulti($booksHash, $expiry = 0, $persist_to = 0, $replicate_to = 0);
   foreach ($booksHash as $key => $value) {
      $cb->delete($key, $cas = "", $persist_to = 0, $replicate_to = 0);
   }
   $cb->set("a", 101);
   var_dump($cb->get("a"));
   $cb->delete("a",$cas = "", $persist_to = 0, $replicate_to = 0);                                                                                                      
}                                                                                                                                                                       
?>
