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


    // Define ERC 20 necessary events

    event Transfer(
address indexed from,
address indexed to,
uint256 value
);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);

    constructor (

string memory _propertyID,
uint8 _decimalUnits,
string memory _propertySymbol,
address _mainPropertyOwner,
uint8 _tax,
uint256 _initialPropertyShares
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

    function transfer(address _to, uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
uint256 allowance = allowed[_from][msg.sender];
require(balances[_from] >= _value && allowance >= _value);
balances[_to] += _value;
balances[_from] -= _value;
if (allowance < MAX_UINT256) {
allowed[_from][msg.sender] -= _value;
}
emit Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}


    function setTax (uint8 _x) public onlyGov {
        require( _x <= 100, "Valid tax rate  (0% - 100%) required" );
        {
            tax = _x;
        }
    }

    function claimOwnership () public {
        require(balances[msg.sender] > (totalSupply /2) && msg.sender != mainPropertyOwner,
        "Error. You do not own more than 50% of the property tokens or you are the main owner allready");
        mainPropertyOwner = msg.sender;
  }


    receive() external payable {

}

   // function realEstate(){
    //}
}