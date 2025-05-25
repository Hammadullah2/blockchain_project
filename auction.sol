// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address payable public owner;
    uint public startTime;
    uint public endTime;
    bool public canceled;
    uint public highestBindingBid;
    address payable public highestBidder;
    uint public bidIncrement;

    mapping(address => uint) public bids;

    constructor(uint _biddingTime, uint _bidIncrement) {
        owner = payable(msg.sender);
        startTime = block.timestamp;
        endTime = block.timestamp + _biddingTime;
        bidIncrement = _bidIncrement;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier ongoing() {
        require(!canceled && block.timestamp >= startTime && block.timestamp <= endTime, "Auction not active");
        _;
    }

    function cancelAuction() external onlyOwner {
        require(!canceled, "Already canceled");
        canceled = true;
    }

    function placeBid() external payable ongoing {
        uint newBid = bids[msg.sender] + msg.value;
        require(newBid > highestBindingBid, "Bid too low");

        bids[msg.sender] = newBid;

        if (newBid <= bids[highestBidder]) {
            highestBindingBid = min(newBid + bidIncrement, bids[highestBidder]);
        } else {
            highestBindingBid = min(newBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
    }

    function finalizeAuction() external {
        require(canceled || block.timestamp > endTime, "Auction not yet ended or canceled");
        require(msg.sender == owner || bids[msg.sender] > 0, "Not a participant");

        address payable recipient;
        uint value;

        if (canceled) {
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else {
            if (msg.sender == owner) {
                recipient = owner;
                value = highestBindingBid;
            } else if (msg.sender == highestBidder) {
                recipient = highestBidder;
                value = bids[highestBidder] - highestBindingBid;
            } else {
                recipient = payable(msg.sender);
                value = bids[msg.sender];
            }
        }

        bids[msg.sender] = 0;
        (bool sent, ) = recipient.call{value: value}("");
        require(sent, "Transfer failed");
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
} 
