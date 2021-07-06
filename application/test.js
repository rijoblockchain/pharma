// For this usecase illustration, we will use both Org1 & Org2 client identity from this same app
// In real world the Org1 & Org2 identity will be used in different apps to achieve asset transfer.
async function main() {
    try {

        /** ******* Fabric client init: Using Org1 identity to Org1 Peer ********** */
        const gatewayOrg1 = await initContractFromOrg1Identity();
        const networkOrg1 = await gatewayOrg1.getNetwork(myChannel);
        const contractOrg1 = networkOrg1.getContract(myChaincodeName);
        // Since this sample chaincode uses, Private Data Collection level endorsement policy, addDiscoveryInterest
        // scopes the discovery service further to use the endorsement policies of collections, if any
        contractOrg1.addDiscoveryInterest({ name: myChaincodeName, collectionNames: [memberAssetCollectionName, org1PrivateCollectionName] });

        /** ~~~~~~~ Fabric client init: Using Org2 identity to Org2 Peer ~~~~~~~ */
        const gatewayOrg2 = await initContractFromOrg2Identity();
        const networkOrg2 = await gatewayOrg2.getNetwork(myChannel);
        const contractOrg2 = networkOrg2.getContract(myChaincodeName);
        contractOrg2.addDiscoveryInterest({ name: myChaincodeName, collectionNames: [memberAssetCollectionName, org2PrivateCollectionName] });
        try {
            // Sample transactions are listed below
            // Add few sample Assets & transfers one of the asset from Org1 to Org2 as the new owner
            let randomNumber = Math.floor(Math.random() * 1000) + 1;
            // use a random key so that we can run multiple times
            let assetID1 = `asset${randomNumber}`;
            let assetID2 = `asset${randomNumber + 1}`;
            const assetType = 'ValuableAsset';
            let result;
            let asset1Data = { objectType: assetType, assetID: assetID1, color: 'green', size: 20, appraisedValue: 100 };
            let asset2Data = { objectType: assetType, assetID: assetID2, color: 'blue', size: 35, appraisedValue: 727 };

            console.log('\n**************** As Org1 Client ****************');
            console.log('Adding Assets to work with:\n--> Submit Transaction: CreateAsset ' + assetID1);
            let statefulTxn = contractOrg1.createTransaction('CreateAsset');
            //if you need to customize endorsement to specific set of Orgs, use setEndorsingOrganizations
            //statefulTxn.setEndorsingOrganizations(mspOrg1);
            let tmapData = Buffer.from(JSON.stringify(asset1Data));
            statefulTxn.setTransient({
                asset_properties: tmapData
            });
            result = await statefulTxn.submit();

            //Add asset2
            console.log('\n--> Submit Transaction: CreateAsset ' + assetID2);
            statefulTxn = contractOrg1.createTransaction('CreateAsset');
            tmapData = Buffer.from(JSON.stringify(asset2Data));
            statefulTxn.setTransient({
                asset_properties: tmapData
            });
            result = await statefulTxn.submit();


            console.log('\n--> Evaluate Transaction: GetAssetByRange asset0-asset9');
            // GetAssetByRange returns assets on the ledger with ID in the range of startKey (inclusive) and endKey (exclusive)
            result = await contractOrg1.evaluateTransaction('GetAssetByRange', 'asset0', 'asset9');
            console.log(`<-- result: ${prettyJSONString(result.toString())}`);
            if (!result || result.length === 0) {
                doFail('recieved empty query list for GetAssetByRange');
            }
            console.log('\n--> Evaluate Transaction: ReadAssetPrivateDetails from ' + org1PrivateCollectionName);
            // ReadAssetPrivateDetails reads data from Org's private collection. Args: collectionName, assetID
            result = await contractOrg1.evaluateTransaction('ReadAssetPrivateDetails', org1PrivateCollectionName, assetID1);
            console.log(`<-- result: ${prettyJSONString(result.toString())}`);
            verifyAssetPrivateDetails(result, assetID1, 100);

            // Attempt Transfer the asset to Org2 , without Org2 adding AgreeToTransfer //
            // Transaction should return an error: "failed transfer verification ..."
            let buyerDetails = { assetID: assetID1, buyerMSP: mspOrg2 };
            try {
                console.log('\n--> Attempt Submit Transaction: TransferAsset ' + assetID1);
                statefulTxn = contractOrg1.createTransaction('TransferAsset');
                tmapData = Buffer.from(JSON.stringify(buyerDetails));
                statefulTxn.setTransient({
                    asset_owner: tmapData
                });
                result = await statefulTxn.submit();
                console.log('******** FAILED: above operation expected to return an error');
            } catch (error) {
                console.log(`   Successfully caught the error: \n    ${error}`);
            }
            console.log('\n~~~~~~~~~~~~~~~~ As Org2 Client ~~~~~~~~~~~~~~~~');
            console.log('\n--> Evaluate Transaction: ReadAsset ' + assetID1);
            result = await contractOrg2.evaluateTransaction('ReadAsset', assetID1);
            console.log(`<-- result: ${prettyJSONString(result.toString())}`);
            verifyAssetData(mspOrg2, result, assetID1, 'green', 20, Org1UserId);


            // Org2 cannot ReadAssetPrivateDetails from Org1's private collection due to Collection policy
            //    Will fail: await contractOrg2.evaluateTransaction('ReadAssetPrivateDetails', org1PrivateCollectionName, assetID1);

            // Buyer from Org2 agrees to buy the asset assetID1 //
            // To purchase the asset, the buyer needs to agree to the same value as the asset owner
            let dataForAgreement = { assetID: assetID1, appraisedValue: 100 };
            console.log('\n--> Submit Transaction: AgreeToTransfer payload ' + JSON.stringify(dataForAgreement));
            statefulTxn = contractOrg2.createTransaction('AgreeToTransfer');
            tmapData = Buffer.from(JSON.stringify(dataForAgreement));
            statefulTxn.setTransient({
                asset_value: tmapData
            });
            result = await statefulTxn.submit();

            //Buyer can withdraw the Agreement, using DeleteTranferAgreement
            /*statefulTxn = contractOrg2.createTransaction('DeleteTranferAgreement');
            statefulTxn.setEndorsingOrganizations(mspOrg2);
            let dataForDeleteAgreement = { assetID: assetID1 };
            tmapData = Buffer.from(JSON.stringify(dataForDeleteAgreement));
            statefulTxn.setTransient({
                agreement_delete: tmapData
            });
            result = await statefulTxn.submit();*/

            console.log('\n**************** As Org1 Client ****************');
            // All members can send txn ReadTransferAgreement, set by Org2 above
            console.log('\n--> Evaluate Transaction: ReadTransferAgreement ' + assetID1);
            result = await contractOrg1.evaluateTransaction('ReadTransferAgreement', assetID1);
            console.log(`<-- result: ${prettyJSONString(result.toString())}`);

            // Transfer the asset to Org2 //
            // To transfer the asset, the owner needs to pass the MSP ID of new asset owner, and initiate the transfer
            console.log('\n--> Submit Transaction: TransferAsset ' + assetID1);

            statefulTxn = contractOrg1.createTransaction('TransferAsset');
            tmapData = Buffer.from(JSON.stringify(buyerDetails));
            statefulTxn.setTransient({
                asset_owner: tmapData
            });
            result = await statefulTxn.submit();

            //Again ReadAsset : results will show that the buyer identity now owns the asset:
            console.log('\n--> Evaluate Transaction: ReadAsset ' + assetID1);
            result = await contractOrg1.evaluateTransaction('ReadAsset', assetID1);
            console.log(`<-- result: ${prettyJSONString(result.toString())}`);
            verifyAssetData(mspOrg1, result, assetID1, 'green', 20, Org2UserId);

            //Confirm that transfer removed the private details from the Org1 collection:
            console.log('\n--> Evaluate Transaction: ReadAssetPrivateDetails');
            // ReadAssetPrivateDetails reads data from Org's private collection: Should return empty
            result = await contractOrg1.evaluateTransaction('ReadAssetPrivateDetails', org1PrivateCollectionName, assetID1);
            console.log(`<-- result: ${prettyJSONString(result.toString())}`);
            if (result && result.length > 0) {
                doFail('Expected empty data from ReadAssetPrivateDetails');
            }
            console.log('\n--> Evaluate Transaction: ReadAsset ' + assetID2);
            result = await contractOrg1.evaluateTransaction('ReadAsset', assetID2);
            console.log(`<-- result: ${prettyJSONString(result.toString())}`);
            verifyAssetData(mspOrg1, result, assetID2, 'blue', 35, Org1UserId);

            console.log('\n********* Demo deleting asset **************');
            let dataForDelete = { assetID: assetID2 };
            try {
                //Non-owner Org2 should not be able to DeleteAsset. Expect an error from DeleteAsset
                console.log('--> Attempt Transaction: as Org2 DeleteAsset ' + assetID2);
                statefulTxn = contractOrg2.createTransaction('DeleteAsset');
                tmapData = Buffer.from(JSON.stringify(dataForDelete));
                statefulTxn.setTransient({
                    asset_delete: tmapData
                });
                result = await statefulTxn.submit();
                console.log('******** FAILED : expected to return an error');
            } catch (error) {
                console.log(`  Successfully caught the error: \n    ${error}`);
            }
            // Delete Asset2 as Org1
            console.log('--> Submit Transaction: as Org1 DeleteAsset ' + assetID2);
            statefulTxn = contractOrg1.createTransaction('DeleteAsset');
            tmapData = Buffer.from(JSON.stringify(dataForDelete));
            statefulTxn.setTransient({
                asset_delete: tmapData
            });
            result = await statefulTxn.submit();

            console.log('\n--> Evaluate Transaction: ReadAsset ' + assetID2);
            result = await contractOrg1.evaluateTransaction('ReadAsset', assetID2);
            console.log(`<-- result: ${prettyJSONString(result.toString())}`);
            if (result && result.length > 0) {
                doFail('Expected empty read, after asset is deleted');
            }

            console.log('\n~~~~~~~~~~~~~~~~ As Org2 Client ~~~~~~~~~~~~~~~~');
            // Org2 can ReadAssetPrivateDetails: Org2 is owner, and private details exist in new owner's Collection
            console.log('\n--> Evaluate Transaction as Org2: ReadAssetPrivateDetails ' + assetID1 + ' from ' + org2PrivateCollectionName);
            result = await contractOrg2.evaluateTransaction('ReadAssetPrivateDetails', org2PrivateCollectionName, assetID1);
            console.log(`<-- result: ${prettyJSONString(result.toString())}`);
            verifyAssetPrivateDetails(result, assetID1, 100);
        } finally {
            // Disconnect from the gateway peer when all work for this client identity is complete
            gatewayOrg1.disconnect();
            gatewayOrg2.disconnect();
        }
    } catch (error) {
        console.error(`Error in transaction: ${error}`);
        if (error.stack) {
            console.error(error.stack);
        }
        process.exit(1);
    }
}

