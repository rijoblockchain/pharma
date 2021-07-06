package manufacturer

import (
	"fmt"
	"encoding/json"
	//"log"
	

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"pharma/distributor"

)

// Manufacturer SmartContract provides functions for managing manufacturer assets
type Manufacturer struct {
	contractapi.Contract
}

type Company struct {
	DocType				string `json:"docType"`
	CompanyID			string `json:"companyID"`
	Name				string `json:"name"`
	Location			string `json:"location"`
	OrganizationRole	string `json:"organizationRole"`
	HierarchyKey		int	   `json:"hierarchyKey"`
}

type Drug struct {	
	DocType				string `json:"docType"`
	Org					string `json:"org"`	
	ProductID			string `json:"productID"`
	Name				string `json:"name"`
	Manufacturer		string `json:"manufacturer"`
	ManufacturingDate	string `json:"manufacturingDate"`
	ExpiryDate			string `json:"expiryDate"`
	Owner				string `json:"owner"`
	Shipment		  []string `json:"shipment"`
}

type Shipment struct {	
	DocType				string `json:"docType"`
	Org					string `json:"org"`	
	ShippingID			string `json:"shippingID"`
	Creator				string `json:"creator"`
	Assets			  []string `json:"assets"`
	Transporter			string `json:"transporter"`
	Status				string `json:"status"`
}

