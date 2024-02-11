// SDPX-License-Identifier: MIT 
pragma solidity >=0.6.12 <0.9.0;

import "./ILogger.sol";

contract Logger is ILogger{
    mapping(address=>uint[]) private payments;

    function pay(address _from, uint _amount) external {
        payments[_from].push(_amount);
    }

    function getPayment(address _from, uint _index) external view returns(uint){
        return payments[_from][_index];
    }
}