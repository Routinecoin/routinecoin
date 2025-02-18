pragma solidity ^0.5.17;
import "safemath.sol";
import "safeERC20.sol";
contract RoutineCoin {
	  using SafeMath for uint256;
	  using SafeERC20 for IERC20;
    IERC20 public token;

    string public constant name = "ROUTINE COIN";
    string public constant symbol = "RTC";
    uint256 public constant decimals = 18;
	  uint256 constant public INVEST_MIN_AMOUNT 	= 5000e18; // 100 USDT 
      
	  uint256 public maxUser = 280;
	  uint256 public currentUser = 0;
	  uint256 public totalInvested;
    address public stakeNode;        
    address public marketing;        
    address public partners; 
    address public angleInvestors; 
    address public liquidityPool; 
    address public reserve;  
    address payable public mainAccount;

    uint256 public constant maxTotalSupply          = 2800000000 * 10**decimals;   
    uint256 public constant totalSupplyInc          = 2240000000 * 10**decimals;   
    uint256 public constant stakeNodeFund           = 1960000000 * 10**decimals;   
    uint256 public constant marketingFund           = 56000000 * 10**decimals;   
    uint256 public constant partnersFund            = 84000000 * 10**decimals;   
    uint256 public constant angleInvestorsFund      = 280000000 * 10**decimals;   
    uint256 public constant liquidityPoolFund       = 280000000 * 10**decimals;   
    uint256 public constant reserveFund             = 140000000 * 10**decimals;

    uint256 public starttime;   
    uint256 public constant marketingPerBlock       = 771604938000000000;
    uint256 public constant partnersPerBlock        = 1157407410000000000;
    uint256 public constant reservePerBlock         = 1929012350000000000;
    uint256 public marketingClaimed;   
    uint256 public partnersClaimed;   
    uint256 public reserveClaimed;   
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint)) allowed;

    // events
    event CreateRoutine(address indexed _to, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed owner, address indexed spender, uint value);
    mapping(address => uint256) public stakeBalanceLedger_;
  

    struct userListDeposit {
      uint256 time;
      uint256 amount;
      uint256 start;
    }

    struct UserList {
      userListDeposit[] userListDeposits;
      uint256 total;
    }
    mapping (uint256 => UserList) public userslist;

    struct Deposit {
      uint256 time;
      uint256 amount;
      uint256 start;
    }

    struct User {
      Deposit[] deposits;
      uint256 checkpoint;
      uint256 withdrawn;
    }
	  mapping (address => User) public users;

    // constructor
    constructor() public
    {
      stakeNode         = 0x14fa12FC197eFdfe04F24809Ab72906Ac36CAFBE;
      marketing         = 0x0cA0b15d5f180eb0a2d9624efF406c183fb09ee2;
      partners          = 0x0Ca6e353144ef20d6206990Aa72f3bb2DdEb31ff;
      liquidityPool     = 0x08b4aC443E6F4b114d3f474A00C69A400B996403;
      reserve           = 0x91592cb1eE5B732EB80f15C5B4901D776d5D6E42;
      mainAccount       = 0x189c3bA7E27050165C7A2F67a7865830192eC2c4;
      token             = IERC20(0x55d398326f99059fF775485246999027B3197955);

      balances[stakeNode]           = stakeNodeFund;        // Deposit tokens for Owners
      balances[liquidityPool]       = liquidityPoolFund;    // Deposit tokens for Owners

      emit Transfer(address(this), stakeNode, stakeNodeFund);
      emit Transfer(address(this), liquidityPool, liquidityPoolFund);

      starttime = block.timestamp;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
      return balances[_owner];  
    }

    function totalSupply() public view returns (uint256) {
    	return totalSupplyInc+getTokenInc()+getTokenIncMarketing(0)+getTokenIncPartners(0)+getTokenIncReserve(0);
    }

    function maxSupply() public view returns (uint256) {
    	return maxTotalSupply;
    }

    function invest(uint256 iamount) public payable{
      uint256 value = iamount*10**18;
      require(value == INVEST_MIN_AMOUNT);
      require(value <= token.allowance(msg.sender, address(this)));
      require(currentUser < maxUser);
      uint256 time = 840;
      
      User storage user = users[msg.sender];
      UserList storage userlist = userslist[0];

      token.safeTransferFrom(msg.sender, mainAccount, value);

      if (user.deposits.length == 0) {
        user.checkpoint = block.timestamp;
      }
      userlist.total = userlist.total+1;

      user.deposits.push(Deposit(time, value, block.timestamp));
      userlist.userListDeposits.push(userListDeposit(time, value, block.timestamp));
      currentUser = currentUser+1;
      stakeBalanceLedger_[msg.sender] = SafeMath.add(stakeBalanceLedger_[msg.sender], value);
      totalInvested = SafeMath.add(totalInvested, value);
    }

    function withdrawdividend() public {
        User storage user = users[msg.sender];

        uint256 totalAmount 		= getUserDividends(msg.sender);
        user.withdrawn 				= user.withdrawn.add(totalAmount);
        balances[msg.sender] = SafeMath.add(balances[msg.sender], totalAmount);
        emit Transfer(address(this), msg.sender, totalAmount);
    }

    function withdrawMarketing() public {
        require(msg.sender == marketing);
        uint256 totalAmount 		= getTokenIncMarketing(1);
        marketingClaimed 				= marketingClaimed.add(totalAmount);
        balances[msg.sender] = SafeMath.add(balances[msg.sender], totalAmount);
        emit Transfer(address(this), msg.sender, totalAmount);
    }

    function withdrawPartners() public {
        require(msg.sender == partners);
        uint256 totalAmount 		= getTokenIncPartners(1);
        partnersClaimed 				= partnersClaimed.add(totalAmount);
        balances[msg.sender] = SafeMath.add(balances[msg.sender], totalAmount);
        emit Transfer(address(this), msg.sender, totalAmount);
    }

    function withdrawReserve() public {
        require(msg.sender == reserve);
        uint256 totalAmount 		= getTokenIncMarketing(1);
        reserveClaimed 				= reserveClaimed.add(totalAmount);
        balances[msg.sender] = SafeMath.add(balances[msg.sender], totalAmount);
        emit Transfer(address(this), msg.sender, totalAmount);
    }

    function getTokenIncMarketing(uint256 user) public view returns (uint256) {
        uint256 totalAmount;
        uint256 time = 840;
        uint256 finish = starttime.add(time.mul(1 days));
        uint256 share = marketingPerBlock;
        uint256 from = starttime;
        uint256 to = finish < block.timestamp ? finish : block.timestamp;
        if (from < to) {
          totalAmount = totalAmount.add(share.mul(to.sub(from)));					
        }	
        if(user == 1) {
          return totalAmount-marketingClaimed;
        } else {
          return totalAmount;
        }
    }

    function getTokenIncPartners(uint256 user) public view returns (uint256) {
        uint256 totalAmount;
        uint256 time = 840;
        uint256 finish = starttime.add(time.mul(1 days));
        uint256 share = partnersPerBlock;
        uint256 from = starttime;
        uint256 to = finish < block.timestamp ? finish : block.timestamp;
        if (from < to) {
          totalAmount = totalAmount.add(share.mul(to.sub(from)));					
        }	
        if(user == 1) {
          return totalAmount-partnersClaimed;
        } else {
          return totalAmount;
        }
    }

    function getTokenIncReserve(uint256 user) public view returns (uint256) {
        uint256 totalAmount;
        uint256 time = 840;
        uint256 finish = starttime.add(time.mul(1 days));
        uint256 share = reservePerBlock;
        uint256 from = starttime;
        uint256 to = finish < block.timestamp ? finish : block.timestamp;
        if (from < to) {
          totalAmount = totalAmount.add(share.mul(to.sub(from)));					
        }	
        if(user == 1) {
          return totalAmount-reserveClaimed;
        } else {
          return totalAmount;
        }
    }

    function getTokenInc() public view returns (uint256) {
        UserList storage userlist = userslist[0];
        uint256 totalAmount;
        for (uint256 i = 0; i < userlist.userListDeposits.length; i++) {			
        uint256 finish = userlist.userListDeposits[i].start.add(userlist.userListDeposits[i].time.mul(1 days));

        uint256 share = 13700000000000000;
        uint256 from = userlist.userListDeposits[i].start;
        uint256 to = finish < block.timestamp ? finish : block.timestamp;
        if (from < to) {
          totalAmount = totalAmount.add(share.mul(to.sub(from)));					
        }	
        
      }
      return totalAmount;
    }

    function getUserDividends(address userAddress) public view returns (uint256) {
      User storage user = users[userAddress];
        uint256 totalAmount;
        for (uint256 i = 0; i < user.deposits.length; i++) {			
        uint256 finish = user.deposits[i].start.add(user.deposits[i].time.mul(1 days));
        if (user.checkpoint < finish) {
          uint256 share = 13700000000000000;
          uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
          uint256 to = finish < block.timestamp ? finish : block.timestamp;
          if (from < to) {
            totalAmount = totalAmount.add(share.mul(to.sub(from)));					
          }	
        }
      }
      return totalAmount-users[userAddress].withdrawn;
    }

    function getTotalDividend(address userAddress) public view returns(uint256, uint256) {
      return (getUserDividends(userAddress), getUserDividends(userAddress)+users[userAddress].withdrawn);
    }

    function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
      return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
      for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
        amount = amount.add(users[userAddress].deposits[i].amount);
      }
    }
    
    function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256 amount, uint256 start, uint256 finish) {
      User storage user = users[userAddress];
      uint256 time;
      time = user.deposits[index].time;
      amount = user.deposits[index].amount;
      start = user.deposits[index].start;
      finish = user.deposits[index].start.add(time.mul(1 days));
    }

    function transfer(address _to, uint256 _value) public returns (bool)
    {
      require(_value <= balances[msg.sender]);
      balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
      balances[_to] = SafeMath.add(balances[_to], _value);
      emit Transfer(msg.sender, _to, _value);
      return true;
    }

    function transferFrom( address _from, address _to, uint256 _amount ) public returns (bool success) {
        require( _to != address(0));
        require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
        balances[_from] = SafeMath.sub(balances[_from],_amount);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender],_amount);
        balances[_to] = SafeMath.add(balances[_to],_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }
    
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require( _spender != address(0));
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
  
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        require( _owner != address(0) && _spender !=address(0));
        return allowed[_owner][_spender];
    }

    function () external payable {
        revert();
    }

}