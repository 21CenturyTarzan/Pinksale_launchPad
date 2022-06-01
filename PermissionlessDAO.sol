// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.5.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File @openzeppelin/contracts/utils/math/SafeMath.sol@v4.5.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File @openzeppelin/contracts/utils/Strings.sol@v4.5.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.5.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/PermissionlessDAO.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
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
    }

    function startProposal(uint256 proposalId) public nonReentrant {
        
        require(proposalId >= 0, " proposal Id is invalid");
        Proposal storage proposal = proposalQueue[proposalId];
        require(proposal.startTime == 0,"proposal already started");
        proposal.startTime = block.timestamp;
        proposal.pState = Process.NONE;
    }

    function stopProposal(uint256 proposalId) public nonReentrant {
        
        require(proposalId >= 0, " proposal Id is invalid");
        require(proposalId < proposalQueue.length, " proposal Id is invalid");
        Proposal storage proposal = proposalQueue[proposalId];
        require(proposal.startTime != 0,"proposal not started");
        proposal.isEnded = true;
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

        // emit ProcessProposal(proposalIndex, proposalId, didPass);
    }
       
    // NOTE: requires that delegate key which sent the original proposal cancels, msg.sender == proposal.creator
    function cancelProposal(uint256 proposalId) public nonReentrant {
        Proposal storage proposal = proposalQueue[proposalId];
        require(msg.sender == proposal.creator, "solely the creator can cancel");
        proposalQueue[proposalId] = proposalQueue[proposalQueue.length - 1];
        proposalQueue.pop();
        // emit CancelProposal(proposalId, msg.sender);
    }

    // function isProposalStart(uint256 proposalIdx) public view returns (bool) {
    //     require(proposalIdx >= 0, "proposal Idx is not valid");
    //     Proposal storage proposal = proposalQueue[proposalIdx];
    //     require(proposal.startTime != 0, "proposal is not started");
    //     bool result = block.timestamp - proposal.startTime > 0 ? true : false;
    //     return result;
    // }
}
