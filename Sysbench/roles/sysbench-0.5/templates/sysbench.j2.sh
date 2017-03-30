#!/usr/bin/env bash

if [ -z $1 ]; then
    echo "Usage: ./sysbench.sh <bench|prepare>"
    exit 1
fi

test_system=performance_test
mysql_host="{{ mysql_host }}"
mysql_user="{{ mysql_user }}"
mysql_password="{{ mysql_pass }}"
result_path="{{ result_path }}"
oltp_tables_count="{{ oltp_tables_count }}"
oltp_table_size="{{ oltp_table_size }}"
num_threads="{{ num_threads }}"
max_time="{{ max_time }}"

echo "target is ${mysql_host}"

set -x
if [ $1 = "bench" ]; then
    # Benchmark
    echo "Start Benchmark..."
    for threads in 1 2 4 8 16 32; do
        /usr/local/src/sysbench/sysbench \
        --mysql-host=${mysql_host} --mysql-user=${mysql_user} --mysql-password=${mysql_password}  \
        --mysql-db="sbtest" \
        --db-ps-mode=disable \
        --rand-init=on \
        --test=sysbench/tests/db/oltp.lua \
        --oltp-read-only=off \
        --oltp_tables_count=${oltp_tables_count} --oltp_table-size=${oltp_table_size} \
        --oltp-dist-type=uniform \
        --percentile=99 \
        --report-interval=1 \
        --max-requests=0 \
        --max-time=${max_time} \
        --num-threads=${threads} \
        run;
    done | tee ${result_path}.out

    # Format
    grep "^\[" ${result_path}.out \
        | cut -d] -f2 \
        | sed -e 's/[a-z]*://g' \
            -e 's/ms//' \
            -e 's/(99%)//' \
            -e 's/[ ]//g' \
            -e 's/response//g' > ${result_path}.csv
elif [ $1 = "prepare" ]; then
    # Prepare
    echo "Start Preparing..."
    /usr/local/src/sysbench/sysbench \
	--mysql-host=${mysql_host} --mysql-user=${mysql_user} --mysql-password=${mysql_password} \
	--mysql-db="sbtest" \
	--test=sysbench/tests/db/parallel_prepare.lua \
	--oltp_tables_count=${oltp_tables_count} --oltp-table-size=${oltp_table_size} \
	--rand-init=on \
	--num-threads=${num_threads} \
	run
fi

