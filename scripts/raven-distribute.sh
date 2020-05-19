#!/bin/bash
set -e

#===============================================================================
# This script handles the ad hoc distribution of feature branches. It takes 4
# arguments, generating a plist and copying the plist ipa to the Apache doc root
#
# ./raven-distribute.sh /path/to/ipa <version> <build> <feature name>
#
# ./raven-distribute.sh ./TravelBank.ipa 4.3.0 1 proj-op-500
#===============================================================================

TARGET="build.vpc.travelbank.com"
BUILD_SERVER_ROOT="/home/admin/builds"
PROJECT="TravelBank"
FILE=$1
VERSION=$2
BUILD=$3
BRANCH_NAME=${BRANCH_NAME:-$4}
FEATURE=${BRANCH_NAME/\//-}
FEATURE_DIRECTORY="$BUILD_SERVER_ROOT/$FEATURE"
PLATFORM_DIRECTORY="$FEATURE_DIRECTORY/ios"
BUILD_TIME=`stat --format "%x" $1`
SECURE_TARGET="https://${TARGET}"

echo $BRANCH_NAME
echo $FEATURE

echo "Generating ${PROJECT}-${VERSION}-${BUILD}.plist"
cat > ${PLATFORM_DIRECTORY}/${PROJECT}-${VERSION}-${BUILD}.plist <<PLIST_DELIM
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>items</key>
 <array>

  <dict>
   <key>assets</key>
   <array>
    <dict>
     <key>kind</key>
     <string>software-package</string>
     <key>url</key>
     <string>${SECURE_TARGET}/${FEATURE}/ios/${PROJECT}.ipa</string>
    </dict>
   </array>

   <key>metadata</key>
   <dict>
    <key>bundle-identifier</key>
    <string>com.travelbank.app.preview</string>
    <key>bundle-version</key>
    <string>${VERSION}</string>
    <key>kind</key>
    <string>software</string>
    <key>subtitle</key>
    <string>${PROJECT}</string>
    <key>title</key>
    <string>${PROJECT}</string>
   </dict>

  </dict>
 </array>
</dict>
</plist>
PLIST_DELIM

echo "Generating index.html"
cat > ${PLATFORM_DIRECTORY}/index.html <<INDEX_DELIM
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <title>${PROJECT} ${FEATURE} ${VERSION} (${BUILD})</title>
    <style type="text/css">
      body {background:#fff;margin:0;padding:0;font-family:arial,helvetica,sans-serif;text-align:center;padding:10px;color:#333;font-size:16px;}
      #container {width:300px;margin:0 auto;}
      h1 {margin:0;padding:0;font-size:14px;}
      p {font-size:13px;}
      .link {background:#ecf5ff;border-top:1px solid #fff;border:1px solid #dfebf8;margin-top:.5em;padding:.3em;}
      .link a {text-decoration:none;font-size:15px;display:block;color:#069;}
      .warning {font-size: 12px; color:#F00; font-weight:bold; margin:10px 0px;}
    </style>
  </head>

  <body>
    <div id="container">
      <h1>iOS 9.0 and newer:</h1>
      <p>${PROJECT} Beta ${VERSION} (${BUILD})</p>
      <p>${FEATURE}</p>
      <p>Built on ${BUILD_TIME}</p>
      <div class="link">
        <a href="itms-services://?action=download-manifest;url=${SECURE_TARGET}/${FEATURE}/ios/${PROJECT}-${VERSION}-${BUILD}.plist">
          Tap to install!
        </a>
      </div>
      <p>
        <strong>Link didn't work?</strong>
        <br />Make sure you're visiting this page on your device, not your computer.
      </p>
    </div>
  </body>
</html>
INDEX_DELIM
