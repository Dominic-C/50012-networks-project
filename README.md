# QUIC vs TCP
This repository contains the steps we took to test the performance of QUIC versus TCP. To begin, we'll explain our methodology.

# Tests
These are the tests we conducted to compare the performance of QUIC vs TCP.
## Handshake Test
For this test, we used the script `handshake_testing/test_handshake.sh`. This script downloads a small file (<1kB) 100 times for http/2 and http/3 from the litespeed server. The script generates the output in the terminal of the averages of the 100 tests for both http/2 and http/3

## Bandwidth Test
For this test, we used the script `bandwidth_testing/start_download.sh`. This script downloads a 10MB file from a litespeed server 10 times with http/2 and 10 times with http/3. The script generates log files for each download.

The script generates the logs for this test in `bandwidth_testing/http2_logs` and `bandwidth_testing/http3_logs` respectively

We then analyze the log files, conduct our analysis and plot graphs in `bandwidth_testing/bandwidth testing.ipynb`

## Congestion Control Test
For this test, we used the scripts `cc_test1.sh` to `cc_test4.sh` under the `congestion_control` folder. These sripts run the following tests:
* run 3 TCP sessions while logging 1 QUIC session in parallel
* run 3 TCP sessions while logging 1 TCP session in parallel
* run 3 QUIC sessions while logging 1 QUIC session in parallel
* run 3 QUIC sessions while logging 1 TCP session in parallel

We also ran the script `temp` to conduct the following tests:
* run 2 TCP and 2 QUIC sessions while logging 1 QUIC session in parallel
* run 2 TCP and 2 QUIC sessions while logging 1 TCP session in parallel

The scripts above generate the logs found in `congestion_control/cc_logs`

The results for our analysis can be found in `congestion_control/cc_logs/.ipynb_checkpoints/plotted-checkpoint.ipynb`

# Commands used for testing
* to download 1 file and log the progress: `curl -o test.iso https://storage.googleapis.com/50012-networks-bucket/ubuntu-18.04.iso 2>&1 | tee test.log`
    * log file will be processed in python and can be used to generate graphs

* to download multiple files in parallel: `cat links.txt | parallel -j 3 curl --http3 {}` where `links.txt` is a list of urls each on a new line
    * requires `sudo apt-get install parallel`
* Should you encounter the error ```curl failed to write to body(xxx)```, use curl command as posted above, pipe output to tac twice as tac reverses the output, before piping it to tee. E.g. `curl -o test.iso https://storage.googleapis.com/50012-networks-bucket/ubuntu-18.04.iso 2>&1 | tac | tac | tee test.log`

* Building curl with http 3 support. Follow instructions on https://github.com/curl/curl/blob/master/docs/HTTP3.md to first build quiche. Before building curl from source, make sure you have pkg-config installed via `sudo apt install pkg-config` .

* Install rust from source: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh` and add `~/.cargo/bin` to the `PATH` before building quiche
```
$ git clone https://github.com/curl/curl
$ cd curl
$ ./buildconf
$ ./configure LDFLAGS="-Wl,-rpath,$PWD/../quiche/target/release" --with-ssl=$PWD/../quiche/deps/boringssl/.openssl --with-quiche=$PWD/../quiche/target/release --disable-libcurl-option --disable-shared
$ make
$ sudo make install
```
* When encountering ```error: linking with cc failed: exit code: 1```, do ```sudo apt install gcc-multilib```
* Building wireshark latest version from source on ubuntu, visit https://kifarunix.com/install-latest-wireshark-on-ubuntu-18-04/

# Bob's great building workshop for Ubuntu 18.04 :))

### Building cURL with http 2 and 3 functionalities from source 
#### http 2
* Ensure you have the latest nghttp2 libraries on your system.

```wget https://github.com/nghttp2/nghttp2/releases/download/v1.40.0/nghttp2-1.40.0.tar.xz``` or 

```curl https://github.com/nghttp2/nghttp2/releases/download/v1.40.0/nghttp2-1.40.0.tar.xz -o```
```
tar -xf nghttp2-1.40.0.tar.xz && cd nghttp2-1.40.0
./configure --prefix=/usr --disable-static --enable-lib-only --docdir=/usr/share/doc/nghttp2-1.40.0
```
--prefix stores the package config files (.pc) in /usr/local/lib (?), --enable-lib-only only builds the package, --disable-static disables static version of libraries.
```
make
sudo make install
```
#### http 3
* Ensure you have the latest quiche installed. ngtcp2 users can go elsewhere (:
   * ```git clone --recursive https://github.com/cloudflare/quiche```
* Ensure you have the latest BoringSSL libraries installed
```
cd quiche/deps/boringssl
mkdir build
cd build
cmake -DCMAKE_POSITION_INDEPENDENT_CODE=on ..
make
cd ..
mkdir -p .openssl/lib
cp build/crypto/libcrypto.a build/ssl/libssl.a .openssl/lib
ln -s $PWD/include .openssl
```
* Ensure you have the latest version of rust installed and your path configured to the binary of cargo. Dont trust the one you have so do ```sudo apt purge rust``` first (:
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
PATH=$PATH:$PWD/.cargo/bin
```
* Build quiche
```
cd /path/to/quiche
QUICHE_BSSL_PATH=$PWD/deps/boringssl cargo build --release --features pkg-config-meta
```

#### Build cURL
* Clone and build curl
   * Ensure you have autoconf and pkg-config installed ```sudo apt install autoconf -y && sudo apt install pkg-config -y``` 
```
cd /path/to/curl
./buildconf
./configure LDFLAGS="-Wl,-rpath,$PWD/../quiche/target/release" --with-ssl=$PWD/../quiche/deps/boringssl/.openssl --with-quiche=$PWD/../quiche/target/release --with-nghttp2 --disable-shared --disable-libcurl-option
make
sudo make install
```
* Binary is found in /usr/local/bin folder
#### Potential errors
* ```error: linking with cc failed: exit code: 1```, do ```sudo apt install gcc-multilib```
* ```libtoolize not found```, do ```sudo apt install libtool```

### Building latest wireshark from source
* Install the required packages
```
apt install qttools5-dev qttools5-dev-tools libqt5svg5-dev qtmultimedia5-dev build-essential automake autoconf libgtk2.0-dev libglib2.0-dev flex bison libpcap-dev libgcrypt20-dev cmake -y
```

* Get wireshark source code
```wget https://1.eu.dl.wireshark.org/src/wireshark-3.0.6.tar.xz -P /tmp```

* Install wireshark
```
cd /tmp
tar -xf wireshark-3.0.6.tar.xz
mkdir build && cd build
cmake /tmp/wireshark-3.0.6
make
sudo make install
```
Hope you enjoyed building your binaries as much as I didn't (:

P.S. If you encountered any other problem, it's probably something I didnt face even though I built my libraries on a fresh Ubuntu 18.04 image
