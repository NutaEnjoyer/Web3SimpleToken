// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

interface ILogger{ 
    function pay(address _from, uint _amount) external;
    function getPayment(address _from, uint _number) external view returns(uint);
}