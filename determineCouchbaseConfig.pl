#!/usr/bin/perl
use strict;
use warnings;
my $file = $ARGV[0];
if(!$file || $file =~ /couchbase.log/) {
   print "Usage: perl determineCouchbaseConfig.pl couchbase.log\n";
   die "Argument couchbase.log has to be provided as input\n";
}
open(FILE,"<",$file) or die "Couldn't open file for reading\n";
while(<FILE>) {
   chomp($_);
   if($_ =~ /OS Name:  +(.+)$/) {
      print "OS Name: $1\n";
   }
   if($_ =~ /^OS Version:  +(.+)$/) {
      print "OS Version: $1\n";
   }
   if($_ =~ /Processor\(s\):  +(.+)$/) {
      print "Number of Processors: $1\n";
   }
   if($_ =~ /Total Physical Memory:  +(.+)$/) {
      print "Total Physical Memory: $1\n";
   }
   if($_ =~ /Available Physical Memory:\s*(.+)$/) {
      print "Available Physical Memory: $1\n";
   }
   if($_ =~ /couchbase-server ([^\s]+)/) {
      print "Couchbase Version: $1\n";
   }
   if($_ =~ /\{enabled,([^\}]+)\}/) {
      print "AutoFailover Enabled: $1\n";
   }
   if($_ =~ /^  *\[?{"([^"]+)",/) {
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
   if($_ =~ /{servers,([^,]+)/) {
      print "Number of Servers: $1\n";
   }
   if($_ =~ /\]\}\]\}\]\}\]\}/) {
      return;
   }
}
close(FILE) or warn "Couldn't close file\n";
