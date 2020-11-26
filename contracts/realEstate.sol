pragma solidity ^0.7.0;

contract realEstate{

    // Declare state variables in this section

    address public gov = msg.sender;
    uint8 public tax;
    address public mainPropertyOwner;

    // Create ERC 20 necessary values


uint256 constant private MAX_UINT256 = 2**256 - 1;
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) public allowed;
uint256 totalSupply;
string public name;
uint8 public decimals;
string public symbol;


    // Define events
    constructor (
uint256 _initialPropertyShares,
string memory _propertyID,
uint8 _decimalUnits,
string memory _propertySymbol,
address _mainPropertyOwner,
uint8 _tax
) {
balances[_mainPropertyOwner] = _initialPropertyShares;
totalSupply = _initialPropertyShares;
name = _propertyID;
decimals = _decimalUnits;
symbol = _propertySymbol;
tax = _tax;
mainPropertyOwner = _mainPropertyOwner;
}

    // Define modifiers in this section
    modifier onlyGov{
        require(msg.sender == gov);
        _;
}
    modifier onlyPropOwner{
        require(msg.sender == mainPropertyOwner);
        _;
}
    // Define functions in this section

  //  function payRent () payable {
//    deposits[msg.sender] += msg.value;
//}

    function setTax (uint8 _x) public onlyGov {
        require( _x <= 100, "Valid tax rate  (0% - 100% required)" );
        {
            tax = _x;
        }
    }


    receive() external payable {

}

   // function realEstate(){
    //}
}