#!/usr/bin/env bash
echo "We are cygwin! Installing apt-cyg..."
wget -P ~/bin http://apt-cyg.googlecode.com/svn/trunk/apt-cyg ## need the new version
chmod +x ~/bin/apt-cyg

# install procps-ng

curl --fail --silent --show-error --location --output /dev/stdout \
      https://github.com/imachug/win-sudo/archive/master.tar.gz | \
  tar --file /dev/stdin \
      --extract \
      --verbose \
      --gzip \
      --strip-components 2 \
      --directory "$HOME/bin" \
      --exclude path.sh \
      --exclude aliases \
      --wildcards \
      '*/s'

echo "Cygwin implementation not finalised"
exit 1;
