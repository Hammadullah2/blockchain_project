// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./MYCoin.sol";

contract ICO {
    address public admin;
    MYCoin public tokenContract;
    uint public tokenPrice;
    uint public tokensSold;
    uint public deadline;

    event Sell(address buyer, uint amount);

    constructor(address _tokenAddress, uint _tokenPrice, uint durationMinutes) {
        admin = msg.sender;
        tokenContract = MYCoin(_tokenAddress);
        tokenPrice = _tokenPrice;
        deadline = block.timestamp + (durationMinutes * 1 minutes);
    }

    function buyTokens(uint numberOfTokens) public payable {
        require(block.timestamp < deadline, "ICO ended");
        require(msg.value == numberOfTokens * tokenPrice, "Incorrect value");
        require(tokenContract.balanceOf(address(this)) >= numberOfTokens, "Not enough tokens");

        tokensSold += numberOfTokens;
        require(tokenContract.transfer(msg.sender, numberOfTokens), "Token transfer failed");

        emit Sell(msg.sender, numberOfTokens);
    }

    function endICO() public {
        require(msg.sender == admin, "Only admin");
        require(block.timestamp >= deadline, "ICO not ended yet");

        // transfer remaining tokens back to admin
        uint remaining = tokenContract.balanceOf(address(this));
        if (remaining > 0) {
            tokenContract.transfer(admin, remaining);
        }

        // transfer raised funds to admin
        payable(admin).transfer(address(this).balance);
    }
}
