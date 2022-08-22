//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//in a library all functions should be internak

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        //bringing int price variable from latestRoundData function in the interface contract we imported
        (, int256 price, , , ) = priceFeed.latestRoundData();
        //ETH in terms of USD
        //3000.00000000

        return uint256(price * 1e10); //1**10
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //calling our get price function to get the price of etherum
        uint256 ethPrice = getPrice(priceFeed);
        //we have to multyplt and add first then divide
        //3000.000000000000000000 = ETH / USD price 3000 with 18 decimal zeros
        //1.000000000000000 ETH
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}
