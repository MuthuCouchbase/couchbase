<?php
// adjust these parameters to match your installation
$cb = new Couchbase("54.215.110.211:8091", "", "", "default");
$arrayHash = array();
$counter=1;
while(true) {
   for($i=1;$i < 5001;$i++) {
      $arrayHash["CouchbaseKey".$i] = "Hi Buddy this is Couchbase";
   }
   $cb->setMulti($arrayHash, $expiry = 0, $persist_to = 0, $replicate_to = 0);
   foreach ($arrayHash as $key => $value) {
      $cb->delete($key, $cas = "", $persist_to = 0, $replicate_to = 0);
   }
   var_dump("Setting and Deleting keys for the $counter time");
   $counter+=1;
}
?>
