#!/bin/bash
rm cc_logs/1http3_vs_3http2.log
echo "beginning tests!"

# 1 http3 vs 3 http2 connections
cat http2_links.txt | parallel -j 3 curl --http2 {} &
curl -o test.txt --http3 https://http3-test.litespeedtech.com:4433/10000000 2>&1 | tee "cc_logs/1http3_vs_3http2.log" &
wait

echo "********* Test 2 done! **********"
