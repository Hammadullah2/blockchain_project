// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function transfer(address to, uint tokens) external returns (bool success);
    function balanceOf(address tokenOwner) external view returns (uint balance);
}

contract MYCoin is ERC20Interface {
    string public name = "Previx";
    string public symbol = "PRV";
    uint public override totalSupply;
    uint public decimals = 18;
    address public founder;

    mapping(address => uint) public balances;

    event Transfer(address indexed from, address indexed to, uint tokens);

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function transfer(address to, uint tokens) public override returns (bool success) {
        require(balances[msg.sender] >= tokens, "Insufficient balance");
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }
}
