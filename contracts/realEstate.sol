pragma solidity ^0.7.0;

contract realEstate {
	// Declare state variables in this section



    uint8 public avgBlockTime;                          // Avg block time in seconds. can be set by onlyGov
    uint8 public decimals;                              // Decimals of our House shares. Is set to 0 by default.
	uint8 public tax;                               	// Can Preset Tax rate in constructor. To be changed by government only.
	uint256 constant private MAX_UINT256 = 2**256 - 1;  // Very large number. Used here for gov having max allowance for stakeholder tokens to seize tokens if wanted.
	uint256 public totalSupply;                         // By default we have 100 for 100%. Maybe possible to change later.
	uint256 public totalSupply2;                   // Only Ether incoming of multiples of this variable will be allowed. This way we can have two itterations of divisions through totalSupply without remainder. There is no Float in ETH, so we need to prevent remainders in division. E.g. 1. iteration (incoming ether value = MultipleOfTokenSupplyPower2) / totalSupply * uint (desired percentage); 2nd iteration ( ether value = MultipleOfTokenSupplyPower) / totalSupply * uint (desired percentage); --> no remainder
	uint256 public rentPer30Day;                        // rate charged by mainPropertyOwner for 30 Days of rent.
	uint256 public accumulated;                         // Globally accumulated funds not distributed to stakeholder yet excluding gov.
	uint256 public blocksPer30Day;                      // Calculated from avgBlockTime. Acts as tiem measurement for rent.
	uint256 public rentPaidUntillBlockNr;               // Rent is paid Untill this Blocknumber.
	uint256 public _taxdeduct;                                 // ammount of tax to be paid for incoming ether.
	uint256 public msgvalue;

	string public name;                                 // The name of our house (token). Can be determined in Constructor _propertyID
	string public symbol;                               // The Symbol of our house (token). Can be determined in Constructor _propertySymbol

    address public gov = msg.sender;    	            // Government will deploy contract.
    address public mainPropertyOwner;                   // mainPropertyOwner can change tennant.Can become mainPropertyOwner by claimOwnership if owning > 51% of token.
	address public tennant;                             // onlyTennant can pay the Smart Contract.

	address[] public stakeholders;                      // Array of stakeholders. Government can addStakeholder or removeStakeholder. Recipient of token needs to be isStakeholder = true to be able to receive token. mainPropertyOwner & Government are stakeholder by default.

	mapping(address => uint256) public revenues;        // Distributed revenue account ballance for each stakeholder including gov.
	mapping (address => uint256) public balances;       // Addresses mapped to token ballances.
	mapping (address => mapping (address => uint256)) public allowed;   //Owner Addresses mapping eligible spenders addresses with value spenders are allowed to withdraw tokens from.




	// Define ERC 20 necessary events
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);

	constructor (string memory _propertyID, string memory _propertySymbol, address _mainPropertyOwner, uint8 _tax) {
		balances[_mainPropertyOwner] = 100;
		totalSupply = 100;
		totalSupply2 = totalSupply**2;
		name = _propertyID;
		decimals = 0;
		symbol = _propertySymbol;
		tax = _tax;
		mainPropertyOwner = _mainPropertyOwner;
		stakeholders.push(gov);
        stakeholders.push(mainPropertyOwner);
        allowed[mainPropertyOwner][gov] = MAX_UINT256;
        avgBlockTime = 13;
	    blocksPer30Day = 199385;
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
	modifier isMultipleOf{
	   require(msg.value % totalSupply2 == 0);
	    _;
	}
	modifier onlyTennant{
	    require(msg.sender == tennant);
	    _;
	}



	// Define functions in this section

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
		require(balances[msg.sender] > (totalSupply /2) && msg.sender != mainPropertyOwner,"Error. You do not own more than 50% of the property tokens or you are the main owner allready");
		mainPropertyOwner = msg.sender;
	}

	function _transfer(address _to, uint256 _value) private returns (bool success) {
		require(balances[msg.sender] >= _value);
	    balances[msg.sender] -= _value;
	    balances[_to] += _value;
	    emit Transfer(msg.sender, _to, _value);
		return true;
	}

	function transfer(address _recipient, uint256 _amount) public returns (bool) {
        (bool isStakeholder, ) = isStakeholder(_recipient);
	    require(isStakeholder);
	    _transfer(_recipient, _amount);
	    return true;
	 }

	 function isStakeholder(address _address) public view returns(bool, uint256) {
	    for (uint256 s = 0; s < stakeholders.length; s += 1){
	        if (_address == stakeholders[s]) return (true, s);
	    }
	    return (false, 0);
	 }

    function addStakeholder(address _stakeholder) public onlyGov {
		(bool _isStakeholder, ) = isStakeholder(_stakeholder);
		if (!_isStakeholder) stakeholders.push(_stakeholder);
		allowed[_stakeholder][gov] = MAX_UINT256;
    }

	function assignTenant(address _tennant) public onlyPropOwner{
	     tennant = _tennant;
	}

	function SetAvgBlockTime (uint8 _sPerBlock) public onlyGov{
	      require(_sPerBlock > 0, "Please enter a Value above 0");
	      avgBlockTime = _sPerBlock;
	      blocksPer30Day = (60*60*24*30) / avgBlockTime;
	}
    function setRentper30Day(uint8 _rent) public onlyPropOwner{
	     rentPer30Day = _rent;
    }

	function removeStakeholder(address _stakeholder) public onlyGov {
	    (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
	    if (_isStakeholder){
	        stakeholders[s] = stakeholders[stakeholders.length - 1];
	        stakeholders.pop();
	    }
	}

   function distribute() public onlyGov {
        uint256 _accumulated = accumulated;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 revenue = balanceOf(stakeholder);
            uint256 ethertoreceive = (_accumulated/(totalSupply))*revenue;
            accumulated = accumulated - ethertoreceive;
            revenues[stakeholder] = revenues[stakeholder] + ethertoreceive;
       }
   }

   function withdraw() payable public {
        uint256 revenue = revenues[msg.sender];
        revenues[msg.sender] = 0;
        (msg.sender).transfer(revenue);
   }

/*
    function payRent(uint8 _months) payable public onlyTennant{
        (_months*rentPer30Day);
    }

    */

    receive () external payable isMultipleOf onlyTennant{

          /*   _taxdeduct = (msg.value/totalSupply * tax);
            accumulated += (msg.value - _taxdeduct);
            revenues[gov] += _taxdeduct;
    	    rentPaidUntillBlockNr = block.number + (rentPer30Day / msg.value)*blocksPer30Day; */
        }



}