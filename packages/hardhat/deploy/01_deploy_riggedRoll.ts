import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
import { DiceGame } from "../typechain-types";

const deployRiggedRoll: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const diceGame: DiceGame = await ethers.getContract("DiceGame");
  const diceGameAddress = await diceGame.getAddress();

  await deploy("RiggedRoll", {
    from: deployer,
    log: true,
    args: [diceGameAddress],
    autoMine: true,
  });

  // Esto déjalo para más adelante, cuando hagas Checkpoint 3
  // y quieras pasar ownership a tu wallet del frontend.
  // const riggedRoll = await ethers.getContract("RiggedRoll", deployer);
  // await riggedRoll.transferOwnership("TU_DIRECCION");
};

export default deployRiggedRoll;
deployRiggedRoll.tags = ["RiggedRoll"];
