/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const init = require('./init.js');

function prettyJSONString(inputString) {
    if (inputString) {
        return JSON.stringify(JSON.parse(inputString), null, 2);
    }
    else {
        return inputString;
    }
}

async function main(org, drugName, serialNo) {
    try {
       const contractOrg = await init.initContract(org)

       try{
           let result
                   
            console.log('\n--> Evaluate Transaction: GetDrugHistory, get the history of a drug(001)');
			result = await contractOrg.evaluateTransaction('viewHistory', drugName, serialNo);
            console.log(`*** Result: ${prettyJSONString(result.toString())}`);
            return result
       }finally {
        // Disconnect from the gateway peer when all work for this client identity is complete
        init.disconnect();
    }

    }catch (error) {
        console.error(`Error in transaction: ${error}`);
        if (error.stack) {
            console.error(error.stack);
        }
        process.exit(1);
    }
}

module.exports.execute = main;