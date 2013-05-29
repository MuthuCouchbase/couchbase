<?php
// adjust these parameters to match your installation
$cb = new Couchbase("54.241.219.191:8091", "", "", "default");
$arrayHash = array();
$counter=0;
$file_handle = fopen("name1.txt", "rb");
while (!feof($file_handle) ) {
   $line_of_text = fgets($file_handle);
   $parts = explode(',', $line_of_text);
   $arrayHash[$parts[0]] = $parts[1];
}
fclose($file_handle);
while(true) {
   for ($i = 0; $i < count($arrayHash); ++$i) {
      $temp_array = array($arrayHash[$i]);
      $counter+=1;
      if($counter%5000 == 0) {
         $cb->setMulti($temp_array, $expiry = 0, $persist_to = 0, $replicate_to = 0);
         var_dump("Setting and Deleting keys for the $counter time");
         $temp_array = array();
      }
   }
}
?>
