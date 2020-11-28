pragma solidity ^0.7.0;


contract realEstate{



    // Declare state variables in this section

        // government will deploy contract

    address public gov = msg.sender;

        //there is a tax rate that the government can specify

    uint8 public tax;

        //main property has special privileges. can become main property owner by claiming function to claim  ownership if owning 51%.

    address public mainPropertyOwner;


        //An array of stakeholders is stored in an array. You can become a stakeholder by holding token and calling a function.

    address[] public stakeholders;

        //accumulated revenue for each stakeholder

    mapping(address => uint256) public revenues;

    //accumulated funds not distributed yet

   uint256 public accumulated;



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
string memory _propertySymbol,
address _mainPropertyOwner,
uint8 _tax
) {
balances[_mainPropertyOwner] = 100;
totalSupply = 100;
name = _propertyID;
decimals = 0;
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


    //
    //
    //
    //
    //

    function _transfer(address _to, uint256 _value) private returns (bool success) {
    require(balances[msg.sender] >= _value);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
    }
       function transfer(address _recipient, uint256 _amount)
       public
       returns (bool)
   {
       (bool isStakeholder, ) = isStakeholder(_recipient);
       require(isStakeholder);
       _transfer(_recipient, _amount);
       return true;
   }

   function isStakeholder(address _address)
       public
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);

   }

      function addStakeholder(address _stakeholder)
       public
       onlyGov
   {
       (bool _isStakeholder, ) = isStakeholder(_stakeholder);
       if (!_isStakeholder) stakeholders.push(_stakeholder);
   }

   /**
    * @notice A method to remove a stakeholder.
    * @param _stakeholder The stakeholder to remove.
    */
   function removeStakeholder(address _stakeholder)
       public
       onlyGov
   {
       (bool _isStakeholder, uint256 s)
           = isStakeholder(_stakeholder);
       if (_isStakeholder){
           stakeholders[s]
               = stakeholders[stakeholders.length - 1];
           stakeholders.pop();
       }
   }

   //
    // @notice A simple method that calculates the proportional
    //share for each stakeholder.
    //@param _stakeholder The stakeholder to calculate share for.



   function distribute()
       public
       onlyGov
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           address stakeholder = stakeholders[s];
           uint256 revenue
               = address(this).balance;
           accumulated = accumulated - revenue;
           revenues[stakeholder]
               = revenues[stakeholder] + revenue;
       }
   }

   /**
    * @notice A method to withdraw revenues.
    */
   function withdraw()
       public
   {
       uint256 revenue = revenues[msg.sender];
       revenues[msg.sender] = 0;
    (msg.sender).transfer(revenue);
   }




        //increase accumulated by incoming transfer ammount
      receive () external payable{
       accumulated += msg.value;
   }

}