// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract SimpleEscrow {
    enum State { AWAITING_FUND, FUNDED, RELEASED, REFUNDED, CANCELLED, DISPUTED }

    struct EscrowDeal {
        address depositor;
        address beneficiary;
        address arbiter;
        address token; 
        uint256 amount;
        uint256 createdAt;
        State state;
        string metadata; 
    }

    uint256 public nextId;
    mapping(uint256 => EscrowDeal) public deals;

    
    uint256 private _status;
    constructor() { _status = 1; }
    modifier nonReentrant() {
        require(_status == 1, "Reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    
    event EscrowCreated(uint256 indexed id, address indexed depositor, address indexed beneficiary, address arbiter, address token, uint256 amount);
    event Funded(uint256 indexed id);
    event Released(uint256 indexed id, address to, uint256 amount);
    event Refunded(uint256 indexed id, address to, uint256 amount);
    event Cancelled(uint256 indexed id);
    event Disputed(uint256 indexed id);

    

    function createEscrow(address _beneficiary, address _arbiter, address _token, uint256 _amount, string calldata _metadata) external returns (uint256) {
        require(_beneficiary != address(0), "zero beneficiary");
        require(_arbiter != address(0), "zero arbiter");
        require(_amount > 0, "amount 0");

        uint256 id = nextId++;
        deals[id] = EscrowDeal({
            depositor: msg.sender,
            beneficiary: _beneficiary,
            arbiter: _arbiter,
            token: _token,
            amount: _amount,
            createdAt: block.timestamp,
            state: State.AWAITING_FUND,
            metadata: _metadata
        });

        emit EscrowCreated(id, msg.sender, _beneficiary, _arbiter, _token, _amount);
        return id;
    }

    function fundEscrow(uint256 id) external payable nonReentrant {
        EscrowDeal storage e = deals[id];
        require(e.state == State.AWAITING_FUND, "not awaiting fund");
        require(msg.sender == e.depositor, "only depositor can fund");

        if (e.token == address(0)) {
            require(msg.value == e.amount, "wrong ETH amount");
        } else {
            require(msg.value == 0, "no ETH for token escrow");
            bool ok = IERC20(e.token).transferFrom(msg.sender, address(this), e.amount);
            require(ok, "ERC20 transferFrom failed");
        }

        e.state = State.FUNDED;
        emit Funded(id);
    }

    function release(uint256 id) external nonReentrant {
        EscrowDeal storage e = deals[id];
        require(e.state == State.FUNDED || e.state == State.DISPUTED, "not fundable");
        require(msg.sender == e.arbiter || msg.sender == e.depositor, "not authorized");

        e.state = State.RELEASED;
        _send(e.token, e.beneficiary, e.amount);
        emit Released(id, e.beneficiary, e.amount);
    }

    function refund(uint256 id) external nonReentrant {
        EscrowDeal storage e = deals[id];
        require(e.state == State.FUNDED || e.state == State.DISPUTED, "not refundable");
        require(msg.sender == e.arbiter, "only arbiter can refund");

        e.state = State.REFUNDED;
        _send(e.token, e.depositor, e.amount);
        emit Refunded(id, e.depositor, e.amount);
    }

    
    function cancel(uint256 id) external {
        EscrowDeal storage e = deals[id];
        require(e.state == State.AWAITING_FUND, "cannot cancel");
        require(msg.sender == e.depositor, "only depositor");

        e.state = State.CANCELLED;
        emit Cancelled(id);
    }

    function raiseDispute(uint256 id) external {
        EscrowDeal storage e = deals[id];
        require(e.state == State.FUNDED, "only funded can dispute");
        require(msg.sender == e.beneficiary || msg.sender == e.depositor, "only parties");

        e.state = State.DISPUTED;
        emit Disputed(id);
    }

    function _send(address token, address to, uint256 amount) internal {
        if (token == address(0)) {
            (bool ok, ) = payable(to).call{ value: amount }("");
            require(ok, "ETH transfer failed");
        } else {
            bool ok = IERC20(token).transfer(to, amount);
            require(ok, "ERC20 transfer failed");
        }
    }

    function getDeal(uint256 id) external view returns (EscrowDeal memory) {
        return deals[id];
    }

    receive() external payable {}
}
