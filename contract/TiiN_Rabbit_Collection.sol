//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract TiiN_Rabbit_Collection is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint256 private _totalRabbits = 1200;
    uint256 private _rabbitPrice = 0.00 ether;
    uint256 private _maxPerMint = 1;
    uint256 private _walletLimit = 1;
    uint256 private _reservedRabbits = 200;
    bool private _isSaleLive = true;
    string private _baseTokenURI;
    string private _contractURI;

    constructor(string memory baseURI) ERC721("TiiN Rabbit Collection", "TRC") {
        setBaseURI(baseURI);
    }

    //Getters

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function rabbitPrice() public view returns (uint256) {
        return _rabbitPrice;
    }

    function walletLimit() public view returns (uint256) {
        return _walletLimit;
    }

    function totalRabbits() public view returns (uint256) {
        return _totalRabbits;
    }

    function maxPerMint() public view returns (uint256) {
        return _maxPerMint;
    }

    function isSaleLive() public view returns (bool) {
        return _isSaleLive;
    }

    function reservedRabbits() public view onlyOwner returns (uint256) {
        return _reservedRabbits;
    }

    //Setters

    function setPrice(uint256 _newCost) public onlyOwner {
        _rabbitPrice = _newCost;
    }

    function setWalletLimit(uint256 _newLimit) public onlyOwner {
        _walletLimit = _newLimit;
    }

    function setMaxPerMint(uint256 _newMintLimit) public onlyOwner {
        _maxPerMint = _newMintLimit;
    }
    
    function setTotalRabbits(uint256 _newTotal) public onlyOwner {
        _totalRabbits = _newTotal;
    }

    function setReservedRabbits(uint256 _newTotal) public onlyOwner {
        _reservedRabbits = _newTotal;
    }

    function setBaseURI(string memory _newURI) public onlyOwner {
        _baseTokenURI = _newURI;
    }

    function setContractURI(string memory _newContract) external onlyOwner {
        _contractURI = _newContract;
    }

    function deactivateSale() external onlyOwner {
        _isSaleLive = false;
    }

    function activateSale() external onlyOwner {
        _isSaleLive = true;
    }

    function mintRabbit(uint256 _count) public payable {
        uint256 totalMinted = _tokenIds.current();
        uint256 tokenCount = balanceOf(msg.sender);

        require(_isSaleLive, "Sale must be active to mint");
        require(totalMinted.add(_count) <= (_totalRabbits - _reservedRabbits), "Not enough NFTs left!");
        require(_count >0 && _count <= _maxPerMint, "Cannot mint specified number of NFTs.");
        require(msg.value >= _rabbitPrice.mul(_count), "Not enough BNB to purchase NFTs.");
        require((_count + tokenCount) <= _walletLimit, "Sorry you can only mint 1 per wallet");

        for (uint256 i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }

    function ownerMint(uint256 _count) public payable onlyOwner {
        uint256 totalMinted = _tokenIds.current();

        require(_reservedRabbits > 0, "Not enough reserved NFTs left!");
        require(totalMinted.add(_count) <= _totalRabbits, "Not enough NFTs left!");
        require(_count >0 && _count <= _maxPerMint, "Cannot mint specified number of NFTs.");

        for (uint256 i = 0; i < _count; i++) {
            _mintSingleNFT();
            _reservedRabbits = _reservedRabbits.sub(1);
        }
    }

    function _mintSingleNFT() private {
        uint256 totalMinted = _tokenIds.current();
        _safeMint(msg.sender, totalMinted);
        _tokenIds.increment();
    }

    function tokensOfOwner(address _owner) external view returns (uint[] memory) {

        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokensId = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function allTokensWithMeta() external view returns (string[] memory) {

        uint256 tokenCount = _tokenIds.current();
        string[] memory tokensId = new string[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenURI(i);
        }
        return tokensId;
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No BNB left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

}

