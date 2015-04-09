# Run this in a path you don't care about, things may get deleted!
VERSION="0.9.12"
BUILD="betable3"

set -e -x
ORIGPWD="$(pwd)"
TMP="$(mktemp -d)"
cd $TMP
trap "rm -rf \"$TMP\"" EXIT INT QUIT TERM

git clone --depth 1 git@github.com:graphite-project/graphite-web.git
cd graphite-web
git checkout "tags/$VERSION"

# Apply patches
patch -p1 < "$ORIGPWD/patches/graphite-syslogger.patch"
patch -p1 < "$ORIGPWD/patches/safe-unpickle.patch"

# Stupid hack for new django
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/render/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/metrics/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/dashboard/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/cli/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/version/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/browser/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/account/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/graphlot/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/composer/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/whitelist/urls.py
sed -i.bak "s/from django\.conf\.urls\.defaults import \*/from django.conf.urls import patterns, url, include/g" webapp/graphite/events/urls.py
python setup.py install --install-data $TMP/prepare/var/lib/graphite --install-lib $TMP/prepare/opt/graphite/webapp --prefix $TMP/prepare/opt/graphite
cd ../prepare

rm -f "$ORIGPWD/graphite-web_${VERSION}-${BUILD}_amd64.deb"

fakeroot fpm -m "Nate Brown <nate@betable.com>" \
             -n "graphite-web" -v "$VERSION-$BUILD" \
             -p "$ORIGPWD/graphite-web_${VERSION}-${BUILD}_amd64.deb" \
             -d "whisper = 0.9.12" -d "carbon = 0.9.12" \
             -s "dir" -t "deb" "."
