#!/bin/sh
FROM_HOST=127.0.0.1
FROM_USER=root
FROM_PASS=123456
FROM_DATABASE=test

TO_HOST=127.0.0.1
TO_USER=root
TO_PASS=123456
TO_DATABASE=test

#-s 去掉表头
MYSQL_ETL="mysql -h $FROM_HOST -P3306 -D$FROM_DATABASE -u$FROM_USER -p$FROM_PASS -s -e"
table_sql="select table_name from information_schema.tables where table_schema ='$FROM_DATABASE'"

hive_table=$($MYSQL_ETL "${table_sql}")

echo $hive_table
for table in $hive_table
do
echo $table
mysqldiff --server1=$FROM_USER:$FROM_PASS@$FROM_HOST --server2=$TO_USER:$TO_PASS@$TO_HOST --difftype=sql $FROM_DATABASE.$table:$TO_DATABASE.$table >> update.sql
done

