#!/usr/bin/perl
use strict;
use warnings;
system("grep \'curr_items|vb_active_curr_items|_wat|mem_used|vb_replica_curr_items\' -E stats.log | grep -vE \'tot| 0\$\' > /var/tmp/file");
open(FILE,"<","/var/tmp/file") or die "Couldn't open file\n";
while(<FILE>) {
   chomp($_);
   my ($flag, $value) = split("  +", $_);
   my $key_meta_size = 54+70;
   if($flag =~ /items/ ) {
     print $flag."_size\t".($value*$key_meta_size)/(1024*1024*1024)." GB\n" if(length($value) > 10);
     print $flag."_size\t".($value*$key_meta_size)/(1024*1024)." MB\n" if(length($value) <= 10);
   }
   else {
      print $flag."\t".($value)/(1024*1024*1024)." GB\n" if(length($value) > 10);
      print $flag."\t".($value)/(1024*1024)." MB\n" if(length($value) <= 10);
   }
}
close(FILE) or warn "Couldn't close file\n";