main();



async function initContractFromDistributorIdentity() {
    console.log('\n--> Fabric client user & Gateway init: Using Distributor identity to Distributor Peer');
    // build an in memory object with the network configuration (also known as a connection profile)
    const ccpDistributor = buildCCPDistributor();

    // build an instance of the fabric ca services client based on
    // the information in the network configuration
    const caDistributorClient = buildCAClient(FabricCAServices, ccpDistributor, 'ca.distributor.pharma-net.com');

    // setup the wallet to cache the credentials of the application user, on the app server locally
    const walletPathDistributor = path.join(__dirname, 'wallet/distributor');
    const walletDistributor = await buildWallet(Wallets, walletPathDistributor);

    // in a real application this would be done on an administrative flow, and only once
    // stores admin identity in local wallet, if needed
    await enrollAdmin(caDistributorClient, walletDistributor, mspDistributor);
    // register & enroll application user with CA, which is used as client identify to make chaincode calls
    // and stores app user identity in local wallet
    // In a real application this would be done only when a new user was required to be added
    // and would be part of an administrative flow
    await registerAndEnrollUser(caDistributorClient, walletDistributor, mspDistributor, DistributorUserId/*, 'distributor.department1'*/);

    try {
        // Create a new gateway for connecting to Org's peer node.
        const gatewayDistributor = new Gateway();
        //connect using Discovery enabled
        await gatewayDistributor.connect(ccpDistributor,
            { wallet: walletDistributor, identity: DistributorUserId, discovery: { enabled: true, asLocalhost: true } });

        return gatewayDistributor;
    } catch (error) {
        console.error(`Error in connecting to gateway: ${error}`);
        process.exit(1);
    }
}

