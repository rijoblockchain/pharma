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

async function main(newCompany) {
    try {
       const org = newCompany["organizationRole"] 
       const contractOrg = await init.initContract(org)

       try{
           let result
        
            console.log(`Registering ${org} to company state ledger`);
            let statefulTxn = contractOrg.createTransaction('RegisterCompany');
            //if you need to customize endorsement to specific set of Orgs, use setEndorsingOrganizations
            //statefulTxn.setEndorsingOrganizations(mspOrg1);
            let tmapData = Buffer.from(JSON.stringify(newCompany));
            
            statefulTxn.setTransient({
                company_records: tmapData
            });
            result = await statefulTxn.submit();
            console.log(result)
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