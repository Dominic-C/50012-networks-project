# QUIC vs TCP
This repository contains the steps we took to test the performance of QUIC versus TCP. To begin, we'll explain our methodology.

## Methodology
Our initial plan was to launch a chromium server and try to server files off of it. However, due to technical challenges such as incomplete binaries, we were unable to build the chromium server.

The alternative solution was to upload a file into a server owned by google, then try to download it using http/3 (built on QUIC) and http/2 (built on TCP).

Luckily for us, the latest version of curl at the time of writing, v7.67 had support for http/3. However, it was not available on the linux repositories. Thus we had to build it from source code which was quite challenging.

After building curl v7.67, we uploaded files into Google Cloud Storage (GCS) buckets and make the contents publicly accessible.

## Testing
We used two setups for our testing

### Setup 1
Amazon EC2 Free tier
* Throughput: ~70Mbits

### Setup 2
Virutal Machine
* Throughput: varies

## commands used for testing
* to download 1 file and log the progress: `curl -o test.iso https://storage.googleapis.com/50012-networks-bucket/ubuntu-18.04.iso 2>&1 | tee test.log`
    * log file will be processed in python and can be used to generate graphs

* to download multiple files in parallel: `cat links.txt | parallel -j 3 curl --http3 {}` where `links.txt` is a list of urls each on a new line
    * requires `sudo apt-get install parallel`

