# Property Titles Recorder

The Property Titles Recorder is a decentralized application (Dapp) built on the Sepolia blockchain Testnet that enables secure and transparent recording of property titles. Using ERC721 Smart Contracts, this Dapp allows users to tokenize property titles into NFTs (Non-Fungible Tokens) along with associated metadata. Furthermore, it leverages IPFS for immutable and decentralized storage of essential documents. One standout feature is its ability to filter titles based on the instrument number. The Dapp also includes a role-based access control system, allowing authorized users to approve property titles after verifying associated documents and information.

<a href="https://ibb.co/0rc1Cw0"><img src="https://i.ibb.co/Wf67kTr/Propertytitle.png" alt="Propertytitle" border="0"></a>


### Contract Functions:

### Modifiers
- `onlyManager()`
- `onlyOwner()`

### Contract Initialization
- `constructor()`

### Property Functions
- `createProperty(string memory tokenURI, uint256 instrumentNum)`
- `setTokenURI(uint256 tokenId, string memory _tokenURI)`
- `recordProperty(uint256 tokenId, uint256 instrumentNum)`

### Data Retrieval Functions
- `fetchAllPropertiesByManagers()`
- `fetchAllProperties()`
- `fetchPropertiesByNum(uint256 _instrumentNum)`
- `fetchUserProperty()`

### Manager Functions
- `addManager(address _newManager)`
- `approvedPropertyStatus(uint256 tokenId)`

### Contract Address

[View Property Title Recorder Smart Contract on Sepolia Testnet](https://sepolia.etherscan.io/tx/0x3112d31ab34c5e15656bf7a8257f2779c548ad521b3cf7c43c10b015610b56d9)


## Foundry Test
Follow the [instructions](https://book.getfoundry.sh/getting-started/installation.html) to install [Foundry](https://github.com/foundry-rs/foundry).

Clone and install dependencies: git submodule update --init --recursive  
Test Contract: ```forge test --contracts ./src/test/PropertyRecorder.t.sol -vvvv```

