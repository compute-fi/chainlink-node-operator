// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

// Quick and easy solution for Compute balance. For the mock Compute solution. 
// Store yield in compute contract inside a mapping. Use that yield for compute fees.

contract ComputeContract is ChainlinkClient, ConfirmedOwner {
  mapping(address => uint256) public computeBalances; // stores the compute balance for every tokenbound address.
  uint256 public computePrice; // Compute price can be set and changed by the owner. Use a workable amount.

    using Chainlink for Chainlink.Request;

    uint256 private constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18
    // uint256 public currentPrice;
    string public currentReceivedID;

    event RequestComputeFulfilled(
        bytes32 indexed requestId,
        // uint256 indexed price
        string indexed receivedID
    ); 

  constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    // computePrice = 0.001 ether; // Default price, can be changed by owner
  }

  // To receive stEth or Eth from defi contract, may have to be adapted to accept stEth idk
  receive() external payable {
    computeBalances[msg.sender] += msg.value;
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
        currentReceivedID = _receivedID;
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
}