echo "TROUBLESHOOTING and Some Necessary Information about the Customer's Cluster"

echo "*************************************************************************************************"
echo "http://hub.internal.couchbase.com/confluence/display/supp/High+beam.smp+or+Erl.exe+resource+usage"

echo "*************************Too Many Connections***************************************************************"
echo "Number of Connections by port"
grep '^tcp' couchbase.log | awk -F"  *" '{print $4" "$6}' | grep -E ':8091|:11210|:11211' | sort | uniq -c

echo "************************High Beam.smp CPU Usage****************************************************************"
echo "Total Number of Views:"
grep 'couchbase design docs|Total docs:' -E ddocs.log

echo "****************************************************************************************"
echo "Total Number of Bucket:"
grep 'ep_dbname' stats.log | awk -F"/" '{print $8}' | sort -u | wc -l

echo "****************************************************************************************"
echo "Error in Views:"
grep 'views:error' ns_server.views.log

echo "http://hub.internal.couchbase.com/confluence/display/supp/Slow+Reading+From+Disk"

echo "***************************Slow Reading from Disk*************************************************************"
echo "Checking the bg_fetch: Get this over a period of time"
grep 'ep_bg_fetched:|ep_bg_fetch_delay:' -E stats.log

echo "****************************************************************************************"
echo "Disk Fragmentation: How to check this ?"

echo "****************************************************************************************"
echo "System paging activity"
grep 'vmstat 1' -A 12 couchbase.log | awk -F"  *" '{print $9}' | grep -v '^$'

echo "****************************************************************************************"
echo "Disk subsystem is overloaded Checking Iostat, iotop, free"
grep '^free -t' -A 6 couchbase.log

echo "****************************************************************************************"
echo "http://hub.internal.couchbase.com/confluence/display/supp/Couchbase+Server+Paged+out"
echo "*******************************Couchbase Server Paged out********************************************************"
echo  "Memcached memory fragmentation| Unknown Memcached memory leak (as observed at the system level)"
grep 'total_allocated_bytes:|total_fragmentation_bytes:' -E stats.log | sort -u

echo "****************************************************************************************"
echo "Undersized RAM leading to swap"

echo "****************************************************************************************"
echo "External system resource usage causing swap"

echo "*****************************************************************************************"
echo "http://hub.internal.couchbase.com/confluence/display/supp/Undersized+RAM"

echo "****************************************************************************************"
echo "**************************************K/V undersized bucket*******************************"
echo "****************************************************************************************"
echo "****************************High RAM usage on one or Several nodes************************"

echo "****************************************************************************************"
echo "http://hub.internal.couchbase.com/confluence/display/supp/Undersized+RAM"

echo "****************************************************************************************"

echo "**************************************High CPU due to Indexing/Querying*******************"

echo "****************************************************************************************"

echo "************************************High CPU due to Compaction*****************************"

echo "****************************************************************************************"

echo "***********************************High CPU due to bucket count****************************"

echo "****************************************************************************************"

echo "http://hub.internal.couchbase.com/confluence/display/supp/Application+Errors"
echo "****************************Application Errors******************************************"

echo "*************************************TMP_OOM & OOM*******************************"
echo "Get a Pattern for all the buckets over a period of time"
echo "*****************************************************************************************"

echo "**********************************Failed to Read/Write from Server and Client**************"
echo "how do we determine this Flags"

echo "http://hub.internal.couchbase.com/confluence/display/supp/Backup+or+Restore+problems"
echo "http://hub.internal.couchbase.com/confluence/display/supp/Disk+Full#DiskFull-DiskFullfromlackoftombstonepurging%282.0%2C2.0.1and2.0.2only%29"

echo "***********************************************************************************************"
echo "Determine Log, Data and Indexes are on the same partition.This is due to the requirement of ns_server to periodically update its configuration file, and it will crash if it cannot do so.  Keep in mind that a disk partition can be filled up from data both inside and outside of Couchbase...but the fact that it filled up is what causes issues."

grep 'ep_dbname|ep_alog_path' -E stats.log | sort -u
echo "************************************************************************************************"

echo "Disk Full from Couchbase Data"
echo "How to check this ?"

echo "************************************************************************************************"
echo "Disk Full from too much other data"
grep -A 20 '^df ' couchbase.log

echo "************************************************************************************************"
echo "Disk Full from lack of tombstone purging (2.0, 2.0.1 and 2.0.2 only)"
echo "Please refer http://support.couchbase.com/entries/21451884-2-0-x-Tombstone-Purging?flash_digest=0158ade90d8b77f56d9bc33dbe594ee726567e2b"

echo "************************************************************************************************"

echo "Disk full from compaction not running or not catching up"
echo "grep -i 'Error' ns_server.couchdb.log"
echo "************************************************************************************************"

echo "http://hub.internal.couchbase.com/confluence/display/supp/OS+or+Hardware+Failure"
echo "Operating System or Hardware restart"
echo "***************OS Errors**************"
grep panic couchbase.log | head
echo "**************Kernel Errors**************"
grep 'ECC' couchbase.log | head
echo "***************Uptime**************"
grep 'uptime' couchbase.log -A 3
echo "***************OS Restart Activity **************"
grep 'Started & configured logging' ns_server.info.log

echo **************************************************************************************************"
