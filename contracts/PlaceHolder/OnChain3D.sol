// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@4.9.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.9.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.9.0/contracts/security/ReentrancyGuard.sol";

interface ITokenURI {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract OnChain3D is ERC721Enumerable, Ownable, ReentrancyGuard {
    uint256 public constant _price = 0.002 ether;
    uint256 public constant _maxSupply = 2000;
    event MetadataUpdate(uint256 _tokenId);
    address private renderer;

    constructor() ERC721("OnChain3D", "OC3D") {}

    function setMetadataRenderer(address _renderer) public onlyOwner {
        renderer = _renderer;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Enumerable) returns (bool) {
        return
            interfaceId == bytes4(0x49064906) ||
            super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        ERC721._requireMinted(tokenId);
        return ITokenURI(renderer).tokenURI(tokenId);
    }

    function mintToken(uint numberOfTokens) public payable nonReentrant {
        require(numberOfTokens <= 10, "Exceeded max token purchase");
        require(
            totalSupply() + numberOfTokens <= _maxSupply,
            "Purchase would exceed max supply of tokens"
        );
        require(
            _price * numberOfTokens <= msg.value,
            "Ether value sent is not correct"
        );

        for (uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = totalSupply();
            if (totalSupply() < _maxSupply) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function metadataRendererAddress() public view returns (address) {
        return renderer;
    }

    function emitUpdate(uint256 _id) public {
        require(msg.sender == renderer, "only renderer can invoke the update");
        emit MetadataUpdate(_id);
    }

    function withdraw() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        // Address.sendValue(payable(owner()), balance);

        payable(owner()).transfer(balance);
    }
}
