

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/PropertyRecorder.sol";

contract ContractTest is Test {
    address admin = address(0x1);
    PropertyRecorder propertyRecorder;

    struct PropertyData {
      uint256 tokenId;
      address recorder;
      address database;
      uint256 instrumentNumber;
      bool recorded;
    }


    function setUp() public {
        // Create contract Instance
        propertyRecorder = new PropertyRecorder();
        vm.label(address(admin), "Admin");
    }


    function testCreateProperty() public returns(uint256 tokenId) {
        string memory tokenURI1 = "ipfs://token1.com";
        uint256 InstrumentNum1 = 1992;
        string memory tokenURI2 = "ipfs://token2.com";
        uint256 InstrumentNum2 = 1995;

        // Property #1
        tokenId = propertyRecorder.createProperty(tokenURI1, InstrumentNum1);
        (,
         address recorder,
         address database,
         uint256 instrumentNum,) = propertyRecorder.idToProperty(tokenId);
        console2.log("The token Id for token1 is", tokenId);
        // console2.log("Struct info", tokenId, recorder, database, instrumentNum);
        console2.log("Struct info for token 1...", instrumentNum);
        assertEq(tokenId, 1);

        // Property #2
        tokenId = propertyRecorder.createProperty(tokenURI2, InstrumentNum2);
        (,
         recorder,
         database,
         instrumentNum ,) = propertyRecorder.idToProperty(tokenId);
        console2.log("Struct info for token 2...", instrumentNum);
        assertEq(tokenId, 2);
    }   

    function testfetchAllProperties() public returns(PropertyData[] memory) {
        testCreateProperty();
        propertyRecorder.fetchAllProperties();
        
    }

    function testfetchPropertiesByNum(uint256 InstrumentNumber) public {
        testCreateProperty();
        propertyRecorder.fetchPropertiesByNum(InstrumentNumber);
        
    }
    

    function testfetchUserProperty() public {
        testCreateProperty();
        propertyRecorder.fetchUserProperty();
        
    }

    
}