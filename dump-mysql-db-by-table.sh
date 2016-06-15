#!/bin/bash

#	dump mMySQL database storing one SQL file per table

# 	* script will prompt for password for db access
#  	* output files are compressed and saved in "./db-dump/", unless DIR is specified on command-line.

clear
echo

[ $# -lt 2 ] && echo 'Usage: $(basename $0) <DB_USER> <DB_NAME> [<DOUT>] [<DB_HOST>]\n' && exit 1

db_user=$1
db_name=$2
dir_out=$3
db_host=$4

[ -n "$dir_out" ] || dir_out='./db-dump'
[ -n "$db_host" ] || db_host='localhost'

dir_out=$dir_out/$db_name
test -d $dir_out || mkdir -p $dir_out

echo 'Dumping tables into separate SQL command files for database '$db_name' into directory '$dir_out' \n'

echo -n "Enter password: "
stty -echo
read db_pass
stty echo
echo ''

(
	tbl_cont=0

	for t in $(mysql -NBA -h $db_host -u $db_user -p$db_pass $db_name -e 'SHOW TABLES') 
		do 
			echo "DUMPING TABLE: $t"
			mysqldump -h $db_host -u $db_user -p$db_pass $db_name $t | gzip > $dir_out/$t.sql.gz
			tbl_cont=$((tbl_cont+1))
		done

	echo
	echo $tbl_cont 'tables dumped from database '$db_name' into directory '$d_out '\n'

) > log-$db_name-dump.log &