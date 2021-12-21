const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

//const { abi, evm } = require('../compile');
//const { interface, bytecode } = require('../compile');


const compiledFile = require("../compile"); 
const interface = compiledFile.abi;
const bytecode = compiledFile.evm.bytecode.object;

//const compiled_contract = require('../compile');
//const interface_abi = compiled_contract.output.contracts['Vehicle_Rental.sol']['Vehicle_Rental'].abi;
//const bytecode = compiled_contract.output.contracts['Vehicle_Rental.sol']['Vehicle_Rental'].evm.bytecode.object;



let accounts;
let vehicle_rental;


beforeEach(async () => {
    // Get a list of all accounts
    accounts = await web3.eth.getAccounts();

    // Use one of those accounts to deploy the contract
    vehicle_rental = await new web3.eth.Contract(interface)
        .deploy({ data: bytecode /** , arguments: [] */ })
        .send({ from: accounts[0], gas: '1000000'})
});

describe('vehicle_rental', () => {
    it('deploys a contract', () => {
        console.log(vehicle_rental)
    });
});

