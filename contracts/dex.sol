// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";

contract Dex {

    event buy(address account, address _tokenAddr, uint256 _cost, uint256 _amount);
    event sell(address account, address _tokenAddr, uint256 _cost, uint256 _amount);

    mapping(address => bool) public supportedTokenAddr;

    modifier supportToken(address _tokenAddr) {
        require(supportedTokenAddr[_tokenAddr] == true, "This token is not supported");
        _;
    }

    constructor(address[] memory _tokenAddr) {
        for(uint i = 0; i < _tokenAddr.length; i++) {
            supportedTokenAddr[_tokenAddr[i]] = true;
        }
    }

    function buyToken(address _tokenAddr, uint256 _cost, uint256 _amount) external payable supportToken(_tokenAddr) {
        ERC20 token = ERC20(_tokenAddr);
        require(msg.value == _cost, "Insufficient fund");
        require(token.balanceOf(address(this)) >= _amount, "Token sold out");
        token.transfer(msg.sender, _amount);
        emit buy(msg.sender, _tokenAddr, _cost, _amount);
    }

    function sellToken(address _tokenAddr, uint256 _cost, uint256 _amount) external supportToken(_tokenAddr) {
        ERC20 token = ERC20(_tokenAddr);
        require(token.balanceOf(address(this)) >= _cost, "Insufficient token balance");
        require(address(this).balance >= _amount, "Dex does not have enough funds");
        token.transferFrom(msg.sender, address(this), _cost);
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        require(success, "ETH transfer failed");
        emit sell(msg.sender, _tokenAddr, _cost, _amount);
    }
}