// Invokes the AddDrug smart contract to add a drug to the state ledger
func (m *Manufacturer) AddDrug(ctx contractapi.TransactionContextInterface, drugInfo []byte) (string, error) {
	
	//clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()

	type DrugInfo struct {
		Org				string `json:"org"`	
		DrugName		string `json:"drugName"`	
		SerialNo		string `json:"serialNo"`
		MfgDate			string `json:"mfgDate"`
		ExpDate			string `json:"expDate"`
		CompanyCRN		string `json:"companyCRN"`
	}
	
	var drugData DrugInfo
	
	err := json.Unmarshal(drugInfo, &drugData)
	if err != nil {
		return "", fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	drugCompositeKey, err := ctx.GetStub().CreateCompositeKey("drug.pharma-net.com", []string{drugData.DrugName, drugData.SerialNo})
	if err != nil {
		return "", fmt.Errorf("failed to create composite key: %v", err)
	}

	manufacturer, _ := 	getCompanyByPartialCompositeKey(ctx, drugData.CompanyCRN, "company.pharma-net.com")
	/*manufacturer, err := readCompany(ctx, manufacturerCompositeKey)
	if err != nil {
		return nil, err
	}*/
	//companyCompositeKey, err := ctx.GetStub().CreateCompositeKey("company.pharma-net.com", []string{manufacturer.Name, drugData.CompanyCRN})

	newDrug := Drug {
		DocType:			"drug",
		Org:				drugData.Org,
		ProductID:			drugCompositeKey,
		Name:				drugData.DrugName,
		Manufacturer:		manufacturer.CompanyID,
		ManufacturingDate:	drugData.MfgDate,
		ExpiryDate:			drugData.ExpDate,			
		Owner:				manufacturer.CompanyID,
		Shipment:		  []string{""},

	}

	marshaledDrug, err := json.Marshal(newDrug)
	if err != nil {
		return "", fmt.Errorf("failed to marshal drug into JSON: %v", err)
	}
	err = ctx.GetStub().PutState(drugCompositeKey, marshaledDrug)
	if err != nil {
		return "", fmt.Errorf("failed to put drug: %v", err)
	}
	
	return string(marshaledDrug), nil

}


// Invokes the CreateShipment smart contract to create shipment asset to the state ledger
func (manufacturer *Manufacturer) CreateShipment(ctx contractapi.TransactionContextInterface, shipmentInfo []byte) (string, error) {
	type ShipmentData struct {
		Org				string `json:"org"`	
		BuyerCRN		string `json:"buyerCRN"`	
		DrugName		string `json:"drugName"`
		ListOfAssets  []string `json:"listOfAssets"`
		TransporterCRN	string `json:"transporterCRN"`
	}
	
	var shipmentData ShipmentData
	
	err := json.Unmarshal(shipmentInfo, &shipmentData)
	if err != nil {
		return "", fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	shipmentCompositeKey, err := ctx.GetStub().CreateCompositeKey("shipment.pharma-net.com", []string{shipmentData.BuyerCRN, shipmentData.DrugName})
	if err != nil {
		return "", fmt.Errorf("failed to create composite key: %v", err)
	}

	poCompositeKey, err := ctx.GetStub().CreateCompositeKey("po.pharma-net.com", []string{shipmentData.BuyerCRN, shipmentData.DrugName})
	if err != nil {
		return "", fmt.Errorf("failed to create composite key: %v", err)
	}

	poJSON, err := ctx.GetStub().GetState(poCompositeKey) //get the PO details from chaincode state
	if err != nil {
		return "", fmt.Errorf("failed to read PO: %v", err)
	}

	//No PO found, return empty response
	if poJSON == nil {
		return "", fmt.Errorf("%v does not exist in state ledger", err)
	}

	var po distributor.PurchaseOrder
	err = json.Unmarshal(poJSON, &po)
	if err != nil {
		return "", fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	if po.Quantity != len(shipmentData.ListOfAssets) {
		return "", fmt.Errorf("The length of listOfAssets should be exactly equal to the quantity specified in the PO")
	}

	transporter, _ := 	getCompanyByPartialCompositeKey(ctx, shipmentData.TransporterCRN, "company.pharma-net.com")
	
	shipmentAssets := []string{""}

	for _, asset := range shipmentData.ListOfAssets {
		var drug Drug
		drugCompositeKey, err := ctx.GetStub().CreateCompositeKey("drug.pharma-net.com", []string{shipmentData.DrugName, asset})
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

		err = json.Unmarshal(drugJSON, &drug)
		if err != nil {
			return "", fmt.Errorf("failed to unmarshal JSON: %v", err)
		}

		shipmentAssets = append(shipmentAssets, drugCompositeKey)	
		

		drug.Owner = transporter.CompanyID

		marshaledDrug, err := json.Marshal(drug)
		if err != nil {
			return "", fmt.Errorf("failed to marshal drug into JSON: %v", err)
		}
		err = ctx.GetStub().PutState(drugCompositeKey, marshaledDrug)
		if err != nil {
			return "", fmt.Errorf("failed to put drug: %v", err)
		}
	}
	
	shipmentAssets = shipmentAssets[1:]
	

	newShipment := Shipment {
		DocType:			"shipment",	
		Org:				shipmentData.Org,				
		ShippingID:			shipmentCompositeKey,
		Creator:			po.Seller,
		Assets:				shipmentAssets,			    
		Transporter:		transporter.CompanyID,
		Status:				"In-Transit",

	}

	marshaledShipment, err := json.Marshal(newShipment)
	if err != nil {
		return "", fmt.Errorf("failed to marshal Shipment into JSON: %v", err)
	}
	err = ctx.GetStub().PutState(shipmentCompositeKey, marshaledShipment)
	if err != nil {
		return "", fmt.Errorf("failed to put Shipment: %v", err)
	}
	
	return string(marshaledShipment), nil
	
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


func queryDrugByDrugName(ctx contractapi.TransactionContextInterface, drugName string) ([]*Drug, error) {
	queryString := fmt.Sprintf(`{"selector":{"docType":"drug","name":"%s"}}`, drugName)
	return getQueryResultForDrug(ctx, queryString)
}

// getQueryResultForQueryString executes the passed in query string.
// The result set is built and returned as a byte array containing the JSON results.
func getQueryResultForDrug(ctx contractapi.TransactionContextInterface, queryString string) ([]*Drug, error) {
	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	return constructDrugQueryResponseFromIterator(resultsIterator)
}

// constructQueryResponseFromIterator constructs a slice of assets from the resultsIterator
func constructDrugQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) ([]*Drug, error) {
	var drugs []*Drug
	for resultsIterator.HasNext() {
		queryResult, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		var drug Drug
		err = json.Unmarshal(queryResult.Value, &drug)
		if err != nil {
			return nil, err
		}
		drugs = append(drugs, &drug)
	}

	return drugs, nil
}

/*func queryCompanyByCompanyCRN(ctx contractapi.TransactionContextInterface, companyCRN string) ([]*Company, error) {
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
}*/

