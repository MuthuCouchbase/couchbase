#!/usr/bin/perl
use strict;
use warnings;
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
