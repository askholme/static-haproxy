USE_STATIC_PCRE=1
TARGET=linux2628
HAPROXY_VERSION="${HAPROXY_MAJOR_VERSION}.${HAPROXY_MINOR_VERSION}"
PCRE_TARBALL="pcre-${PCRE_VERSION}.tar.gz"
OPENSSL_TARBALL="openssl-${OPENSSL_VERSION}.tar.gz"
ZLIB_TARBALL="zlib-${ZLIB_VERSION}.tar.gz"
HAPROXY_TARBALL="haproxy-${HAPROXY_VERSION}.tar.gz"
#rm -rf haproxy*
#rm -rf pcre*
#rm -rf openssl*
#rm -rf zlib*
#if [[ -d "haproxy" ]]; then
#  rm -rf haproxy
#fi
CWD=$(pwd)
DATE=`date +"%Y-%m-%d %H:%M:%S"`
touch .timestamp
if [[ ! -d "${PCRE_TARBALL%.tar.gz}" ]]; then
  wget "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE_TARBALL}"
  tar --no-same-owner --mtime=.timestamp -xvzf "${PCRE_TARBALL}" && rm -f "${PCRE_TARBALL}"
  find "${PCRE_TARBALL%.tar.gz}" -print0 |xargs -0 touch --date="$DATE"
fi
 
if [[ ! -d "${OPENSSL_TARBALL%.tar.gz}" ]]; then
  wget "http://www.openssl.org/source/${OPENSSL_TARBALL}"
  tar --no-same-owner --mtime=.timestamp -xvzf "${OPENSSL_TARBALL}" && rm -f "${OPENSSL_TARBALL}"
  find "${OPENSSL_TARBALL%.tar.gz}" -print0 |xargs -0 touch --date="$DATE"
fi
 
if [[ ! -d "${ZLIB_TARBALL%.tar.gz}" ]]; then
  wget "http://zlib.net/${ZLIB_TARBALL}"
  tar --no-same-owner --mtime=.timestamp -xvzf "${ZLIB_TARBALL}" && rm -rf "${ZLIB_TARBALL}"
  find "${ZLIB_TARBALL%.tar.gz}" -print0 |xargs -0 touch --date="$DATE"
fi
if [[ ! -d "${HAPROXY_TARBALL%.tar.gz}" ]]; then
  wget "http://www.haproxy.org/download/${HAPROXY_MAJOR_VERSION}/src/${HAPROXY_TARBALL}"
  tar --no-same-owner --mtime=.timestamp -zxvf "${HAPROXY_TARBALL}" && rm -rf "${HAPROXY_TARBALL}"
  find "${HAPROXY_TARBALL%.tar.gz}" -print0 |xargs -0 touch --date="$DATE"
fi
cd $CWD/openssl-${OPENSSL_VERSION}
SSLDIR=$CWD/opensslbin
mkdir -p $SSLDIR
./config --prefix=$SSLDIR no-shared no-ssl2
make && make install_sw
PCREDIR=$CWD/pcrebin
mkdir -p $PCREDIR
cd $CWD/pcre-${PCRE_VERSION}
CFLAGS='-O2 -Wall' ./configure --prefix=$PCREDIR --disable-shared
make && make install
ZLIBDIR=$CWD/zlibbin
mkdir -p $ZLIBDIR
cd $CWD/zlib-${ZLIB_VERSION}
./configure --static --prefix=$ZLIBDIR
make && make install
# patch makefile to allow ZLIBPATHS
mkdir -p $CWD/bin
cd $CWD/haproxy-${HAPROXY_VERSION}
patch -p0 Makefile < $CWD/haproxy_makefile.patch
sed -s 's#PREFIX = /usr/local#PREFIX = $CWD/bin#g'
make TARGET=linux2628 USE_STATIC_PCRE=1 USE_ZLIB=1 USE_OPENSSL=1 ZLIB_LIB=$ZLIBDIR/lib ZLIB_INC=$ZLIBDIR/include SSL_INC=$SSLDIR/include SSL_LIB=$SSLDIR/lib ADDLIB=-ldl -lzlib PCREDIR=$PCREDIR 
make install
cd $CWD/bin
cp $CWD/zlib-${ZLIB_VERSION}/README .
cp $CWD/openssl-${OPENSSL_VERSION}/LICENSE
cp $CWD/pcre-${PCRE_VERSION}/LICENCE .
cp $CWD/haproxy-${HAPROXY_VERSION}/LICENSE .
cat << EOF > README
Statically linked haproxy for production use.
Linked against
   Zlib ${ZLIB_VERSION}
   OpenSSL ${OPENSSL_VERSION}
   Pcre ${PCRE_VERSION}
See http://github.com/askholme/static-haproxy for more info
EOF
tar czf $TRAVIS_BUILD_DIR/haproxy.tar.gz .
