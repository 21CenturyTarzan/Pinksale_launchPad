// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract PermissionlessDAO is ReentrancyGuard {
    using SafeMath for uint256;

    address public DCAToken;            // main utility token
    uint256 public proposalCount;       // total proposals submitted
    uint256 public minReqToken;         // minimum number of tokens needed for pitching new proposal. 
    
    enum Vote {
        Null,       // default value, counted as abstention
        Yes,
        No
    }

    enum Process {
        NONE,       // not processed yet.
        NOPASS,     // not passed.
        FPASS,      // passed with fund.
        NFPASS      // passed without fund.
    }

    struct Proposal {
        uint256 proposalId; // index of proposal start from 0 ~ 
        address creator;    // the account that submitted the proposal (can be non-member)
        bool    isCryptoFlow; // true if proposal ask to move crypto
        
        bool    isETH;      // true if token is Native token.
        address pToken;     // type of tokens that will be send.
        uint256 pTokenNum;  // number of token.
        address pTargetWallet;
        
        string  details;    // proposal details
        uint256 startTime;  // the period in which voting can start for this proposal
        uint256 yesVotes;   // the total number of YES votes for this proposal
        uint256 noVotes;    // the total number of NO votes for this proposal
        uint256 votingPeriodLength;      // default = 5 days
        bool    isEnded;    // true after passing proposal.
        Process pState;     // process state;
    }

    mapping(uint256 => mapping(address => Vote)) public votesByMember; // the votes on this proposal by each member on each proposal
    mapping(address => uint256) public members;
    // mapping(uint256 => Process) public processState;
    // mapping(uint256 => Proposal) public proposals;
    Proposal[] public proposalQueue;

            
    event SubmitProposalEvent(uint256 id, address creator, bool cryptoFlow, bool eth, address token, uint256 amount, address targetWallet, uint256 period, string details);
    event StartProposalEvent(uint256 id, uint256 sTime);
    event StopProposalEvent(uint256 proposalId);
    event dVoteEvent(uint256 Id, uint256 uintVote);
    event ProcessProposalEvent(uint256 proposalIndex, Process pState);
    event CancelProposalEvent(uint256 proposalId, address sender);

    modifier onlyTokenholder {
        require( IERC20(DCAToken).balanceOf(msg.sender) > 0, "not a tokenholder");
        _;
    }
   
    constructor( address _DCAToken, uint256 _minReqToken) {
        
        require(_minReqToken > 0, "minimum # of token for pitching a new proposal is invalid!");
        proposalCount = 0;
        minReqToken = _minReqToken;
        DCAToken = _DCAToken;
    }
    
    function submitProposal(
        bool    isCryptoFlow,
        bool    isETH,
        uint256 _tokenOffered,
        address _pToken,
        address _targetWallet,
        uint256 _votingPeriodLength,
        string memory details
    ) public nonReentrant onlyTokenholder returns (bool ) {
        require(IERC20(DCAToken).balanceOf(msg.sender) > minReqToken, "you don't have enough token to submit proposal.");
        if (isCryptoFlow){
            require(_tokenOffered > 0, "offered invalid amount of token.");
            require(_targetWallet != address(0), "target wallet is invalid.");
            require(_votingPeriodLength != 0, "voting period is invalid.");
            if(isETH){  // proposal for native token flow.
                _submitProposal(proposalCount, true, true, _tokenOffered, address(0), _targetWallet, _votingPeriodLength, details);
            }else{      // proposal for token flow.
                require(_pToken != address(0), "pToken is invalid");
                _submitProposal(proposalCount, true, false, _tokenOffered, _pToken, _targetWallet, _votingPeriodLength, details);
            }
            return true;
        }
        
        _submitProposal(proposalCount, false, false, 0, address(0), address(0), _votingPeriodLength, details);        
        return true;
    }

    function _submitProposal(
        uint256 id,
        bool    _isCryptoFlow,
        bool    _isETH,
        uint256 _tokenOffered,
        address _pToken,
        address _targetWallet,
        uint256 _votingPeriodLength,
        string memory _details
    ) internal {

        Proposal memory proposal;
        proposal.proposalId = id;
        proposal.creator = msg.sender;
        proposal.isCryptoFlow = _isCryptoFlow;
        proposal.isETH = _isETH;
        proposal.pToken = _pToken;
        proposal.pTokenNum = _tokenOffered;
        proposal.pTargetWallet = _targetWallet;
        proposal.startTime = 0;
        proposal.yesVotes = 0;
        proposal.noVotes = 0;
        proposal.details = _details;
        proposal.votingPeriodLength = _votingPeriodLength;
        proposal.isEnded = false;

        proposalQueue.push(proposal);
        proposalCount += 1;
        emit SubmitProposalEvent( id, msg.sender, _isCryptoFlow, _isETH, _pToken, _tokenOffered, _targetWallet, _votingPeriodLength, _details);
    }

    function startProposal(uint256 proposalId) public nonReentrant {
        
        require(proposalId >= 0, " proposal Id is invalid");
        Proposal storage proposal = proposalQueue[proposalId];
        require(proposal.startTime == 0,"proposal already started");
        proposal.startTime = block.timestamp;
        proposal.pState = Process.NONE;
        emit StartProposalEvent(proposalId, block.timestamp);
    }

    function stopProposal(uint256 proposalId) public nonReentrant {
        
        require(proposalId >= 0, " proposal Id is invalid");
        require(proposalId < proposalQueue.length, " proposal Id is invalid");
        Proposal storage proposal = proposalQueue[proposalId];
        require(proposal.startTime != 0,"proposal not started");
        proposal.isEnded = true;
        emit StopProposalEvent(proposalId);
    }

 
    function submitVote(uint256 proposalId, uint8 uintVote) public nonReentrant onlyTokenholder {
        address memberAddress = msg.sender;
        Proposal storage proposal = proposalQueue[proposalId];

        require(uintVote < 3, "must be less than 3");
        Vote vote = Vote(uintVote);

        require(proposal.startTime != 0, "not started");
        require(proposal.isEnded == false, "already ended");
        require((proposal.startTime + proposal.votingPeriodLength) > block.timestamp, "period passed");
        require(votesByMember[proposalId][memberAddress] == Vote.Null, "member has already voted");
        require(vote == Vote.Yes || vote == Vote.No, "vote must be either Yes or No");

        votesByMember[proposalId][memberAddress] = vote;

        if (vote == Vote.Yes) {
            proposal.yesVotes = proposal.yesVotes.add(IERC20(DCAToken).balanceOf(memberAddress));            
        } else if (vote == Vote.No) {
            proposal.noVotes = proposal.noVotes.add(IERC20(DCAToken).balanceOf(memberAddress));
        }

        emit dVoteEvent(proposalId, uintVote);
    }

    function processProposal(uint256 proposalIndex) public nonReentrant {
        require(proposalIndex <= proposalCount, "proposal does not exist");
        Proposal storage proposal = proposalQueue[proposalIndex]; 
        require(proposal.isEnded == true || (proposal.startTime + proposal.votingPeriodLength) <= block.timestamp , "proposal is not finished.");

        // PROPOSAL PASSED
        if (proposal.yesVotes >= proposal.noVotes) {
            if(proposal.isCryptoFlow){
                if(proposal.isETH){
                   (bool sent, ) = proposal.pTargetWallet.call{value: proposal.pTokenNum}("");
                   require(sent, "Failed to send Ether");
                }else{
                    IERC20(DCAToken).transfer(proposal.pTargetWallet, proposal.pTokenNum);
                }
                proposal.pState = Process.FPASS;
            }
            else { // crypto doesn't flow.            
                proposal.pState = Process.NFPASS;
            }
        } else {        // PROPOSAL FAILED
            proposal.pState = Process.NOPASS;
        }

        emit ProcessProposalEvent(proposalIndex, proposal.pState);
    }
       
    // NOTE: requires that delegate key which sent the original proposal cancels, msg.sender == proposal.creator
    function cancelProposal(uint256 proposalId) public nonReentrant {
        Proposal storage proposal = proposalQueue[proposalId];
        require(msg.sender == proposal.creator, "solely the creator can cancel");
        proposalQueue[proposalId] = proposalQueue[proposalQueue.length - 1];
        proposalQueue.pop();
        emit CancelProposalEvent(proposalId, msg.sender);
    }

    // function isProposalStart(uint256 proposalIdx) public view returns (bool) {
    //     require(proposalIdx >= 0, "proposal Idx is not valid");
    //     Proposal storage proposal = proposalQueue[proposalIdx];
    //     require(proposal.startTime != 0, "proposal is not started");
    //     bool result = block.timestamp - proposal.startTime > 0 ? true : false;
    //     return result;
    // }
}