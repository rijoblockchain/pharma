# Manufacturer Terminal1 - Setting the env variables

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true

export CORE_PEER_LOCALMSPID="manufacturerMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/users/Admin@manufacturer.pharma-net.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Distributor Terminal2 - Setting the env variables

cd network

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true

export CORE_PEER_LOCALMSPID="distributorMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/peers/peer0.distributor.pharma-net.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/distributor.pharma-net.com/users/Admin@distributor.pharma-net.com/msp
export CORE_PEER_ADDRESS=localhost:9051


# Retailer Terminal3

cd network

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true

export CORE_PEER_LOCALMSPID="retailerMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/peers/peer0.retailer.pharma-net.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/retailer.pharma-net.com/users/Admin@retailer.pharma-net.com/msp
export CORE_PEER_ADDRESS=localhost:11051

# Consumer Terminal4

cd network

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true

export CORE_PEER_LOCALMSPID="consumerMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/peers/peer0.consumer.pharma-net.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/consumer.pharma-net.com/users/Admin@consumer.pharma-net.com/msp
export CORE_PEER_ADDRESS=localhost:13051

# Transporter Terminal5

cd network

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true

export CORE_PEER_LOCALMSPID="transporterMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/peers/peer0.transporter.pharma-net.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/transporter.pharma-net.com/users/Admin@transporter.pharma-net.com/msp
export CORE_PEER_ADDRESS=localhost:15051

# Payer Terminal - Patient1 goes to Payer and Payer creates the patient

export COMPANY_RECORDS=$(echo -n "{\"docType\":\"company\",\"companyCRN\":\"Manufacturer123\",\"name\":\"Sun Pharma\",\"location\":\"New Delhi\",\"organizationRole\":\"Manufacturer\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"RegisterCompany","Args":[]}' --transient "{\"company_records\":\"$COMPANY_RECORDS\"}"

export COMPANY_RECORDS=$(echo -n "{\"docType\":\"company\",\"companyCRN\":\"Distributor123\",\"name\":\"Sothern Pharmaceutical Distributor\",\"location\":\"Tamil Nadu\",\"organizationRole\":\"Distributor\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"RegisterCompany","Args":[]}' --transient "{\"company_records\":\"$COMPANY_RECORDS\"}"

export COMPANY_RECORDS=$(echo -n "{\"docType\":\"company\",\"companyCRN\":\"Retailer123\",\"name\":\"MedPlus\",\"location\":\"Bengaluru\",\"organizationRole\":\"Retailer\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"RegisterCompany","Args":[]}' --transient "{\"company_records\":\"$COMPANY_RECORDS\"}"

export COMPANY_RECORDS=$(echo -n "{\"docType\":\"company\",\"companyCRN\":\"Transporter123\",\"name\":\"ABC Logistics\",\"location\":\"Mumbai\",\"organizationRole\":\"Transporter\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"RegisterCompany","Args":[]}' --transient "{\"company_records\":\"$COMPANY_RECORDS\"}"



export DRUG_INFORMATION=$(echo -n "{\"org\":\"Manufacturer\",\"drugName\":\"Paracetamol\",\"serialNo\":\"Para1234\",\"mfgDate\":\"15/01/2021\",\"expDate\":\"20/02/2022\",\"companyCRN\":\"Manufacturer123\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"AddDrug","Args":[]}' --transient "{\"drug_information\":\"$DRUG_INFORMATION\"}"

export DRUG_INFORMATION=$(echo -n "{\"org\":\"Manufacturer\",\"drugName\":\"Paracetamol\",\"serialNo\":\"Para1235\",\"mfgDate\":\"13/02/2021\",\"expDate\":\"17/05/2022\",\"companyCRN\":\"Manufacturer123\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"AddDrug","Args":[]}' --transient "{\"drug_information\":\"$DRUG_INFORMATION\"}"

export DRUG_INFORMATION=$(echo -n "{\"org\":\"Manufacturer\",\"drugName\":\"Paracetamol\",\"serialNo\":\"Para1236\",\"mfgDate\":\"06/03/2021\",\"expDate\":\"23/05/2022\",\"companyCRN\":\"Manufacturer123\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"AddDrug","Args":[]}' --transient "{\"drug_information\":\"$DRUG_INFORMATION\"}"


export PO_INFORMATION=$(echo -n "{\"org\":\"Distributor\",\"buyerCRN\":\"Distributor123\",\"sellerCRN\":\"Manufacturer123\",\"drugName\":\"Paracetamol\",\"quantity\":3}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"CreatePO","Args":[]}' --transient "{\"po_information\":\"$PO_INFORMATION\"}"

export SHIPMENT_INFORMATION=$(echo -n "{\"org\":\"Manufacturer\",\"buyerCRN\":\"Distributor123\",\"drugName\":\"Paracetamol\",\"listOfAssets\":[\"Para1234\",\"Para1235\",\"Para1236\"],\"transporterCRN\":\"Transporter123\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"CreateShipment","Args":[]}' --transient "{\"shipment_information\":\"$SHIPMENT_INFORMATION\"}"

export UPDATE_INFORMATION=$(echo -n "{\"org\":\"Transporter\",\"buyerCRN\":\"Distributor123\",\"drugName\":\"Paracetamol\",\"transporterCRN\":\"Transporter123\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"UpdateShipment","Args":[]}' --transient "{\"update_information\":\"$UPDATE_INFORMATION\"}"



export PO_INFORMATION=$(echo -n "{\"org\":\"Retailer\",\"buyerCRN\":\"Retailer123\",\"sellerCRN\":\"Distributor123\",\"drugName\":\"Paracetamol\",\"quantity\":3}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"CreatePO","Args":[]}' --transient "{\"po_information\":\"$PO_INFORMATION\"}"

export SHIPMENT_INFORMATION=$(echo -n "{\"org\":\"Distributor\",\"buyerCRN\":\"Retailer123\",\"drugName\":\"Paracetamol\",\"listOfAssets\":[\"Para1234\",\"Para1235\",\"Para1236\"],\"transporterCRN\":\"Transporter123\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"CreateShipment","Args":[]}' --transient "{\"shipment_information\":\"$SHIPMENT_INFORMATION\"}"

export UPDATE_INFORMATION=$(echo -n "{\"org\":\"Transporter\",\"buyerCRN\":\"Retailer123\",\"drugName\":\"Paracetamol\",\"transporterCRN\":\"Transporter123\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"UpdateShipment","Args":[]}' --transient "{\"update_information\":\"$UPDATE_INFORMATION\"}"

export RETAIL_INFORMATION=$(echo -n "{\"org\":\"Retailer\",\"drugName\":\"Paracetamol\",\"serialNo\":\"Para1234\",\"retailerCRN\":\"Retailer123\",\"customerAadhar\":\"654762332163\"}" | base64 | tr -d \\n)


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma-net.com --tls --cafile "${PWD}/organizations/ordererOrganizations/pharma-net.com/orderers/orderer.pharma-net.com/msp/tlscacerts/tlsca.pharma-net.com-cert.pem" -C pharmachannel -n pharma --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/manufacturer.pharma-net.com/peers/peer0.manufacturer.pharma-net.com/tls/ca.crt"  -c '{"function":"RetailDrug","Args":[]}' --transient "{\"retail_information\":\"$RETAIL_INFORMATION\"}"


peer chaincode query -C pharmachannel -n pharma -c '{"function":"viewHistory","Args":["Paracetamol","Para1234"]}'

peer chaincode query -C pharmachannel -n pharma -c '{"function":"viewDrugCurrentState","Args":["Paracetamol","Para1234"]}'