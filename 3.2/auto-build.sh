#!/bin/sh

echo -----
echo "Setup ABUILD"
echo -----
echo "Update to the last apkindex"
echo "${APORT_REPO} (${APORT_BRANCH})"
export GIT_SSH_COMMAND='ssh -i ${GIT_SSHKEY_NAME} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
git clone --depth 1 --branch $APORT_BRANCH $APORT_REPO $APORT_DIR  > /dev/null
echo "${APK_REPO}"
git clone --depth 1 --branch $APK_BRANCH $APK_REPO $APK_DIR > /dev/null

echo -----
echo "Start BUILDREPO"
echo -----

mkdir -p $APK_DIR/$ALPINE_VERSION
buildrepo -k -a $APORT_DIR -d $APK_DIR/$ALPINE_VERSION "$1"
ls -Rla $APK_DIR/$ALPINE_VERSION

echo "-----"
if [ "$DEPLOY" = "true" ]; then
  echo "Deploy to $APK_REPO"
  cd $APORT_DIR
  version=$(git describe --always)
  echo "Version : $version"
  cd $APK_DIR
  git config user.name $GIT_NAME
  git config user.email $GIT_EMAIL
  git add --all
  git commit -m "bot build aport(${version})"
  git push origin $APK_BRANCH
fi
