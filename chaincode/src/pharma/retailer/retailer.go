package retailer

import (
	"fmt"
	"encoding/json"

	//"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"pharma/distributor"
	"pharma/manufacturer"

)

// Retailer SmartContract provides functions for managing retailer assets
type Retailer struct {
	contractapi.Contract
}

type Company struct {
	DocType				string `json:"docType"`
	Org					string `json:"org"`	
	CompanyID			string `json:"companyID"`
	Name				string `json:"name"`
	Location			string `json:"location"`
	OrganizationRole	string `json:"organizationRole"`
	HierarchyKey		int	   `json:"hierarchyKey"`
}

/*type PurchaseOrder struct {	
	POID				string `json:"poID"`
	DrugName			string `json:"drugName"`
	Quantity			int    `json:"quantity"`
	Buyer				string `json:"buyer"`
	Seller				string `json:"seller"`
}*/

// Invokes the CreatePO smart contract to create purchase order to the state ledger
func (r *Retailer) CreatePO(ctx contractapi.TransactionContextInterface, poInfo []byte) (string, error) {
	type POData struct {
		Org				string `json:"org"`	
		BuyerCRN		string `json:"buyerCRN"`	
		SellerCRN		string `json:"sellerCRN"`
		DrugName		string `json:"drugName"`
		Quantity		int    `json:"quantity"`
	}
	
	var poData POData
	
	err := json.Unmarshal(poInfo, &poData)
	if err != nil {
		return "", fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	poCompositeKey, err := ctx.GetStub().CreateCompositeKey("po.pharma-net.com", []string{poData.BuyerCRN, poData.DrugName})
	if err != nil {
		return "", fmt.Errorf("failed to create composite key: %v", err)
	}

	buyer, _ := getCompanyByPartialCompositeKey(ctx, poData.BuyerCRN, "company.pharma-net.com")

	seller, _ := getCompanyByPartialCompositeKey(ctx, poData.SellerCRN, "company.pharma-net.com")
	
	if buyer.HierarchyKey - seller.HierarchyKey != 1 {
		return "", fmt.Errorf("%v not allowed to buy from %v", buyer.Name, seller.Name)
	}
	//buyerCompositeKey, err := ctx.GetStub().CreateCompositeKey("company.pharma-net.com", []string{buyer[0].Name, poData.BuyerCRN})
	//sellerCompositeKey, err := ctx.GetStub().CreateCompositeKey("company.pharma-net.com", []string{seller[0].Name, poData.SellerCRN})

	newPO := distributor.PurchaseOrder {
		Org:				poData.Org,	
		POID:				poCompositeKey,
		DrugName:			poData.DrugName,
		Quantity:			poData.Quantity,
		Buyer:				buyer.CompanyID,
		Seller:				seller.CompanyID,

	}

	marshaledPO, err := json.Marshal(newPO)
	if err != nil {
		return "", fmt.Errorf("failed to marshal PO into JSON: %v", err)
	}
	err = ctx.GetStub().PutState(poCompositeKey, marshaledPO)
	if err != nil {
		return "", fmt.Errorf("failed to put PO: %v", err)
	}
	
	return string(marshaledPO), nil
}


// Invokes the RetailDrug smart contract in retailer to sell drug to customers
func (r *Retailer) RetailDrug(ctx contractapi.TransactionContextInterface, retailInfo []byte) (string, error) {
	type Retail struct {
		Org				string `json:"org"`	
		DrugName		string `json:"drugName"`
		SerialNo		string `json:"serialNo"`
		RetailerCRN		string `json:"retailerCRN"`	
		CustomerAadhar	string `json:"customerAadhar"`		
	}
	
	var retail Retail

	err := json.Unmarshal(retailInfo, &retail)
	if err != nil {
		return "", fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	drugCompositeKey, err := ctx.GetStub().CreateCompositeKey("drug.pharma-net.com", []string{retail.DrugName, retail.SerialNo})
	if err != nil {
		return "", fmt.Errorf("failed to create composite key: %v", err)
	}

	drugJSON, err := ctx.GetStub().GetState(drugCompositeKey) //get the drug details from chaincode state
	if err != nil {
		return "", fmt.Errorf("failed to read drug: %v", err)
	}

	//No Drug found, return empty response
	if drugJSON == nil {
		return "", fmt.Errorf("%v does not exist in state ledger", err)
	}

	var drug manufacturer.Drug
	err = json.Unmarshal(drugJSON, &drug)
	if err != nil {
		return "", fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	drug.Owner = retail.CustomerAadhar
	marshaledDrug, err := json.Marshal(drug)
	if err != nil {
		return "", fmt.Errorf("failed to marshal drug into JSON: %v", err)
	}
	err = ctx.GetStub().PutState(drugCompositeKey, marshaledDrug)
	if err != nil {
		return "", fmt.Errorf("failed to put drug: %v", err)
	}

	return string(marshaledDrug), nil
}

func getCompanyByPartialCompositeKey(ctx contractapi.TransactionContextInterface, queryString string, namespace string) (*Company, error) {
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
func readCompany(ctx contractapi.TransactionContextInterface, companyID string) (*Company, error) {
	companyBytes, err := ctx.GetStub().GetState(companyID)
	if err != nil {
		return nil, fmt.Errorf("failed to get company %s: %v", companyID, err)
	}
	if companyBytes == nil {
		return nil, fmt.Errorf("company %s does not exist", companyID)
	}

	var company Company
	err = json.Unmarshal(companyBytes, &company)
	if err != nil {
		return nil, err
	}

	return &company, nil
}
