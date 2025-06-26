// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EnergyTrading {
    struct EnergyOffer {
        address seller;
        uint256 totalEnergy;
        uint256 availableEnergy;
        uint256 pricePerUnit; // seller's asking price (in wei)
        bool isActive;
    }

    struct EnergyBid {
        address buyer;
        uint256 amount;
        uint256 pricePerUnit; // buyer's willing price (in wei)
        bool isActive;
    }

    uint256 public offerCount;
    uint256 public bidCount;
    uint256 public marketClearingPrice;

    mapping(uint256 => EnergyOffer) public offers;
    mapping(uint256 => EnergyBid) public bids;

    event EnergyListed(uint256 offerId, address seller, uint256 totalEnergy, uint256 pricePerUnit);
    event EnergyBought(uint256 offerId, address buyer, uint256 amount, uint256 totalPrice);
    event EnergyOfferCancelled(uint256 offerId);
    event MarketClearingPriceUpdated(uint256 newPrice);
    event BidPlaced(uint256 bidId, address buyer, uint256 amount, uint256 pricePerUnit);
    event BidCancelled(uint256 bidId);
    event BidMatched(uint256 offerId, uint256 bidId, uint256 tradedAmount, uint256 tradePrice);

    // SELLER: List energy offer
    function listEnergy(uint256 totalEnergy, uint256 pricePerUnit) external {
        require(totalEnergy > 0 && pricePerUnit > 0, "Invalid input");

        offerCount++;
        offers[offerCount] = EnergyOffer(msg.sender, totalEnergy, totalEnergy, pricePerUnit, true);
        emit EnergyListed(offerCount, msg.sender, totalEnergy, pricePerUnit);
        updateMarketClearingPrice();
    }

    // BUYER: Direct buy from an offer at offer price
    function buyEnergy(uint256 offerId, uint256 amount) external payable {
        EnergyOffer storage offer = offers[offerId];
        require(offer.isActive && amount > 0 && amount <= offer.availableEnergy, "Invalid trade amount");

        uint256 cost = amount * offer.pricePerUnit;
        require(msg.value >= cost, "Insufficient ETH");

        payable(offer.seller).transfer(cost);
        if (msg.value > cost) payable(msg.sender).transfer(msg.value - cost);

        offer.availableEnergy -= amount;
        if (offer.availableEnergy == 0) offer.isActive = false;

        emit EnergyBought(offerId, msg.sender, amount, cost);
        updateMarketClearingPrice();
    }

    // SELLER: Cancel energy offer
    function cancelOffer(uint256 offerId) external {
        EnergyOffer storage offer = offers[offerId];
        require(msg.sender == offer.seller && offer.isActive, "Unauthorized or inactive");

        offer.isActive = false;
        emit EnergyOfferCancelled(offerId);
        updateMarketClearingPrice();
    }

    // MCP Calculation
    function updateMarketClearingPrice() public {
        uint256 totalEnergy;
        uint256 totalValue;

        for (uint256 i = 1; i <= offerCount; i++) {
            EnergyOffer storage offer = offers[i];
            if (offer.isActive && offer.availableEnergy > 0) {
                totalEnergy += offer.availableEnergy;
                totalValue += offer.availableEnergy * offer.pricePerUnit;
            }
        }

        marketClearingPrice = (totalEnergy > 0) ? totalValue / totalEnergy : 0;
        emit MarketClearingPriceUpdated(marketClearingPrice);
    }

    function getMarketClearingPrice() external view returns (uint256) {
        return marketClearingPrice;
    }

    // BUYER: Place custom bid
    function placeBid(uint256 amount, uint256 pricePerUnit) external payable {
        require(amount > 0 && pricePerUnit > 0, "Invalid bid");
        require(msg.value >= amount * pricePerUnit, "Insufficient deposit");

        bidCount++;
        bids[bidCount] = EnergyBid(msg.sender, amount, pricePerUnit, true);
        emit BidPlaced(bidCount, msg.sender, amount, pricePerUnit);
    }

    // BUYER: Cancel bid
    function cancelBid(uint256 bidId) external {
        EnergyBid storage bid = bids[bidId];
        require(msg.sender == bid.buyer && bid.isActive, "Unauthorized or inactive");

        uint256 refund = bid.amount * bid.pricePerUnit;
        bid.isActive = false;
        payable(msg.sender).transfer(refund);

        emit BidCancelled(bidId);
    }

    // SELLER matches buyer's bid (even if lower than offer price)
    function matchBidToOffer(uint256 offerId, uint256 bidId, uint256 amountToTrade) external {
        EnergyOffer storage offer = offers[offerId];
        EnergyBid storage bid = bids[bidId];

        require(offer.isActive && bid.isActive, "Offer or bid inactive");
        require(msg.sender == offer.seller, "Only seller can match");
        require(amountToTrade > 0 && amountToTrade <= offer.availableEnergy, "Invalid trade amount");
        require(amountToTrade <= bid.amount, "Not enough in bid");

        uint256 tradePrice = amountToTrade * bid.pricePerUnit;

        // Transfer bid escrow to seller
        payable(offer.seller).transfer(tradePrice);

        // Update state
        offer.availableEnergy -= amountToTrade;
        bid.amount -= amountToTrade;

        if (offer.availableEnergy == 0) offer.isActive = false;
        if (bid.amount == 0) bid.isActive = false;

        emit BidMatched(offerId, bidId, amountToTrade, tradePrice);
        updateMarketClearingPrice();
    }

    // GETTERS
    function getOffer(uint256 offerId) external view returns (
        address seller, uint256 totalEnergy, uint256 availableEnergy, uint256 pricePerUnit, bool isActive
    ) {
        EnergyOffer memory o = offers[offerId];
        return (o.seller, o.totalEnergy, o.availableEnergy, o.pricePerUnit, o.isActive);
    }

    function getBid(uint256 bidId) external view returns (
        address buyer, uint256 amount, uint256 pricePerUnit, bool isActive
    ) {
        EnergyBid memory b = bids[bidId];
        return (b.buyer, b.amount, b.pricePerUnit, b.isActive);
    }
}
