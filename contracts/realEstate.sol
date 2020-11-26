pragma solidity ^0.7.0;

contract realEstate{
    /// Declare state variables in this section
  ///  address public owner = msg.sender;
    address public gov = msg.sender;
    uint8 public tax = 100;

    /// Define events

    /// Define modifiers in this section
    modifier onlyGov{
        require(msg.sender == owner);
        _;
}
    modifier onlyPropOwner{
        require(msg.sender == owner);
        _;
}
    /// Define functions in this section

  ///  function payRent () payable {
///    deposits[msg.sender] += msg.value;
///}

    function setTax (uint8 _x) public onlyGov {
        require( _x <= 100, "Valid tax rate  (0% - 100%) required" );
        {
            tax = _x;
        }
    }


    receive() external payable {

}

   /// function realEstate(){
    ///}
}