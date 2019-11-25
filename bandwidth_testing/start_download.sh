#!/bin/bash
rm -rf http3_logs
rm -rf http2_logs

mkdir http3_logs
for i in {1..10}
do
    curl -o test.txt --http3 https://http3-test.litespeedtech.com:4433/10000000 2>&1 | tee "http3_logs/http3_${i}.log"
done

mkdir http2_logs
for j in {1..10}
do
    curl -o test.txt --http2 https://http3-test.litespeedtech.com:443/10000000 2>&1 | tee "http2_logs/http2_${j}.log"
done