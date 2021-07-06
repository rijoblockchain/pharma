/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, Wallets } = require('fabric-network');
const path = require('path');

const { buildCCPManufacturer, buildCCPDistributor, buildCCPRetailer, buildCCPConsumer, buildCCPTransporter, buildWallet } = require('./utils/AppUtil.js');

const myChannel = 'pharmachannel';
const myChaincodeName = 'pharma';

let gateway
const ManufacturerUserId = 'manufacturerUser1';
const DistributorUserId = 'distributorUser1';
const RetailerUserId = 'retailerUser1';
const ConsumerUserId = 'consumerUser1';
const TransporterUserId = 'transporterUser1';

async function initContractFromManufacturer() {
    console.log('\n--> Fabric client user & Gateway init: Using Manufacturer identity to Manufacturer Peer');
    // build an in memory object with the network configuration (also known as a connection profile)
    const ccpManufacturer = buildCCPManufacturer();

    // setup the wallet to cache the credentials of the application user, on the app server locally
    const walletPathManufacturer = path.join(__dirname, 'wallet/manufacturer');
    const walletManufacturer = await buildWallet(Wallets, walletPathManufacturer);
    const identity = await walletManufacturer.get(ManufacturerUserId);
		if (!identity) {
			console.log('An identity for the manufacturer user does not exist in the wallet');
			return;
		}

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

async function initContractFromDistributor() {
    console.log('\n--> Fabric client user & Gateway init: Using Distributor identity to Distributor Peer');
    // build an in memory object with the network configuration (also known as a connection profile)
    const ccpDistributor = buildCCPDistributor();

    // setup the wallet to cache the credentials of the application user, on the app server locally
    const walletPathDistributor = path.join(__dirname, 'wallet/distributor');
    const walletDistributor = await buildWallet(Wallets, walletPathDistributor);
    const identity = await walletDistributor.get(DistributorUserId);
		if (!identity) {
			console.log('An identity for the distributor user does not exist in the wallet');
			return;
		}

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

async function initContractFromRetailer() {
    console.log('\n--> Fabric client user & Gateway init: Using Retailer identity to Retailer Peer');
    // build an in memory object with the network configuration (also known as a connection profile)
    const ccpRetailer = buildCCPRetailer();

    // setup the wallet to cache the credentials of the application user, on the app server locally
    const walletPathRetailer = path.join(__dirname, 'wallet/retailer');
    const walletRetailer = await buildWallet(Wallets, walletPathRetailer);
    const identity = await walletRetailer.get(RetailerUserId);
		if (!identity) {
			console.log('An identity for the retailer user does not exist in the wallet');
			return;
		}

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

async function initContractFromConsumer() {
    console.log('\n--> Fabric client user & Gateway init: Using Consumer identity to Consumer Peer');
    // build an in memory object with the network configuration (also known as a connection profile)
    const ccpConsumer = buildCCPConsumer();

    // setup the wallet to cache the credentials of the application user, on the app server locally
    const walletPathConsumer = path.join(__dirname, 'wallet/consumer');
    const walletConsumer = await buildWallet(Wallets, walletPathConsumer);
    const identity = await walletConsumer.get(ConsumerUserId);
		if (!identity) {
			console.log('An identity for the consumer user does not exist in the wallet');
			return;
		}

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

async function initContractFromTransporter() {
    console.log('\n--> Fabric client user & Gateway init: Using Transporter identity to Transporter Peer');
    // build an in memory object with the network configuration (also known as a connection profile)
    const ccpTransporter = buildCCPTransporter();

    // setup the wallet to cache the credentials of the application user, on the app server locally
    const walletPathTransporter = path.join(__dirname, 'wallet/transporter');
    const walletTransporter = await buildWallet(Wallets, walletPathTransporter);
    const identity = await walletTransporter.get(TransporterUserId);
		if (!identity) {
			console.log('An identity for the transporter user does not exist in the wallet');
			return;
		}

   
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



exports.initContract = async (org) => {
    if(org == "Manufacturer") {
        /** ******* Fabric client init: Using Manufacturer identity to Manufacturer Peer ********** */
    gateway = await initContractFromManufacturer();
    }
    if(org == "Distributor") {
        /** ******* Fabric client init: Using Manufacturer identity to Manufacturer Peer ********** */
    gateway = await initContractFromDistributor();
    }
    if(org == "Retailer") {
        /** ******* Fabric client init: Using Retailer identity to Retailer Peer ********** */
    gateway = await initContractFromRetailer();
    }
    if(org == "Consumer") {
        /** ******* Fabric client init: Using Consumer identity to Consumer Peer ********** */
    gateway = await initContractFromConsumer();
    }
    if(org == "Transporter") {
        /** ******* Fabric client init: Using Transporter identity to Transporter Peer ********** */
    gateway = await initContractFromTransporter();    
    }

    const network = await gateway.getNetwork(myChannel);
    const contract = network.getContract(myChaincodeName);
    // Since this sample chaincode uses, Private Data Collection level endorsement policy, addDiscoveryInterest
    // scopes the discovery service further to use the endorsement policies of collections, if any
    contract.addDiscoveryInterest({ name: myChaincodeName});
    return contract
    
}

exports.disconnect = () => {
	console.log('.....Disconnecting from Fabric Gateway');
	gateway.disconnect();
}


