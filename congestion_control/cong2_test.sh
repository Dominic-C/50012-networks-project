#!/bin/bash
echo "beginning tests!"

cat http2_2links.txt | parallel -j 2 curl --http2 {} &
curl -o test.txt --http2 https://http3-test.litespeedtech.com:443/10000000 &
curl -o test.txt --http2 https://http3-test.litespeedtech.com:443/10000000 2>&1 | tee "cc_logs/2http3_vs_2http2_quic.log" &
wait

echo "********* Test 2 done! **********"
