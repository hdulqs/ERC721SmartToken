// 
// MIT License
// 
// Copyright (c) 2018 REGA Risk Sharing
//   
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 
// Author: Sergei Sevriugin
// Version: 0.0.1
//  

pragma solidity ^0.4.17;

import './TokenCrowdsurance.sol';
import './interfaces/IERC20Token.sol';

/// Luggage crowdsurance protection product based on TokenCrowdsurance NFT token 
contract LuggageCrowdsurance is TokenCrowdsurance {
    /// REGA Risk Sharing Token smart contract address
    IERC20Token public  RST;                // RST smart contract address
    uint256     public  joinAmountRST;      // Join amount in RST
    bool        public  RSTOnly;            // Join only for RST tokens
    uint8       public  maxHold;            // Maximum number of toikens for one address
    /// join function
    /// @return cowdsuranceId NFT token ID for created crowdsurance
    function join() public payable returns(uint256 cowdsuranceId) {
        uint256 amount = msg.value;
        address member = msg.sender;
        uint256 score = addressToScore[member];
        require(score != uint256(0));
        require(balanceOf(member) < maxHold);

        if (RSTOnly) {
            // now need to check that the member has approved the transfer joinAmountRST to join
            require(RST != address(0));                     // check that we have valid contract address
            require(joinAmountRST != uint256(0));           // join RST amount must be > 0
            uint256 rstAmt = RST.allowance(member, owner);  // check if the member has gave permision to spend some amount
            require(rstAmt >= joinAmountRST);               // ... and check if allowance is more then joinAmount
            amount = addressToAmount[member];               // get join amount and check...
            require(rstAmt >= amount && amount >= joinAmountRST);
            // transfer join RST amount to the owner account
            require(RST.transferFrom(member, owner, amount));
        }
        else {
            require(amount != uint256(0) && amount >= parameters.joinAmount);
            require(amount == addressToAmount[member]);
        }
        // call internal _join after all checkups 
        cowdsuranceId = _join(member, score, amount);
    }
    function LuggageCrowdsurance(address _rst, uint256 _amount, bool _only, uint8 _max) 
                TokenCrowdsurance("Luggage Crowdsurance NFT", "LCS") public {
        // setting up contract parameters 
        RST = IERC20Token(_rst);
        joinAmountRST = _amount; 
        RSTOnly = _only; 
        maxHold = _max;
    }
}