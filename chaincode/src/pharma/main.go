/*
SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"log"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"pharma/pharma"
)

func main() {
	pharmaChaincode, err := contractapi.NewChaincode(&pharma.Pharma{})
	if err != nil {
		log.Panicf("Error creating Pharma chaincode: %v", err)
	}

	if err := pharmaChaincode.Start(); err != nil {
		log.Panicf("Error starting chaincode: %v", err)
	}

	/*usersChaincode, err := contractapi.NewChaincode(&chaincode.Users{})
	if err != nil {
		log.Panicf("Error creating Users chaincode: %v", err)
	}

	if err := usersChaincode.Start(); err != nil {
		log.Panicf("Error starting Users chaincode: %v", err)
	}*/
}
