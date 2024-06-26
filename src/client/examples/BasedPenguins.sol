// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {LPNClientV0} from "../LPNClientV0.sol";
import {ILPNRegistry} from "../../interfaces/ILPNRegistry.sol";
import {
    ERC721Enumerable,
    ERC721
} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {L1BlockNumber} from "../../utils/L1Block.sol";

/// @notice Refer to docs page https://lagrange-labs.gitbook.io/lagrange-v2-1/zk-coprocessor/testnet-euclid-developer-docs/implement-an-nft-mint-whitelist-on-base-with-pudgy-penguins
contract BasedPenguins is LPNClientV0, ERC721Enumerable {
    address public constant PUDGY_PENGUINS =
        0xBd3531dA5CF5857e7CfAA92426877b022e612cf8;
    string public constant PUDGY_METADATA_URI =
        "ipfs://bafybeibc5sgo2plmjkq2tzmhrn54bk3crhnc23zd2msg4ea7a4pxrkgfna/";

    uint256 id;

    struct MintRequest {
        address sender;
    }

    mapping(uint256 requestId => MintRequest request) public mintRequests;

    constructor(ILPNRegistry lpnRegistry_)
        ERC721("Based Penguins", "BPDGY")
        LPNClientV0(lpnRegistry_)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return PUDGY_METADATA_URI;
    }

    function requestMint() external payable {
        uint256 requestId = queryPudgyPenguins();
        mintRequests[requestId] = MintRequest({sender: msg.sender});
    }

    function queryPudgyPenguins() private returns (uint256) {
        return lpnRegistry.request{value: lpnRegistry.gasFee()}(
            PUDGY_PENGUINS,
            bytes32(uint256(uint160(msg.sender))),
            L1BlockNumber(),
            L1BlockNumber(),
            0
        );
    }

    function processCallback(uint256 requestId, uint256[] calldata results)
        internal
        override
    {
        bool isPudgyHolder = results.length > 0;

        if (isPudgyHolder) {
            MintRequest memory req = mintRequests[requestId];
            _mint(req.sender, id);

            id++;
        }

        delete mintRequests[requestId];
    }
}
