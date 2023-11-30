// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Purchase {

    uint public constant depositFee = 2000000000;
    uint public constant price = 500000000000;
    
    address public buyer;
    address public seller;
    bool public paid;
    bool public delivered;
    bool public completed;

    event ItemBought ();
    event ItemDelivered ();
    
    constructor() {
        seller = msg.sender;
    }

    function buy() public payable {
        require(!paid, "The item has already been sold");
        require(msg.value == depositFee + price, "The amount must be equal to the item price plus the deposit fee");
        paid = true;
        buyer = msg.sender;
        emit ItemBought();
    }

    function confirmDelivery() public {
        require(msg.sender == buyer, "Only the buyer can confirm the delivery");
        require(paid, "The item has not been shipped yet");
        require(!delivered, "The deposit has already been returned");
        (bool sent, bytes memory data) = payable(msg.sender).call{value: depositFee}("");
        require(sent, "Failed to return the deposit fee to the buyer");
        delivered = true;
        emit ItemDelivered();
    }

    function getPayment() public {
        require(msg.sender == seller, "Only the seller can retrieve the payment for the item");
        require(delivered, "The delivery has not been confirmed yet");
        (bool sent, bytes memory data) = payable(msg.sender).call{value: price}("");
        require(sent, "Failed to retrieve the payment for the item");
        completed = true;
    }
}
