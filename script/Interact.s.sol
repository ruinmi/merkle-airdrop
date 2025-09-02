// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {JiaToken} from "src/JiaToken.sol";
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract Claim is Script {
    bytes32 public proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proofOne, proofTwo];
    address public claimant = 0x58fCc43E6DE8Ea449c6E44938154344D6346e0D2;
    bytes public signature = hex"27eacce377bfdaae5c9996fad4f116c86d7dc52cf9f9a90d27fd948f95aea2544d3cbec8739f2f8b217be7878b3568593df350a641cb5d8b78e27c92b792a1b61c";
    uint256 public amount = 25 ether;

    function run() public {
        MerkleAirdrop airdrop = MerkleAirdrop(DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid));

        bytes memory sig = signature;
        bytes32 r; bytes32 s; uint8 v;
        assembly ("memory-safe") {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }

        vm.startBroadcast();

        airdrop.claim(claimant, amount, proof, v, r, s);

        vm.stopBroadcast();
    }
}

contract GetDigest is Script {
    address public claimant = 0x58fCc43E6DE8Ea449c6E44938154344D6346e0D2;
    uint256 public amount = 25 ether;
    
    function run() public returns (bytes32 digest) {
        MerkleAirdrop airdrop = MerkleAirdrop(DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid));
        digest = airdrop.getDigest(claimant, amount);
    }
}

contract SplitSignature is Script {
    bytes public signature = hex"7d33c6f4ef71ce3642c791d259fe07fd65a561fa448d741ec97f6c2b4a2a5fab68bb170a3f7ba82e54f1582a6301437bfe2748b0bcae95c87923b6863953d6051b";

    function run() public returns (bytes32 r, bytes32 s, uint8 v) {
        bytes memory sig = signature;
        assembly ("memory-safe") {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }
    }
}

contract BalanceOf is Script {
    address public account = 0x58fCc43E6DE8Ea449c6E44938154344D6346e0D2;
    
    function run() public returns (uint256 balance) {
        JiaToken token = JiaToken(DevOpsTools.get_most_recent_deployment("JiaToken", block.chainid));
        balance = token.balanceOf(account);
    }
}