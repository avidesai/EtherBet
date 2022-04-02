pragma solidity ^0.8.10;

contract PredictionMarket {
    enum President { Biden, Trump }
    struct Result {
        President winner;
        President loser;
    }
    Result public result;
    bool public electionFinished;

    mapping(President => uint) public bets;
    mapping(address => mapping(President => uint)) public betsPerGambler;
    address public oracle; 

    constructor(address _oracle) {
        oracle = _oracle;
    }

    function placeBet(President _president) external payable {
        require(electionFinished == false, 'Event has already passed');
        bets[_president] += msg.value;
        betsPerGambler[msg.sender][_president] += msg.value;
    }

    function withdrawGain() external {
        uint userBet = betsPerGambler[msg.sender][result.winner];
        require(userBet > 0, 'You do not have a winning bet');
        require(electionFinished == true, 'The event has not finished yet');
        // Winner's gains are composed of original bet + proportional share of losing bet pool
        uint gain = userBet + bets[result.loser] * userBet / bets[result.winner];
        // Reset betters bets so user cannot withdraw multiple times
        betsPerGambler[msg.sender][President.Biden] = 0;
        betsPerGambler[msg.sender][President.Trump] = 0;
        payable(msg.sender).transfer(gain);
    }

    function reportResult(President _winner, President _loser) external {
        require(oracle == msg.sender, 'Only oracle is allowed');
        require(electionFinished == false, 'Event is finished');
        result.winner = _winner;
        result.loser = _loser;
        electionFinished = true;
    }

}