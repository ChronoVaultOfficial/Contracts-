// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChronoVault {
    address public owner;

    struct Vault {
        address beneficiary;
        uint256 unlockTime;
        string message;
        bool claimed;
    }

    mapping(uint256 => Vault) public vaults;
    uint256 public nextVaultId;

    event VaultCreated(uint256 vaultId, address beneficiary, uint256 unlockTime);
    event VaultClaimed(uint256 vaultId, address claimant);

    constructor() {
        owner = msg.sender;
    }

    function createVault(address _beneficiary, uint256 _unlockTime, string memory _message) external {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");

        vaults[nextVaultId] = Vault({
            beneficiary: _beneficiary,
            unlockTime: _unlockTime,
            message: _message,
            claimed: false
        });

        emit VaultCreated(nextVaultId, _beneficiary, _unlockTime);
        nextVaultId++;
    }

    function claimVault(uint256 _vaultId) external {
        Vault storage vault = vaults[_vaultId];
        require(msg.sender == vault.beneficiary, "Not the beneficiary");
        require(block.timestamp >= vault.unlockTime, "Too early to claim");
        require(!vault.claimed, "Already claimed");

        vault.claimed = true;
        emit VaultClaimed(_vaultId, msg.sender);
    }

    function getVaultMessage(uint256 _vaultId) external view returns (string memory) {
        Vault storage vault = vaults[_vaultId];
        require(msg.sender == vault.beneficiary, "Access denied");
        return vault.message;
    }
}
