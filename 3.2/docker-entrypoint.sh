#!/bin/sh

export APORT_GIT=${APORT_REPO:-"git@github.com:alpine-library/alpinelib-aports.git"}
export APORT_BRANCH=${APORT_BRANCH:-master}
export APORT_REPOS=${APORT_REPOS:-"main"}
export APORT_DIR=${APORT_DIR:-/repo/$ALPINE_VERSION}

export APK_GIT=${APK_REPO:-"git@github.com:alpine-library/repo.git"}
export APK_BRANCH=${APK_BRANCH:-gh-pages}
export APK_DIR=${APK_DIR:-/repo/packages}

export ABUILD_SSHKEY_NAME=${ABUILD_SSHKEY_NAME:-/repo/alpine-library.github.io-5629488a.rsa}
export GIT_NAME=${GIT_NAME:-bot}
export GIT_EMAIL=${GIT_EMAIL:-bot@3ko.fr}
export GIT_SSHKEY_NAME=${ABUILD_SSHKEY_NAME:-/repo/alpine-library.github.io-5629488a.rsa}

default_colors() {
        NORMAL="\033[1;0m"
        STRONG="\033[1;1m"
        RED="\033[1;31m"
        GREEN="\033[1;32m"
        YELLOW="\033[1;33m"
        BLUE="\033[1;34m"
}

default_colors


msg() {
	local prompt="$GREEN>>>${NORMAL}"
        [ -z "$quiet" ] && printf "${prompt} $@\n" >&2
}

info() {
	local prompt="$YELLOW>>>${NORMAL}"
        [ -z "$quiet" ] && printf "${prompt} $@\n" >&2
}

error() {
	local prompt="$RED>>>${NORMAL}"
        printf "${prompt} $@\n" >&2
}

build_setup() {
  if [ -z "$ABUILD_SSHKEY" ]; then
  	set -- echo "error SET \$ABUILD_SSHKEY ENV"
  	exit
  else
  		echo "$ABUILD_SSHKEY" > $ABUILD_SSHKEY_NAME
  		export ABUILD_SSHKEY="***"
  	  chown abuild:abuild $ABUILD_SSHKEY_NAME
  		chmod 600 $ABUILD_SSHKEY_NAME
  		sudo sh -c "cat /etc/abuild.conf.orig > /etc/abuild.conf"
  		sudo sh -c "echo PACKAGER_PRIVKEY='${ABUILD_SSHKEY_NAME}'" >> /etc/abuild.conf
  fi

  if [ "$ALPINE_VERSION" = "edge" ]; then
    export APORT_BRANCH="master"
  else
    export APORT_BRANCH=$ALPINE_VERSION"-stable"
  fi

  msg "Update to the last apkindex"
  sudo apk update > /dev/null
  msg "${APORT_GIT} (${APORT_BRANCH})"
  export GIT_SSH_COMMAND="ssh -i ${GIT_SSHKEY_NAME} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  git clone --depth 1 --branch $APORT_BRANCH $APORT_GIT $APORT_DIR > /dev/null
  msg "${APK_GIT}"
  git clone --depth 1 --branch $APK_BRANCH $APK_GIT $APK_DIR > /dev/null

  sudo chown -R abuild:abuild /repo

	msg "Ready to Build!"
}

build_repo() {
  local sourcepath=$1
  local buildpath=$2
  local buildver=$3
  local buildarch=$4

  info "Building $sourcepath"
  for package in $1/*/APKBUILD; do
     build_package $package
  done
  build_indexandsign
}

build_package() {
  local apkbuild="$1"
	msg "Invoking abuild for ${apkbuild}..."
  cd $(dirname $apkbuild)
	gosu abuild abuild -c -r -P $APK_DIR
}

build_indexandsign() {
    msg "Indexing $APK_DIR/$ALPINE_VERSION/x86_64"
    apk index -o $buildpath/APKINDEX.tar.gz $APK_DIR/$ALPINE_VERSION/x86_64/*.apk
    msg "Singing $APK_DIR/$ALPINE_VERSION/x86_64"
    abuild-sign -k $ABUILD_SSHKEY_NAME $APK_DIR/$ALPINE_VERSION/x86_64/APKINDEX.tar.gz
}

build_deploy() {
    msg "Deploy to $APK_REPO"
    cd $APORT_DIR
    version=$(git describe --always)
    echo "Version : $version"
    cd $APK_DIR
    git config user.name $GIT_NAME
    git config user.email $GIT_EMAIL
    git add --all
    git commit -m "bot build aport(${version})"
    git push origin $APK_BRANCH
}


usage() {
	echo " "
	echo "Commands:"
	echo " "
	echo " build -- build the repo"
	echo " "
}

if [ "$1" = 'build' ]; then
  build_setup
	build_repo "$APORT_DIR" "$APK_DIR" "$ALPINE_VERSION" "$(abuild -A)"
  if [ "$DEPLOY" = "true" ]; then
    build_deploy
  fi
else
	usage
fi
