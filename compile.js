const path = require("path");
const fs = require("fs");
const solc = require("solc");

const vehicle_rentalPath = path.resolve(__dirname, "contracts", "Vehicle_Rental.sol");
const source = fs.readFileSync(vehicle_rentalPath, "utf8");

//module.exports = solc.compile(source, 1).contracts[":Vehicle_Rental"]; // This would be used for earlier versions of solc

const input = {
    language: "Solidity",
    sources: {
      "Vehicle_Rental.sol": {
        content: source,
      },
    },
    settings: {
      outputSelection: {
        "*": {
          "*": ["*"],
        },
      },
    },
  };
  const output = JSON.parse(solc.compile(JSON.stringify(input)));
   
  module.exports = output.contracts["Vehicle_Rental.sol"].Vehicle_Rental;