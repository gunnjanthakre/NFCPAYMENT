// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyDigitalCurrency {
    string public name = "MyDigitalCurrency";
    string public symbol = "MDC";
    uint8 public decimals = 18;
    uint256 private _totalSupply;

    address public owner;

    mapping(address => uint256) private _balances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        _totalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply); // Minting event
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
}
