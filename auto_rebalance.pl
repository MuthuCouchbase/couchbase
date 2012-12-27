#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
my ($serverIp, $userName, $password, $nodesToAdd, $nodesToRemove);
my $tmpFile = "/var/tmp/stats.txt";

GetOptions ("serverIp=s"      => \$serverIp,
            "userName=s"      => \$userName,
            "password=s"      => \$password,
            "nodesToAdd=s"    => \$nodesToAdd,
            "nodesToRemove=s" => \$nodesToRemove);

if(!$serverIp || !$userName || !$password) {
    print "Usage: perl auto_rebalance.pl --serverIp --userName --password --nodesToAdd --nodesToRemove\n";
    print "Please provide either nodesToAdd or nodesToRemove and the rest\n";
    die "Inputs doesn't match\n";
}
sub list_servers() {
    my $server_list=`/opt/couchbase/bin/couchbase-cli server-list -c $serverIp:8091 -u $userName -p $password |cut -d ':' -f1|cut -d ' ' -f2`;
    return $server_list;
}

sub list_buckets() {
    my @bucket_list=`/opt/couchbase/bin/couchbase-cli bucket-list -c $serverIp:8091 |grep -v '^ '`;
    return @bucket_list;
}
my $serverList=list_servers();
my @bucketList=list_buckets();

sub cluster_status() {
    print "Entering the CLuster Status\n";
    foreach my $bucket(@bucketList) {
        $bucket =~ s/\n//g;
        if($bucket =~ /[A-Za-z0-9]+/) {
           `/opt/couchbase/bin/cbstats $serverIp:11211 all $bucket | egrep "ep_queue_size|ep_flusher_todo|ep_tap_rebalance_count" > $tmpFile`;
        }
    }
    # grab dwq stats
    my $ep_queue_size=`cat $tmpFile | grep 'ep_queue_size'|cut -f2 -d:`;
    $ep_queue_size =~ s/\n|\t|\s|  *//g;

    # grab tap conns
    my $tap_rebalance_queue=`cat $tmpFile | grep 'ep_tap_rebalance_count'|cut -f2 -d:`;
    $tap_rebalance_queue =~ s/\n|\t|\s|  *//g;

    # check if dwq > a million per node or if tap conns for rebalance still live - if so, return 1, if not, return 0
    if(($ep_queue_size > 10) || ($tap_rebalance_queue =~ /[0-9]+/)) {
       print "Entering the Cluster Check\n";
       return 1;
    }
    else {
       return 0;
    }
}
my $ret_value = 0;
sub rebalance() {
    eval {
       if($ret_value == 0) {
          if(defined $nodesToAdd && !defined $nodesToRemove) {
             $ret_value = system("/opt/couchbase/bin/couchbase-cli rebalance -c $serverIp:8091 --server-add=$nodesToAdd -u $userName -p $password") || 0;
          }
          elsif(defined $nodesToRemove && !defined $nodesToAdd) {
             $ret_value = system("/opt/couchbase/bin/couchbase-cli rebalance -c $serverIp:8091 --server-remove=$nodesToRemove -u $userName -p $password") || 0;
          }
          elsif(defined $nodesToAdd && defined $nodesToRemove) {
             $ret_value = system("/opt/couchbase/bin/couchbase-cli rebalance -c $serverIp:8091 --server-remove=$nodesToRemove --server-add=$nodesToAdd -u $userName -p $password") || 0;
          }
          elsif(!$nodesToAdd && !$nodesToRemove) {
             $ret_value = system("/opt/couchbase/bin/couchbase-cli rebalance -c $serverIp:8091  -u $userName -p $password") || 0;
          }
       }
       elsif($ret_value !=0 && defined $nodesToRemove) {
          $ret_value = system("/opt/couchbase/bin/couchbase-cli rebalance -c $serverIp:8091  -u $userName -p $password --server-remove=$nodesToRemove") || 0;
       }
       else {
          $ret_value = system("/opt/couchbase/bin/couchbase-cli rebalance -c $serverIp:8091  -u $userName -p $password") || 0;
       }
    };
#    my $ret_value = system("/opt/couchbase/bin/couchbase-cli rebalance -c $serverIp:8091 --server-remove=$nodesToRemove -u $userName -p $password`;
    if($ret_value != 0) {
        print "There's an error in rebalance  - $@\n";
        return 0;
    }
    else {
        return 1;
    }
}

while ( rebalance() == 0 ) {
    print "I have failed here\n";
    sleep(100);
    print "I am retrying\n";
    rebalance();
    if ( cluster_status() == 1 ) {
        sleep(300);
    }
}
