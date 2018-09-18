pragma solidity ^0.4.24;

import "./IERC223.sol";
import "./IERC223Receiver.sol";
import "./IERC223BasicReceiver.sol";
import "./Fund.sol";
import "openzeppelin-solidity/contracts/ownership/Contactable.sol";
import "openzeppelin-solidity/contracts/AddressUtils.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * @title HEdpAY
 */
contract Hedpay is IERC223, Contactable {
  using AddressUtils for address;
  using SafeMath for uint;

  string public constant name = "HEdpAY";
  string public constant symbol = "Hdp.ф";
  uint8 public constant decimals = 4;
  uint8 public constant secondPhaseBonus = 33;
  uint8[3] public thirdPhaseBonus = [10, 15, 20];
  uint public constant totalSupply = 10000000000000;
  uint public constant secondPhaseStartTime = 1537056000;
  uint public constant secondPhaseEndTime = 1540943999;
  uint public constant thirdPhaseStartTime = 1540944000;
  uint public constant thirdPhaseEndTime = 1543622399;
  uint public constant startTime = secondPhaseStartTime;
  uint public constant endTime = thirdPhaseEndTime;
  uint public constant cap = 200000 ether;
  uint public constant goal = 25000 ether;
  uint public constant rate = 100;
  uint public constant minimumWeiAmount = 100 finney;
  uint public constant salePercent = 9;
  uint public constant bonusPercent = 1;
  uint public constant reservedPercent = 5;
  uint public constant teamPercent = 2;
  uint public constant preSalePercent = 3;

  uint public creationTime;
  uint public weiRaised;
  uint public tokensSold;
  uint public buyersCount;
  uint public saleAmount;
  uint public bonusAmount;
  uint public reservedAmount;
  uint public teamAmount;
  uint public preSaleAmount;

  Fund public reserveFund;

  mapping (address => uint) internal balances;
  mapping (address => mapping (address => uint)) internal allowed;
  mapping (address => uint) internal bonuses;

  /**
   * @dev Constructor that sets initial contract parameters
   */
  constructor() public {
    balances[owner] = totalSupply;
    creationTime = block.timestamp;
    saleAmount = totalSupply.div(100).mul(salePercent).mul(
      10 ** uint(decimals)
    );
    bonusAmount = totalSupply.div(100).mul(bonusPercent).mul(
      10 ** uint(decimals)
    );
    reservedAmount = totalSupply.div(100).mul(reservedPercent).mul(
      10 ** uint(decimals)
    );
    teamAmount = totalSupply.div(100).mul(teamPercent).mul(
      10 ** uint(decimals)
    );
    preSaleAmount = totalSupply.div(100).mul(preSalePercent).mul(
      10 ** uint(decimals)
    );
  }

  /**
   * @dev Gets an account tokens balance
   * @param _owner address the tokens owner
   * @return uint the specified address owned tokens amount
   */
  function balanceOf(address _owner) public view returns (uint) {
    require(_owner != address(0));
    return balances[_owner];
  }

  /**
   * @dev Gets the specified accounts approval value
   * @param _owner address the tokens owner
   * @param _spender address the tokens spender
   * @return uint the specified accounts spending tokens amount
   */
  function allowance(address _owner, address _spender) 
    public view returns (uint)
  {
    require(_owner != address(0));
    require(_spender != address(0));
    return allowed[_owner][_spender];
  }
  
  /**
   * @dev Checks whether the ICO has started
   * @return bool true if the crowdsale began
   */
  function hasStarted() public view returns (bool) {
    return block.timestamp >= startTime;
  }
  
  /**
   * @dev Checks whether the ICO has ended
   * @return bool `true` if the crowdsale is over
   */
  function hasEnded() public view returns (bool) {
    return block.timestamp > endTime;
  }

  /**
   * @dev Checks whether the cap has reached
   * @return bool `true` if the cap has reached
   */
  function capReached() public view returns (bool) {
    return weiRaised >= cap;
  }

  /**
   * @dev Gets the current tokens amount can be purchased for the specified 
   * @dev wei amount
   * @param _weiAmount uint wei amount
   * @return uint tokens amount
   */
  function getTokenAmount(uint _weiAmount) public pure returns (uint) {
    return _weiAmount.mul(rate).div((18 - uint(decimals)) ** 10);
  }

  /**
   * @dev Gets the current tokens amount can be purchased for the specified 
   * @dev wei amount (including bonuses)
   * @param _weiAmount uint wei amount
   * @return uint tokens amount
   */
  function getTokenAmountBonus(uint _weiAmount)
    public view returns (uint)
  {
    if (hasStarted() && secondPhaseEndTime >= block.timestamp) {
      return(
        getTokenAmount(_weiAmount).
        add(
          getTokenAmount(_weiAmount).
          div(100).
          mul(uint(secondPhaseBonus))
        )
      ); 
    } else if (thirdPhaseStartTime <= block.timestamp && !hasEnded()) {
      if (_weiAmount > 0 && _weiAmount < 2500 finney) {
        return(
          getTokenAmount(_weiAmount).
          add(
            getTokenAmount(_weiAmount).
            div(100).
            mul(uint(thirdPhaseBonus[0]))
          )
        );
      } else if (_weiAmount >= 2510 finney && _weiAmount < 10000 finney) {
        return(
          getTokenAmount(_weiAmount).
          add(
            getTokenAmount(_weiAmount).
            div(100).
            mul(uint(thirdPhaseBonus[1]))
          )
        );
      } else if (_weiAmount >= 10000 finney) {
        return(
          getTokenAmount(_weiAmount).
          add(
            getTokenAmount(_weiAmount).
            div(100).
            mul(uint(thirdPhaseBonus[2]))
          )
        );
      }
    } else {
      return getTokenAmount(_weiAmount);
    }
  }

  /**
   * @dev Gets an account tokens bonus
   * @param _owner address the tokens owner
   * @return uint owned tokens bonus
   */
  function bonusOf(address _owner) public view returns (uint) {
    require(_owner != address(0));
    return bonuses[_owner];
  }

  /**
   * @dev Gets an account tokens balance without freezed part of the bonuses
   * @param _owner address the tokens owner
   * @return uint owned tokens amount without freezed bonuses
   */
  function balanceWithoutFreezedBonus(address _owner) 
    public view returns (uint) 
  {
    require(_owner != address(0));
    if (block.timestamp >= thirdPhaseEndTime.add(90 days)) {
      if (bonusOf(_owner) < 10000) {
        return balanceOf(_owner);
      } else {
        return balanceOf(_owner).sub(bonuses[_owner].div(2));
      }
    } else if (block.timestamp >= thirdPhaseEndTime.add(180 days)) { 
      return balanceOf(_owner);
    } else {
      return balanceOf(_owner).sub(bonuses[_owner]);
    }
  }

  /**
   * @dev ERC-20 compatible function to transfer tokens
   * @param _to address the tokens recepient
   * @param _value uint amount of the tokens to be transferred
   */
  function transfer(address _to, uint _value) public {
    transfer(_to, _value, "");
  }

  /**
   * @dev Function to transfer tokens
   * @param _to address the tokens recepient
   * @param _value uint amount of the tokens to be transferred
   * @param _data bytes metadata
   */
  function transfer(address _to, uint _value, bytes _data) public {
    require(_value <= balanceWithoutFreezedBonus(msg.sender));
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    _safeTransfer(msg.sender, _to, _value, _data);

    emit Transfer(msg.sender, _to, _value, _data);
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
  {
    require(_from != address(0));
    require(_to != address(0));
    require(_value <= allowance(_from, msg.sender));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _safeTransfer(_from, _to, _value, _data);

    emit Transfer(_from, _to, _value, _data);
    emit Approval(_from, msg.sender, allowance(_from, msg.sender));
  }

  /**
   * @dev Function to approve account to spend owned tokens
   * @param _spender address the tokens spender
   * @param _value uint amount of the tokens to be approved
   */
  function approve(address _spender, uint _value) public {
    require(_spender != address(0));
    require(_value <= balanceWithoutFreezedBonus(msg.sender));
    allowed[msg.sender][_spender] = _value;
    _safeApprove(_spender, _value);
    emit Approval(msg.sender, _spender, _value);
  }

  /**
   * @dev Function to increase spending tokens amount
   * @param _spender address the tokens spender
   * @param _value uint increase tokens amount
   */
  function increaseApproval(address _spender, uint _value) public {
    require(_spender != address(0));
    require(
      allowance(msg.sender, _spender).add(_value) <= 
      balanceWithoutFreezedBonus(msg.sender)
    );
    
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_value);
    _safeApprove(_spender, allowance(msg.sender, _spender));
    emit Approval(msg.sender, _spender, allowance(msg.sender, _spender));
  }

  /**
   * @dev Function to decrease spending tokens amount
   * @param _spender address the tokens spender
   * @param _value uint decrease tokens amount
   */
  function decreaseApproval(address _spender, uint _value) public {
    require(_spender != address(0));
    require(_value <= allowance(msg.sender, _spender));
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].sub(_value);
    _safeApprove(_spender, allowance(msg.sender, _spender));
    emit Approval(msg.sender, _spender, allowance(msg.sender, _spender));
  }
  
  /**
   * @dev Function to set an account bonus
   * @param _owner address the tokens owner
   * @param _value uint bonus tokens amount
   */
  function setBonus(address _owner, uint _value, bool preSale) 
    public onlyOwner 
  {
    require(_owner != address(0));
    require(_value <= balanceOf(_owner));
    require(bonusAmount > 0 || reservedAmount > 0);
    require(_value <= bonusAmount || _value <= reservedAmount);

    bonuses[_owner] = _value;
    if (preSale) {
      preSaleAmount = preSaleAmount.sub(_value);
      transfer(_owner, _value, abi.encode("transfer the bonus"));
    } else {
      if (_value <= bonusAmount) {
        bonusAmount = bonusAmount.sub(_value);
        transfer(_owner, _value, abi.encode("transfer the bonus"));
      } else if (_value > bonusAmount && _value <= reservedAmount) {
        reservedAmount = reservedAmount.sub(_value);
        transferFrom(
          reserveFund, 
          _owner, 
          _value, 
          abi.encode("transfer the bonus")
        );
      }
    }

  }

  /**
   * @dev Function to refill balance of the specified account
   * @param _to address the tokens recepient
   * @param _weiAmount uint amount of the tokens to be transferred
   */
  function refill(address _to, uint _weiAmount) public onlyOwner {
    require(_preValidateRefill(_to, _weiAmount));
    setBonus(
      _to,
      getTokenAmountBonus(_weiAmount).sub(
        getTokenAmount(_weiAmount)
      ),
      false
    );
    buyersCount = buyersCount.add(1);
    saleAmount = saleAmount.sub(getTokenAmount(_weiAmount));
    transfer(_to, getTokenAmount(_weiAmount), abi.encode("refill"));
  }

  /**
   * @dev Function to refill balances of the specified accounts
   * @param _to address[] the tokens recepients
   * @param _weiAmount uint[] amounts of the tokens to be transferred
   */
  function refillArray(address[] _to, uint[] _weiAmount) public onlyOwner {
    require(_to.length == _weiAmount.length);
    for (uint i = 0; i < _to.length; i++) {
      refill(_to[i], _weiAmount[i]);
    }
  }

  /**
   * @dev Function to set the reserve fund and transfer tokens to it
   * @param _reserveFund Fund address of the deployed reserve fund
   */
  function setReserveFund(Fund _reserveFund) public onlyOwner {
    require(address(_reserveFund) != address(0));
    reserveFund = _reserveFund;
    transfer(
      address(_reserveFund), 
      reservedAmount, 
      abi.encode("transfer reserved tokens to the reserve fund")
    );
  }

  /**
   * @dev Function to finalize the sale
   * @param _teamFund address the team fund
   */
  function finalize(address _teamFund) public onlyOwner {
    require(_teamFund != address(0));
    require(teamAmount > 0);
    transfer(
      _teamFund,
      teamAmount,
      abi.encode("transfer reserved for team tokens to the team fund")
    );
    teamAmount = 0;
  }

  /**
   * @dev Internal function to call the `tokenFallback` if the tokens 
   * @dev recepient is the smart-contract. If the contract doesn't implement 
   * @dev this function transaction fails
   * @param _from address the tokens owner
   * @param _to address the tokens recepient (perhaps the contract)
   * @param _value uint amount of the tokens to be transferred
   * @param _data bytes metadata
   */
  function _safeTransfer(
    address _from, 
    address _to, 
    uint _value, 
    bytes _data
  ) 
    internal 
  {
    if (_to.isContract()) {
      IERC223BasicReceiver receiver = IERC223BasicReceiver(_to);
      receiver.tokenFallback(_from, _value, _data);
    }
  }

  /**
   * @dev Internal function to call the `receiveApproval` if the tokens 
   * @dev recepient is the smart-contract. If the contract doesn't implement 
   * @dev this function transaction fails
   * @param _spender address the tokens recepient (perhaps the contract)
   * @param _value uint amount of the tokens to be approved
   */
  function _safeApprove(address _spender, uint _value) internal {
    if (_spender.isContract()) {
      IERC223Receiver receiver = IERC223Receiver(_spender);
      receiver.receiveApproval(msg.sender, _value);
    }
  }

  /**
   * @dev Internal function to prevalidate refill before execution
   * @param _to address the tokens recepient
   * @param _weiAmount uint amount of the tokens to be transferred
   * @return bool `true` if the refill can be executed
   */
  function _preValidateRefill(address _to, uint _weiAmount) 
    internal view returns (bool) 
  {
    return(
      hasStarted() && _weiAmount > 0 &&  weiRaised.add(_weiAmount) <= cap
      && _to != address(0) && _weiAmount >= minimumWeiAmount &&
      getTokenAmount(_weiAmount) <= saleAmount
    );
  }
}
