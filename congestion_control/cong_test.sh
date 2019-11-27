#!/bin/bash
echo "beginning tests!"

cat http3_2links.txt | parallel -j 2 curl --http3 {} &
curl -o test.txt --http3 https://http3-test.litespeedtech.com:4433/10000000 &
curl -o test.txt --http3 https://http3-test.litespeedtech.com:4433/10000000 2>&1 | tee "cc_logs/2http3_vs_2http2_quic.log" &
wait

echo "********* Test 2 done! **********"
