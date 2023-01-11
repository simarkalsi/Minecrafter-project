// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}


    /** 
    * @title CrowdFund Smart Contract
    * @author Simar Kalsi
    */

contract CrowdFund is Initializable {

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint startAt;
        uint endAt;
        bool claimed;
    }

    IERC20 public token;
    uint public count;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint startAt,
        uint endAt
    );
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);

    

    //upgradable contracts dont have contructor intialization so we have to go with Initializable libarary of openzepplin
     

     //enter address of custom erc20 token
     function initialize(address _token ) public initializer {
       token = IERC20(_token);
    }

    //Making new campaign
    //enter goal amount, starting time, ending time 
    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp,"Start time is less than current Block Timestamp");
        require(_endAt > _startAt,"End time is less than Start time");

        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(count,msg.sender,_goal,_startAt,_endAt);
    }

    //cancelling campaign only by creator
    //Enter Campaign Id
    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "You did not create this Campaign");
        require(block.timestamp < campaign.startAt, "Campaign has already started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    //pledging from donator in campaign 
    //enter  campaign Id and amount want to add in pledge amount
    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Campaign has not Started yet");
        require(block.timestamp <= campaign.endAt, "Campaign has already ended");
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    //option to reduce pledging amount by donor 
    //enter Campaign Id and amount want to reduce from pledged amount
    function unPledge(uint _id,uint _amount) external payable{
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Campaign has not Started yet");
        require(block.timestamp <= campaign.endAt, "Campaign has already ended");
        require(pledgedAmount[_id][msg.sender] >= _amount,"You do not have enough tokens Pledged to withraw");

        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    //amount claiming by creator if pledge amount is greater or equal to campaign goal
    //Enter Id of campaign
    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "You did not create this Campaign");
        require(block.timestamp > campaign.endAt, "Campaign has not ended");
        require(campaign.pledged >= campaign.goal, "Campaign did not succed");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);

        emit Claim(_id);
    }

    //refund to donor if pledge amount is smaller than campaign goal
    //Enter Id of campaign
    function refund(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "You cannot Withdraw, Campaign has succeeded");

        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;

        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }


}