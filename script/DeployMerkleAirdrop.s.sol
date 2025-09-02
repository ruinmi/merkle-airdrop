// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {JiaToken} from "src/JiaToken.sol";

contract DeployMerkleAirdrop is Script {
    function run() public returns (JiaToken token, MerkleAirdrop merkleAirdrop) {
        bytes32 merkleRoot = 0x48451cda2e2e39c7345c4428801cfd309fc395dbf6759f0917e7530e1b97ce78;
        uint256 amountToAirdrop = 4 * 15 * 1e18;
        
        vm.startBroadcast();
        token = new JiaToken();
        merkleAirdrop = new MerkleAirdrop(address(token), merkleRoot);
        token.mint(address(merkleAirdrop), amountToAirdrop);
        vm.stopBroadcast();
    }
}