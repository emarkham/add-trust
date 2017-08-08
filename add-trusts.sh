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
example-compartment-B)


# define domain-list
DOMAIN_LIST=("aa.local" "bb.local" "cc.local")



for COMPART in ${COMPARTMENT_LIST[@]}; do
   for DOM in ${DOMAIN_LIST[@]}; do
       # echo "ssc compartments add-inter-forest-trust --domain-name ${DOM} --compartment-name ${COMPART} --force"
       printf "Adding trust for \e[96m${DOM}\e[0m to \e[92m${COMPART}\e[0m\n"
       RESULT=$(ssc compartments add-inter-forest-trust --domain-name ${DOM} --compartment-name ${COMPART} --force)
       # RESULT="Successfully added role Active Directory Inter-Forest Trust for compartment"
       if [[ ${RESULT} != *"Successfully added"* ]] ; then
        # Retry just once
        printf "\e[91mretrying... \e[0m"
        sleep 5
        RESULT=$(ssc compartments add-inter-forest-trust --domain-name ${DOM} --compartment-name ${COMPART} --force)
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
    printf "\e[93mFailed to create inter-forest-trusts for the following:\n"
    printf '%s\n' "${FAILLIST[@]}"
    printf '\e[0m' # clear color
fi
