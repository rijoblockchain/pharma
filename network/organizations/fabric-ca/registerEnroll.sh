#!/bin/bash

function createManufacturer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/manufacturer.pharma-net.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-manufacturer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name manufactureradmin --id.secret manufactureradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/msp" --csr.hosts peer0.manufacturer.pharma-net.com --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls" --enrollment.profile tls --csr.hosts peer0.manufacturer.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/tlsca/tlsca.manufacturer.pharma-net.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/ca"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/ca/ca.manufacturer.pharma-net.com-cert.pem"


  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/msp" --csr.hosts peer1.manufacturer.pharma-net.com --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/msp/config.yaml"

  infoln "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/tls" --enrollment.profile tls --csr.hosts peer1.manufacturer.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/tls/server.key"

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/msp/tlscacerts/ca.crt"

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/tlsca/tlsca.manufacturer.pharma-net.com-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer1.manufacturer.pharma-net.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/ca/ca.manufacturer.pharma-net.com-cert.pem"


  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/users/User1@manufacturer.pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/users/User1@manufacturer.pharma-net.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://manufactureradmin:manufactureradminpw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/users/Admin@manufacturer.pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/users/Admin@manufacturer.pharma-net.com/msp/config.yaml"
}

function createDistributor() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/distributor.pharma-net.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-distributor --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-distributor.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-distributor.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-distributor.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-distributor.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-distributor --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-distributor --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-distributor --id.name distributoradmin --id.secret distributoradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-distributor -M "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/msp" --csr.hosts peer0.distributor.pharma-net.com --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-distributor -M "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls" --enrollment.profile tls --csr.hosts peer0.distributor.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/tlsca/tlsca.distributor.pharma-net.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/ca"
  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/ca/ca.distributor.pharma-net.com-cert.pem"

  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-distributor --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-distributor -M "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/msp" --csr.hosts peer1.distributor.pharma-net.com --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/msp/config.yaml"

  infoln "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-distributor -M "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/tls" --enrollment.profile tls --csr.hosts peer1.distributor.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/tls/server.key"

  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/msp/tlscacerts/ca.crt"

  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/tlsca/tlsca.distributor.pharma-net.com-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer1.distributor.pharma-net.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/ca/ca.distributor.pharma-net.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-distributor -M "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/users/User1@distributor.pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/users/User1@distributor.pharma-net.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://distributoradmin:distributoradminpw@localhost:8054 --caname ca-distributor -M "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/users/Admin@distributor.pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/users/Admin@distributor.pharma-net.com/msp/config.yaml"
}

function createRetailer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/retailer.pharma-net.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-retailer --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-retailer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-retailer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-retailer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-retailer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name retaileradmin --id.secret retaileradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/msp" --csr.hosts peer0.retailer.pharma-net.com --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls" --enrollment.profile tls --csr.hosts peer0.retailer.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/tlsca/tlsca.retailer.pharma-net.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/ca"
  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/ca/ca.retailer.pharma-net.com-cert.pem"


  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:9054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/msp" --csr.hosts peer1.retailer.pharma-net.com --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/msp/config.yaml"

  infoln "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:9054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/tls" --enrollment.profile tls --csr.hosts peer1.retailer.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/tls/server.key"

  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/msp/tlscacerts/ca.crt"

  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/tlsca/tlsca.retailer.pharma-net.com-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer1.retailer.pharma-net.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/ca/ca.retailer.pharma-net.com-cert.pem"


  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/users/User1@retailer.pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/users/User1@retailer.pharma-net.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://retaileradmin:retaileradminpw@localhost:9054 --caname ca-retailer -M "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/users/Admin@retailer.pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/retailer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/users/Admin@retailer.pharma-net.com/msp/config.yaml"
}

function createConsumer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/consumer.pharma-net.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-consumer --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-consumer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-consumer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-consumer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-consumer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-consumer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-consumer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-consumer --id.name consumeradmin --id.secret consumeradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-consumer -M "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/msp" --csr.hosts peer0.consumer.pharma-net.com --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-consumer -M "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls" --enrollment.profile tls --csr.hosts peer0.consumer.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/tlsca/tlsca.consumer.pharma-net.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/ca"
  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/ca/ca.consumer.pharma-net.com-cert.pem"


  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-consumer --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:10054 --caname ca-consumer -M "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/msp" --csr.hosts peer1.consumer.pharma-net.com --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/msp/config.yaml"

  infoln "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:10054 --caname ca-consumer -M "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/tls" --enrollment.profile tls --csr.hosts peer1.consumer.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/tls/server.key"

  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/msp/tlscacerts/ca.crt"

  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/tlsca/tlsca.consumer.pharma-net.com-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer1.consumer.pharma-net.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/ca/ca.consumer.pharma-net.com-cert.pem"


  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca-consumer -M "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/users/User1@consumer.pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/users/User1@consumer.pharma-net.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://consumeradmin:consumeradminpw@localhost:10054 --caname ca-consumer -M "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/users/Admin@consumer.pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/consumer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/users/Admin@consumer.pharma-net.com/msp/config.yaml"
}

function createTransporter() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/transporter.pharma-net.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-transporter --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-transporter.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-transporter.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-transporter.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-transporter.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-transporter --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-transporter --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-transporter --id.name transporteradmin --id.secret transporteradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-transporter -M "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/msp" --csr.hosts peer0.transporter.pharma-net.com --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-transporter -M "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls" --enrollment.profile tls --csr.hosts peer0.transporter.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/tlsca/tlsca.transporter.pharma-net.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/ca"
  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/ca/ca.transporter.pharma-net.com-cert.pem"


  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-transporter --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:11054 --caname ca-transporter -M "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/msp" --csr.hosts peer1.transporter.pharma-net.com --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/msp/config.yaml"

  infoln "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:11054 --caname ca-transporter -M "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/tls" --enrollment.profile tls --csr.hosts peer1.transporter.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/tls/server.key"

  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/msp/tlscacerts/ca.crt"

  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/tlsca/tlsca.transporter.pharma-net.com-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer1.transporter.pharma-net.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/ca/ca.transporter.pharma-net.com-cert.pem"


  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-transporter -M "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/users/User1@transporter.pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/users/User1@transporter.pharma-net.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://transporteradmin:transporteradminpw@localhost:11054 --caname ca-transporter -M "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/users/Admin@transporter.pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/transporter/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/users/Admin@transporter.pharma-net.com/msp/config.yaml"
}



function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/pharma-net.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/pharma-net.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:12054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/pharma-net.com/msp/config.yaml"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:12054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp" --csr.hosts orderer.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/pharma-net.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:12054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls" --enrollment.profile tls --csr.hosts orderer.pharma-net.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/pharma-net.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:12054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/pharma-net.com/users/Admin@pharma-net.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/pharma-net.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/pharma-net.com/users/Admin@pharma-net.com/msp/config.yaml"
}