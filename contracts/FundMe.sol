// Get funds from users , withdraw funds , set a minimum funding in value USD

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

//both of those thing help saving gas
//constant assigned once and never changed
//immutable

//use custom errors to save gas
error FundeMe__notOwner();

//

//using NATSPAC TO DOCUMENT OUR CONTRACT
/** @title A contract for crowd funding
 * @author jon
 * @notice this contract is to demo a sample funding contract
 * @dev this implements price feed as our library
 */

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18; //1*10 **18
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    //variables that we set one time outside of its line of declation are set to immutable
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    /*we use this modifier and paste in the functions declartion to check something for
     example here we are checking if its the onwer let him use the withdraw function
     */
    modifier onlyOwner() {
        // require(msg.sender ==  i_owner , "sender is not owner");
        if (msg.sender != i_owner) {
            revert FundeMe__notOwner();
        }

        // _; means we run the require code above and then we use the function if it comes after the statement above then it will run after
        _;
    }

    //function that gets called once only when we deploy a contract
    constructor(address priceFeedAddress) {
        // owner is set to msg.sender
        //variables that we set one time outside of its line of declation are set to immutable
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    /**
     * @notice this function funds this contract
     * @dev this implements price feed as our library
     */

    function fund() public payable {
        //we want to set a minimum fund amount in USD
        //1. how to send ETH to this contract?

        //require that the sender sends atleast more than 1 eth if not it will return didnt send enough eth and reverts that gas
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "didnt send enough eth"
        ); //1e18 = 1 *10 ** 18 == 1000000000000000000 , 18 zeros
        //Revert undos any action before , and sends remaining gas back

        //keeping track of addreses of funders that send money to us
        //anytime somone sendes us money they get added to the list
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            //code
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
        //actually withdraw the funds

        // 3 ways to send funds from a contract
        // 1-transfer :-

        //msg.sender = address
        //payable(msg.sender) = payble address
        //transfer method automatically reverts an error of transaction fails
        payable(msg.sender).transfer(address(this).balance);

        // 2-send
        //in send we have to make a error revert if transcation fails
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "send failed");

        // 3-call
        // if we use call to call an object it reurns 2 variables bool Success or fail of trx or datareturns of type bytes
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
