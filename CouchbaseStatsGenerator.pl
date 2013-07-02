#!/usr/bin/perl                                                                                                                                                         
use strict;
#use warnings;
use Getopt::Long;

my ($s3fileName, $startDate, $endDate, $flags, $node);
my ($date,$host,$bucket,$datapoint,$value);
GetOptions ("startDate=s"  => \$startDate,
            "endDate=s"    => \$endDate,
            "flags=s"      => \$flags,
            "node=s"       => \$node,
            "s3fileName=s" => \$s3fileName
           );
if(!$s3fileName || $s3fileName !~ /ns_server.debug.log|ns_server.stats.log/) {
   print "Usage perl CouchbaseStatsGenerator.pl --flags[optional] --s3fileName=ns_server.debug.log or ns_server.stats.log --startDate[optional] --endDate[optional] --node[optional]\n";
   print "Please provide ns_server.stats.log only for 2.x CB\n";
   die "Please check the inputs\n";
}
$flags = "mem_used,curr_items,curr_items_tot,ep_diskqueue_drain,ep_diskqueue_fill,ep_diskqueue_items,ep_diskqueue_memory,ep_flusher_todo,ep_io_num_read,ep_io_num_write,ep_io_read_bytes,ep_io_write_bytes,ep_kv_size,ep_num_non_resident,ep_num_value_ejects,ep_queue_size,ep_tmp_oom_errors,ep_total_enqueued,ep_value_size,vb_active_curr_items,vb_active_eject,vb_active_itm_memory,vb_active_num_non_resident,vb_active_perc_mem_resident,vb_replica_curr_items,vb_replica_itm_memory,vb_replica_num_non_resident,vb_replica_perc_mem_resident" if(!$flags) ;
$flags =~ s/,/\|/g;
!system("grep -A 217 'Stats for bucket \"' $s3fileName | grep -E 'Stats for bucket \"|$flags' > STATS.txt") or die "Couldn't execute the command\n";

open(FILE,"<","STATS.txt") or die "Couldn't open file for reading\n";
open(OUTPUTFILE,">","OUTPUT_STATS.txt") or die "Couldn't open file for writing\n";
print OUTPUTFILE "DATE,HOST,BUCKET_NAME,FLAG,VALUE\n";
while(<FILE>) {
   chomp($_);
   if($_ =~ / \[([^\]]+)\] \[ns_1@([^:]+):.*?"([^"]+)":$/ || $_ =~ /stats:debug,([^\.]+).*?,ns_1@([^:]+):.*?"([^"]+)":$/) {
      $date = $1;
      $host = $2;
      $bucket = $3;
   }
   elsif($_ =~ /^(ep|vb|mem_used|curr_items)/) {
      my($datapoint,$value) = split("  +",$_); #<b> Make Sure when you copy the script to terminal, edit this to double space as there is a problem that changes to single space while copying
      if(defined $node && $host == "$node") {
         if($date =~ /$startDate/ || $date =~ /$endDate/) {
            print OUTPUTFILE $date.",".$host.",".$bucket.",".$datapoint.",".$value."\n";
         }
         elsif(!$startDate && !$endDate) {
            print OUTPUTFILE $date.",".$host.",".$bucket.",".$datapoint.",".$value."\n";
         }
      }
      elsif($date =~ /$startDate/ || $date =~ /$endDate/) {
         print OUTPUTFILE $date.",".$host.",".$bucket.",".$datapoint.",".$value."\n";
      }
      elsif(!$node && !$startDate && !$endDate) {
         print OUTPUTFILE $date.",".$host.",".$bucket.",".$datapoint.",".$value."\n";
      }   
   }
}
close(FILE) or warn "Couldn't close file after reading\n";   
close(OUTPUTFILE) or warn "Couldn't close fileafter writing\n";   
