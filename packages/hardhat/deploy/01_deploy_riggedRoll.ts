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
    args: [diceGameAddress, "0xC3931Eb96941782a44e57FE3621392205D6b7c95"],
    autoMine: true,
  });
};

export default deployRiggedRoll;
deployRiggedRoll.tags = ["RiggedRoll"];
