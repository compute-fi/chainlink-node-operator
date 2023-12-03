// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransactionRegistry {
    // Struct to represent a compute transaction
    struct ComputeTransaction {
        uint256 requestDate;
        string status;
        uint256 computeTime;
        uint256 fee;
        string computeID;
        string logCID;
        bytes32 currentTransactionHash;
        address caller; // New field to store the caller's address
    }

    // Mapping to store transactions using their transaction hash as a key
    mapping(string => mapping(address => ComputeTransaction)) public computeTransactions;

    // Function to add a new compute transaction
    function addTransaction(
        string memory _computeID,
        string memory _status,
        uint256 _computeTime,
        uint256 _fee,
        string memory _logCID
    ) external {
        // Check if the transaction already exists for the caller
        require(bytes(computeTransactions[_computeID][msg.sender].computeID).length == 0, "Transaction already exists");

        // Create a new transaction
        ComputeTransaction memory newTransaction = ComputeTransaction({
            requestDate: block.timestamp,
            status: _status,
            computeTime: _computeTime,
            fee: _fee,
            computeID: _computeID,
            logCID: _logCID,
            currentTransactionHash: keccak256(abi.encodePacked(block.timestamp, msg.sender, blockhash(block.number - 1))),
            caller: msg.sender
        });

        // Add the new transaction to the mapping using the transaction hash and caller's address
        computeTransactions[_computeID][msg.sender] = newTransaction;
    }

    // Function to update the status and fee of a compute transaction
    function updateTransaction(string memory _computeID, string memory _status, uint256 _fee) external {
        // Check if the transaction exists for the caller
        require(bytes(computeTransactions[_computeID][msg.sender].computeID).length != 0, "Transaction does not exist");

        // Update the status and fee of the transaction
        computeTransactions[_computeID][msg.sender].status = _status;
        computeTransactions[_computeID][msg.sender].fee = _fee;
    }
}