async function initContractFromRetailerIdentity() {
    console.log('\n--> Fabric client user & Gateway init: Using Retailer identity to Retailer Peer');
    // build an in memory object with the network configuration (also known as a connection profile)
    const ccpRetailer = buildCCPRetailer();

    // build an instance of the fabric ca services client based on
    // the information in the network configuration
    const caRetailerClient = buildCAClient(FabricCAServices, ccpRetailer, 'ca.retailer.pharma-net.com');

    // setup the wallet to cache the credentials of the application user, on the app server locally
    const walletPathRetailer = path.join(__dirname, 'wallet/retailer');
    const walletRetailer = await buildWallet(Wallets, walletPathRetailer);

    // in a real application this would be done on an administrative flow, and only once
    // stores admin identity in local wallet, if needed
    await enrollAdmin(caRetailerClient, walletRetailer, mspRetailer);
    // register & enroll application user with CA, which is used as client identify to make chaincode calls
    // and stores app user identity in local wallet
    // In a real application this would be done only when a new user was required to be added
    // and would be part of an administrative flow
    await registerAndEnrollUser(caRetailerClient, walletRetailer, mspRetailer, RetailerUserId/*, 'retailer.department1'*/);

    try {
        // Create a new gateway for connecting to Org's peer node.
        const gatewayRetailer = new Gateway();
        //connect using Discovery enabled
        await gatewayRetailer.connect(ccpRetailer,
            { wallet: walletRetailer, identity: RetailerUserId, discovery: { enabled: true, asLocalhost: true } });

        return gatewayRetailer;
    } catch (error) {
        console.error(`Error in connecting to gateway: ${error}`);
        process.exit(1);
    }
}




