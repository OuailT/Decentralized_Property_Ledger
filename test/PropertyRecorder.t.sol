

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/PropertyRecorder.sol";

contract ContractTest is Test {
    address admin = address(0x1);
    address user = address(0x2);
    PropertyRecorder propertyRecorder;

    function setUp() public {
        // Create contract Instance
        propertyRecorder = new PropertyRecorder();
        vm.label(address(admin), "Admin");
        vm.label(address(user), "User");
    }

    function testCreatePropertybyManager() public returns(uint256 tokenId) {
        testAddManager();
        // In case this is called by an unauthorized address ~~ , it should revert
        vm.startPrank(admin);
            string memory tokenURI1 = "ipfs://token1.com";
            uint256 InstrumentNum1 = 1992;
            tokenId = propertyRecorder.createPropertyByManagers(tokenURI1, InstrumentNum1);
            console.log("Token create by Manager", tokenId);
        vm.stopPrank();
    }

    function testAddManager() public {
        // In case the OnlyOwner adds an address as a Manager ~~ it should pass 
        propertyRecorder.addManager(admin);

        vm.startPrank(user);
        // In case random user tries to add themself as a Manager ~~ it should revert 
        propertyRecorder.addManager(user);
        vm.stopPrank();
    }


    function testCreateProperty() public returns(uint256 tokenId) {
        string memory tokenURI1 = "ipfs://token1.com";
        uint256 InstrumentNum1 = 1992;
        string memory tokenURI2 = "ipfs://token2.com";
        uint256 InstrumentNum2 = 1995;

        vm.startPrank(admin);
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
        vm.stopPrank();

        vm.startPrank(user); 
            // Property #2
            tokenId = propertyRecorder.createProperty(tokenURI2, InstrumentNum2);
            (,
            recorder,
            database,
            instrumentNum ,) = propertyRecorder.idToProperty(tokenId);
            console2.log("Struct info for token 2...", instrumentNum);
            assertEq(tokenId, 2);
        vm.stopPrank();
    }

    
    function testfetchAllProperties() public {
        testCreateProperty();
        PropertyRecorder.PropertyData[] memory items = propertyRecorder.fetchAllProperties();

        for(uint256 i = 0; i < items.length; i++) {
            console2.log("Items", i);
            console2.log("Tokens ID", items[i].tokenId);
            console2.log("Recorder:", items[i].recorder);
            console2.log("Database:", items[i].database);
            console2.log("Instrument Number:", items[i].instrumentNumber);
            console2.log("Recorded:", items[i].recorded);
        }

        console2.log("Arrya lengh", items.length);
        assertEq(items.length, 2);
    }



    function testfetchPropertiesByNum() public {
        testCreateProperty();

        uint256 InstrumentNum1 = 1995;
        PropertyRecorder.PropertyData[] memory items1 =  propertyRecorder.fetchPropertiesByNum(InstrumentNum1);
        console.log("Items1", items1[0].instrumentNumber);
        assertEq(items1.length, 1);
        
    }
    
    
    function testfetchUserProperty() public {
        testCreateProperty();
        propertyRecorder.fetchUserProperty();
        
    }

    
}