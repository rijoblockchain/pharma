package distributor

import (
	"fmt"
	"encoding/json"
	//"log"
	//"encoding/base64"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"

)

// Distributor SmartContract provides functions for managing distributor assets
type Distributor struct {
	contractapi.Contract
}

type Company struct {
	DocType				string `json:"docType"`
	CompanyID			string `json:"companyID"`
	Name				string `json:"name"`
	Location			string `json:"location"`
	OrganizationRole	string `json:"organizationRole"`
	HierarchyKey		int    `json:"hierarchyKey"`
}

type PurchaseOrder struct {	
	Org					string `json:"org"`	
	POID				string `json:"poID"`
	DrugName			string `json:"drugName"`
	Quantity			int    `json:"quantity"`
	Buyer				string `json:"buyer"`
	Seller				string `json:"seller"`
}

// Invokes the CreatePO smart contract to create purchase order to the state ledger
func (d *Distributor) CreatePO(ctx contractapi.TransactionContextInterface, poInfo []byte) (string, error) {
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

	newPO := PurchaseOrder {
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



func queryCompanyByCompanyCRN(ctx contractapi.TransactionContextInterface, companyCRN string) ([]*Company, error) {
	queryString := fmt.Sprintf(`{"selector":{"docType":"company","companyID":"%s"}}`, companyCRN)
	return getQueryResultForQueryString(ctx, queryString)
}

// getQueryResultForQueryString executes the passed in query string.
// The result set is built and returned as a byte array containing the JSON results.
func getQueryResultForQueryString(ctx contractapi.TransactionContextInterface, queryString string) ([]*Company, error) {
	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	return constructQueryResponseFromIterator(resultsIterator)
}

// constructQueryResponseFromIterator constructs a slice of assets from the resultsIterator
func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) ([]*Company, error) {
	var companies []*Company
	for resultsIterator.HasNext() {
		queryResult, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		var company Company
		err = json.Unmarshal(queryResult.Value, &company)
		if err != nil {
			return nil, err
		}
		companies = append(companies, &company)
	}

	return companies, nil
}