async function initContractFromConsumerIdentity() {
    console.log('\n--> Fabric client user & Gateway init: Using Consumer identity to Consumer Peer');
    // build an in memory object with the network configuration (also known as a connection profile)
    const ccpConsumer = buildCCPConsumer();

    // build an instance of the fabric ca services client based on
    // the information in the network configuration
    const caConsumerClient = buildCAClient(FabricCAServices, ccpConsumer, 'ca.consumer.pharma-net.com');

    // setup the wallet to cache the credentials of the application user, on the app server locally
    const walletPathConsumer = path.join(__dirname, 'wallet/consumer');
    const walletConsumer = await buildWallet(Wallets, walletPathConsumer);

    // in a real application this would be done on an administrative flow, and only once
    // stores admin identity in local wallet, if needed
    await enrollAdmin(caConsumerClient, walletConsumer, mspConsumer);
    // register & enroll application user with CA, which is used as client identify to make chaincode calls
    // and stores app user identity in local wallet
    // In a real application this would be done only when a new user was required to be added
    // and would be part of an administrative flow
    await registerAndEnrollUser(caConsumerClient, walletConsumer, mspConsumer, ConsumerUserId/*, 'consumer.department1'*/);

    try {
        // Create a new gateway for connecting to Org's peer node.
        const gatewayConsumer = new Gateway();
        //connect using Discovery enabled
        await gatewayConsumer.connect(ccpConsumer,
            { wallet: walletConsumer, identity: ConsumerUserId, discovery: { enabled: true, asLocalhost: true } });

        return gatewayConsumer;
    } catch (error) {
        console.error(`Error in connecting to gateway: ${error}`);
        process.exit(1);
    }
}

