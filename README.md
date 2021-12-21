# Vehicle Rental - Smart Contract

This is a simple Solidity smart contract (built on version 0.8.0) that aims to emulate a decentralized system capable of providing any vehicle rental service to whoever from whoever.

This Smart Contract is based on the premisse that the vehicle has a unique *ID*. The vehicle's owner can then register this *ID* to a vehicle, detailing the brand, model, plate number (if it's a car or motorcycle), and, most importantly, an initial fee and hourly fee.

This Smart Contract can also append various events while the vehicle is being rented. These events could include overspeeding, abrupt stopping, an accident, or a vehicle malfunction. * ***Unfortunately, because there is no direct connection between the vehicle and this Smart Contract, this feature is limited to the client's willingness to provide this input.*** *

There is currently no frontend that allows for a more seamless experience with this Smart Contract.

---
## Usage

This section is applicable in both Remix or when running locally on your computer.

- For a prospective owner:

    First use the `addVehicle` function detailing the vehicle ID, plate number (if it applies, otherwise just leave it empty), the vehicle brand, its model, an initial fee in *Wei* (again, this is optional) and the hourly fee in *Wei*.

    In the case there was a mistake with the initial properties, the owner can always update with the function `updateVehicle`. To delete the vehicle from the database, simply use the `deleteVehicle` function. The vehicle details can always be checked with the function `getVehicle`.

- For the interested renter:

    The first step would be to use the `rentVehicle` function, specifying the vehicle ID of interest. During the renting of the vehicle, by using the function `getCurrentPrice`, the renter has the ability to check the current price for the rent (in *Wei*). 
    
    To return the vehicle, simply use the `returnVehicle` function with the vehicle's ID while making sure to provide enough *ETH* for the transaction.

    Due to limitations of the current Smart Contract, the event log to the vehicle must be made by the renter himself. The possible events are given by the functions `overSpeeding`, `suddenStop`, `accident` and `malfunction` for the cases of overspeeding, abrupt stopping, accident and vehicle malfunction, respectively. The only input for each of these functions is the vehicle ID.


---
## Testing

For testing, *Web3* v1.6.1 and *Mocha* v9.1.3 are used and a contract instance is created using *Ganache-CLI* v6.12.2 as our local test network. Unfortunately, I was unable to get a test contract deployment to work and, as a result, I was unable to formulate formal testing using this approach. The issue must be on lines 29-31 of `test/Vehicle_Rental.test.js`, but I'm not sure why.

Due to this, all my testing was made by hand on the Remix "*Deploy & Run Transactions*" interface itself. For my testing I have tried the following:

- `addVehicle()` function:

    Tried to add a new vehicle with both new and repeated ID's. Also experimented with adding multiple vehicles.

- `getVehicle()` function:

    Checked for calls of unregistered ID's and, if otherwise, the vehicle information was displayed.

- `deleteVehicle()` function:

    Tried to delete a vehicle with a different address from the one of the owner, as well as removing an ID that was not present in the database.

- `updateVehicle()` function:

    Checked if another address other than the owner could overwrite the vehicle's data, if the vehicle was in use and wether it was registered (via its ID) or not.

- `rentVehicle()` function:

    Checked if a car in use could be rented by another person, if the ID of the vehicle is registered and if the renter has sent enough *ETH* to the owner such that it complies with the *initialFee* imposed by the latter. Also checked if the availability changed, as well as if the renter's address and *start_time* were logged.

- `getCurrentPrice()` function:

    Checked first wether the ID of the vehicle is registered as well as if the function would go through in the case of the vehicle not being in use. Also checked if the total amount of time was correct, along with the calculated price.

- `returnVehicle()` function:

    Checked first wether the ID of the vehicle is registered as well as if anyone besides the renter could proceed with the function. Checked wether the fee was well calculated, if the timer would continue in the case the renter didn't send enough *ETH* to the owner and if the availability, renter address and time logs were clean.

- For the event functions:

    Checked wether or not these functions were called by the renter and the events were stored in order of the function calls along with the renter at the time.