#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem
export PEER0_MANUFACTURER_CA=${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt
export PEER0_DISTRIBUTOR_CA=${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls/ca.crt
export PEER0_RETAILER_CA=${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls/ca.crt
export PEER0_CONSUMER_CA=${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls/ca.crt
export PEER0_TRANSPORTER_CA=${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls/ca.crt
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls/server.key

# Set environment variables for the peer org
setGlobals() {
  local USING_PEER=$1
  local USING_ORG=""
  
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$2
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="manufacturerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MANUFACTURER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/users/Admin@manufacturer.pharma-net.com/msp
    #export CORE_PEER_ADDRESS=localhost:7051
    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:7051
    else
      export CORE_PEER_ADDRESS=localhost:8051
    fi
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="distributorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DISTRIBUTOR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/users/Admin@distributor.pharma-net.com/msp
    #export CORE_PEER_ADDRESS=localhost:9051
    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:9051
    fi
    if [ $USING_PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:10051
    fi
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="retailerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/users/Admin@retailer.pharma-net.com/msp
    #export CORE_PEER_ADDRESS=localhost:9051
    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:11051
    fi
    if [ $USING_PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:12051
    fi  
  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_LOCALMSPID="consumerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CONSUMER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/users/Admin@consumer.pharma-net.com/msp
    #export CORE_PEER_ADDRESS=localhost:9051
    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:13051
    fi
    if [ $USING_PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:14051
    fi 
  elif [ $USING_ORG -eq 5 ]; then
    export CORE_PEER_LOCALMSPID="transporterMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_TRANSPORTER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/users/Admin@transporter.pharma-net.com/msp
    #export CORE_PEER_ADDRESS=localhost:9051
    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:15051
    fi
    if [ $USING_PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:16051
    fi
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi

echo $CORE_PEER_LOCALMSPID
echo $CORE_PEER_ADDRESS
}



# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals 0 $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer0.manufacturer.pharma-net.com:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.distributor.pharma-net.com:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_ADDRESS=peer0.retailer.pharma-net.com:11051
  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_ADDRESS=peer0.consumer.pharma-net.com:13051
  elif [ $USING_ORG -eq 5 ]; then
    export CORE_PEER_ADDRESS=peer0.transporter.pharma-net.com:15051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.org$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_ORG$1_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