async function initContractFromTransporterIdentity() {
    console.log('\n--> Fabric client user & Gateway init: Using Transporter identity to Transporter Peer');
    // build an in memory object with the network configuration (also known as a connection profile)
    const ccpTransporter = buildCCPTransporter();

    // build an instance of the fabric ca services client based on
    // the information in the network configuration
    const caTransporterClient = buildCAClient(FabricCAServices, ccpTransporter, 'ca.transporter.pharma-net.com');

    // setup the wallet to cache the credentials of the application user, on the app server locally
    const walletPathTransporter = path.join(__dirname, 'wallet/transporter');
    const walletTransporter = await buildWallet(Wallets, walletPathTransporter);

    // in a real application this would be done on an administrative flow, and only once
    // stores admin identity in local wallet, if needed
    await enrollAdmin(caTransporterClient, walletTransporter, mspTransporter);
    // register & enroll application user with CA, which is used as client identify to make chaincode calls
    // and stores app user identity in local wallet
    // In a real application this would be done only when a new user was required to be added
    // and would be part of an administrative flow
    await registerAndEnrollUser(caTransporterClient, walletTransporter, mspTransporter, TransporterUserId/*, 'transporter.department1'*/);

    try {
        // Create a new gateway for connecting to Org's peer node.
        const gatewayTransporter = new Gateway();
        //connect using Discovery enabled
        await gatewayTransporter.connect(ccpTransporter,
            { wallet: walletTransporter, identity: TransporterUserId, discovery: { enabled: true, asLocalhost: true } });

        return gatewayTransporter;
    } catch (error) {
        console.error(`Error in connecting to gateway: ${error}`);
        process.exit(1);
    }
}



if(org == "Distributor") {
    /** ******* Fabric client init: Using Manufacturer identity to Manufacturer Peer ********** */
const gatewayDistributor = await initContractFromDistributorIdentity();
const networkDistributor = await gatewayDistributor.getNetwork(myChannel);
const contractDistributor = networkDistributor.getContract(myChaincodeName);
// Since this sample chaincode uses, Private Data Collection level endorsement policy, addDiscoveryInterest
// scopes the discovery service further to use the endorsement policies of collections, if any
contractDistributor.addDiscoveryInterest({ name: myChaincodeName});
}
if(org == "Retailer") {
    /** ******* Fabric client init: Using Retailer identity to Retailer Peer ********** */
const gatewayRetailer = await initContractFromRetailerIdentity();
const networkRetailer = await gatewayRetailer.getNetwork(myChannel);
const contractRetailer = networkRetailer.getContract(myChaincodeName);
// Since this sample chaincode uses, Private Data Collection level endorsement policy, addDiscoveryInterest
// scopes the discovery service further to use the endorsement policies of collections, if any
contractRetailer.addDiscoveryInterest({ name: myChaincodeName});
}
if(org == "Consumer") {
    /** ******* Fabric client init: Using Consumer identity to Consumer Peer ********** */
const gatewayConsumer = await initContractFromConsumerIdentity();
const networkConsumer = await gatewayConsumer.getNetwork(myChannel);
const contractConsumer = networkConsumer.getContract(myChaincodeName);
// Since this sample chaincode uses, Private Data Collection level endorsement policy, addDiscoveryInterest
// scopes the discovery service further to use the endorsement policies of collections, if any
contractConsumer.addDiscoveryInterest({ name: myChaincodeName});
}
if(org == "Transporter") {
    /** ******* Fabric client init: Using Transporter identity to Transporter Peer ********** */
const gatewayTransporter = await initContractFromTransporterIdentity();
const networkTransporter = await gatewayTransporter.getNetwork(myChannel);
const contractTransporter = networkTransporter.getContract(myChaincodeName);
// Since this sample chaincode uses, Private Data Collection level endorsement policy, addDiscoveryInterest
// scopes the discovery service further to use the endorsement policies of collections, if any
contractTransporter.addDiscoveryInterest({ name: myChaincodeName});

}
    

