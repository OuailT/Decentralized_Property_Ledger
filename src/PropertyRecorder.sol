// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


/// @notice Smart contract that allows users to record property titles in the form of NFTs


contract PropertyRecorder is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsTransferred; // Transfer title
    
    //TODO: Add modifiers to function
    address public admin;
    address[] public managers;

    // Id to property Struct
    mapping(uint256 => PropertyData) public idToProperty;

    // Address to bool
    mapping(address => bool) public isManager;

    struct PropertyData {
      uint256 tokenId;
      address recorder;
      address database;
      uint256 instrumentNumber;
      bool recorded;
    }

    event PropertyCreated (
      uint256 indexed tokenId,
      address recorder,
      address database,
      uint256 instrumentNum,
      bool recorded
    );
    
    constructor() ERC721("Property title", "PTT") {
      admin = msg.sender;
    }

    /*** modifier */
    modifier onlyManager() {
      require(isManager[msg.sender],"Caller not authorized");
      _;
    }

    modifier onlyOwner() {
      require(admin == msg.sender, "Caller not authorized");
      _;
    }

    /// @notice Allows minting a property and recording the associated metadata
    /// @param tokenURI URL that holds the metadata of the property
    /// @param instrumentNum Instrument number associated with a property/NFT
    /// @return The tokenId of the minted property
    function createPropertyByManagers(string memory tokenURI, uint256 instrumentNum) public onlyManager() returns (uint) {
      _tokenIds.increment();
      uint256 newTokenId = _tokenIds.current();

      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenURI);
      recordProperty(newTokenId, instrumentNum);
      return newTokenId;
    }

    
    /// @notice Allows minting a property and recording the associated metadata
    /// @param tokenURI URL that holds the metadata of the property
    /// @param instrumentNum Instrument number associated with a property/NFT
    /// @return The tokenId of the minted property
    function createProperty(string memory tokenURI, uint256 instrumentNum) public returns (uint) {
      _tokenIds.increment();
      uint256 newTokenId = _tokenIds.current();

      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenURI);
      recordProperty(newTokenId, instrumentNum);
      return newTokenId;
    }


    /// @notice Allows recording the metadata of a property
    /// @param tokenId Token ID of the minted property
    /// @param instrumentNum Instrument number associated with a property/NFT
    function recordProperty(
      uint256 tokenId,
      uint256 instrumentNum
    ) internal {

      idToProperty[tokenId] =  PropertyData(
        tokenId,
        msg.sender, // recorder
        address(this),
        instrumentNum, // database
        true
      );
    

      _transfer(msg.sender, address(this), tokenId);
      emit PropertyCreated(
        tokenId,
        msg.sender,
        address(this),
        instrumentNum,
        true
      );
    }


    /// @notice Returns the properties held by the contract
    /// @return PropertyData[]
    function fetchAllProperties() public view returns (PropertyData[] memory) {
      uint itemCount = _tokenIds.current();
      uint unsoldItemCount = _tokenIds.current() - _itemsTransferred.current();
      uint currentIndex = 0;

      PropertyData[] memory items = new PropertyData[](unsoldItemCount);
      for (uint i = 0; i < itemCount; i++) {
        if (idToProperty[i + 1].database == address(this)) {
          uint currentId = i + 1;
          PropertyData storage currentItem = idToProperty[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    
    /// @notice Fetches and filters properties based on their _instrumentNumber
    /// @param _instrumentNum Instrument number of a property
    /// @return PropertyData[]
    function fetchPropertiesByNum(uint256 _instrumentNum) public view returns (PropertyData[] memory) {
    uint256 itemCount = _tokenIds.current();
    uint256 count = 0;

    // Count the number of tokens that match the instrument number
    for (uint256 i = 0; i < itemCount; i++) {
        if (idToProperty[i + 1].database == address(this) && idToProperty[i + 1].instrumentNumber == _instrumentNum) {
            count++;
        }
    }

    // Create a new array with the correct size
    PropertyData[] memory items = new PropertyData[](count);
    uint256 currentIndex = 0;

    // Populate the array with tokens that match the instrument number
    for (uint256 i = 0; i < itemCount; i++) {
        if (idToProperty[i + 1].database == address(this) && idToProperty[i + 1].instrumentNumber == _instrumentNum) {
            PropertyData storage currentItem = idToProperty[i + 1];
            items[currentIndex] = currentItem;
            currentIndex++;
        }
    }

    return items;
  }


    /// @notice Fetch property that user recorded
    /// @return PropertyData[]
    function fetchUserProperty() public view returns (PropertyData[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToProperty[i + 1].recorder == msg.sender) {
          itemCount += 1;
        }
      }

      PropertyData[] memory items = new PropertyData[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToProperty[i + 1].recorder == msg.sender) {
          uint currentId = i + 1;
          PropertyData storage currentItem = idToProperty[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }


    /// @notice Function that allows the admin to add a new manager
    /// @param _newManager Manager address
    function addManager(address _newManager) external onlyOwner {
      require(!isManager[_newManager], "Manager is not unique");
        managers.push(_newManager);
        isManager[_newManager] = true;
    }
}