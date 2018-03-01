#!/bin/bash

#
#  Copyright 2017 Skyport Systems, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# Simple example script to add several inter-forest-trusts to multiple compartments
# You must be logged into SkySecure Center
# Usage:
#       add-trusts.sh
#
# -----------------------------------------------------------------------------------


# define compartment-list
COMPARTMENT_LIST=(
example-compartment-A 
example-compartment-B
)


# define domain-list
DOMAIN_LIST=(
"aa.local" 
"bb.local" 
"cc.local"
)




RED='\e[91m'
GRN='\e[92m'
BLU='\e[96m'
YEL='\e[93m'
NOCO='\e[0m'


if ! ssc_loc="$(type -p "ssc")"; then
  echo "You must have SSC installed, download from:"
  echo "https://cdn.skyportsystems.com/SkyportSystemsRepo/skysecure-cli-1.7.0-2017_11_20_1238.noarch.rpm"
  exit 1
fi

add_iftrust () {
  ssc compartments add-inter-forest-trust --domain-name $1 --compartment-name $2 --force
}

for COMPART in ${COMPARTMENT_LIST[@]}; do
   for DOM in ${DOMAIN_LIST[@]}; do
       printf "Adding trust for ${BLU}${DOM}\e[0m to ${GRN}${COMPART}${NOCO}\n"
       RESULT= add_iftrust ${DOM} ${COMPART}
       # RESULT="Successfully added role Active Directory Inter-Forest Trust for compartment"
       if [[ ${RESULT} != *"Successfully added"* ]] ; then
        # Retry just once
        printf "${RED}retrying... $NOCO"
        sleep 5
        RESULT= add_iftrust ${DOM} ${COMPART}
        echo "${RESULT}"
         if [[ ${RESULT} != *"Successfully added"* ]] ; then
           FAILLIST+=(${COMPART}' : '${DOM})
         fi
       fi
   done
   echo ""
   COUNT=$(ssc compartments show-roles --compartment-name ${COMPART} | grep ad-inter-forest | wc -l | tr -d [:blank:])
   if [[ ${COUNT} -ne  ${#DOMAIN_LIST[@]} ]] ; then
    FAILURE_DETECTED=1
   fi
 done

if [[ FAILURE_DETECTED ]] ; then
    printf "${YEL}Error when creating inter-forest-trust for compartment : domain:\n"
    if [[ $FAILLIST ]] ; then 
      printf '%s\n' "${FAILLIST[@]}"
    fi
fi
