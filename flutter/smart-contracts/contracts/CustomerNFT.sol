// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0; 

import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; // NFT's standard
import "@openzeppelin/contracts/access/Ownable.sol"; // to handle the ownership of the contract
import "@openzeppelin/contracts/utils/Counters.sol"; // to auto-increment the tokenID

contract CustomerNFT is ERC721URIStorage, Ownable {

    mapping (uint256 => uint256) private subscription_book;
    // keeping track of the tokenID
    mapping(address => uint256) private mintedWallets;
    
    IERC721 public adminNFT; // Reference to your AdminNFT contract

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor(address _nftAddress) ERC721("CustomerNFT", "CST") {
        adminNFT = IERC721(_nftAddress);
    }

    modifier onlyAdminNFTOwner () {
        // require that the sender has at least 1 BossNFT
        require(
            adminNFT.balanceOf(msg.sender) > 0,
            "Only AdminNFT owners can call this function"
        );
        _; // placeholder for the statement
    }

    /// The tokenId is auto-incremented
    function safeMint(address to, uint monthsValidity) public onlyAdminNFTOwner {
        uint256 tokenId = _tokenIdCounter.current();
        
        _safeMint(to, tokenId);

        mintedWallets[to] = tokenId;

        // here, in order to transform the monthsValidity in seconds we should 
        // do monthsValidity * 30 days.
        subscription_book[tokenId] = block.timestamp + monthsValidity * 30 seconds;

        _tokenIdCounter.increment();
    }

    function accessGym() public view {
        require(balanceOf(msg.sender) > 0, "The caller has no any CustomerNFT token");
        uint256 tokenId = mintedWallets[msg.sender];
        require(subscription_book[tokenId] > block.timestamp, "The subscription is expired");
    }

    function getCurrentTime() public view returns(uint){
        return block.timestamp;
    }

    function getExpirationByTokenId(uint256 tokenId) public view returns(uint256) {
        return subscription_book[tokenId];
    }

    function getTokenIdByAddress(address customerAddress) public view returns(uint256){
        return mintedWallets[customerAddress];
    }

}