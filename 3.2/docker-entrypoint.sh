#!/bin/sh
set -e
apk update > /dev/null

export APORT_REPO=${APORT_REPO:-"git@github.com:alpine-library/alpinelib-aports.git"}
export APORT_DIR=${APORT_DIR:-/repo/aports}
export APK_REPO=${APK_REPO:-"git@github.com:alpine-library/repo.git"}
export APK_BRANCH=${APORT_BRANCH:-gh-pages}
export APK_DIR=${APK_DIR:-/repo/packages}
export ABUILD_SSHKEY_NAME=${ABUILD_SSHKEY_NAME:-/alpine-library.github.io-5629488a.rsa}
export GIT_NAME=${GIT_NAME:-bot}
export GIT_EMAIL=${GIT_EMAIL:-bot@3ko.fr}
export GIT_SSHKEY_NAME=${ABUILD_SSHKEY_NAME:-/alpine-library.github.io-5629488a.rsa}



if [ -z "$ABUILD_SSHKEY" ]; then
	set -- echo "error SET \$ABUILD_SSHKEY ENV"
	exit
else
		echo "$ABUILD_SSHKEY" > $ABUILD_SSHKEY_NAME
		export ABUILD_SSHKEY="***"
		chown abuild:abuild $ABUILD_SSHKEY_NAME
		chmod 600 $ABUILD_SSHKEY_NAME
		cat /etc/abuild.conf.orig > /etc/abuild.conf
		echo "PACKAGER_PRIVKEY=\"${ABUILD_SSHKEY_NAME}\"" >> /etc/abuild.conf
fi

if [ "$ALPINE_VERSION" = "edge" ]; then
  export APORT_BRANCH="master"
else
  export APORT_BRANCH=$ALPINE_VERSION"-stable"
fi



if [ "$1" = 'build' ]; then
	chown -R abuild:abuild /repo
	set -- gosu abuild auto-build "$2"
else
	echo "use build ${repo} for autobuild"
	#set -- echo "please use command build ${repo}"
fi

exec "$@"
