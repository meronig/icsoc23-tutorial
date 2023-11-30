// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Purchase {

    uint public constant depositFee = 2000000000;
    
    struct Item {
        address buyer;
        address seller;
        uint price;
        bool paid;
        bool delivered;
        bool completed;
    }

    mapping (uint => Item) public items;

    //only if we need to track item ids inside smart contract
    uint[] itemIds;

    event ItemBought (uint id);
    event ItemDelivered (uint id);

    //only if we need to track item ids inside smart contract
    function getItemIds() public view returns (uint[] memory) {
        return itemIds;
    }
    
    function addItem(uint id, uint price) public {
        require(items[id].price==0, "Item already exists");
        items[id].price = price;
        items[id].seller = msg.sender;
        //only if we need to track item ids inside smart contract
        itemIds.push(id);
    }

    function buy(uint id) public payable {
        require(items[id].price!=0, "Item does not exist");
        require(!items[id].paid, "The item has already been sold");
        require(msg.value == depositFee + items[id].price, "The amount must be equal to the item price plus the deposit fee");
        items[id].paid = true;
        items[id].buyer = msg.sender;
        emit ItemBought(id);
    }

    function confirmDelivery(uint id) public {
        require(msg.sender == items[id].buyer, "Only the buyer can confirm the delivery");
        require(items[id].paid, "The item has not been shipped yet");
        require(!items[id].delivered, "The deposit has already been returned");
        (bool sent, bytes memory data) = payable(msg.sender).call{value: depositFee}("");
        require(sent, "Failed to return the deposit fee to the buyer");
        items[id].delivered = true;
        emit ItemDelivered(id);
    }

    function getPayment(uint id) public {
        require(msg.sender == items[id].seller, "Only the seller can retrieve the payment for the item");
        require(items[id].delivered, "The delivery has not been confirmed yet");
        require(!items[id].completed, "The payment has already been retrieved");
        (bool sent, bytes memory data) = payable(msg.sender).call{value: items[id].price}("");
        require(sent, "Failed to retrieve the payment for the item");
        items[id].completed = true;
    }

}
