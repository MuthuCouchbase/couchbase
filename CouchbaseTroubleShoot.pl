# print "Usage perl CouchbaseTroubleShoot.pl from the cbcollect unzipped folder\n";
#
#
use strict;
use warnings;
print "Usage perl CouchbaseTroubleShoot.pl\n";
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
   if($_ =~ /^ +\[?{"([^"]+)",/ && $_ !~ /port_listen|url=|\~s|EVENT_NOSELECT|SASL_|\/opt\/couchbase|\~B|MEMCACHED_TOP_KEYS/) {
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
   my ($flag, $value) = split(/ +/, $_);
   my $key_meta_size = 54+70;
   if($flag =~ / (.+?items):/ ) {
     print $flag."\t$value\tcalculated_$1_size\t".int(($value*$key_meta_size)/(1024*1024*1024))." GB\n" if(length($value) > 10 && $value != "0");
     print $flag."\t$value\tcalculated_$1_size\t".int(($value*$key_meta_size)/(1024*1024))." MB\n" if(length($value) <= 10 && $value != "0");
   }
   elsif($flag =~ /_wat|mem_used|kv_size/) {
      print $flag."\t".int(($value)/(1024*1024*1024))." GB\n" if(length($value) > 10 && $value ne "0");
      print $flag."\t".int(($value)/(1024*1024))." MB\n" if(length($value) <= 10 && $value ne "0");
   }
   }
}
close(FILE) or warn "Couldn't close file\n";

system("echo \"*******************Initial Toubleshooting**************************************\"");

system("echo \"**************************************Checking the Number of Connections by port:**************************************\"");
system("grep '^tcp' couchbase.log | awk -F\" *\" '{print \$4\" \"\$6}' | grep -E ':8091|:11210|:11211' | sort | uniq -c");

system("echo \"**************************************Checking Total Number of Views:**************************************\"");
system("grep 'couchbase design docs|Total docs:' -E ddocs.log");

system("echo \"**************************************Checking Total Number of Bucket:**************************************\"");
system("grep 'ep_dbname' stats.log | awk -F\"/\" '{print \$8}' | sort -u | wc -l");

system("echo \"**************************************Checking Error in Views:**************************************\"");
system("grep 'views:error' ns_server.views.log");

system("echo \"**************************************Checking the bg_fetch and get this over a period of time:**************************************\"");
system("grep 'ep_bg_fetched:|ep_bg_fetch_delay:' -E stats.log");

system("echo \"**************************************Checking System paging activity:**************************************\"");
system("grep 'vmstat 1' -A 12 couchbase.log | awk -F\" *\" '{print \$9}' | grep -v '^$'");

system("echo \"**************************************Checking if Disk subsystem is overloaded using Iostat, iotop, free:**************************************\"");
system("grep '^free -t' -A 6 couchbase.log");

system("echo \"**************************************Checking Memcached memory fragmentation and Unknown Memcached memory leak (as observed at the system level):**************************************\"");
system("grep 'total_allocated_bytes:|total_fragmentation_bytes:' -E stats.log | sort -u");

system("echo \"**************************************Checking Log, Data and Indexes are on the same partition.This is due to the requirement of ns_server to periodically update its configuration file, \
and it will crash if it cannot do so. Keep in mind that a disk partition can be filled up from data both inside and outside of Couchbase...but the fact that it filled up is
what causes issues.**************************************\"");
system("grep 'ep_dbname|ep_alog_path' -E stats.log | sort -u");

system("echo \"**************************************Checking Disk Full from too much other data:**************************************\"");
system("grep -A 20 '^df ' couchbase.log");

system("echo \"**************************************Checking Disk full from compaction not running or not catching up:**************************************\"");
system("grep -i 'Error' ns_server.couchdb.log\"");

system("echo \"**************************************Checking Operating System or Hardware restart:**************************************\"");
system("echo \"**************************************Checking OS Errors:**************************************\"");
system("grep panic couchbase.log | head");

system("echo \"**************************************Checking Kernel Errors:**************************************\"");
system("grep 'ECC' couchbase.log | head");

system("echo \"**************************************Checking Host Uptime:**************************************\"");
system("grep 'uptime' couchbase.log -A 3");

system("echo \"**************************************Checking OS Restart Activity:**************************************\"");
system("grep 'Started & configured logging' ns_server.info.log");

system("echo \"*************************************************************************************************\"");
