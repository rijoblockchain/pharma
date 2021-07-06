package pharma

import (
	"fmt"
	"encoding/json"
	"time"

	//"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/golang/protobuf/ptypes"
	"pharma/manufacturer"
	"pharma/distributor"
	"pharma/retailer"
	"pharma/transporter"

)

// PHarma SmartContract provides functions for managing an manufacturer, distributor, retailer, consumer and transporter smart contracts
type Pharma struct {
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

type HistoryQueryResult struct {
	Record    *manufacturer.Drug    `json:"record"`
	TxId       string    			`json:"txId"`
	Timestamp time.Time 			`json:"timestamp"`
	IsDelete  bool      			`json:"isDelete"`
}

// InitPropertyLedger initializes the contract
func (p *Pharma) InitPharmaLedger(ctx contractapi.TransactionContextInterface) error {
	fmt.Println("Pharma Ledger is initiated")
	return nil
}

// Invokes the RegisterCompany smart contract to register a new company
func (p *Pharma) RegisterCompany(ctx contractapi.TransactionContextInterface) (string, error) {
	
	
type CompanyInput struct {
	CompanyCRN			string `json:"companyCRN"`
	Name				string `json:"name"`
	Location			string `json:"location"`
	OrganizationRole	string `json:"organizationRole"`
}
	// Get the function invoking client's MSP ID
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("failed getting the client's MSPID: %v", err)
	}
	
	/*peerMSPID, err := shim.GetMSPID()
	if err != nil {
		return nil, fmt.Errorf("failed getting the peer's MSPID: %v", err)
	}

	if clientMSPID != peerMSPID {
		return nil, fmt.Errorf("client from org %v is not authorized to read or write private data from an org %v peer", clientMSPID, peerMSPID)
	}*/


	// Records are passed in transient field to make it more secure.
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return "", fmt.Errorf("error getting transient: %v", err)
	}

	transientCompanyJSON, ok := transientMap["company_records"]
	if !ok {
		//log error to stdout
		return "", fmt.Errorf("Company not found in the transient map input")
	}

	var companyInput CompanyInput

	err = json.Unmarshal(transientCompanyJSON, &companyInput)
	if err != nil {
		return "", fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	if len(companyInput.CompanyCRN) == 0 {
		return "", fmt.Errorf("CompanyCRN field must be a non-empty string")
	}
	if len(companyInput.Name) == 0 {
		return "", fmt.Errorf("Name  must be a non-empty string")
	}
	if len(companyInput.Location) == 0 {
		return "", fmt.Errorf("Location field must be a non-empty string")
	}
	if len(companyInput.OrganizationRole) == 0 {
		return "", fmt.Errorf("OrganizationRole field must be a non-empty string")
	}

	companyCompositeKey, err := ctx.GetStub().CreateCompositeKey("company.pharma-net.com", []string{companyInput.CompanyCRN, companyInput.Name})
	if err != nil {
		return "", fmt.Errorf("failed to create composite key into JSON: %v", err)
	}


	company := Company {
		DocType:				"company",
		CompanyID:				companyCompositeKey,			
		Name:					companyInput.Name,
		Location:				companyInput.Location,
		OrganizationRole:		companyInput.OrganizationRole,
	}

	if clientMSPID == "manufacturerMSP" {
		company.HierarchyKey = 1
	} else if clientMSPID == "distributorMSP" {
		company.HierarchyKey = 2
	} else if clientMSPID == "retailerMSP" {
		company.HierarchyKey = 3
	} else if clientMSPID == "transporterMSP" {
		company.HierarchyKey = 4 
	}

	marshaledCompany, err := json.Marshal(company)
	fmt.Println(string(marshaledCompany))
	fmt.Println(&company)
	if err != nil {
		return "", fmt.Errorf("failed to marshal company into JSON: %v", err)
	}
	err = ctx.GetStub().PutState(companyCompositeKey, marshaledCompany)
	if err != nil {
		return "", fmt.Errorf("failed to put company: %v", err)
	}
	
	
	return string(marshaledCompany), nil
	
}

