// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;


contract Auction{ 
    address payable public owner;
    uint DEFAUL_DURATION = 2 days;
    uint FEE = 10;
    bool AUTO_WITHDRAW = true;

    struct Auction { 
        address payable seller;
        address buyer;
        uint startPrice;
        uint finishPrice;
        uint discountRate;
        uint startAt;
        uint endsAt;
        uint duration;
        bool stop;
    }

    Auction[] public auctions;

    event auctionCreate (address payable indexed seller, Auction auction, uint startAt);
    event auctionBuy (address indexed buyer, Auction auction, uint endsAt);

    constructor (){ 
        owner = payable(msg.sender);
    }

    modifier indexAuction(uint index) { 
        require(index < auctions.length, "Incorrect index");
        require(!auctions[index].stop, "Auction already stopped");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "You should be owner");
        _;
    }

    function changeOwner(address payable newOwner) external onlyOwner {
        owner = payable(newOwner);
    }

    function switchAutoWithdraw() external onlyOwner {
        AUTO_WITHDRAW = !AUTO_WITHDRAW;
    }

    function autoWithdraw() external view onlyOwner returns(bool){
        return AUTO_WITHDRAW;
    }

    function getBalance() external view onlyOwner returns(uint) {
        return address(this).balance;
    }

    function createAuction(uint _startPrice, uint _discountRate, uint _duration) public {
        uint duration = _duration > 0 ? _duration : DEFAUL_DURATION;
        require(_startPrice >= _discountRate * _duration, "Incorrect start price");
        Auction memory newAuction = Auction(
            payable(msg.sender),
            msg.sender,
            _startPrice,
            _startPrice,
            _discountRate,
            block.timestamp,
            block.timestamp,
            duration,
            false
        );
        auctions.push(newAuction);
        emit auctionCreate(payable(msg.sender), newAuction, block.timestamp);
    }
    
    function getCurrentPrice(uint index) external view indexAuction(index) returns(uint) { 
        Auction memory cAuction = auctions[index];
        return cAuction.startPrice - cAuction.discountRate * (block.timestamp - cAuction.startAt);
    }

    function buy(uint index) external payable indexAuction(index) { 
        Auction storage cAuction = auctions[index];
        uint _finishPrice = cAuction.startPrice - cAuction.discountRate * (block.timestamp - cAuction.startAt);
        require(msg.value >= _finishPrice, "Not enough funds!");
        cAuction.stop = true;
        cAuction.buyer = msg.sender;
        cAuction.endsAt = block.timestamp;
        cAuction.finishPrice = _finishPrice;

        cAuction.seller.transfer(_finishPrice - ((_finishPrice * FEE) / 100));

        emit auctionBuy(msg.sender, cAuction, block.timestamp);
        
        uint different = msg.value - _finishPrice;
        
        if (different > 0){
            payable(msg.sender).transfer(different);
        }

        if (AUTO_WITHDRAW){
            owner.transfer(((_finishPrice * FEE) / 100)); 
        }
    }

}
