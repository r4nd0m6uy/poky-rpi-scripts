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

################################################################################
# Variables
source ./meta_layers
PROJECT_BASE=$(pwd)
POKY_BASE=${PROJECT_BASE}/poky

################################################################################
# Clone required repository and check out the right version
update_meta_layers()
{
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
}

################################################################################
# Build an image
build_image()
{
  cd ${POKY_BASE}
  [ ! -d build ] && export TEMPLATECONF="meta-random-guy-rpi/conf"
  source ./oe-init-build-env
  bitbake rpi-basic-image
}

################################################################################
# Main script
update_meta_layers
build_image
