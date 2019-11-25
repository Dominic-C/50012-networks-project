#!/bin/bash
rm cc_logs/1http2_vs_3http2.log
echo "beginning test"

# 1 http2 vs 3 http2 connections
cat http2_links.txt | parallel -j 3 curl --http2 {} &
curl -o test.txt --http2 https://http3-test.litespeedtech.com:443/10000000 2>&1 | tee "cc_logs/1http2_vs_3http2.log" &
wait

echo "********* Test 4 done! **********"
