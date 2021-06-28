package transporter

import (
	"fmt"
	"encoding/json"

	//"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"pharma/manufacturer"

)

// Retailer SmartContract provides functions for managing retailer assets
type Transporter struct {
	contractapi.Contract
}


// Invokes the UpdateShipment smart contract in transporter to update shipment transaction
func (t *Transporter) UpdateShipment(ctx contractapi.TransactionContextInterface, shipmentInfo []byte) (*manufacturer.Shipment, error) {
	type ShipmentData struct {
		BuyerCRN		string `json:"buyerCRN"`	
		DrugName		string `json:"drugName"`
		TransporterCRN	string `json:"transporterCRN"`
	}
	
	var shipmentData ShipmentData
	
	err := json.Unmarshal(shipmentInfo, &shipmentData)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	shipmentCompositeKey, err := ctx.GetStub().CreateCompositeKey("shipment.pharma-net.com", []string{shipmentData.BuyerCRN, shipmentData.DrugName})
	if err != nil {
		return nil, fmt.Errorf("failed to create composite key: %v", err)
	}

	shipmentJSON, err := ctx.GetStub().GetState(shipmentCompositeKey) //get the Shipment details from chaincode state
	if err != nil {
		return nil, fmt.Errorf("failed to read Shipment: %v", err)
	}

	//No Shipment found, return empty response
	if shipmentJSON == nil {
		return nil, fmt.Errorf("%v does not exist in state ledger", err)
	}

	var updateShipment manufacturer.Shipment
	err = json.Unmarshal(shipmentJSON, &updateShipment)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	updateShipment.Status = "Delivered"

	marshaledUpdateShipment, err := json.Marshal(updateShipment)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal Shipment into JSON: %v", err)
	}
	err = ctx.GetStub().PutState(shipmentCompositeKey, marshaledUpdateShipment)
	if err != nil {
		return nil, fmt.Errorf("failed to put Shipment: %v", err)
	}

	for _, asset := range updateShipment.Assets {
		var drug manufacturer.Drug
		/*drugCompositeKey, err := ctx.GetStub().CreateCompositeKey("drug.pharma-net.com", []string{shipmentData.DrugName, asset})
		if err != nil {
			return nil, fmt.Errorf("failed to create composite key: %v", err)
		}*/

		drugJSON, err := ctx.GetStub().GetState(asset) //get the drug details from chaincode state
		if err != nil {
			return nil, fmt.Errorf("failed to read drug: %v", err)
		}

		//No Drug found, return empty response
		if drugJSON == nil {
			return nil, fmt.Errorf("%v does not exist in state ledger", err)
		}

		err = json.Unmarshal(drugJSON, &drug)
		if err != nil {
			return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
		}
		
		buyer, _ := getCompanyByPartialCompositeKey(ctx, shipmentData.BuyerCRN, "company.pharma-net.com")

		drug.Owner = buyer.CompanyID
		drug.Shipment = append(drug.Shipment, shipmentCompositeKey)
		if drug.Shipment[0] == ""{
			drug.Shipment = drug.Shipment[1:]
		}
		

		marshaledDrug, err := json.Marshal(drug)
		if err != nil {
			return nil, fmt.Errorf("failed to marshal drug into JSON: %v", err)
		}
		err = ctx.GetStub().PutState(asset, marshaledDrug)
		if err != nil {
			return nil, fmt.Errorf("failed to put drug: %v", err)
		}
	}
	
	
	return &updateShipment, nil


}

func getCompanyByPartialCompositeKey(ctx contractapi.TransactionContextInterface, queryString string, namespace string) (*manufacturer.Company, error) {
	// Execute a key range query on all keys starting with queryString
	assetResultsIterator, err := ctx.GetStub().GetStateByPartialCompositeKey(namespace, []string{queryString})
	if err != nil {
		return nil, err
	}

	defer assetResultsIterator.Close()
	
	for assetResultsIterator.HasNext() {
		responseRange, err := assetResultsIterator.Next()
		
		if err != nil {
			return nil, err
		}

		manufacturer, err := readCompany(ctx,responseRange.Key)
		if err != nil {
			return nil, err
		}

		return manufacturer, nil
	}

	return nil, nil
}

// ReadAsset retrieves an asset from the ledger
func readCompany(ctx contractapi.TransactionContextInterface, companyID string) (*manufacturer.Company, error) {
	companyBytes, err := ctx.GetStub().GetState(companyID)
	if err != nil {
		return nil, fmt.Errorf("failed to get company %s: %v", companyID, err)
	}
	if companyBytes == nil {
		return nil, fmt.Errorf("company %s does not exist", companyID)
	}

	var company manufacturer.Company
	err = json.Unmarshal(companyBytes, &company)
	if err != nil {
		return nil, err
	}

	return &company, nil
}
