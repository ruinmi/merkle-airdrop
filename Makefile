-include .env

.PHONY: deploy

deploy:
	@forge script script/DeployMerkleAirdrop.s.sol --rpc-url $(ANVIL_RPC_URL) --broadcast --account no1

digest:
	@forge script script/Interact.s.sol:GetDigest --rpc-url $(ANVIL_RPC_URL)

claim:
	@forge script script/Interact.s.sol:Claim --rpc-url $(ANVIL_RPC_URL) --broadcast --account no1

split:
	@forge script script/Interact.s.sol:SplitSignature --rpc-url $(ANVIL_RPC_URL)

balance:
	@forge script script/Interact.s.sol:BalanceOf --rpc-url $(ANVIL_RPC_URL)


