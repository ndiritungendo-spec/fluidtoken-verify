# fluidtoken-verify// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * Flattened OpenZeppelin + FluidToken
 * - IERC20
 * - IERC20Metadata
 * - Context
 * - ERC20
 * - SafeERC20 (with IERC20)
 * - Ownable
 * - FluidToken (your contract)
 *
 * NOTE: This file is intended for contract verification on Polygonscan.
 */

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This is a compact version of OpenZeppelin's ERC20 suitable for verification.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    // Internal transfer
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    // Internal mint
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    // Internal burn
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    // Allowance operations
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _allowances[owner][spender] = currentAllowance - amount;
            }
        }
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

/**
 * @dev SafeERC20 minimal helper for safe transfers and approvals.
 * This is a compact variant compatible with OpenZeppelin SafeERC20.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/* ========== Chainlink Aggregator Interface ========== */
interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80, int256, uint256, uint256, uint80);
    function decimals() external view returns (uint8);
}

/* ========== FluidToken Contract (your code inlined) ========== */

contract FluidToken is ERC20, Ownable {
    using SafeERC20 for IERC20;

    uint256 public constant TOTAL_SUPPLY = 10_000_000 * 1e18;
    uint256 public constant SALE_SUPPLY = (TOTAL_SUPPLY * 40) / 100;
    uint256 public constant AIRDROP_SUPPLY = (TOTAL_SUPPLY * 30) / 100;
    uint256 public constant MARKETING_LIQUIDITY_SUPPLY = (TOTAL_SUPPLY * 10) / 100;
    uint256 public constant TEAM_SUPPLY = (TOTAL_SUPPLY * 10) / 100;
    uint256 public constant DEV_SUPPLY = (TOTAL_SUPPLY * 10) / 100;

    address public foundationWallet;
    address public relayerWallet;

    address public marketingWallet = 0xD40C17e2076A6CaB4fCb4C7ad50693c0bd87c96F;
    address public teamWallet = 0x22A978289a5864be1890DAC00154A7d343273342;
    address public devWallet = 0x4cA465F7B25b630B62b4C36b64Dff963f81E27C0;

    uint256 public fldPriceUSDT6 = 1e6;
    uint256 public fldSold;

    mapping(address => AggregatorV3Interface) public priceFeeds;
    AggregatorV3Interface public nativePriceFeed;

    struct AirdropInfo {
        uint256 totalAllocated;
        uint8 claimedYears;
        uint256 startTime;
        bool completed;
    }
    mapping(address => AirdropInfo) public airdrops;
    address[] public airdropRecipients;
    uint256 public distributedAirdrops;
    uint8 public constant AIRDROP_YEARS = 5;

    uint32 private _finderRewardPPM = 1000;

    address[] public signers;
    mapping(address => bool) public isSigner;
    uint256 public requiredApprovals;

    struct Proposal {
        address token;
        address to;
        uint256 amount;
        uint256 approvals;
        bool executed;
    }
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public proposalApprovedBy;
    uint256 public proposalCount;

    event PriceUpdated(uint256 newPriceUSDT6);
    event PriceFeedSet(address token, address feed);
    event NativeFeedSet(address feed);
    event FoundationWalletUpdated(address newWallet);
    event RelayerWalletUpdated(address newWallet);
    event SaleExecuted(address indexed buyer, address payToken, uint256 payAmount, uint256 fldAmount);
    event AirdropAllocated(address indexed user, uint256 amount);
    event AirdropClaimed(address indexed user, uint256 amount, uint8 year);
    event FinderRewardUpdated(uint32 ppm);
    event ProposalCreated(uint256 id, address token, address to, uint256 amount);
    event ProposalApproved(uint256 id, address approver);
    event ProposalExecuted(uint256 id, address executor);

    constructor(
        address _foundationWallet,
        address _relayerWallet,
        address[] memory _initialSigners,
        uint256 _requiredApprovals
    ) ERC20("Fluid Token", "FLD") {
        require(_foundationWallet != address(0), "invalid foundation wallet");
        require(_relayerWallet != address(0), "invalid relayer wallet");
        require(_initialSigners.length >= _requiredApprovals && _requiredApprovals > 0, "invalid multisig");

        foundationWallet = _foundationWallet;
        relayerWallet = _relayerWallet;

        _mint(address(this), TOTAL_SUPPLY);

        _transfer(address(this), marketingWallet, MARKETING_LIQUIDITY_SUPPLY);
        _transfer(address(this), teamWallet, TEAM_SUPPLY);
        _transfer(address(this), devWallet, DEV_SUPPLY);

        for (uint i = 0; i < _initialSigners.length; i++) {
            address s = _initialSigners[i];
            require(s != address(0), "zero signer");
            require(!isSigner[s], "duplicate signer");
            isSigner[s] = true;
            signers.push(s);
        }
        requiredApprovals = _requiredApprovals;
    }

    function setFldPriceUSDT6(uint256 priceUSDT6) external onlyOwner {
        require(priceUSDT6 > 0, "price>0");
        fldPriceUSDT6 = priceUSDT6;
        emit PriceUpdated(priceUSDT6);
    }

    function setPriceFeed(address token, address feed) external onlyOwner {
        require(token != address(0) && feed != address(0), "zero addr");
        priceFeeds[token] = AggregatorV3Interface(feed);
        emit PriceFeedSet(token, feed);
    }

    function setNativePriceFeed(address feed) external onlyOwner {
        require(feed != address(0), "zero feed");
        nativePriceFeed = AggregatorV3Interface(feed);
        emit NativeFeedSet(feed);
    }

    function setFoundationWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "zero");
        foundationWallet = newWallet;
        emit FoundationWalletUpdated(newWallet);
    }

    function setRelayerWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "zero");
        relayerWallet = newWallet;
        emit RelayerWalletUpdated(newWallet);
    }

    function setFinderRewardPPM(uint32 ppm) external onlyOwner {
        require(ppm >= 10 && ppm <= 10000, "ppm out of range");
        _finderRewardPPM = ppm;
        emit FinderRewardUpdated(ppm);
    }

    function finderRewardPPM() external view returns (uint32) {
        return _finderRewardPPM;
    }

    function buyWithERC20AndGas(address payToken, uint256 payAmount, uint256 gasFee) external {
        require(payAmount > gasFee, "payAmount must > gasFee");
        require(relayerWallet != address(0) && foundationWallet != address(0), "wallets not set");
        require(address(priceFeeds[payToken]) != address(0), "no feed");

        uint256 saleAmount = payAmount - gasFee;
        if(gasFee > 0) IERC20(payToken).safeTransferFrom(msg.sender, relayerWallet, gasFee);
        IERC20(payToken).safeTransferFrom(msg.sender, foundationWallet, saleAmount);

        AggregatorV3Interface feed = priceFeeds[payToken];
        (, int256 price,,,) = feed.latestRoundData();
        require(price > 0, "invalid feed");
        uint8 aggDecimals = feed.decimals();
        uint8 tokenDecimals;
        try IERC20Metadata(payToken).decimals() returns (uint8 d) { tokenDecimals = d; } catch { tokenDecimals = 18; }

        uint256 usd18 = (saleAmount * uint256(price) * 1e18) / ((10 ** tokenDecimals) * (10 ** aggDecimals));
        uint256 fldAmount = (usd18 * 1e6) / fldPriceUSDT6;
        require(balanceOf(address(this)) >= fldAmount, "contract lacks FLD");
        require(fldSold + fldAmount <= SALE_SUPPLY, "sale supply exceeded");

        _transfer(address(this), msg.sender, fldAmount);
        fldSold += fldAmount;

        uint256 airdropAlloc = (fldAmount * AIRDROP_SUPPLY) / SALE_SUPPLY;
        if (airdropAlloc > 0) _allocateAirdrop(msg.sender, airdropAlloc);

        emit SaleExecuted(msg.sender, payToken, payAmount, fldAmount);
    }

    function buyWithNativeAndGas(uint256 gasFee) external payable {
        require(msg.value > gasFee, "msg.value <= gasFee");
        require(relayerWallet != address(0) && foundationWallet != address(0), "wallets not set");
        uint256 saleAmount = msg.value - gasFee;

        if(gasFee > 0) { (bool sentGas, ) = payable(relayerWallet).call{value: gasFee}(""); require(sentGas, "gas transfer failed"); }
        (bool sentSale, ) = payable(foundationWallet).call{value: saleAmount}(""); require(sentSale, "sale transfer failed");

        (, int256 answer,,,) = nativePriceFeed.latestRoundData();
        require(answer > 0, "invalid feed");
        uint8 aggDecimals = nativePriceFeed.decimals();
        uint256 usd18 = (saleAmount * uint256(answer) * 1e18) / (1e18 * (10 ** aggDecimals));
        uint256 fldAmount = (usd18 * 1e6) / fldPriceUSDT6;
        require(balanceOf(address(this)) >= fldAmount, "contract lacks FLD");
        require(fldSold + fldAmount <= SALE_SUPPLY, "sale supply exceeded");

        _transfer(address(this), msg.sender, fldAmount);
        fldSold += fldAmount;

        uint256 airdropAlloc = (fldAmount * AIRDROP_SUPPLY) / SALE_SUPPLY;
        if(airdropAlloc > 0) _allocateAirdrop(msg.sender, airdropAlloc);

        emit SaleExecuted(msg.sender, address(0), msg.value, fldAmount);
    }

    function _allocateAirdrop(address user, uint256 amount) internal {
        require(user != address(0) && amount > 0, "invalid");
        require(distributedAirdrops + amount <= AIRDROP_SUPPLY, "exceeds pool");
        AirdropInfo storage info = airdrops[user];
        if(info.totalAllocated == 0) { info.startTime = block.timestamp; airdropRecipients.push(user); }
        info.totalAllocated += amount;
        distributedAirdrops += amount;
        emit AirdropAllocated(user, amount);
    }

    function claimAirdrop() external {
        AirdropInfo storage info = airdrops[msg.sender];
        require(info.totalAllocated > 0 && !info.completed, "none or done");

        uint256 yearsSince = (block.timestamp - info.startTime) / 365 days;
        require(yearsSince >= 1, "first claim not yet");

        uint8 currentYear = uint8(yearsSince);
        require(currentYear >= 1 && currentYear <= AIRDROP_YEARS, "no claimable");
        require(info.claimedYears + 1 == currentYear, "already claimed/missed");

        uint256 perYear = info.totalAllocated / AIRDROP_YEARS;
        info.claimedYears += 1;
        if(info.claimedYears == AIRDROP_YEARS) info.completed = true;

        _transfer(address(this), msg.sender, perYear);
        emit AirdropClaimed(msg.sender, perYear, currentYear);
    }

    modifier onlySigner() { require(isSigner[msg.sender], "not signer"); _; }

    function createProposal(address token, address to, uint256 amount) external onlySigner returns(uint256){
        require(to!=address(0)&&amount>0,"invalid");
        proposalCount++;
        proposals[proposalCount]=Proposal(token,to,amount,0,false);
        emit ProposalCreated(proposalCount, token, to, amount);
        return proposalCount;
    }

    function approveProposal(uint256 id) external onlySigner {
        require(id>0 && id<=proposalCount, "unknown");
        Proposal storage p = proposals[id];
        require(!proposalApprovedBy[id][msg.sender], "already approved");
        require(!p.executed, "already executed");

        p.approvals++;
        proposalApprovedBy[id][msg.sender] = true;
        emit ProposalApproved(id, msg.sender);
    }

    function executeProposal(uint256 id) external onlySigner {
        Proposal storage p = proposals[id];
        require(!p.executed, "already executed");
        require(p.approvals >= requiredApprovals, "insufficient approvals");

        if(p.token == address(0)) {
            (bool sent, ) = payable(p.to).call{value: p.amount}("");
            require(sent, "transfer failed");
        } else {
            IERC20(p.token).safeTransfer(p.to, p.amount);
        }

        p.executed = true;
        emit ProposalExecuted(id, msg.sender);
    }

    receive() external payable {}
}
