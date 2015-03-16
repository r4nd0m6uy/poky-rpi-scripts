#!/bin/sh
# Helper script to build an image for the raspberry PI
# Copyright (C) 2015 Guy Morand
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Stops on error
set -e

################################################################################
# Variables
source ./meta_layers
PROJECT_BASE=$(pwd)
POKY_BASE=${PROJECT_BASE}/poky

################################################################################
# Shows this script usage
usage()
{
  echo "${0} [ -h | -u | -b ]"
  echo "-h    Shows this help"
  echo "-u    Update meta-layers repositories"
  echo "-i    Init poky environment"
  echo "-b    Build an image"
}

################################################################################
# Clone required repository and check out the right version
update_meta_layers()
{
  echo "Updating meta-layers ..."
  cd ${PROJECT_BASE}

  # Poky meta-layer
  [ ! -d poky ] && git clone ${META_POKY_URL}
  cd ${POKY_BASE}
  git checkout ${META_POKY_VERSION}

  # openembedded meta-layer
  cd ${POKY_BASE}
  [ ! -d meta-openembedded ] && git clone ${META_OE_URL}
  cd meta-openembedded
  git checkout ${META_OE_VERSION}

  # Raspberry pi meta-layer
  cd ${POKY_BASE}
  [ ! -d meta-raspberrypi ] && git clone ${META_RASPBERRY_URL}
  cd meta-raspberrypi
  git checkout ${META_RASPBERRY_VERSION}

  # Random Guy's Raspberry PI meta-layer
  cd ${POKY_BASE}
  [ ! -d meta-random-guy-rpi ] && git clone ${META_RANDOM_GUY_RPI_URL}
  cd meta-random-guy-rpi
  git checkout ${META_RANDOM_GUY_RPI_VERSION}

  echo "meta-layers up to date!"
}

################################################################################
# Initialize poky environment
init_poky_env()
{
  # Make sure update was called ...
  [ ! -d ${POKY_BASE} ] && update_meta_layers

  # Remove existing configuration if exists and user want to
  echo "Initializing poky environement ..."
  cd ${POKY_BASE}
  if [ -d build ]
  then
    echo -n "A poky environement already exists, would you like to remove it "
    echo "and restart again? [y/N]"

    read REMOVE_ENV
    REMOVE_ENV=$(echo $REMOVE_ENV | head -c1)
    if [ ${REMOVE_ENV} = "y" -o ${REMOVE_ENV} = "Y" ]
    then
      rm -rf build/conf
    else
      return
    fi
  fi

  # Initialize the environment
  export TEMPLATECONF="meta-random-guy-rpi/conf"
  source ./oe-init-build-env > /dev/null

  echo "Your poky environment is ready!"
}

################################################################################
# Build an image
build_image()
{
  # Make sure we have an environement ready
  cd ${PROJECT_BASE}
  [ ! -d ${POKY_BASE}/build/conf ] && init_poky_env

  # Start the build
  cd ${POKY_BASE}

  source ./oe-init-build-env > /dev/null
  bitbake rpi-random-guy-image
}

################################################################################
# Main script
while getopts "huib" FLAG; do
  case $FLAG in
    h)
      usage
      exit 0
      ;;
    u)
      update_meta_layers
      exit 0
      ;;
    i)
      init_poky_env
      exit 0
      ;;
    b)
      build_image
      exit 0
      ;;
    \?)
      usage
      exit 1
      ;;
  esac
done

# Default behavior, build an image
build_image
