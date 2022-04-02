pragma solidity ^0.8.10;

contract PredictionMarket {
    enum Side { Biden, Trump }
    struct Result {
        Side winner;
        Side loser;
    }
    Result public result;
    bool public electionFinished;

    mapping(Side => uint) public bets;
    mapping(address => mapping(Side => uint)) public betsPerGambler;
    address public oracle; 

    constructor(address _oracle) {
        oracle = _oracle;
    }

    function placeBet(Side _side) external payable {
        require(electionFinished == false, 'Event has already passed');
        bets[_side] += msg.value;
        betsPerGambler[msg.sender][_side] += msg.value;
    }

    function withdrawGain() external {
        uint gamblerBet = betsPerGambler[msg.sender][result.winner];
        require(gamblerBet > 0, 'You do not have a winning bet');
        require(electionFinished == true, 'The event has not finished yet');
        // Winner's gains are composed of original bet + proportional share of losing bet pool
        uint gain = gamblerBet + bets[result.loser] * gamblerBet / bets[result.winner];
        // Reset betters bets so user cannot withdraw multiple times
        betsPerGambler[msg.sender][Side.Biden] = 0;
        betsPerGambler[msg.sender][Side.Trump] = 0;
        payable(msg.sender).transfer(gain);
    }

    function reportResult(Side _winner, Side _loser) external {
        require(oracle == msg.sender, 'Only oracle is allowed');
        require(electionFinished == false, 'Event is finished');
        result.winner = _winner;
        result.loser = _loser;
        electionFinished = true;
    }

}