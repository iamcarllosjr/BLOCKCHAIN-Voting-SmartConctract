//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Votes is Ownable {

    uint256 public currentVoting = 0;
    Candidates[] public voting;
    mapping (uint256 => mapping(address => VotingData)) public votingDatas;
    
    error InvalidChoice(uint8);
    error NoOpenVotes();
    error YouAlreadyVoting();

    event VotingDatas (address indexed Address, uint8 Choice, uint256 Date);

    constructor(address initialOwner) Ownable(initialOwner) {}

    struct Candidates {
        string candidate1;
        uint256 votes1;
        string candidate2;
        uint256 votes2;
        uint256 maxDate;
        uint256 currentVoting;
    }

    struct VotingData {
        address Address;
        uint8 Choice;
        uint256 Date;
        uint256 currentVoting;
    }

    function addCandidates(string memory _candidate1, string memory _candidate2, uint256 timeToVote) public onlyOwner {
        if(voting.length >= 0) currentVoting++;
        Candidates memory newCandidates;
        newCandidates.candidate1 = _candidate1;
        newCandidates.candidate2 = _candidate2;
        newCandidates.maxDate = timeToVote + block.timestamp;
        newCandidates.currentVoting = currentVoting;
        voting.push(newCandidates);
    }

    function addVote(uint8 _choice) public {
        //Verificando a escolha dos votos, precisa ser 1 ou 2;
        if (_choice != 1 && _choice != 2 ) {
            revert InvalidChoice(_choice);
        }

         //Verificando se a votação está aberta;
        if(getCurrentVotes().maxDate <= block.timestamp) {
            revert NoOpenVotes();
        }

        //Verificando se esse address já votou nessa votação;
        if(votingDatas[currentVoting][msg.sender].Date > 0){
            revert YouAlreadyVoting();
        }

        //Salvando dados da votação no array votingDatas
        votingDatas[currentVoting][msg.sender].Address = msg.sender;
        votingDatas[currentVoting][msg.sender].Choice = _choice;
        votingDatas[currentVoting][msg.sender].Date = block.timestamp;
        votingDatas[currentVoting][msg.sender].currentVoting = currentVoting;

        //Incrementando numero de votos para os candidatos
        if(_choice == 1) {
            voting[currentVoting - 1].votes1++;

        } else { 
            voting[currentVoting - 1].votes2++;
        }

        //Emitindo evento com os dados da votação
        emit VotingDatas (msg.sender, _choice, block.timestamp);
    }

    function getAllVotes() public view returns  (Candidates[] memory){
        return voting;
    }

    function getCurrentVotes() public view returns (Candidates memory){
        return  voting[currentVoting - 1];
    }

    function getVotesByIndex(uint256 _index) public view returns (Candidates memory){
        return  voting[_index];
    }

}