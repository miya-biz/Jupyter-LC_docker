#!/bin/bash

set -xe

# Download the icons for wrapper-kernels
# The widget of kernels in the JupyterLab will be broken if the icons does not exist
# - logo-32x32.png
# - logo-64x64.png
# - logo-svg.svg

# the path of scripts
BASE_PATH=$(dirname $0)

# For Python3, copy the icons from /opt/conda/share/jupyter/kernels/python3/
KERNEL_PATH=${BASE_PATH}/python3
SOURCE_PATH=/opt/conda/share/jupyter/kernels/python3
cp ${SOURCE_PATH}/logo-32x32.png ${KERNEL_PATH}/logo-32x32.png
cp ${SOURCE_PATH}/logo-64x64.png ${KERNEL_PATH}/logo-64x64.png
cp ${SOURCE_PATH}/logo.svg ${KERNEL_PATH}/logo-svg.svg

# For Bash, copy the icons from https://github.com/odb/official-bash-logo/
# ex.) https://github.com/odb/official-bash-logo/blob/master/assets/Logos/Icons/PNG/16x16.png
KERNEL_PATH=${BASE_PATH}/bash

SOURCE_BASE_URL=https://raw.githubusercontent.com/odb/official-bash-logo/master/assets/Logos/Icons
curl -L ${SOURCE_BASE_URL}/PNG/16x16.png -o ${KERNEL_PATH}/logo-32x32.png
curl -L ${SOURCE_BASE_URL}/PNG/32x32.png -o ${KERNEL_PATH}/logo-64x64.png
curl -L ${SOURCE_BASE_URL}/SVG/16x16.svg -o ${KERNEL_PATH}/logo-svg.svg
