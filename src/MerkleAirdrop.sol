// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {EfficientHashLib} from "solady/utils/EfficientHashLib.sol";
import {IERC20, SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";
import {console} from "forge-std/console.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;
    error InvalidProof();
    error AlreadyClaimed();
    error InvalidSignature();

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    IERC20 private immutable _token;
    bytes32 private immutable _merkleRoot;
    bytes32 private constant TYPE_HASH = keccak256("AirdropClaim(address account,uint256 amount)");
    mapping(address => bool) private _claimed;

    event Claimed(address indexed account, uint256 amount);

    constructor(address token, bytes32 merkleRoot) EIP712("MerkleAirdrop", "1") {
        _token = IERC20(token);
        _merkleRoot = merkleRoot;
    }

    function claim(address account, uint256 amount, bytes32[] calldata proof, uint8 v, bytes32 r, bytes32 s) external {
        require(_claimed[account] == false, AlreadyClaimed());
        _claimed[account] = true;

        bytes32 digest = getDigest(account, amount);
        console.log("account:", account);
        console.log("amount:", amount);
        console.logBytes32(digest);
        require(_isValidSignature(account, digest, v, r, s), InvalidSignature());

        bytes32 leaf = EfficientHashLib.hash(EfficientHashLib.hash(abi.encode(account, amount)));
        require(MerkleProof.verify(proof, _merkleRoot, leaf), InvalidProof());

        _token.safeTransfer(account, amount);
        emit Claimed(account, amount);
    }

    function getTypeHash() public pure returns (bytes32) {
        return TYPE_HASH;
    }

    function getDigest(address account, uint256 amount) public view returns (bytes32 digest){
        digest = _hashTypedDataV4(keccak256(abi.encode(
            TYPE_HASH,
            account,
            amount
        )));
    }
    
    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) private pure returns (bool) {
        (address recovered, , ) = ECDSA.tryRecover(digest, v, r, s);
        return account == recovered;
    }
}
