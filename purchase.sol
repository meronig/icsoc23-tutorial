// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Purchase {

    uint public constant price = 50000000000;
    
    address public buyer;
    address public seller;
    bool public paid;
	bool public completed;
    
    event ItemBought ();
    
    constructor() {
        seller = msg.sender;
    }

    function buy() public payable {
        require(!paid, "The item has already been sold");
        require(msg.value == price, "The amount must be equal to the item price plus the deposit fee");
        paid = true;
        buyer = msg.sender;
        emit ItemBought();
    }

    function getPayment() public {
        require(msg.sender == seller, "Only the seller can retrieve the payment for the item");
        require(paid, "The item is still for sale");
        (bool sent, bytes memory data) = payable(msg.sender).call{value: price}("");
        require(sent, "Failed to retrieve the payment for the item");
        completed = true;
    }

}