/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');

const { buildCCPManufacturer, buildCCPDistributor, buildCCPRetailer, buildCCPConsumer, buildCCPTransporter, buildWallet } = require('./utils/AppUtil.js');
const { buildCAClient, registerAndEnrollUser, enrollAdmin } = require('./utils/CAUtil.js');

const myChannel = 'pharmachannel';
const myChaincodeName = 'pharma';

const mspManufacturer = 'manufacturerMSP';
const mspDistributor = 'distributorMSP';
const mspRetailer = 'retailerMSP';
const mspConsumer = 'consumerMSP';
const mspTransporter = 'transporterMSP';

const ManufacturerUserId = 'manufacturerUser1';
const DistributorUserId = 'distributorUser1';
const RetailerUserId = 'retailerUser1';
const ConsumerUserId = 'consumerUser1';
const TransporterUserId = 'transporterUser1';

async function initContractFromManufacturerIdentity() {
    console.log('\n--> Fabric client user & Gateway init: Using Manufacturer identity to Manufacturer Peer');
    // build an in memory object with the network configuration (also known as a connection profile)
    const ccpManufacturer = buildCCPManufacturer();

    // build an instance of the fabric ca services client based on
    // the information in the network configuration
    const caManufacturerClient = buildCAClient(FabricCAServices, ccpManufacturer, 'ca.manufacturer.pharma-net.com');

    // setup the wallet to cache the credentials of the application user, on the app server locally
    const walletPathManufacturer = path.join(__dirname, 'wallet/manufacturer');
    const walletManufacturer = await buildWallet(Wallets, walletPathManufacturer);

    // in a real application this would be done on an administrative flow, and only once
    // stores admin identity in local wallet, if needed
    await enrollAdmin(caManufacturerClient, walletManufacturer, mspManufacturer);
    // register & enroll application user with CA, which is used as client identify to make chaincode calls
    // and stores app user identity in local wallet
    // In a real application this would be done only when a new user was required to be added
    // and would be part of an administrative flow
    await registerAndEnrollUser(caManufacturerClient, walletManufacturer, mspManufacturer, ManufacturerUserId/*, 'manufacturer.department1'*/);

    try {
        // Create a new gateway for connecting to Org's peer node.
        const gatewayManufacturer = new Gateway();
        //connect using Discovery enabled
        await gatewayManufacturer.connect(ccpManufacturer,
            { wallet: walletManufacturer, identity: ManufacturerUserId, discovery: { enabled: true, asLocalhost: true } });

        return gatewayManufacturer;
    } catch (error) {
        console.error(`Error in connecting to gateway: ${error}`);
        process.exit(1);
    }
}

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



async function main(org) {
    if(org == "Manufacturer") {
        /** ******* Fabric client init: Using Manufacturer identity to Manufacturer Peer ********** */
    const gatewayManufacturer = await initContractFromManufacturerIdentity();
    const networkManufacturer = await gatewayManufacturer.getNetwork(myChannel);
    const contractManufacturer = networkManufacturer.getContract(myChaincodeName);
    // Since this sample chaincode uses, Private Data Collection level endorsement policy, addDiscoveryInterest
    // scopes the discovery service further to use the endorsement policies of collections, if any
    contractManufacturer.addDiscoveryInterest({ name: myChaincodeName});
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
    
    
    
}

module.exports.execute = main;

