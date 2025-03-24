pragma solidity ^ 0.5.17;
import "safemath.sol";
import "safeERC20.sol";
contract RoutineCoin {
	using SafeMath for uint256;
        using SafeERC20 for IERC20;
            IERC20 public token;

    string public constant name = "ROUTINE COIN";
    string public constant symbol = "ROU";
    uint256 public constant decimals = 18;
    address public stakeNode;        
    address public marketing;        
    address public partners; 
    address public preMined; 
    address public reserve;  

    uint256 public constant maxTotalSupply = 1790000000 * 10 ** decimals;   
    uint256 public constant totalSupplyInc = 0 * 10 ** decimals;   
    uint256 public constant stakeNodeFund = 1432000000 * 10 ** decimals;   
    uint256 public constant marketingFund = 35800000 * 10 ** decimals;   
    uint256 public constant partnersFund = 53700000 * 10 ** decimals;   
    uint256 public constant preMinedFund = 179000000 * 10 ** decimals;   
    uint256 public constant reserveFund = 89500000 * 10 ** decimals;

    uint256 public starttime;   
    uint256 public constant stakeNodePerBlock = 9075654710000000000;
    uint256 public constant marketingPerBlock = 226891368000000000;
    uint256 public constant partnersPerBlock = 340337052000000000;
    uint256 public constant reservePerBlock = 567228419000000000;
    uint256 public stakeNodeClaimed;   
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
    mapping(uint256 => UserList) public userslist;

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
    mapping(address => User) public users;

    // constructor
    constructor() public
    {
        stakeNode = 0x27440F8C09b07c3Fd84F8F789C00A681037284C5;
        marketing = 0x75F5A65338475525BC6c4A778d0b308D3decC26F;
        partners = 0x92AeadCb87AB163f30D2F950891D70Cd9A166bA2;
        preMined = 0x74ED9f9b47b0788E53259dcaFBCf44dE28F4149C;
        reserve = 0x6dC43a3BCa8a600dAF94EFb5A940303683dcFa34;
        balances[preMined] = preMinedFund;        // Deposit tokens for Owners
      emit Transfer(address(this), preMined, preMinedFund);
        starttime = block.timestamp;
    }

    function balanceOf(address _owner) view public returns(uint256 balance) {
        return balances[_owner];
    }

    function totalSupply() public view returns(uint256) {
        return preMinedFund + getTokenIncStakeNode(0) + getTokenIncMarketing(0) + getTokenIncPartners(0) + getTokenIncReserve(0);
    }

    function maxSupply() public view returns(uint256) {
        return maxTotalSupply;
    }

    function withdrawStakeNode() public {
        require(msg.sender == stakeNode);
        uint256 totalAmount = getTokenIncStakeNode(1);
        stakeNodeClaimed = stakeNodeClaimed.add(totalAmount);
        balances[msg.sender] = SafeMath.add(balances[msg.sender], totalAmount);
        emit Transfer(address(this), msg.sender, totalAmount);
    }

    function withdrawMarketing() public {
        require(msg.sender == marketing);
        uint256 totalAmount = getTokenIncMarketing(1);
        marketingClaimed = marketingClaimed.add(totalAmount);
        balances[msg.sender] = SafeMath.add(balances[msg.sender], totalAmount);
        emit Transfer(address(this), msg.sender, totalAmount);
    }

    function withdrawPartners() public {
        require(msg.sender == partners);
        uint256 totalAmount = getTokenIncPartners(1);
        partnersClaimed = partnersClaimed.add(totalAmount);
        balances[msg.sender] = SafeMath.add(balances[msg.sender], totalAmount);
        emit Transfer(address(this), msg.sender, totalAmount);
    }

    function withdrawReserve() public {
        require(msg.sender == reserve);
        uint256 totalAmount = getTokenIncReserve(1);
        reserveClaimed = reserveClaimed.add(totalAmount);
        balances[msg.sender] = SafeMath.add(balances[msg.sender], totalAmount);
        emit Transfer(address(this), msg.sender, totalAmount);
    }

    function getTokenIncStakeNode(uint256 user) public view returns(uint256) {
        uint256 totalAmount;
        uint256 time = 1825;
        uint256 finish = starttime.add(time.mul(1 days));
        uint256 share = stakeNodePerBlock;
        uint256 from = starttime;
        uint256 to = finish < block.timestamp ? finish : block.timestamp;
        if (from < to) {
            totalAmount = totalAmount.add(share.mul(to.sub(from)));
        }
        if (user == 1) {
            return totalAmount - stakeNodeClaimed;
        } else {
            return totalAmount;
        }
    }

    function getTokenIncMarketing(uint256 user) public view returns(uint256) {
        uint256 totalAmount;
        uint256 time = 1825;
        uint256 finish = starttime.add(time.mul(1 days));
        uint256 share = marketingPerBlock;
        uint256 from = starttime;
        uint256 to = finish < block.timestamp ? finish : block.timestamp;
        if (from < to) {
            totalAmount = totalAmount.add(share.mul(to.sub(from)));
        }
        if (user == 1) {
            return totalAmount - marketingClaimed;
        } else {
            return totalAmount;
        }
    }

    function getTokenIncPartners(uint256 user) public view returns(uint256) {
        uint256 totalAmount;
        uint256 time = 1825;
        uint256 finish = starttime.add(time.mul(1 days));
        uint256 share = partnersPerBlock;
        uint256 from = starttime;
        uint256 to = finish < block.timestamp ? finish : block.timestamp;
        if (from < to) {
            totalAmount = totalAmount.add(share.mul(to.sub(from)));
        }
        if (user == 1) {
            return totalAmount - partnersClaimed;
        } else {
            return totalAmount;
        }
    }

    function getTokenIncReserve(uint256 user) public view returns(uint256) {
        uint256 totalAmount;
        uint256 time = 1825;
        uint256 finish = starttime.add(time.mul(1 days));
        uint256 share = reservePerBlock;
        uint256 from = starttime;
        uint256 to = finish < block.timestamp ? finish : block.timestamp;
        if (from < to) {
            totalAmount = totalAmount.add(share.mul(to.sub(from)));
        }
        if (user == 1) {
            return totalAmount - reserveClaimed;
        } else {
            return totalAmount;
        }
    }

    function transfer(address _to, uint256 _value) public returns(bool)
    {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
      emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns(bool success) {
        require(_to != address(0));
        require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
        balances[_from] = SafeMath.sub(balances[_from], _amount);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _amount);
        balances[_to] = SafeMath.add(balances[_to], _amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns(bool success) {
        require(_spender != address(0));
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {
        require(_owner != address(0) && _spender != address(0));
        return allowed[_owner][_spender];
    }

    function () external payable {
        revert();
    }

}
