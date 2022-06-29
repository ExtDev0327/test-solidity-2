//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./IContractA.sol";

/// @title Test B Contract
/// @author Akira Saito
contract BContract is ERC721URIStorage, ERC721Holder {
    IContractA private _aContract;
    mapping(address => uint256) public escrowedTokens;

    constructor(
        address aContract_,
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        _aContract = IContractA(aContract_);
    }

    /// @dev user should input A's token to get B's token.
    /// @param to destination address.
    /// @param tokenId token ID to be minted.
    /// @param _tokenURI tokenUri of the token to be minted.
    /// @param aTokenId tokenID minted from AContract which will be escrowed.
    /// @return return true if succeeded.
    function mint(
        address to,
        uint256 tokenId,
        string memory _tokenURI,
        uint256 aTokenId
    ) external returns (bool) {
        require(
            _aContract.ownerOf(aTokenId) == msg.sender,
            "user doesn't own this token"
        );
        _aContract.safeTransferFrom(msg.sender, address(this), aTokenId);
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        escrowedTokens[msg.sender] = aTokenId;
        return true;
    }

    /// @dev retreive an escrowed token for user and burn b token.
    /// @param tokenId token of b contract to be burned.
    /// @return return true if succeeded.
    function swap(uint256 tokenId) external returns (bool) {
        require(ownerOf(tokenId) == msg.sender, "user doesn't own this token");

        _burn(tokenId);
        _aContract.safeTransferFrom(
            address(this),
            msg.sender,
            escrowedTokens[msg.sender]
        );
        escrowedTokens[msg.sender] = 0;
        return true;
    }
}
