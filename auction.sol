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
    address[] public bidders;
    bool public autoClosed;

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
        require(!canceled && !autoClosed && block.timestamp >= startTime && block.timestamp <= endTime, "Auction not active");
        _;
    }

    function cancelAuction() external onlyOwner {
        require(!canceled, "Already canceled");
        canceled = true;
    }

    function placeBid() external payable ongoing {
        // uint newBid = bids[msg.sender] + msg.value;
        //require(newBid > highestBindingBid, "Bid too low");

        //bids[msg.sender] = newBid;

        require(msg.value >0, "no money sent");

        //5 bids max
        if(bids[msg.sender] == 0){
            bidders.push(msg.sender);
            require(bidders.length <=5, "5 bids only");
            if(bidders.length == 5 ){
                autoClosed = true;
                endTime = block.timestamp;
            }
        }

        bids[msg.sender] += msg.value;

        // 1 of 2 by random
        if(bids[msg.sender] == bids[highestBidder] && msg.sender != highestBidder){
            if(random()%2 == 0){
                highestBidder = payable(msg.sender);
            }
        }

        if (bids[msg.sender] > bids[highestBidder]) {
            highestBindingBid = bids[msg.sender];
            highestBidder = payable(msg.sender);
        } else if(msg.sender != highestBidder){
            highestBindingBid = min(bids[highestBidder], bids[msg.sender] + bidIncrement);
            // highestBidder = payable(msg.sender);
        }
    }

    function finalizeAuction() external onlyOwner {
    require(autoClosed || canceled || block.timestamp > endTime, "Auction not yet ended");

    if (!canceled) {
        
        (bool ownerPaid, ) = owner.call{value: highestBindingBid}("");
        require(ownerPaid, "Owner payment failed");

        
        for (uint i = 0; i < bidders.length; i++) {
            address payable bidder = payable(bidders[i]);

            if (bids[bidder] == 0) continue;

            uint refund;
            if (bidder == highestBidder) {
                refund = bids[bidder] - highestBindingBid;
            } else {
                refund = bids[bidder];
            }

            bids[bidder] = 0;

            if (refund > 0) {
                (bool sent, ) = bidder.call{value: refund}("");
                require(sent, "Refund failed");
            }
        }
    } else {
        
        for (uint i = 0; i < bidders.length; i++) {
            address payable bidder = payable(bidders[i]);

            if (bids[bidder] > 0) {
                uint refund = bids[bidder];
                bids[bidder] = 0;

                (bool sent, ) = bidder.call{value: refund}("");
                require(sent, "Cancel refund failed");
            }
        }
    }
}


    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
    function random() private view returns (uint) {
    return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
    }

} 
