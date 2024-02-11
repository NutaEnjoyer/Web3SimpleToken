// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import "./ILogger.sol";
import "./Ownable.sol";

contract Demo is Ownable {
    ILogger logger;

    constructor (address _logger) {
        logger = ILogger(_logger);
    }

    receive() external payable {
        logger.pay(msg.sender, msg.value);
    }

    function pay(address _from, uint _amount) public onlyOwner{ 
        logger.pay(_from, _amount);
    }

    function getPayment(address _from, uint _number) public view returns(uint) {
        return logger.getPayment(_from, _number);
    }
}