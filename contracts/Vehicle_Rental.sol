pragma solidity 0.8.0;


/** @title Vehicle Rental
  * @author Eduardo Santiago
  * @notice This is a basic contract that resembles the rental of a vehicle that also is able to log certain events.
  * @dev */

contract Vehicle_Rental {



    struct Vehicle {
        string vehicleID;
        string vehiclePlate;
        string vehicleBrand;
        string vehicleModel;
        address ownerAddress;
        uint24 initialFee;
        uint24 hourlyFee;

        bool isStored;
        bool isAvailable;
        address renter;
        uint start_time;
        uint end_time;

        string[] events;
        address[] renter_that_triggered_events;
    }

    mapping (string => Vehicle) Vehicles;


    /** @notice The addVehicle function serves the purpose of adding a new vehicle into  */
    function addVehicle(string memory _vehicleID, string memory _vehiclePlate, string memory _vehicleBrand, string memory _vehicleModel, uint24 _initialFee, uint24 _hourlyFee) public {
        
        if (keccak256(bytes(Vehicles[_vehicleID].vehicleID)) == keccak256(bytes(_vehicleID)))
            revert("This ID is already assigned. If you wish to update the information on this ID, please use the 'Update' function.");
        
        Vehicles[_vehicleID].vehicleID    = _vehicleID;
        Vehicles[_vehicleID].vehiclePlate = _vehiclePlate;
        Vehicles[_vehicleID].vehicleBrand = _vehicleBrand;
        Vehicles[_vehicleID].vehicleModel = _vehicleModel;
        Vehicles[_vehicleID].ownerAddress = msg.sender;
        Vehicles[_vehicleID].initialFee   = _initialFee;
        Vehicles[_vehicleID].hourlyFee    = _hourlyFee;

        Vehicles[_vehicleID].isStored     = true;
        Vehicles[_vehicleID].isAvailable  = true;

    }


    function getVehicle(string memory _vehicleID) view public returns(Vehicle memory) {
        if(!Vehicles[_vehicleID].isStored)
            revert("This ID is not registered in the database.");
      return Vehicles[_vehicleID];
   }


   function deleteVehicle(string memory _vehicleID) public {
       require(Vehicles[_vehicleID].ownerAddress == msg.sender, "Address not authorized.");

       if(!Vehicles[_vehicleID].isStored)
            revert("This ID is not registered in the database.");

       Vehicles[_vehicleID].isStored = false;
       Vehicles[_vehicleID].vehicleID = "";
    }


  function updateVehicle(string memory _vehicleID, string memory _vehiclePlate, string memory _vehicleBrand, string memory _vehicleModel, uint24 _initialFee, uint24 _hourlyFee) public {
      require(Vehicles[_vehicleID].ownerAddress == msg.sender, "Address not authorized.");
      require(Vehicles[_vehicleID].isAvailable == true, "Cannot update while vehicle is in use.");

       if(!Vehicles[_vehicleID].isStored)
            revert("This ID is not registered in the database.");
            
        Vehicles[_vehicleID].vehiclePlate = _vehiclePlate;
        Vehicles[_vehicleID].vehicleBrand = _vehicleBrand;
        Vehicles[_vehicleID].vehicleModel = _vehicleModel;
        Vehicles[_vehicleID].initialFee   = _initialFee;
        Vehicles[_vehicleID].hourlyFee    = _hourlyFee;
    }





// Now for the usage of the Vehicles

    

    function rentVehicle(string memory _vehicleID) public payable {
        require(msg.value >= Vehicles[_vehicleID].initialFee, "Not enough balance to proceed with the rental.");
        require(Vehicles[_vehicleID].isAvailable == true, "Vehicle is currently unavailable.");

        (bool sent, bytes memory data) = Vehicles[_vehicleID].ownerAddress.call{value: msg.value}("");
        require(sent, "Failed to send Ether.");

        Vehicles[_vehicleID].isAvailable = false;
        Vehicles[_vehicleID].renter      = msg.sender; 

        Vehicles[_vehicleID].start_time  = block.timestamp;
    }


    function getCurrentPrice(string memory _vehicleID) public returns(uint, uint) {
        require( Vehicles[_vehicleID].isAvailable == false, "The vehicle is not in use. Please check the identifier");
        Vehicles[_vehicleID].end_time  = block.timestamp;
        uint time = Vehicles[_vehicleID].end_time - Vehicles[_vehicleID].start_time;
        uint price = (time * uint(Vehicles[_vehicleID].hourlyFee)) / 3600 ;

        return (time, price);
    }


    function returnVehicle(string memory _vehicleID) payable public {
        require( msg.sender == Vehicles[_vehicleID].renter, "Invalid address.");

        Vehicles[_vehicleID].end_time  = block.timestamp;
        uint time = Vehicles[_vehicleID].end_time - Vehicles[_vehicleID].start_time;
        uint price = (time * uint(Vehicles[_vehicleID].hourlyFee)) / 3600 ;
        require(msg.value >= price, "Not enough balance to finish the rental.");

        Vehicles[_vehicleID].isAvailable  = true;
        delete Vehicles[_vehicleID].renter;
        delete Vehicles[_vehicleID].start_time;
        delete Vehicles[_vehicleID].end_time;
    }





    // Events

    function overSpeeding(string memory _vehicleID) public {
        require( msg.sender == Vehicles[_vehicleID].renter, "Invalid address.");

        Vehicles[_vehicleID].events.push("Overspeeding");
        Vehicles[_vehicleID].renter_that_triggered_events.push(msg.sender);
    }

    function suddenStop(string memory _vehicleID) public {
        require( msg.sender == Vehicles[_vehicleID].renter, "Invalid address.");

        Vehicles[_vehicleID].events.push("Sudden stop");
        Vehicles[_vehicleID].renter_that_triggered_events.push(msg.sender);
    }

    function accident(string memory _vehicleID) public {
        require( msg.sender == Vehicles[_vehicleID].renter, "Invalid address.");

        Vehicles[_vehicleID].events.push("Accident");
        Vehicles[_vehicleID].renter_that_triggered_events.push(msg.sender);
    }

    function malfunction(string memory _vehicleID) public {
        require( msg.sender == Vehicles[_vehicleID].renter, "Invalid address.");

        Vehicles[_vehicleID].events.push("Malfunction");
        Vehicles[_vehicleID].renter_that_triggered_events.push(msg.sender);
    }


}