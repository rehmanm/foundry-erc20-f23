//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract ManualToken {
    string constant NAME = "Manual Token";
    uint256 constant TOTAL_SUPPLY = 100 ether;
    uint8 constant DECIMALS = 18;
    string public symbol = "MANUAL";

    mapping(address => uint256) private s_balances;

    function name() public pure returns (string memory) {
        return NAME;
    }

    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(s_balances[msg.sender] >= _value, "Insufficient balance");
        s_balances[msg.sender] -= _value;
        s_balances[_to] += _value;
        return true;
    }
}
