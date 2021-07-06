const express = require('express');
const app = express();
const cors = require('cors');
const port = 3000;

// Import all function modules
const addToWallet = require('./addToWallet');
const registerCompany = require('./registerCompany.js');
const addDrug = require('./addDrug.js');
const createPO = require('./createPO.js');
const createShipment = require('./createShipment.js');
const updateShipment = require('./updateShipment.js');
const retailDrug = require('./retailDrug.js');
const viewHistory = require('./viewHistory.js');
const viewDrugCurrentState = require('./viewDrugCurrentState.js');


// Define Express app settings
app.use(cors());
app.use(express.json()); // for parsing application/json
app.use(express.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded
app.set('title', 'Pharma App');

app.get('/', (req, res) => res.send("This is Pharma Supply Chain Application"));

function prettyJSONString(inputString) {
    if (inputString) {
        return JSON.stringify(JSON.parse(inputString), null, 2);
    }
    else {
        return inputString;
    }
}

app.post('/addToWallet', (req, res) => {
	addToWallet.execute(req.body.org)
			.then(() => {
				console.log('User credentials added to wallet');
				const result = {
					status: 'success',
					message: `${req.body.org} User credentials added to wallet`
				};
				res.json(result);
			})
			.catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/registerCompany', (req, res) => {
	//let newCompany = JSON.stringify(req.body);
	let newCompany = req.body;
	console.log(newCompany);
	registerCompany.execute(newCompany)
			.then((result) => {
				console.log(`Transaction has been successful, result is: ${prettyJSONString(result.toString())}`);
        		res.status(200).send(result);

			})
			.catch((error) => {
				console.error(`Failed to submit transaction: ${error}`);
        		process.exit(1);
			});
});

app.post('/addDrug', (req, res) => {
	let newDrug = req.body;
	console.log(newDrug);
	addDrug.execute(newDrug)
			.then((result) => {
				console.log(`Transaction has been successful, result is: ${prettyJSONString(result.toString())}`);
        		res.status(200).send(result);

			})
			.catch((error) => {
				console.error(`Failed to submit transaction: ${error}`);
        		process.exit(1);
			});
});

app.post('/createPO', (req, res) => {
	let newPO = req.body;
	console.log(newPO);
	createPO.execute(newPO)
			.then((result) => {
				console.log(`Transaction has been successful, result is: ${prettyJSONString(result.toString())}`);
        		res.status(200).send(result);

			})
			.catch((error) => {
				console.error(`Failed to submit transaction: ${error}`);
        		process.exit(1);
			});
});

app.post('/createShipment', (req, res) => {
	let newShipment = req.body;
	console.log(newShipment);
	createShipment.execute(newShipment)
			.then((result) => {
				console.log(`Transaction has been successful, result is: ${prettyJSONString(result.toString())}`);
        		res.status(200).send(result);

			})
			.catch((error) => {
				console.error(`Failed to submit transaction: ${error}`);
        		process.exit(1);
			});
});

app.post('/updateShipment', (req, res) => {
	let newShipment = req.body;
	console.log(newShipment);
	updateShipment.execute(newShipment)
			.then((result) => {
				console.log(`Transaction has been successful, result is: ${prettyJSONString(result.toString())}`);
        		res.status(200).send(result);

			})
			.catch((error) => {
				console.error(`Failed to submit transaction: ${error}`);
        		process.exit(1);
			});
});

app.post('/retailDrug', (req, res) => {
	let retailedDrug = req.body;
	console.log(retailedDrug);
	retailDrug.execute(retailedDrug)
			.then((result) => {
				console.log(`Transaction has been successful, result is: ${prettyJSONString(result.toString())}`);
        		res.status(200).send(result);

			})
			.catch((error) => {
				console.error(`Failed to submit transaction: ${error}`);
        		process.exit(1);
			});
});

app.post('/viewHistory', (req, res) => {
	viewHistory.execute(req.body.org, req.body.drugName, req.body.serialNo)
			.then((result) => {
				console.log(`Evaluation has been successful, result is: ${prettyJSONString(result.toString())}`);
        		res.status(200).send(result);

			})
			.catch((error) => {
				console.error(`Failed to evaluate: ${error}`);
        		process.exit(1);
			});
});

app.post('/viewDrugCurrentState', (req, res) => {
	viewDrugCurrentState.execute(req.body.org, req.body.drugName, req.body.serialNo)
			.then((result) => {
				console.log(`Evaluation has been successful, result is: ${prettyJSONString(result.toString())}`);
        		res.status(200).send(result);

			})
			.catch((error) => {
				console.error(`Failed to evaluate: ${error}`);
        		process.exit(1);
			});
});




app.listen(port, () => console.log(`Pharma Supply Chain App listening on port ${port}!`));