pragma solidity ^0.4.24;

import "./Fund.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * @title Contract that holds reserve tokens
 */
contract ReserveFund is Fund {
  using SafeMath for uint;

  uint public constant creationTime = 1537056000;

  uint public firstLimit = 20000000;
  uint public secondLimit = 10000000;
  uint public thirdLimit = 20000000;

  /**
   * @dev Constructor that sets the initial contract parameters
   * @param _token ERC223 address of the ERC-223 token
   */
  constructor(IERC223 _token) public Fund(_token, "Reserve Fund") {
  }

  /**
   * @dev ERC-20 compatible function to transfer tokens
   * @param _to address the tokens recepient
   * @param _value uint amount of the tokens to be transferred
   */
  function transfer(address _to, uint _value) public onlyOwner {
    _timeLimit(_value);
    super.transfer(_to, _value);
  }
  
  /**
   * @dev Function to transfer tokens
   * @param _to address the tokens recepient
   * @param _value uint amount of the tokens to be transferred
   * @param _data bytes metadata
   */
  function transfer(address _to, uint _value, bytes _data) public onlyOwner {
    _timeLimit(_value);
    super.transfer(_to, _value, _data);
  }

  /**
   * @dev Function to approve account to spend owned tokens
   * @param _spender address the tokens spender
   * @param _value uint amount of the tokens to be approved
   */
  function approve(address _spender, uint _value) public onlyOwner {
    _timeLimit(_value);
    super.approve(_spender, _value);
  }

  /**
   * @dev Internal function to check and substract the limit
   * @param _value uint amount of the tokens to be transferred/approved
   */
  function _timeLimit(uint _value) internal {
    if (block.timestamp < creationTime.add(360 days)) {
      require(_value <= firstLimit);
      firstLimit = firstLimit.sub(_value);
    } else if (
      block.timestamp >= creationTime.add(360 days) && 
      block.timestamp < creationTime.add(540 days)
    ) {
      require(_value <= firstLimit.add(secondLimit));
      if (firstLimit >= _value) {
        firstLimit = firstLimit.sub(_value);
      } else {
        secondLimit = secondLimit.sub(_value);
      }
    } else if (
      block.timestamp >= creationTime.add(540 days) && 
      block.timestamp < creationTime.add(720 days)
    ) {
      require(_value <= firstLimit.add(secondLimit).add(thirdLimit));
      if (firstLimit >= _value) {
        firstLimit = firstLimit.sub(_value);
      } else if (secondLimit >= _value) {
        secondLimit = secondLimit.sub(_value);
      } else {
        thirdLimit = thirdLimit.sub(_value);
      }
    }
  }

}
