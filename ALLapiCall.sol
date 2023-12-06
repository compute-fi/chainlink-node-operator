// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

// Quick and easy solution for Compute balance. For the mock Compute solution. 
// Store yield in compute contract inside a mapping. Use that yield for compute fees.

contract ComputeContract is ChainlinkClient, ConfirmedOwner {
     // Struct to represent a compute transaction
    struct ComputeTransaction {
        uint256 requestDate;
        string status;
        uint256 computeTime;
        uint256 fee;
        string computeID;
        string logCID;
        string transactionHash;
        address caller; // New field to store the caller's address
    }

    mapping(address => uint256) public computeBalances;
    mapping(string => mapping(address => ComputeTransaction)) public computeTransactions;
    mapping(address => string[]) public stringArrays;
    uint256 public computePrice;
    using Chainlink for Chainlink.Request;

    uint256 private constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18
    string public currentFolderID;
    string public currentStatus;
    string public currentLogCID;
    bytes32 public currentTransactionHash;

    event RequestComputeFulfilled(
        bytes32 indexed requestId,
        // uint256 indexed price
        string indexed receivedID
    ); 
    // Define an event for emitting ComputeTransaction with indexed parameters
    event TransactionUpdated(
        uint256  requestDate,
        string  status,
        uint256  computeTime,
        uint256  fee,
        string indexed computeID,
        string  logCID,
        string indexed transactionHash,
        address indexed caller
    );


  constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        computePrice = 1; // Default price, can be changed by owner
  }

  // To receive stEth or Eth from defi contract, may have to be adapted to accept stEth idk
  receive() external payable {
    computeBalances[msg.sender] += msg.value;
  }
  

    function addString(string memory value) internal {
        stringArrays[msg.sender].push(value);
    }

    function getString(uint256 index, address _userwallet) public view returns (string memory) {
        require(index < stringArrays[msg.sender].length, "Index out of bounds");
        return stringArrays[_userwallet][index];
    }

    function getAllStrings(address _userwallet) public view returns (string[] memory) {
        return stringArrays[_userwallet];
    }

  // to change the compute price after deployment
  function setComputePrice(uint256 _price) public onlyOwner {
    computePrice = _price;
  }

  // Pay for compute call from the Compute balance.
  function callAPI(
       address _oracle,
        string memory _jobId,
        string memory _fileUrl
  ) public {
    require(computeBalances[msg.sender] >= computePrice, "Insufficient balance");
    computeBalances[msg.sender] -= computePrice;
    currentTransactionHash = keccak256(abi.encodePacked(block.timestamp, msg.sender, blockhash(block.number - 1)));
    // API call logic goes here
            Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillComputeRequest.selector
        );
        // Create a bytes array to store the concatenated string
        bytes memory url = abi.encodePacked(
            "https://kkpy.onrender.com/compute?fileUrl=",
            _fileUrl
        );

        req.add(
            "get",
            string(url)
        );
        req.add("path", "generatedfolder");
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
  }

    // Support function for API
    function fulfillComputeRequest(
        bytes32 _requestId,
        string memory _receivedID
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestComputeFulfilled(_requestId, _receivedID);
        currentFolderID = _receivedID;        
    }

        function callStatus(
        address _oracle,
        string memory _jobId,
        string memory _computeID
    ) public {

        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillStatusRequest.selector
        );

        bytes memory url = abi.encodePacked(
            "https://kkpy.onrender.com/status?folderID=",
            _computeID
        );

        req.add(
            "get",
            string(url)
        );
        req.add("path", "result");
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);

    }

    function fulfillStatusRequest(
        bytes32 _requestId,
        string memory _receivedID
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestComputeFulfilled(_requestId, _receivedID);
        currentStatus = _receivedID;
    }

    function callLogAPI(
        address _oracle,
        string memory _jobId,
        string memory _computeID
    ) public {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillLogRequest.selector
        );

        bytes memory url = abi.encodePacked(
            "https://kkpy.onrender.com/output?folderID=",
            _computeID
        );

        req.add(
            "get",
            string(url)
        );
        req.add("path", "ipfshash");
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function fulfillLogRequest(
        bytes32 _requestId,
        string memory _receivedID
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestComputeFulfilled(_requestId, _receivedID);
        currentLogCID = _receivedID;
    }

        function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

      // Function to add a new compute transaction
    function addTransaction(
        string memory _computeID,
        string memory _transactionHash
    ) external {
        // Check if the transaction already exists for the caller
        require(bytes(computeTransactions[_computeID][msg.sender].computeID).length == 0, "Transaction already exists");

        // Create a new transaction
        ComputeTransaction memory newTransaction = ComputeTransaction({
            requestDate: block.timestamp,
            status: "Pending",
            computeTime: 0,
            fee: computePrice,
            computeID: _computeID,
            logCID: "Pending",
            transactionHash: _transactionHash,
            caller: msg.sender
        });

        // Add the new transaction to the mapping using the transaction hash and caller's address
        computeTransactions[_computeID][msg.sender] = newTransaction;

        addString(_computeID);

                // Emit the event with the struct values
        emit TransactionUpdated(
            newTransaction.requestDate,
            newTransaction.status,
            newTransaction.computeTime,
            newTransaction.fee,
            newTransaction.computeID,
            newTransaction.logCID,
            newTransaction.transactionHash,
            newTransaction.caller
        );
    }

    // Function to update the status and fee of a compute transaction
    function updateTransaction(
    string memory _computeID, 
    string memory _status, 
    string memory _logCID,
    uint256 _computeTime
    ) external {
        // Check if the transaction exists for the caller
        require(bytes(computeTransactions[_computeID][msg.sender].computeID).length != 0, "Transaction does not exist");

        // Update the status and fee of the transaction
        computeTransactions[_computeID][msg.sender].status = _status;
        computeTransactions[_computeID][msg.sender].logCID = _logCID;
        computeTransactions[_computeID][msg.sender].computeTime = _computeTime;


        // Emit the event with the updated struct values
        emit TransactionUpdated(
            computeTransactions[_computeID][msg.sender].requestDate,
            computeTransactions[_computeID][msg.sender].status,
            computeTransactions[_computeID][msg.sender].computeTime,
            computeTransactions[_computeID][msg.sender].fee,
            computeTransactions[_computeID][msg.sender].computeID,
            computeTransactions[_computeID][msg.sender].logCID,
            computeTransactions[_computeID][msg.sender].transactionHash,
            computeTransactions[_computeID][msg.sender].caller
        );
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public onlyOwner {
        cancelChainlinkRequest(
            _requestId,
            _payment,
            _callbackFunctionId,
            _expiration
        );
    }
    
    // Support function for API
    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
 
    }
    // Function to convert bytes32 to string
function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
    // Convert bytes32 to bytes (by appending 0x)
    bytes memory bytesData = abi.encodePacked(_bytes32);

    // Convert bytes to string
    return string(bytesData);
}
}