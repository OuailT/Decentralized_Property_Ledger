// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


/// @title A contract for recording property titles as NFTs on the blockchain
/// @notice This contract uses ERC-721 standard for tokenizing property titles and allows various user roles to interact with property data.
/// @dev The contract utilizes OpenZeppelin's ERC721 and Counters libraries for token creation and management.

contract PropertyRecorder is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _titlesTransferred; // Transfer title
    
    //TODO: Add modifiers to function
    address public admin;
    address[] public managers;

    error UnautorizedCaller(string message);

    // Id to property Struct
    mapping(uint256 => PropertyData) public idToProperty;

    // Address to bool
    mapping(address => bool) public isManager;

    struct PropertyData {
      uint256 tokenId;
      address recorder;
      address database;
      uint256 instrumentNumber;
      string status;
      bool recorded;
    }

    event PropertyCreated (
      uint256 indexed tokenId,
      address recorder,
      address database,
      uint256 instrumentNum,
      string status,
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
      require(admin == msg.sender, "Caller not the owner");
      _;
    }

    

    /// @notice Allows minting of a property and recording the associated metadata
    /// @param tokenURI URL that holds the metadata of the property
    /// @param instrumentNum Instrument number associated with the property/NFT
    /// @return newTokenId The tokenId of the minted property
    function createProperty(string memory tokenURI, uint256 instrumentNum) external returns (uint256) {
      _tokenIds.increment();
      uint256 newTokenId = _tokenIds.current();

      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenURI);
      recordProperty(newTokenId, instrumentNum);
      return newTokenId;
    }


    /// @notice Allows the owner of an NFT or a manager to change the metadata
    /// @param tokenId The token ID of the NFT
    /// @param _tokenURI New metadata URI to be set for the token
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
        if(idToProperty[tokenId].recorder == msg.sender) {
            return _setTokenURI(tokenId, _tokenURI);
        } else if(isManager[msg.sender]) {
            return _setTokenURI(tokenId, _tokenURI);
        } else {
            revert UnautorizedCaller("Unautorized Caller");
        }   
    }


    /// @notice Records the metadata of a property internally
    /// @param tokenId Token ID of the minted property
    /// @param instrumentNum Instrument number associated with the property/NFT
    function recordProperty(
      uint256 tokenId,
      uint256 instrumentNum
    ) internal {
      string memory status = "pending";

      idToProperty[tokenId] =  PropertyData(
        tokenId,
        msg.sender, // recorder
        address(this),
        instrumentNum,
        status, // database
        true
      );
    
      _transfer(msg.sender, address(this), tokenId);

      emit PropertyCreated(
        tokenId,
        msg.sender,
        address(this),
        instrumentNum,
        status,
        true
      );
    }


    /// @notice Returns the properties held by the contract that managers can view
    /// @return items Array of PropertyData that managers have access to
    function fetchAllPropertiesByManagers() public view returns (PropertyData[] memory) {
      uint itemCount = _tokenIds.current();
      uint currentIndex = 0;
    
      PropertyData[] memory items = new PropertyData[](itemCount);
      for (uint i = 0; i < itemCount; i++) {
        if (idToProperty[i + 1].database == address(this) && isManager[msg.sender]) {
          uint currentId = i + 1;
          PropertyData storage currentItem = idToProperty[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }


    /// @notice Returns all the properties recorded in the contract
    /// @return items Array of all recorded PropertyData
    function fetchAllProperties() public view returns (PropertyData[] memory) {
      uint itemCount = _tokenIds.current();
      uint currentIndex = 0;
      
      PropertyData[] memory items = new PropertyData[](itemCount);
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

    
    /// @notice Fetches and filters properties based on their instrument number
    /// @param _instrumentNum Instrument number of a property
    /// @return items Array of PropertyData matching the instrument number
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


    /// @notice Fetches properties recorded by the calling user
    /// @return items Array of PropertyData recorded by the user
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

    
    /// @notice Allows the admin to add a new manager
    /// @param _newManager Address of the manager to be added
    function addManager(address _newManager) external onlyOwner {
      require(!isManager[_newManager], "Manager is not unique");
        managers.push(_newManager);
        isManager[_newManager] = true;
    }


    /// @notice Allows Managers to approve the status of properties
    /// @param tokenId Token ID of the property to approve
    function approvedPropertyStatus(uint256 tokenId) external onlyManager {
      PropertyData storage property = idToProperty[tokenId];
      require(property.recorder != address(0), "property doesn't exesit...");
        string memory newStatus = "approved";
        property.status =  newStatus; 
    }
    
}
