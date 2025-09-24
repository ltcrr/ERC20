// SPDX-License-Identifier: MIT


modifier nonReentrant() {
uint256 status = _status;
if (status == 2) revert();
_status = 2;
_;
_status = 1;
}


uint256 private _status = 1;


function createCampaign(uint256 goal, uint64 startAt, uint64 endAt) external returns (uint256) {
if (goal == 0) revert InvalidAmount();
if (endAt <= startAt) revert InvalidAmount();
if (endAt > startAt + MAX_DURATION) revert InvalidAmount();
if (startAt < block.timestamp) revert InvalidAmount();


campaignCount++;
campaigns[campaignCount] = Campaign({
creator: payable(msg.sender),
goal: goal,
pledged: 0,
startAt: startAt,
endAt: endAt,
withdrawn: false
});


emit CampaignCreated(campaignCount, msg.sender, goal, startAt, endAt);
return campaignCount;
}


function contribute(uint256 id) external payable campaignExists(id) nonReentrant {
Campaign storage c = campaigns[id];
if (block.timestamp < c.startAt || block.timestamp > c.endAt) revert CampaignNotActive();
if (msg.value == 0) revert InvalidAmount();


c.pledged += msg.value;
contributions[id][msg.sender] += msg.value;


emit Contributed(id, msg.sender, msg.value);
}


function withdraw(uint256 id) external campaignExists(id) nonReentrant {
Campaign storage c = campaigns[id];
if (msg.sender != c.creator) revert NotCreator();
if (block.timestamp <= c.endAt) revert CampaignNotEnded();
if (c.pledged < c.goal) revert GoalNotReached();
if (c.withdrawn) revert AlreadyWithdrawn();


uint256 amount = c.pledged;
c.withdrawn = true;
(bool ok, ) = c.creator.call{value: amount}('');
if (!ok) revert();


emit Withdrawn(id, c.creator, amount);
}


function refund(uint256 id) external campaignExists(id) nonReentrant {
Campaign storage c = campaigns[id];
if (block.timestamp <= c.endAt) revert CampaignNotEnded();
if (c.pledged >= c.goal) revert GoalNotReached();


uint256 bal = contributions[id][msg.sender];
if (bal == 0) revert NothingToRefund();


contributions[id][msg.sender] = 0;
(bool ok, ) = payable(msg.sender).call{value: bal}('');
if (!ok) revert();


emit Refunded(id, msg.sender, bal);
}


receive() external payable {
revert();
}


fallback() external payable {
revert();
}
}
