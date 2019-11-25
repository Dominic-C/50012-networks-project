#!/bin/bash
echo "Removing old files"
rm -rf cc_logs

echo "beginning tests!"

# 1 http2 vs 3 http3 connections
cat http3_links.txt | parallel -j 3 curl --http3 {} & # run http3 curls
# run and log 1 http2
curl -o test.txt --http2 https://http3-test.litespeedtech.com:443/10000000 2>&1 | tee "cc_logs/1http2_vs_3http3.log" &
wait

echo "********* Test 1 done! **********"

# 1 http3 vs 3 http2 connections
cat http2_links.txt | parallel -j 3 curl --http2 {} &
curl -o test.txt --http3 https://http3-test.litespeedtech.com:4433/10000000 2>&1 | tee "cc_logs/1http3_vs_3http2.log" &
wait

echo "********* Test 2 done! **********"

# 1 http3 vs 3 http3 connections
cat http2_links.txt | parallel -j 3 curl --http3 {} &
curl -o test.txt --http3 https://http3-test.litespeedtech.com:4433/10000000 2>&1 | tee "cc_logs/1http3_vs_3http3.log" &
wait

echo "********* Test 3 done! **********"

# 1 http2 vs 3 http2 connections
cat http2_links.txt | parallel -j 3 curl --http2 {} &
curl -o test.txt --http2 https://http3-test.litespeedtech.com:443/10000000 2>&1 | tee "cc_logs/1http2_vs_3http3.log" &
wait

echo "********* Test 4 done! **********"
