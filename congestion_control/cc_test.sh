#!/bin/bash
rm 1_http2_vs_http3.log

# 1 http2 vs 3 http3 connections
cat http3_links.txt | parallel -j 3 curl --http3 {} & # run http3 curls
# run and log 1 http3
curl -o test.txt --http2 https://http3-test.litespeedtech.com:443/10000000 2>&1 | tee "1_http2_vs_http3.log" &
wait

echo "test1 done"
