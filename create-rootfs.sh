#!/bin/bash

set -e

# check for root privileges
if [ "$UID" != "0" ]; then
	echo "You need root privileges to run this"
	exit 1
fi

# argument check
if [ -z $1 ]; then
	echo "You need to provide the arch as an argument." >&2
	echo "Example: $0 x86_64" >&2
	exit 1
fi
if [[ $1 != "x86_64" ]] && [[ $1 != "i486" ]]; then
	echo "arch can only be i486 or x86_64"
	exit 1
fi

ARCH=$1
ROOTFS=rootfs-$ARCH
VERSIONS=docker-$ARCH/PKG_VERSIONS
VERSIONS_TMP=`mktemp`

rm -rf $ROOTFS pkgstore
mkdir $ROOTFS pkgstore docker-$ARCH
slapt-get --config slapt-getrc.$ARCH --update
for pkg in `cat PKG_NAMES | cut -d'#' -f 1`; do
	URI=`slapt-get --config slapt-getrc.$ARCH --install --reinstall --print-uris $pkg | grep "^http://"`
	PKGFILE=`basename $URI`
	echo "Downloading $PKGFILE..."
	[ ! -f pkgstore/$PKGFILE ] && wget -q -P pkgstore $URI
	echo "Installing $PKGFILE..."
	spkg -qq -i --root $ROOTFS pkgstore/$PKGFILE
	echo $PKGFILE >> $VERSIONS_TMP
done
cat > $VERSIONS << EOF
# This package lists the full package names, including version number
# and build number of all packages included in the mini-root fs.
EOF
cat $VERSIONS_TMP | sort | uniq >> $VERSIONS
rm -f $VERSIONS_TMP

# change the obsolete default repo
sed -i "s#salix.hostingxtreme.com#slackware.uk/salix#" $ROOTFS/etc/slapt-get/slapt-getrc
# sed default lang to en_US
sed -i "s/^ *\(export LANG=\).*$/\1en_US.utf8/" $ROOTFS/etc/profile.d/lang.sh

# create the tarball
cd rootfs-$ARCH
tar cv ./ | xz -9 > ../docker-$ARCH/rootfs-$ARCH.tar.xz
cd ..

set +e