// Invokes the AddDrug smart contract to add a drug to the state ledger
func (p *Pharma) AddDrug(ctx contractapi.TransactionContextInterface) (string, error) {
	var manufacturer *manufacturer.Manufacturer
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "manufacturerMSP" {
		return "", fmt.Errorf("client from org %v is not authorized to add new drug", clientMSPID)
	}

	// Records are passed in transient field to make it more secure.
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return "", fmt.Errorf("error getting transient: %v", err)
	}


	// Drug records are private, therefore they get passed in transient field, instead of func args
	transientDrugJSON, ok := transientMap["drug_information"]
	if !ok {
		//log error to stdout
		return "", fmt.Errorf("new Drug not found in the transient map input")
	}

	newDrug, err := manufacturer.AddDrug(ctx, transientDrugJSON)
	if err != nil {
		return "", fmt.Errorf("failed to add drug: %v", err)
	}

	return newDrug, nil
}

// Invokes the CreatePO smart contract in distributor or retailer to create a purchase order
func (p *Pharma) CreatePO(ctx contractapi.TransactionContextInterface) (string, error) {
	var distributorContract *distributor.Distributor
	var retailerContract *retailer.Retailer
	var newPO string

	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "distributorMSP" && clientMSPID != "retailerMSP"{
		return "", fmt.Errorf("client from org %v is not authorized to create purchase order", clientMSPID)
	}

	// Records are passed in transient field to make it more secure.
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return "", fmt.Errorf("error getting transient: %v", err)
	}


	// PO records are private, therefore they get passed in transient field, instead of func args
	transientPOJSON, ok := transientMap["po_information"]
	if !ok {
		//log error to stdout
		return "", fmt.Errorf("new PO not found in the transient map input")
	}

	if clientMSPID == "distributorMSP" {
		newPO, err = distributorContract.CreatePO(ctx, transientPOJSON)
		if err != nil {
			return "", fmt.Errorf("failed to create purchase order: %v", err)
		} 
	} else {
		newPO, err = retailerContract.CreatePO(ctx, transientPOJSON)
		if err != nil {
			return "", fmt.Errorf("failed to create purchase order: %v", err)
		} 
	}
	

	return newPO, nil
}

// Invokes the CreateShipment smart contract in manufacturer or distributor to create shipment transaction
func (p *Pharma) CreateShipment(ctx contractapi.TransactionContextInterface) (string, error) {
	var manufacturerContract *manufacturer.Manufacturer
	var newShipment string

	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "distributorMSP" && clientMSPID != "manufacturerMSP"{
		return "", fmt.Errorf("client from org %v is not authorized to create shipment", clientMSPID)
	}

	// Records are passed in transient field to make it more secure.
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return "", fmt.Errorf("error getting transient: %v", err)
	}

	transientShipmentJSON, ok := transientMap["shipment_information"]
	if !ok {
		//log error to stdout
		return "", fmt.Errorf("new Shipment not found in the transient map input")
	}


	newShipment, err = manufacturerContract.CreateShipment(ctx, transientShipmentJSON)
	if err != nil {
		return "", fmt.Errorf("failed to create shipment: %v", err)
	} 
	

	return newShipment, nil
}

// Invokes the UpdateShipment smart contract in transporter to update shipment transaction
func (p *Pharma) UpdateShipment(ctx contractapi.TransactionContextInterface) (string, error) {
	var transporterContract *transporter.Transporter
	var updateShipment string

	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "transporterMSP" {
		return "", fmt.Errorf("client from org %v is not authorized to update shipment", clientMSPID)
	}

	// Records are passed in transient field to make it more secure.
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return "", fmt.Errorf("error getting transient: %v", err)
	}


	transientShipmentJSON, ok := transientMap["update_information"]
	if !ok {
		//log error to stdout
		return "", fmt.Errorf("update Shipment not found in the transient map input")
	}


	updateShipment, err = transporterContract.UpdateShipment(ctx, transientShipmentJSON)
	if err != nil {
		return "", fmt.Errorf("failed to update shipment: %v", err)
	} 
	

	return updateShipment, nil
}

