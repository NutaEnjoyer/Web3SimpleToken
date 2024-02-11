// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import "./IERC20.sol";

abstract contract ERC20 is IERC20 {
    address owner;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    string _name;
    string _symbol;

    uint _totalSupply;

    function name() external view returns(string memory){
        return _name;
    }

    function symbol() external view returns(string memory){
        return _symbol;
    }

    modifier enoughTokens(address _from, uint _amount){
        require(balanceOf(_from) >= _amount, "Not enough tokens");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not an owner");
        _;
    }

    constructor (string memory name_, string memory symbol_, uint initialSupply, address shop){
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(shop, initialSupply);
    }

    function totalSupply() external view returns(uint){
        return _totalSupply;
    }

    function mint(address _to, uint amount) public onlyOwner {
        _beforeTokenTransfer(address(0), _to, amount);
        balances[_to] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), _to, amount);
    }

    function burn(address _from, uint amount) public onlyOwner enoughTokens(_from, amount){
        _beforeTokenTransfer(_from, address(0), amount);
        balances[_from] -= amount;
        _totalSupply -= amount;
        emit Transfer(_from, address(0), amount);
    }

    function decimals() external pure returns(uint){
        return 18; // 1 token = 1 wei
    }

    function balanceOf(address addr) public view returns(uint){
        return balances[addr];
    }

    function transfer(address to, uint amount) public enoughTokens(msg.sender, amount){
        _beforeTokenTransfer(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual {}

    function allowance(address _owner, address spender) public view returns(uint){
        return allowances[_owner][spender];
    }

    function approve(address spender, uint amount) public {
        _approve(msg.sender, spender, amount);
    }

    function _approve(address sender, address spender, uint amount) internal virtual {
        allowances[sender][spender] += amount;
        emit Approve(sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) public enoughTokens(sender, amount){
        require(allowance(sender, recipient) >= amount, "Not allowance");
        _beforeTokenTransfer(sender, recipient, amount);
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][recipient] -= amount;
        emit Transfer(msg.sender, recipient, amount);
    }
}


contract AnyaToken is ERC20 {
    constructor(address shop) ERC20("AnyaToken", "ANT", 20, shop) {}
}

contract AnyaShop{
    IERC20 public token;
    address payable public owner;
    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed _seller);

    modifier onlyOwner(){
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier enoughTokens(address _from, uint _amount){
        require(token.balanceOf(_from) >= _amount, "Not enough tokens");
        _;
    }

    constructor(){
        token = new AnyaToken(address(this));
        owner = payable(msg.sender);
    }

    function tokenBalance() public view returns(uint) {
        return token.balanceOf(address(this));
    }

    receive() external payable {
        uint tokensToBuy = msg.value;
        require(tokensToBuy > 0, "No funds!");

        require(tokenBalance() >= tokensToBuy, "Not enough tokens!");

        token.transfer(msg.sender, tokensToBuy);
        emit Bought(tokensToBuy, msg.sender);
    }    

    function sell(uint _amount) external enoughTokens(msg.sender, _amount){
        require(_amount > 0, "Amount can not be zero or less");
        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Has not allowance");
        token.transferFrom(msg.sender, address(this), _amount);
        payable(msg.sender).transfer(_amount);

        emit Sold(_amount, msg.sender);
    }

    function withdrawToOwner(uint _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Has not enough balance");
        if (_amount == 0){
            owner.transfer(address(this).balance);
        }else{
            owner.transfer(_amount);
        }
    }
}


