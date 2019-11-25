#!/bin/bash
for i in {1..10}
do
    curl -o test.txt --http3 http://http3-test.litespeedtech.com:4433/ 2>&1 | tee "http3_${i}.log"
    rm test.txt
done

for j in {1..10}
do
    curl -o test.txt --http2 http://http3-test.litespeedtech.com:4433/ 2>&1 | tee "http3_${j}.log"
    rm test.txt
done