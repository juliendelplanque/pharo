#!/usr/bin/env bash

set -ex

# I will use the name of the image to determine the vm version (because file name is in the format Pharo7.0.0-rc1)
#
PHARO_NAME_PREFIX=$(find . -name Pharo*.zip | head -n 1 | cut -d'/' -f 2 | cut -d'-' -f 1-2)
PHARO_SHORT_VERSION=$(echo "${PHARO_NAME_PREFIX}" | cut -d'-' -f 1| cut -c 6- | cut -d'.' -f 1-2 | sed 's/\.//')

destDir="/appli/files.pharo.org/image/${PHARO_SHORT_VERSION}/"
echo "Uploading Images to pharo.files.org/$destDir"
scp -o StrictHostKeyChecking=no -v \
  latest*.zip \
  #{PHARO_NAME_PREFIX}*.zip \
  Pharo-metacello*.zip \
    pharoorgde@ssh.cluster023.hosting.ovh.net:files/image/${PHARO_SHORT_VERSION}/

# this is not being used
#scp -o StrictHostKeyChecking=no -v \
#  #{PHARO_NAME_PREFIX}-bootstrap*.zip \
#  #{PHARO_NAME_PREFIX}-core*.zip \
#  #{PHARO_NAME_PREFIX}-compiler*.zip \
#  #{PHARO_NAME_PREFIX}-monticello*.zip \
#  #{PHARO_NAME_PREFIX}-rpackage*.zip \
#  #{PHARO_NAME_PREFIX}-hermesPackages*.zip \
#    pharoorgde@ssh.cluster023.hosting.ovh.net:files/image/${PHARO_SHORT_VERSION}/bootstrap/
