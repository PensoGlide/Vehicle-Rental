pragma solidity 0.8.0;


/// @title Vehicle Rental
/// @author Eduardo Santiago
/// @notice This is a basic contract that resembles the rental of a vehicle that also is able to log certain events.
/// @dev 

contract Vehicle_Rental {


    ///////////////////////////     Parameter definition     ///////////////////////////


    /** @dev Each vehicle is stored in a struct-type variable containing various owner-defined parameters, variables for the flow of the contract and arrays for the events and the respective renter with which these events ocurred.
           * Each Vehicle is then stored in 
           * The biggest place for improvement of this struct is in the storing of events and the respective renter. Ideally a mapping would be used, but I couldn't make it work as of yet.*/

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




    ///////////////////////////     Interaction with database     ///////////////////////////


    /// @notice The addVehicle function serves the purpose of adding a new vehicle into the Smart-Contract
    /// @dev The only restriction for this function is that the vehicle ID is unique
    /// @param _vehicleID     Identifier of the vehicle
    /// @param _vehiclePlate  The plate of the vehicle 
    /// @param _vehicleBrand  Brand / Company that manufactured the vehicle
    /// @param _vehicleModel  Model of the vehicle at hand
    /// @param _initialFee    The initial fee for the rental of the vehicle in Wei. If it is undesired, simply set this to 0
    /// @param _hourlyFee     The fee that will be payed each hour by the renter in Wei
    
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


    /// @notice The getVehicle function serves to get the information of the vehicle with the ID provided as input
    /// @dev The only restriction to this function is wether the the vehicle is stored or not (a parameter of the struct Vehicle)
    /// @param _vehicleID  Identifier of the vehicle whose information is intended to retreive
    /// @return Vehicle    Struct with all the parameters of the desired vehicle
    
    function getVehicle(string memory _vehicleID) view public returns(Vehicle memory) {
        if(!Vehicles[_vehicleID].isStored)
            revert("This ID is not registered in the database.");
      return Vehicles[_vehicleID];
   }


    /// @notice The deleteVehicle function serves to remove the vehicle from the usable vehicles
    /// @dev There are two restrictions. The first is that only the owner of the vehicle is able to use this function and that the ID is registered. The way the vehicle is removed is by setting the isStored property to false and emptying the ID used
    /// @param _vehicleID  Identifier of the vehicle whose information is intended to retreive
    
    function deleteVehicle(string memory _vehicleID) public {
       require(Vehicles[_vehicleID].ownerAddress == msg.sender, "Address not authorized.");

       if(!Vehicles[_vehicleID].isStored)
            revert("This ID is not registered in the database.");

       Vehicles[_vehicleID].isStored = false;
       Vehicles[_vehicleID].vehicleID = "";
    }


    /// @notice The updateVehicle function serves to update the properties of the vehicle intended
    /// @dev There are several restrictions. The first is that only the owner of the vehicle is able to use this function, the vehicle must be available to use and that the ID is registered.
    /// @param _vehiclePlate  The plate of the vehicle 
    /// @param _vehicleBrand  Brand / Company that manufactured the vehicle
    /// @param _vehicleModel  Model of the vehicle at hand
    /// @param _initialFee    The initial fee for the rental of the vehicle in Wei. If it is undesired, simply set this to 0
    /// @param _hourlyFee     The fee that will be payed each hour by the renter in Wei
    
    function updateVehicle(string memory _vehicleID, string memory _vehiclePlate, string memory _vehicleBrand, string memory _vehicleModel, uint24 _initialFee, uint24 _hourlyFee) public {
      require(Vehicles[_vehicleID].ownerAddress == msg.sender, "Address not authorized.");
      require(Vehicles[_vehicleID].isAvailable == true, "Cannot update while vehicle is unavailable.");

       if(!Vehicles[_vehicleID].isStored)
            revert("This ID is not registered in the database.");
            
        Vehicles[_vehicleID].vehiclePlate = _vehiclePlate;
        Vehicles[_vehicleID].vehicleBrand = _vehicleBrand;
        Vehicles[_vehicleID].vehicleModel = _vehicleModel;
        Vehicles[_vehicleID].initialFee   = _initialFee;
        Vehicles[_vehicleID].hourlyFee    = _hourlyFee;
    }





    ///////////////////////////     Usage of the Vehicles     ///////////////////////////

    
    /// @notice The rentVehicle function serves to allow the user to rent a vehicle by providing its ID
    /// @dev There are three restrictions. The ID must valid, the initial fee must be paid, the vehicle must be available and the transaction must be successful. This triggers a timer so that the renter pays for the time the car is registered in his/her name
    /// @param _vehicleID  Identifier of the vehicle intended to be rented
    
    function rentVehicle(string memory _vehicleID) public payable {
        if(!Vehicles[_vehicleID].isStored)
            revert("This ID is not registered in the database.");
        require(msg.value >= Vehicles[_vehicleID].initialFee, "Not enough balance to proceed with the rental.");
        require(Vehicles[_vehicleID].isAvailable == true, "Vehicle is currently unavailable.");

        (bool sent, bytes memory data) = Vehicles[_vehicleID].ownerAddress.call{value: msg.value}("");
        require(sent, "Failed to send Ether.");

        Vehicles[_vehicleID].isAvailable = false;
        Vehicles[_vehicleID].renter      = msg.sender; 

        Vehicles[_vehicleID].start_time  = block.timestamp;
    }


    /// @notice The getCurrentPrice function allows the user to check how much he is paying at he current time (taking into account the last mined block)
    /// @dev There are two restrictions. The ID must valid and the vehicle must be in use. The unix time converted into hours times the hourly price defined by the owner (if the number is decimal it is rounded to the lowest integer)
    /// @param _vehicleID  Identifier of the vehicle being used
    /// @return price      The price to be payed at the moment this function is used (and inserted in a block)
    
    function getCurrentPrice(string memory _vehicleID) public returns(uint) {
        if(!Vehicles[_vehicleID].isStored)
            revert("This ID is not registered in the database.");
        require( Vehicles[_vehicleID].isAvailable == false, "The vehicle is not in use. Please check the ID");
        Vehicles[_vehicleID].end_time  = block.timestamp;
        uint time = Vehicles[_vehicleID].end_time - Vehicles[_vehicleID].start_time;
        uint price = (time * uint(Vehicles[_vehicleID].hourlyFee)) / 3600 ;

        return price;
    }


    /// @notice The returnVehicle function allows the user to return the vehicle after successfully paying the stipulated fee
    /// @dev There are several restrictions. The ID must valid, the vehicle must be in use, the transfer should be successfull and the value must cover the fee. To determine the price, the unix time is converted into hours and is multiplied by the hourly price defined by the owner (if the number is decimal it is rounded to the lowest integer). Also, the renter address and timers are reset so that the rental process may be repeated
    /// @param _vehicleID  Identifier of the vehicle being used
    
    function returnVehicle(string memory _vehicleID) payable public {
        if(!Vehicles[_vehicleID].isStored)
            revert("This ID is not registered in the database.");
        require( msg.sender == Vehicles[_vehicleID].renter, "Invalid address.");

        Vehicles[_vehicleID].end_time  = block.timestamp;
        uint time = Vehicles[_vehicleID].end_time - Vehicles[_vehicleID].start_time;
        uint price = (time * uint(Vehicles[_vehicleID].hourlyFee)) / 3600 ;

        require(msg.value >= price, "Not enough balance to finish the rental.");
        (bool sent, bytes memory data) = Vehicles[_vehicleID].ownerAddress.call{value: msg.value}("");
        require(sent, "Failed to send Ether.");

        Vehicles[_vehicleID].isAvailable  = true;
        delete Vehicles[_vehicleID].renter;
        delete Vehicles[_vehicleID].start_time;
        delete Vehicles[_vehicleID].end_time;
    }





    ///////////////////////////     Events     ///////////////////////////


    /// @notice The overSpeeding function is used to register the ocurrence of overspeeding
    /// @dev Ideally, the vehicle would use this function automatically. As it stands, it only requires that it is the renter and not someone else that logs this event. The event is stored in an ordered array, as well as its user, so that there is a direct link between the indices of the type of event and renter with which that event ocurred
    /// @param _vehicleID  Identifier of the vehicle being used

    function overSpeeding(string memory _vehicleID) public {
        require( msg.sender == Vehicles[_vehicleID].renter, "Invalid address.");

        Vehicles[_vehicleID].events.push("Overspeeding");
        Vehicles[_vehicleID].renter_that_triggered_events.push(msg.sender);
    }


    /// @notice The suddenStop function is used to register the ocurrence of sudden stopping
    /// @dev Ideally, the vehicle would use this function automatically. As it stands, it only requires that it is the renter and not someone else that logs this event. The event is stored in an ordered array, as well as its user, so that there is a direct link between the indices of the type of event and renter with which that event ocurred
    /// @param _vehicleID  Identifier of the vehicle being used

    function suddenStop(string memory _vehicleID) public {
        require( msg.sender == Vehicles[_vehicleID].renter, "Invalid address.");

        Vehicles[_vehicleID].events.push("Sudden stop");
        Vehicles[_vehicleID].renter_that_triggered_events.push(msg.sender);
    }


    /// @notice The accident function is used to register the ocurrence of an accident
    /// @dev Ideally, the vehicle would use this function automatically. As it stands, it only requires that it is the renter and not someone else that logs this event. The event is stored in an ordered array, as well as its user, so that there is a direct link between the indices of the type of event and renter with which that event ocurred
    /// @param _vehicleID  Identifier of the vehicle being used

    function accident(string memory _vehicleID) public {
        require( msg.sender == Vehicles[_vehicleID].renter, "Invalid address.");

        Vehicles[_vehicleID].events.push("Accident");
        Vehicles[_vehicleID].renter_that_triggered_events.push(msg.sender);
    }


    /// @notice The malfunction function is used to register the ocurrence of a malfunction in the vehicle
    /// @dev Ideally, the vehicle would use this function automatically. As it stands, it only requires that it is the renter and not someone else that logs this event. The event is stored in an ordered array, as well as its user, so that there is a direct link between the indices of the type of event and renter with which that event ocurred
    /// @param _vehicleID  Identifier of the vehicle being used

    function malfunction(string memory _vehicleID) public {
        require( msg.sender == Vehicles[_vehicleID].renter, "Invalid address.");

        Vehicles[_vehicleID].events.push("Malfunction");
        Vehicles[_vehicleID].renter_that_triggered_events.push(msg.sender);
    }


}