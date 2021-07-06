/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const fs = require('fs');
const path = require('path');

exports.buildCCPManufacturer = () => {
	// load the common connection configuration file
	const ccpPath = path.resolve(__dirname, '..','..', 'network', 'organizations', 'peerOrganizations', 'manufacturer.pharma-net.com', 'connection-manufacturer.json');
	const fileExists = fs.existsSync(ccpPath);
	if (!fileExists) {
		throw new Error(`no such file or directory: ${ccpPath}`);
	}
	const contents = fs.readFileSync(ccpPath, 'utf8');

	// build a JSON object from the file contents
	const ccp = JSON.parse(contents);
	

	console.log(`Loaded the network configuration located at ${ccpPath}`);
	return ccp;
};

exports.buildCCPDistributor = () => {
	// load the common connection configuration file
	const ccpPath = path.resolve(__dirname, '..','..', 'network', 'organizations', 'peerOrganizations', 'distributor.pharma-net.com', 'connection-distributor.json');
	const fileExists = fs.existsSync(ccpPath);
	if (!fileExists) {
		throw new Error(`no such file or directory: ${ccpPath}`);
	}
	const contents = fs.readFileSync(ccpPath, 'utf8');

	// build a JSON object from the file contents
	const ccp = JSON.parse(contents);

	console.log(`Loaded the network configuration located at ${ccpPath}`);
	return ccp;
};

exports.buildCCPRetailer = () => {
	// load the common connection configuration file
	const ccpPath = path.resolve(__dirname, '..','..', 'network', 'organizations', 'peerOrganizations', 'retailer.pharma-net.com', 'connection-retailer.json');
	const fileExists = fs.existsSync(ccpPath);
	if (!fileExists) {
		throw new Error(`no such file or directory: ${ccpPath}`);
	}
	const contents = fs.readFileSync(ccpPath, 'utf8');

	// build a JSON object from the file contents
	const ccp = JSON.parse(contents);

	console.log(`Loaded the network configuration located at ${ccpPath}`);
	return ccp;
};

exports.buildCCPConsumer = () => {
	// load the common connection configuration file
	const ccpPath = path.resolve(__dirname, '..','..', 'network', 'organizations', 'peerOrganizations', 'consumer.pharma-net.com', 'connection-consumer.json');
	const fileExists = fs.existsSync(ccpPath);
	if (!fileExists) {
		throw new Error(`no such file or directory: ${ccpPath}`);
	}
	const contents = fs.readFileSync(ccpPath, 'utf8');

	// build a JSON object from the file contents
	const ccp = JSON.parse(contents);

	console.log(`Loaded the network configuration located at ${ccpPath}`);
	return ccp;
};

exports.buildCCPTransporter = () => {
	// load the common connection configuration file
	const ccpPath = path.resolve(__dirname, '..','..', 'network', 'organizations', 'peerOrganizations', 'transporter.pharma-net.com', 'connection-transporter.json');
	const fileExists = fs.existsSync(ccpPath);
	if (!fileExists) {
		throw new Error(`no such file or directory: ${ccpPath}`);
	}
	const contents = fs.readFileSync(ccpPath, 'utf8');

	// build a JSON object from the file contents
	const ccp = JSON.parse(contents);

	console.log(`Loaded the network configuration located at ${ccpPath}`);
	return ccp;
};

exports.buildWallet = async (Wallets, walletPath) => {
	// Create a new  wallet : Note that wallet is for managing identities.
	let wallet;
	if (walletPath) {
		wallet = await Wallets.newFileSystemWallet(walletPath);
		console.log(`Built a file system wallet at ${walletPath}`);
	} else {
		wallet = await Wallets.newInMemoryWallet();
		console.log('Built an in memory wallet');
	}

	return wallet;
};

exports.prettyJSONString = (inputString) => {
	if (inputString) {
		 return JSON.stringify(JSON.parse(inputString), null, 2);
	}
	else {
		 return inputString;
	}
}