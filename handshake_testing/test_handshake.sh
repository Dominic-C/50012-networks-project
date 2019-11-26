#!/bin/bash
# Tan You 1002690
# for 50.012 networks project
[ $# -le 2 ] && { printf "Usage: $0 no_of_tests http2_site http3_site \nrequires curl version 7.68 or above \n"; exit 1; }
total_time_pretransfer=0
loops=$1
http2_site=$2
http3_site=$3
# test new and reuse connections for tcp/tls and quic
echo "Testing tcp/tls and quic handshake times"

for ((c=1;c<=$loops;c++))
do
	# curl --http2  https://http3-test.litespeedtech.com:443 -o test.txt
	total_time_pretransfer=$(echo "$total_time_pretransfer + $(curl -o /dev/null -sw '%{time_pretransfer}' --http2 $http2_site)" | bc)
done
avg_time_pretransfer=$(echo "scale=5 ; $total_time_pretransfer / $loops" | bc)
echo "Average time for initial tcp/tls handshake over $loops tests is: $avg_time_pretransfer"

curl_cmd="-sw %{time_pretransfer}+"
file_cmd=" -o /dev/null --http2 $http2_site"
for ((c=1;c<=$loops+1;c++))
do
	curl_cmd="$curl_cmd$file_cmd"
done
total_time_pretransfer="$(curl $curl_cmd)0"
total_time_pretransfer=$(echo "${total_time_pretransfer#*+}" | bc)
avg_time_pretransfer=$(echo "scale=5 ; $total_time_pretransfer / $loops" | bc)
echo "Average time for subsequent tcp/tls handshakes over $loops tests is $avg_time_pretransfer"

for ((c=1;c<=$loops;c++))
do
	# curl --http3  https://http3-test.litespeedtech.com:4433 -o test.txt
	total_time_pretransfer=$(echo "$total_time_pretransfer + $(curl -o /dev/null -sw '%{time_pretransfer}' --http3 $http3_site)" | bc)
done
avg_time_pretransfer=$(echo "scale=5 ; $total_time_pretransfer / $loops" | bc)
echo "Average time for initial quic handshake over $loops tests is: $avg_time_pretransfer"

curl_cmd="-sw %{time_pretransfer}+"
file_cmd=" -o /dev/null --http3 $http3_site"
for ((c=1;c<=$loops+1;c++))
do
	curl_cmd="$curl_cmd$file_cmd"
done
total_time_pretransfer="$(curl $curl_cmd)0"
total_time_pretransfer=$(echo "${total_time_pretransfer#*+}" | bc)
avg_time_pretransfer=$(echo "scale=5 ; $total_time_pretransfer / $loops" | bc)
echo "Average time for subsequent quic \"handshake\" over $loops tests is $avg_time_pretransfer"

