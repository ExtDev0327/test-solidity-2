//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC721.sol";

interface IContractA is IERC721 {
    function mint(
        address to,
        uint256 tokenId,
        string memory _tokenURI
    ) external payable returns (bool);
}
