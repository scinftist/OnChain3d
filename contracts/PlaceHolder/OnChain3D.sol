// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/security/ReentrancyGuard.sol";

interface ITokenURI {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract OnChain3D is ERC721Enumerable, Ownable, ReentrancyGuard {
    uint256 public constant _saleDuration = 10 * 86400;

    uint256 public constant _price = 0.01 ether;
    uint256 public constant _maxSupply = 10000;

    uint256 public _startTime;
    address private renderer;
    //IERC4906
    event MetadataUpdate(uint256 _tokenId);

    constructor() ERC721("OnChain3D-sepolia", "OC3D-sepolia") {
        _startTime = block.timestamp;
    }

    function setMetadataRenderer(address _renderer) public onlyOwner {
        renderer = _renderer;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        ERC721._requireMinted(tokenId);
        return ITokenURI(renderer).tokenURI(tokenId);
    }

    function mintToken(uint numberOfTokens) public payable nonReentrant {
        require(
            block.timestamp < _startTime + _saleDuration,
            "Sale Duration ended"
        );
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

    // maybe would be removed for mainnet for gas saving
    function pokeMetadataUpdate(uint256 _tokenId) external {
        require(msg.sender == renderer, "onlyrenderer");
        emit MetadataUpdate(_tokenId);
    }

    /// @dev See {IERC165-supportsInterface}.\\ ERC4906
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == bytes4(0x49064906) ||
            super.supportsInterface(interfaceId);
    }

    function remainingTime() public view returns (uint256) {
        if (_startTime + _saleDuration > block.timestamp) {
            return _startTime + _saleDuration - block.timestamp;
        } else {
            return 0;
        }
    }

    function withdraw() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        Address.sendValue(payable(owner()), balance);
    }
}
