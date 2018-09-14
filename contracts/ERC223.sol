pragma solidity ^0.4.24;

import "./ERC223Basic.sol";


contract ERC223 is ERC223Basic {
  function allowance(address _owner, address _spender) 
    public view returns (uint);

  function transferFrom(address _from, address _to, uint _value, bytes _data) 
    public;

  function approve(address _spender, uint _value) public;
  event Approval(address indexed owner, address indexed spender, uint value);
}
