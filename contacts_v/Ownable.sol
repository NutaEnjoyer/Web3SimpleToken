// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

contract Ownable{
    address public owner;
    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner (){
        require(owner == msg.sender, "Not an owner!");
        _;
    }
}