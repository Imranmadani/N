// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {BaseScript} from "../BaseScript.s.sol";
import {LPNQueryV0} from "../../src/client/LPNQueryV0.sol";
import {LPNRegistryV0} from "../../src/LPNRegistryV0.sol";
import {
    PUDGEY_PENGUINS,
    isEthereum,
    isMainnet
} from "../../src/utils/Constants.sol";
import {L1BlockNumber} from "../../src/utils/L1Block.sol";

contract Query is BaseScript {
    LPNRegistryV0 registry = LPNRegistryV0(getDeployedRegistry());
    LPNQueryV0 queryClient = LPNQueryV0(getDeployedQueryClient());

    address constant BLUR = 0x29469395eAf6f95920E59F858042f0e28D98a20B;

    function run() external broadcaster {
        address holder = deployer;
        if (isMainnet()) {
            holder = BLUR;
        }
        query(holder);
    }

    function query(address holder) private {
        uint256 endBlock = L1BlockNumber();
        uint256 startBlock = endBlock - 100;
        uint8 offset = 5;
        address storageContract = getDeployedStorageContract();

        if (!isEthereum()) {
            storageContract = isMainnet()
                ? getDeployedStorageContract("mainnet")
                : getDeployedStorageContract("sepolia");
        }

        queryClient.query{value: registry.gasFee()}(
            storageContract, holder, startBlock, endBlock, offset
        );
    }
}
