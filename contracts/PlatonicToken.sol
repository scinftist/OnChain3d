//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/ERC721.sol";

// import "./ABDKMath64x64.sol";
// import "./Trigonometry.sol";
interface iMetadata {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract PlatonicToken is ERC721 {
    // address public immutable renderer;
    uint256 immutable maxToken = 500;
    uint256 public tokenCounter = 0;
    iMetadata private renderer0;

    constructor() ERC721("Solidity 3D Engine", "S3DE") {}

    function setMetadataRenderer(iMetadata _renderer0) public {
        renderer0 = _renderer0;
    }

    function mintToken() public {
        require(tokenCounter < 1000, "max token reached");
        ERC721._safeMint(msg.sender, tokenCounter);
        tokenCounter++;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        ERC721._requireMinted(tokenId);
        return renderer0.tokenURI(tokenId);
    }
}
