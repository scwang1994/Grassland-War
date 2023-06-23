import { HardhatRuntimeEnvironment } from "hardhat/types";
import { task } from "hardhat/config";
import logger from "../logger";

task("debug:decodeTx", "debug toolbox")
  .addParam("contract", "contract name")
  .addParam("txhash", "transaction hash")
  .setAction(async (taskArguments, { ethers, artifacts }) => {
    const tx = await ethers.provider.getTransaction(taskArguments.txhash);

    const contractArti = artifacts.readArtifactSync(taskArguments.contract);
    const contract = await ethers.getContractFactoryFromArtifact(contractArti);
    const decodeTx = contract.interface.parseTransaction(tx);
    logger.info(JSON.stringify(decodeTx.args, null, 2));
  });

task("debug:decodeTxLogs", "decode transaction logs")
  .addParam("contract", "contract name")
  .addParam("txhash", "transaction hash")
  .setAction(async (taskArguments, { ethers, artifacts }) => {
    const receipt = await ethers.provider.getTransactionReceipt(
      taskArguments.txhash
    );

    const contractArti = artifacts.readArtifactSync(taskArguments.contract);
    const contract = await ethers.getContractFactoryFromArtifact(contractArti);
    for (const log of receipt.logs) {
      try {
        const decodeLog = contract.interface.parseLog(log);
        console.log(
          "decode success:",
          JSON.stringify(
            Object.assign({}, decodeLog, { eventFragment: null }),
            null,
            2
          )
        );
        logger.log(JSON.stringify(log, null, 2));
      } catch (error) {
        logger.log(JSON.stringify(log, null, 2));
      }
    }
  });
