
本文介绍mysqldiff工具来比较数据表结构，并生成差异SQL语句。
mysqldiff类似Linux下的diff命令，用来比较对象的定义是否相同，并显示不同的地方。
如果要比较数据库是否一致，可以用另外一个工具：mysqldbcompare。
以下是mysqldiff的用法。
## 安装mysql-utilities-1.6.5
### 安装步骤
```
>cd /download
>wget https://cdn.mysql.com/archives/mysql-utilities/mysql-utilities-1.6.5.tar.gz
>tar xvf mysql-utilities-1.6.5.tar.gz
>cd mysql-utilities-1.6.5
>python setup.py build
>python setup.py install
>mysqldiff --version
```
## mysqldiff命令
mysqldiff的语法格式是：
```
>mysqldiff --server1=user:pass@host:port:socket --server2=user:pass@host:port:socket db1.object1:db2.object1 db3:db4
```
这个语法有两个用法：

- db1:db2：如果只指定数据库，那么就将两个数据库中互相缺少的对象显示出来，不比较对象里面的差异。这里的对象包括表、存储过程、函数、触发器等。
- db1.object1:db2.object1：如果指定了具体表对象，那么就会详细对比两个表的差异，包括表名、字段名、备注、索引、大小写等所有的表相关的对象。
接下来看一些主要的参数：

- --server1：配置server1的连接。
- --server2：配置server2的连接。
- --character-set：配置连接时用的字符集，如果不显示配置默认使用character_set_client。
- --width：配置显示的宽度。
- --skip-table-options：保持表的选项不变，即对比的差异里面不包括表名、AUTO_INCREMENT、ENGINE、CHARSET等差异。
- --difftype=DIFFTYPE：差异的信息显示的方式，有[unified|context|differ|sql]，默认是unified。如果使用sql，那么就直接生成差异的SQL，这样非常方便。
- --changes-for=：修改对象。例如--changes-for=server2，那么对比以sever1为主，生成的差异的修改也是针对server2的对象的修改。
- --show-reverse：在生成的差异修改里面，同时会包含server2和server1的修改。

## 举例
 1. 准备工作,在两个不同数据库创建表。
```
use db1;
 
create table test1(
    id int not null primary key,
    a varchar(10) not null,
    b varchar(10),
    c varchar(10) comment 'c',
    d int
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='test1';
 
use db2;
create table test2(
    id int not null,
    a varchar(10),
    b varchar(5),
    c varchar(10),
    D int
)ENGINE=myisam DEFAULT CHARSET=utf8 COMMENT='test2';
```
 2. 执行mysqldiff
```
>mysqldiff --server1=root:123456@127.0.0.1 --server2=root:123456@127.0.0.1 --difftype=sql test.test1:test.test2 >update.sql
>vim update.sql
```
>  \# WARNING: Using a password on the command line interface can be insecure.
> \# server1 on 127.0.0.1: ... connected.
> \# server2 on 127.0.0.1: ... connected.
> \# Comparing adott_sandbox.test1 to adott_sandbox.test2             [FAIL]
> \# Transformation for --changes-for=server1:
> \#
> 
> ALTER TABLE `adott_sandbox`.`test1` 
>   DROP PRIMARY KEY, 
>   DROP COLUMN d, 
>   CHANGE COLUMN b b varchar(5) NULL, 
>   ADD COLUMN D int(11) NULL AFTER c, 
>   CHANGE COLUMN a a varchar(10) NULL, 
>   CHANGE COLUMN c c varchar(10) NULL, 
> RENAME TO adott_sandbox.test2 
> , COMMENT='test2';
> 
> \# Compare failed. One or more differences found.


## 如何对比整个数据库
 对比整个数据库提供了2个方法，第一个大家自己尝试。本文主要介绍shell+mysqdiff方案。
 1. mysqldbcompare用于比较两个服务器或同个服务器上的数据库，有文件和数据，并生成差异性SQL语句。
 2.编写shell脚本，利用mysqldiff对比。
 > #!/bin/sh
> FROM_HOST=127.0.0.1
> FROM_USER=root
> FROM_PASS=123456
> FROM_DATABASE=test
> 
> TO_HOST=127.0.0.1
> TO_USER=root
> TO_PASS=123456
> TO_DATABASE=test
> 
> #-s 去掉表头
> MYSQL_ETL="mysql -h $FROM_HOST -P3306 -D$FROM_DATABASE -u$FROM_USER -p$FROM_PASS -s -e"
> table_sql="select table_name from information_schema.tables where table_schema ='$FROM_DATABASE'"
> 
> hive_table=$($MYSQL_ETL "${table_sql}")
> 
> echo $hive_table
> for table in $hive_table
> do
> echo $table
> mysqldiff --server1=$FROM_USER:$FROM_PASS@$FROM_HOST --server2=$TO_USER:$TO_PASS@$TO_HOST --difftype=sql $FROM_DATABASE.$table:$TO_DATABASE.$table >> update.sql
> done

 3.执行脚本，查看结果