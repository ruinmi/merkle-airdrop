// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {JiaToken} from "src/JiaToken.sol";

contract MerkleAirdropTest is Test {
    JiaToken private _token;
    MerkleAirdrop private _airdrop;
    bytes32 private _merkleRoot = 0x48451cda2e2e39c7345c4428801cfd309fc395dbf6759f0917e7530e1b97ce78;
    uint256 public constant AMOUNT_TO_CLAIM = 25e18;
    address private _jiating; // 0x58fCc43E6DE8Ea449c6E44938154344D6346e0D2
    uint256 private _jiatingKey; // 51964664058261426548679704544205656654629121203566432320175149830614137386034
    bytes32 public proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proofOne, proofTwo];
    
    function setUp() public {
        (_jiating, _jiatingKey) = makeAddrAndKey("jiating");
        _airdrop = new MerkleAirdrop(address(_token = new JiaToken()), _merkleRoot);
        _token.mint(address(_airdrop), AMOUNT_TO_CLAIM * 4);
    }

    function signClaim(uint256 amount) public view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 structHash = keccak256(abi.encode(
            _airdrop.getTypeHash(),
            _jiating,
            amount
        ));
        
        bytes32 domainHash = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("MerkleAirdrop"),
            keccak256("1"),
            block.chainid,
            address(_airdrop)
        ));
        
        bytes32 digest = keccak256(abi.encodePacked(
            hex"19_01",
            domainHash,
            structHash
        ));
        
        (v, r, s) = vm.sign(_jiatingKey, digest);
        console.log("v:", v);
        console.logBytes32(r);
        console.logBytes32(s);
    }

    function testClaim() public {
        console.log(_jiating);
        uint256 balanceBefore = _token.balanceOf(_jiating);
        (uint8 v, bytes32 r, bytes32 s) = signClaim(AMOUNT_TO_CLAIM);
        _airdrop.claim(_jiating, AMOUNT_TO_CLAIM, proof, v, r, s);
        
        uint256 balanceAfter = _token.balanceOf(_jiating);
        assertEq(balanceAfter - balanceBefore, AMOUNT_TO_CLAIM);
    }

    function testGetDigest() public view {
        bytes32 digest = _airdrop.getDigest(_jiating, AMOUNT_TO_CLAIM);
        
        console.logBytes32(digest);
    }
}
