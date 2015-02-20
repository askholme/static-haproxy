Travis: [![Build Status](https://travis-ci.org/askholme/static-haproxy.svg?branch=master)](https://travis-ci.org/askholme/static-haproxy) 
Bintray: [![Download](https://api.bintray.com/packages/askholme/static-software/haproxy/images/download.svg) ](https://bintray.com/askholme/static-software/haproxy/_latestVersion)
# Compile a statically linked haproxy

Scripts for compiling a production ready statically linked haproxy
The resulting binaries are available on bintray and are perfect for inclusion to a small (eg. busybox based) docker container.
The container should contain glibc, so consider using the busybox
version from progrium
