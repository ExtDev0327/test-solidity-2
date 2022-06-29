//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/// @title Test A Contract
/// @author Akira Saito
contract AContract is ERC721URIStorage {
    modifier isNotNFTOwner(address account) {
        require(balanceOf(account) == 0);
        _;
    }

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    /// @dev user can own only one token.
    /// @param to destination address.
    /// @param tokenId token ID to be minted.
    /// @param _tokenURI tokenUri of the token to be minted.
    /// @return return true if succeeded.
    function mint(
        address to,
        uint256 tokenId,
        string memory _tokenURI
    ) external payable isNotNFTOwner(to) returns (bool) {
        require(msg.value >= 0.01 ether, "Not enough fund");
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return true;
    }
}
