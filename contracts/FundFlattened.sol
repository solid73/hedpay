pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


/**
 * @title Contactable token
 * @dev Basic version of a contactable contract, allowing the owner to provide a string with their
 * contact information.
 */
contract Contactable is Ownable {

  string public contactInformation;

  /**
    * @dev Allows the owner to set a string with their contact information.
    * @param _info The contact information to attach to the contract.
    */
  function setContactInformation(string _info) public onlyOwner {
    contactInformation = _info;
  }
}


contract IERC223Basic {
  function balanceOf(address _owner) public constant returns (uint);
  function transfer(address _to, uint _value) public;
  function transfer(address _to, uint _value, bytes _data) public;
  event Transfer(
    address indexed from, 
    address indexed to, 
    uint value, 
    bytes data
  );
}


contract IERC223 is IERC223Basic {
  function allowance(address _owner, address _spender) 
    public view returns (uint);

  function transferFrom(address _from, address _to, uint _value, bytes _data) 
    public;

  function approve(address _spender, uint _value) public;
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract IERC223BasicReceiver {
  function tokenFallback(address _from, uint _value, bytes _data) public;
}


contract IERC223Receiver is IERC223BasicReceiver {
  function receiveApproval(address _owner, uint _value) public;
}


/**
 * @title Basic contract that will hold ERC223 tokens
 */
contract ERC223BasicReceiver is IERC223BasicReceiver {
  event TokensReceived(address sender, address origin, uint value, bytes data);
  
  /**
   * @dev Standard ERC223 function that will handle incoming token transfers
   * @param _from address the tokens owner
   * @param _value uint the sent tokens amount
   * @param _data bytes metadata
   */
  function tokenFallback(address _from, uint _value, bytes _data) public {
    require(_from != address(0));
    emit TokensReceived(msg.sender, _from, _value, _data);
  }
}


/**
 * @title Contract that will hold ERC223 tokens
 */
contract ERC223Receiver is ERC223BasicReceiver, IERC223Receiver {
  event ApprovalReceived(address sender, address owner, uint value);

  /**
   * @dev Function that will handle incoming token approvals
   * @param _owner address the tokens owner
   * @param _value uint the approved tokens amount
   */
  function receiveApproval(address _owner, uint _value) public {
    require(_owner != address(0));
    emit ApprovalReceived(msg.sender, _owner, _value);
  }
}


/**
 * @title Contract that can hold and transfer ERC-223 tokens
 */
contract Fund is ERC223Receiver, Contactable {
  IERC223 public token;
  string public fundName;

  /**
   * @dev Constructor that sets the initial contract parameters
   * @param _token ERC223 address of the ERC-223 token
   * @param _fundName string the fund name
   */
  constructor(IERC223 _token, string _fundName) public {
    require(address(_token) != address(0));
    token = _token;
    fundName = _fundName;
  }

  /**
   * @dev ERC-20 compatible function to transfer tokens
   * @param _to address the tokens recepient
   * @param _value uint amount of the tokens to be transferred
   */
  function transfer(address _to, uint _value) public onlyOwner {
    token.transfer(_to, _value);
  }

  /**
   * @dev Function to transfer tokens
   * @param _to address the tokens recepient
   * @param _value uint amount of the tokens to be transferred
   * @param _data bytes metadata
   */
  function transfer(address _to, uint _value, bytes _data) public onlyOwner {
    token.transfer(_to, _value, _data);
  }

  /**
   * @dev Function to transfer tokens from the approved `msg.sender` account
   * @param _from address the tokens owner
   * @param _to address the tokens recepient
   * @param _value uint amount of the tokens to be transferred
   * @param _data bytes metadata
   */
  function transferFrom(
    address _from, 
    address _to, 
    uint _value, 
    bytes _data
  ) 
    public
    onlyOwner
  {
    token.transferFrom(_from, _to, _value, _data);
  }

  /**
   * @dev Function to approve account to spend owned tokens
   * @param _spender address the tokens spender
   * @param _value uint amount of the tokens to be approved
   */
  function approve(address _spender, uint _value) public onlyOwner {
    token.approve(_spender, _value);
  }
}
