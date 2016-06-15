#!/bin/bash

#	restore a MySQL database from the SQL files in the input directory

# 	* script will prompt for password for db access
#	* input files are compressed and stored in DIR

clear
echo ''

[ $# -lt 3 ] && echo "Usage: $(basename $0) <DIR> <DB_USER> <DB_NAME> [<DB_HOST>]" && exit 1

dir_in=$1
db_user=$2
db_name=$3
db_host=$4

[ -n "$db_host" ] || db_host='localhost'

tbl_list=$dir_in/*.sql.gz

echo -n "Enter password: "
stty -echo
read db_pass
stty echo
echo ''

echo '\nCreate database "'$db_name'" in "'$db_host'"'
echo ''

mysql -h $db_host -u $db_user -p$db_pass -e 'CREATE DATABASE IF NOT EXISTS '$db_name

echo 'Importing SQL table files found in "'$dir_in'" into "'$db_name'"'
echo ''

(
	tbl_cont=0

	for f in $tbl_list

	do 
   		echo "IMPORTING FILE: $f"

    	gunzip -c $f | mysql -h $db_host -u $db_user -p$db_pass $db_name

   		tbl_cont=$((tbl_cont+1))
	done

	echo ''
	echo $tbl_cont' files importing to database '$db_name
	echo ''

) > log-$db_name-restore.log &



