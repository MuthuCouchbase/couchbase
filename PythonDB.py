#!/usr/bin/python
import MySQLdb
import optparse

usage = "%prog [opts] localhost user password dbName"
parser=optparse.OptionParser(usage=usage, epilog=epilog)

parser.add_option("-h", "--localhost", action="store_true", default="",
                      help="provide hostname")
parser.add_option("-u", "--user", action="store_true", default="",
                      help="provide username")
parser.add_option("-p", "--password", action="store_true", default="",
                      help="provide password")
parser.add_option("-db", "--dbName", action="store_true", default="",
                      help="provide dbName")
opts, args = parser.parse_args()

if not (opts.all):
        parser.print_usage()
        sys.exit("One of -f or -a must be specified")
        
db = MySQLdb.connect("localhost","user","password","dbName")
cursor = db.cursor()

sql = "Select * from employee"
try:
   cursor.execute(sql)
   results = cursor.fetchall()
   for row in results:
      emp_name = row[0]
      emp_id   = row[1]
      designation = row[2]
      salary = row[3]
      print "empName=%s,empId=%s,Designation=%s,Salary=%s" %(emp_name,emp_id,designation,salary)
except:
      print "Error in Fetching data from MySQL"
      
db.close()      
