#!/usr/bin/perl
use strict;
use warnings;

open(FILE,"<","couchbase.log") or die "Couldn't open file for reading\n";
while(<FILE>) {
   chomp($_);
   if($_ =~ /OS Name: +(.+)$/) {
      print "OS Name: $1\n";
   }
   if($_ =~ /^Linux (.+)$/) {
      print "OS Name: $1\n";
   }
   if($_ =~ /^Mem:\s*([^\s]+) total,\s*([^\s]+) used,\s*([^\s]+) free,\s*([^\s]+) buffers/) {
      print "Total Memory:$1 Memory Used:$2 Free Memory:$3 Buffers:$4\n";
   }
   if($_ =~ /^Swap:\s*([^\s]+) total,\s*([^\s]+) used,\s*([^\s]+) free,\s*([^\s]+) cached/) {
      print "Swap Total:$1 Swap Used:$2 Swap Free:$3 Cached:$4\n";
   }
   if($_ =~ /^OS Version: +(.+)$/) {
      print "OS Version: $1\n";
   }
   if($_ =~ /Processor\(s\): +(.+)$/) {
      print "Number of Processors: $1\n";
   }
   if($_ =~ /Total Physical Memory: +(.+)$/) {
      print "Total Physical Memory: $1\n";
   }
   if($_ =~ /Available Physical Memory:\s*(.+)$/) {
      print "Available Physical Memory: $1\n";
   }
   if($_ =~ /^couchbase-server ([^\s]+)/) {
      print "Couchbase Version: $1\n";
   }
   if($_ =~ /\{enabled,([^\}]+)\}/) {
      print "AutoFailover Enabled: $1\n";
   }
   if($_ =~ /\{replica_index,([^\}]+)\},/) {
      print "Replica Index: $1\n";
   }
   if($_ =~ /\{autocompaction,([^\}]+)\},/) {
      print "Auto Compaction Enabled: $1\n";
   }
   if($_ =~ /\{flush_enabled,([^\}]+)/) {
      print "Flush Enabled: $1\n";
   }
   if($_ =~ /^ *\[?{"([^"]+)",/) {
      print "\n";
      print "====Bucket Level Configuration====\n";
      print "Bucket Name: $1\n";
   }
   if($_ =~ /\[?\{num_replicas,([^\}]+)\}/) {
      print "Number of Replicas: $1\n";
   }
   if($_ =~ /{ram_quota,([^\}]+)},/) {
      print "RAM Quota: $1\n";
   }
   if($_ =~ /{auth_type,([^\}]+)},/) {
      print "Auth Type: $1\n";
   }
   if($_ =~ /{sasl_password,\[([^\]]+)\]},/) {
      print "SASL Password: $1\n";
   }
   if($_ =~ /{type,([^\}]+)},/) {
      print "Bucket Type: $1\n";
   }
   if($_ =~ /{num_vbuckets,([^\}]+)},/) {
      print "Number of VBuckets: $1\n";
   }
   if($_ =~ /{servers,(.+?)\},/) {
      print "Number of Servers: $1\n";
   }
   if($_ =~ /\]\}\]\}\]\}/) {
      last;
   }
   #if($_ =~ /\]\]\},/) {
    
    #return;
   #}
}
close(FILE) or warn "Couldn't close file\n";
open(FILE,"<","stats.log") or die "Couldn't open file\n";
while(<FILE>) {
   chomp($_);
   if($_ =~ /stats checkpoint/) {
      last;
   }
   if($_ =~ /\*\*|^[A-Za-z]+/ && $_ !~ /stats/) {
      print $_."\n";
   };
   if($_ =~ / curr_items:|vb_active_curr_items:|_wat|mem_used|vb_replica_curr_items:|kv_size/) {
   my ($flag, $value) = split("  +", $_);
   my $key_meta_size = 54+70;
   if($flag =~ / (.+?items):/ ) {
     print $flag."\t$value\tcalculated_$1_size\t".int(($value*$key_meta_size)/(1024*1024*1024))." GB\n" if(length($value) > 10 && $value != 0);
     print $flag."\t$value\tcalculated_$1_size\t".int(($value*$key_meta_size)/(1024*1024))." MB\n" if(length($value) <= 10 && $value != 0);
   }
   else {
      print $flag."\t".int(($value)/(1024*1024*1024))." GB\n" if(length($value) > 10 && $value != 0);
      print $flag."\t".int(($value)/(1024*1024))." MB\n" if(length($value) <= 10 && $value != 0);
   }
   }
}
close(FILE) or warn "Couldn't close file\n";
