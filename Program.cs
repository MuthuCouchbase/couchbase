using System;
using System.Configuration;
using System.Threading;
using Couchbase;
using Couchbase.Configuration;
using Enyim.Caching;
using Enyim.Caching.Memcached;

 
namespace couchbaseSupport2525
{
class Program
{
private const string CacheMissIndication = "X";
private const string CacheHitIndication = "_";
private const string UncaughtExceptionIndication = "E";
private const string StoreFailureIndication = "F";
private const string ConfigSectionName = "awsCouchbaseBucket";
 
private static readonly log4net.ILog Logger = log4net.LogManager.GetLogger(typeof(Program));
 
private static CouchbaseClient _couchbaseClient;
 
private static readonly int NumberOfKeys = Convert.ToInt32(ConfigurationManager.AppSettings["numberOfKeys"]);
private static readonly string CacheKeyPrefix = ConfigurationManager.AppSettings["cacheKeyPrefix"];
private static readonly int CacheKeyTimeToLiveMinutes = Convert.ToInt32(ConfigurationManager.AppSettings["cacheKeyTimeToLiveMinutes"]);
private static readonly int SecondsToSleepBetweenIterations = Convert.ToInt32(ConfigurationManager.AppSettings["secondsToSleepBetweenIterations"]);
 
private static readonly TimeSpan TtlOfKeys = new TimeSpan(days: 0, hours: 0, minutes: CacheKeyTimeToLiveMinutes, seconds: 0);
 
static void Main()
{
//LogManager.AssignFactory(new Log4NetFactory());
 
Console.WriteLine("Starting test. There will be {0} keys in use and they will have a TTL of {1} minute(s).", NumberOfKeys, CacheKeyTimeToLiveMinutes);
Console.WriteLine("Will sleep {0} second(s) between iterations.", SecondsToSleepBetweenIterations);
Console.WriteLine("{0} signifies a cache miss followed by a successful set.", CacheMissIndication);
Console.WriteLine("{0} signifies a cache hit.", CacheHitIndication);
Console.WriteLine("{0} signifies an uncaught exception.", UncaughtExceptionIndication);
Console.WriteLine("{0} signifies a cache miss followed by a FAILURE setting new data.", StoreFailureIndication);

 
InitializeClient();
 
while (true)
{
var misses = 0;
for (int i = 0; i < NumberOfKeys; i++)
{
try
{
string cacheKey = GetCacheKey(CacheKeyPrefix, i);
var data = PerformGet(cacheKey);

if (String.IsNullOrWhiteSpace(data) == false)
{
Console.Write(CacheHitIndication);
}
else
{
misses++;
Console.Write(PerformSet(cacheKey, GetCacheKeyValue(i)) ? CacheMissIndication : StoreFailureIndication);
}
}
catch (Exception ex)
{
Console.WriteLine(UncaughtExceptionIndication);
Logger.Error("Uncaught exception", ex);
}
}
 
//spit out stats for this iteration of the loop
Console.WriteLine(" {0} {1}/{2} misses", DateTime.Now.ToString("HH:mm:ss"), misses, NumberOfKeys);
 
//sleep for a while and start it all over
Thread.Sleep(millisecondsTimeout: SecondsToSleepBetweenIterations * 1000);
}
}
 
/// <summary>
/// set up our client to talk to the cache
/// </summary>
static void InitializeClient()
{
var section = (ICouchbaseClientConfiguration)ConfigurationManager.GetSection(ConfigSectionName);
if (section == null || section.Urls.Count <= 0)
throw new ConfigurationErrorsException(
"Cannot create CouchbaseClient. Got a default section with 0 URLs when trying the .config file");
Console.WriteLine("{0} Couchbase REST URLs are: {1}", section.Urls.Count, String.Join(", ", section.Urls));
_couchbaseClient = new CouchbaseClient(section);
Console.WriteLine("Connected {0}", _couchbaseClient);
}
 
/// <summary>
/// Get a cache key string based on the index
/// </summary>
static string GetCacheKey(string keyPrefix, int index)
{
return String.Format("{0}_{1}", keyPrefix, index);
}
 
/// <summary>
/// Get a value to put in the cache for the particular index
/// </summary>
static string GetCacheKeyValue(int index)
{
return String.Format("value_{0}_{1}", index, DateTime.Now.ToString("HH:mm:ss"));
}
 
/// <summary>
/// Try a get data from the cache
/// </summary>
static string PerformGet(string cacheKey)
{
return _couchbaseClient.Get<string>(cacheKey);
}
 
/// <summary>
/// Try to stuff data in the cache and return a flag whether it succeeded or not
/// </summary>
private static bool PerformSet(string cacheKey, string newData)
{
    //Console.WriteLine("Key and Value that are set {0}", _couchbaseClient.Store(StoreMode.Set, cacheKey, newData, TtlOfKeys));
    return _couchbaseClient.Store(StoreMode.Set, cacheKey, newData, TtlOfKeys);
}
}
}
