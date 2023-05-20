// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTContract is ERC721, Ownable {

    using Strings for uint256;

    uint256 public constant MAX_TOKENS = 10000;
    uint256 private constant TOKENS_RESERVED = 5;
    uint256 public price = 80000000000000000;
    uint256 public constant MAX_MINT_PER_TX = 10;

    bool public isSaleActive;
    uint256 public totalSupply;
    mapping(address => uint256) private mintedPerWallet;

    string public baseUri;
    string public baseExtension = ".json";

    constructor() ERC721("NFT Name", "SYMBOL"){
        //base IPFS URI of the NFTs
        baseUri = "ipfs://xxxxxxxx";
        //++i less gas than i++ : no temporary strage varaible

        //In constructor mint the reserved number of tokens
        for(uint256 i = 1; i<=TOKENS_RESERVED; ++i){
            _safeMint(msg.sender, i);
        }
        totalSupply = TOKENS_RESERVED;
    }

    function mint(uint256 _numTokens) external payable{
        require(isSaleActive, "The sale is no longer active");
        require(_numTokens <= MAX_MINT_PER_TX, "You have reached the maximum number you can mint per transaction");
        require(mintedPerWallet[msg.sender] + _numTokens <= 10, "You can only mint 10 per wallet.");
        uint256 curTotalSupply = totalSupply;
        require(curTotalSupply + _numTokens <= MAX_TOKENS, "Exceeds Max Token Count");
        require(_numTokens * price <= msg.value, "Insufficient funds");

        for(uint256 i = 1; i < _numTokens; ++i){
            _safeMint(msg.sender, curTotalSupply + 1);
        }
        mintedPerWallet[msg.sender] += _numTokens;
        totalSupply += _numTokens;
    }
    // Owner Only Functions
    function flipSaleState() external onlyOwner{
        isSaleActive = !isSaleActive;
    }

    //most common usecase for this function would be a late reveal nft collection
    function setBaseURI(string memory _baseUri) external onlyOwner{
        baseUri = _baseUri;
    }

    //A usecase for this is when you have different prices for presale and post sale
    function setPrice(uint256 _price) external onlyOwner{
        price = _price;
    }


    function withdrawAll() external payable onlyOwner{
        uint256 balance = address(this).balance;

        //Splitting the address balance 50/50
        uint256 balanceOne = balance * 50 /100;
        uint256 balanceTwo = balance * 50 / 100;

        (bool transferOne, ) = payable(0xD26D6EA83bd7F54006e80d5f2134d20eC5aF85c4).call{value: balanceOne}("");
        (bool transferTwo, ) = payable(0xD26D6EA83bd7F54006e80d5f2134d20eC5aF85c4).call{value: balanceTwo}("");
        
        //require that both transfers go through, else revert
        require(transferOne && transferTwo, "Transfer failed.");
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistant token"
        );

        string memory currentBaseUri = _baseURI();
        return bytes(currentBaseUri).length > 0 ? string(abi.encodePacked(currentBaseUri, tokenId.toString(), baseExtension)) : 
        "";
    }

    //Internal Functions
    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }











}