// Invokes the RetailDrug smart contract in retailer to sell drug to customers
func (p *Pharma) RetailDrug(ctx contractapi.TransactionContextInterface) (string, error) {
	var retailerContract *retailer.Retailer

	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "retailerMSP"{
		return "", fmt.Errorf("client from org %v is not authorized to create shipment", clientMSPID)
	}

	// Records are passed in transient field to make it more secure.
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return "", fmt.Errorf("error getting transient: %v", err)
	}

	transientRetailJSON, ok := transientMap["retail_information"]
	if !ok {
		//log error to stdout
		return "", fmt.Errorf("new retail not found in the transient map input")
	}


	retailedDrug, err := retailerContract.RetailDrug(ctx, transientRetailJSON)
	if err != nil {
		return "", fmt.Errorf("failed to retail drug: %v", err)
	} 
	

	return retailedDrug, nil
}

// ViewHistory returns the chain of custody for a drug since issuance.
func (p *Pharma) ViewHistory(ctx contractapi.TransactionContextInterface, drugName string, serialNo string) ([]HistoryQueryResult, error) {

	drugCompositeKey, err := ctx.GetStub().CreateCompositeKey("drug.pharma-net.com", []string{drugName, serialNo})
	if err != nil {
		return nil, fmt.Errorf("failed to create composite key: %v", err)
	}

	resultsIterator, err := ctx.GetStub().GetHistoryForKey(drugCompositeKey)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var records []HistoryQueryResult
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var drug manufacturer.Drug
		if len(response.Value) > 0 {
			err = json.Unmarshal(response.Value, &drug)
			if err != nil {
				return nil, err
			}
		} else {
			drug = manufacturer.Drug{
				ProductID: drugCompositeKey,
			}
		}

		timestamp, err := ptypes.Timestamp(response.Timestamp)
		if err != nil {
			return nil, err
		}

		record := HistoryQueryResult{
			TxId:      response.TxId,
			Timestamp: timestamp,
			Record:    &drug,
			IsDelete:  response.IsDelete,
		}
		records = append(records, record)
	}

	return records, nil
}

// ViewDrugCurrentState retrieves a drug from the ledger
func (p *Pharma) ViewDrugCurrentState(ctx contractapi.TransactionContextInterface, drugName string, serialNo string) (*manufacturer.Drug, error) {
	drugCompositeKey, err := ctx.GetStub().CreateCompositeKey("drug.pharma-net.com", []string{drugName, serialNo})
	if err != nil {
		return nil, fmt.Errorf("failed to create composite key: %v", err)
	}
	
	drugBytes, err := ctx.GetStub().GetState(drugCompositeKey)
	if err != nil {
		return nil, fmt.Errorf("failed to get asset %s: %v", drugCompositeKey, err)
	}
	if drugBytes == nil {
		return nil, fmt.Errorf("asset %s does not exist", drugCompositeKey)
	}

	var drug manufacturer.Drug
	err = json.Unmarshal(drugBytes, &drug)
	if err != nil {
		return nil, err
	}

	return &drug, nil
}

// Read the Registered Company
func (p *Pharma) ReadCompany(ctx contractapi.TransactionContextInterface, companyCRN string, companyName string) (*Company, error) {
	companyCompositeKey, err := ctx.GetStub().CreateCompositeKey("company.pharma-net.com", []string{companyName, companyCRN})
	if err != nil {
		return nil, fmt.Errorf("failed to create composite key into JSON: %v", err)
	}

	companyJSON, err := ctx.GetStub().GetState(companyCompositeKey) //get the company details from chaincode state
	if err != nil {
		return nil, fmt.Errorf("failed to read company: %v", err)
	}

	//No Company found, return empty response
	if companyJSON == nil {
		return nil, fmt.Errorf("%v does not exist in state ledger", err)
	}

	var company Company
	err = json.Unmarshal(companyJSON, &company)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	return &company, nil
}