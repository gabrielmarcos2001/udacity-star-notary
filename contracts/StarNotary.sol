pragma solidity ^0.8.0;

//Importing openzeppelin-solidity ERC-721 implemented Standard
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

// StarNotary Contract declaration inheritance the ERC721 openzeppelin implementation
contract StarNotary is ERC721 {

    // Adding a constructor for being able to use open-zeppelin 4.x
    constructor(string memory name_, string memory symbol_) ERC721 (name_, symbol_) {}

    // Star data
    struct Star {
        string name;
    }

    // mapping the Star with the Owner Address
    mapping(uint256 => Star) public tokenIdToStarInfo;

    // mapping the TokenId and price
    mapping(uint256 => uint256) public starsForSale;
    
    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        
        // Builds a new Star struct with the given name
        Star memory newStar = Star(_name);

        // Associates the new star with the token id
        tokenIdToStarInfo[_tokenId] = newStar;

        // Assignes the ownership of the token id to the msg sender
        _mint(msg.sender, _tokenId);
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }

    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return payable(address(uint160(x)));
    }

    /**
    / Allows the sender to buy a star
    */
    function buyStar(uint256 _tokenId) public  payable {

        // Validates the star is for sale 
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        
        // Validates the sender has enought ether for buying the star
        uint256 starCost = starsForSale[_tokenId];
        require(msg.value >= starCost, "You need to have enough Ether");
        
        // Transfers the star token id from the owner address to the sender
        address ownerAddress = ownerOf(_tokenId);
        safeTransferFrom(ownerAddress, msg.sender, _tokenId);
        
        // Converts the star owner address to a payable so we can transfer the star cost
        address payable ownerAddressPayable = _make_payable(ownerAddress);

        // Transfers the cost of the star to the original owner
        ownerAddressPayable.transfer(starCost);

        // If the amount of ether sent was bigger than the star cost we need
        // to return the difference to the buyer
        if(msg.value > starCost) {
            _make_payable(msg.sender).transfer(msg.value - starCost);
        }
    }

    /**
    /   Returns the star name given a token
    */
    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory) {
        return tokenIdToStarInfo[_tokenId].name;
    }

    /**
    /   Exchanges stars ownership for 2 given stars
    */
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        //1. Passing to star tokenId you will need to check if the owner of _tokenId1 or _tokenId2 is the sender
        // require(ownerOf(_tokenId1) == msg.sender || ownerOf(_tokenId2) == msg.sender, "You can't transfer a star you don't own");
        
        uint256 senderToken;

        // Checks which of the stars owns the sender
        if (ownerOf(_tokenId1) == msg.sender) {
            senderToken = _tokenId1;
        }else if (ownerOf(_tokenId2) == msg.sender) {
            senderToken = _tokenId2;
        }

        // Gets the owners of the two tokens
        address tokenId1Owner = ownerOf(_tokenId1);
        address tokenId2Owner = ownerOf(_tokenId2);

        // Exchanges the tokens
        safeTransferFrom(tokenId1Owner, tokenId2Owner, _tokenId1);
        safeTransferFrom(tokenId2Owner, tokenId1Owner, _tokenId2);
    }

    /**
    /   Transfers a star to the destination address _to1
    /   Validates the user transfering the star is the owner
     */
    function transferStar(address _to1, uint256 _tokenId) public {
        // Checks the sender is the owner of the address
        require(ownerOf(_tokenId) == msg.sender, "You can't transfer a Star you don't owned");
        
        // Transfers the star from the original owner address to the destination address
        safeTransferFrom(msg.sender, _to1, _tokenId);
    }

}
