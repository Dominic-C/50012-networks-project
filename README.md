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
* Should you encounter the error ```curl failed to write to body(xxx)```, use curl command as posted above, pipe output to tac twice as tac reverses the output, before piping it to tee. E.g. `curl -o test.iso https://storage.googleapis.com/50012-networks-bucket/ubuntu-18.04.iso 2>&1 | tac | tac | tee test.log`

* Building curl with http 3 support. Follow instructions on https://github.com/curl/curl/blob/master/docs/HTTP3.md to first build quiche. Before building curl from source, make sure you have pkg-config installed via `sudo apt install pkg-config` .
```
$ ./buildconf
$ ./configure LDFLAGS="-Wl,-rpath,$PWD/../quiche/target/release" --with-ssl=$PWD/../quiche/deps/boringssl/.openssl --with-quiche=$PWD/../quiche/target/release --disable-libcurl-option --disable-shared
$ make
$ sudo make install
```
* When encountering ```error: linking with cc failed: exit code: 1```, do ```sudo apt install gcc-multilib```
* Building wireshark latest version from source on ubuntu, visit https://kifarunix.com/install-latest-wireshark-on-ubuntu-18-04/
