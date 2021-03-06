#!/bin/bash
# This file is part of the rsyslog project, released under GPLv3
echo ===============================================================================
echo \[mysql-basic.sh\]: basic test for mysql-basic functionality
. $srcdir/diag.sh init
generate_conf
add_conf '
$ModLoad ../plugins/ommysql/.libs/ommysql
if $msg contains "msgnum" then {
	action(type="ommysql" server="127.0.0.1"
	       db="Syslog" uid="rsyslog" pwd="testbench")
}
'
mysql --user=rsyslog --password=testbench < testsuites/mysql-truncate.sql
startup
injectmsg  0 5000
shutdown_when_empty
wait_shutdown 
# note "-s" is requried to suppress the select "field header"
mysql -s --user=rsyslog --password=testbench < testsuites/mysql-select-msg.sql > $RSYSLOG_OUT_LOG
seq_check  0 4999
exit_test
