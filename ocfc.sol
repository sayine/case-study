// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract OCFC is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => bool) public alreadyMinted;
    mapping(address => uint) public addressToTokenId;
    mapping(address => uint) public trainCounter;

    struct Member {
        uint id;
        uint punchPower;
        uint kickPower;
        uint headOffPower;
        uint score;
        uint bday;
    }
    Member[] public member;

    struct Fight {
        uint id;
        bool isActive;
        uint[3] fighter1Moves;
        uint[3] fighter2Moves;
        address fighter1;        
        address fighter2;
    }
    Fight[] public fight;

    constructor() ERC721("OnChain Fight Club", "Member") {}

    function mintMember() external returns (uint){
        require(alreadyMinted[msg.sender] == false, "Already Minted");
        alreadyMinted[msg.sender] = true;
        uint256 newId = _tokenIds.current();
        member.push(Member(newId, 100, 100, 100, 0, block.timestamp));
        _safeMint(msg.sender, newId);
        addressToTokenId[msg.sender] = newId;
        _tokenIds.increment();
        return newId;
    }

    function createFight(address _fighter1, uint move1, uint move2, uint move3) external {
        require(ownerOf(addressToTokenId[_fighter1]) == msg.sender, "NO");
        fight.push(Fight(fight.length, true, [move1, move2, move3], [move1, move2, move3], _fighter1, 0x0000000000000000000000000000000000000000));
    }

    function joinAndFight(uint fightId, uint move1, uint move2, uint move3) external {
        require(balanceOf(msg.sender)  > 0, "NO");
        require(fight[fightId].isActive == true);
        fight[fightId].fighter2 = msg.sender;
        fight[fightId].fighter2Moves = [move1, move2, move3];
        fight[fightId].isActive = false;

        uint f1PP = member[addressToTokenId[fight[fightId].fighter1]].punchPower;
        uint f1KP = member[addressToTokenId[fight[fightId].fighter1]].kickPower;
        uint f1HP = member[addressToTokenId[fight[fightId].fighter1]].headOffPower;

        uint f2PP = member[addressToTokenId[fight[fightId].fighter2]].punchPower;
        uint f2KP = member[addressToTokenId[fight[fightId].fighter2]].kickPower;
        uint f2HP = member[addressToTokenId[fight[fightId].fighter2]].headOffPower;

        for (uint i=0; i < 3; i++){
        if(fight[fightId].fighter1Moves[i] == fight[fightId].fighter2Moves[i] && fight[fightId].fighter2Moves[i] == 1) {
            if(f1PP >= f2PP) {member[addressToTokenId[fight[fightId].fighter1]].score += (f1PP - f2PP);} 
                else {member[addressToTokenId[fight[fightId].fighter2]].score += (f2PP - f1PP);}
        } 
        else if(fight[fightId].fighter1Moves[i] == fight[fightId].fighter2Moves[i] && fight[fightId].fighter2Moves[i] == 2) {
            if(f1KP >= f2KP) {member[addressToTokenId[fight[fightId].fighter1]].score += (f1KP - f2KP);} 
                else {member[addressToTokenId[fight[fightId].fighter2]].score += (f2KP - f1KP);}
        }
        else if(fight[fightId].fighter1Moves[i] == fight[fightId].fighter2Moves[i] && fight[fightId].fighter2Moves[i] == 3) {
            if(f1HP >= f2HP) {member[addressToTokenId[fight[fightId].fighter1]].score += (f1HP - f2HP);} 
                else {member[addressToTokenId[fight[fightId].fighter2]].score += (f2HP - f1HP);}
        }
        else if(fight[fightId].fighter1Moves[i] == 1 && fight[fightId].fighter2Moves[i] == 2) {
            if(f1PP >= f2KP) {member[addressToTokenId[fight[fightId].fighter1]].score += (f1PP - f2KP + 15);} 
                else {member[addressToTokenId[fight[fightId].fighter2]].score += (f2KP - f1PP + 5);}
        }
        else if(fight[fightId].fighter1Moves[i] == 1 && fight[fightId].fighter2Moves[i] == 3) {
            if(f1PP >= f2HP) {member[addressToTokenId[fight[fightId].fighter1]].score += (f1PP - f2HP + 10);} 
                else {member[addressToTokenId[fight[fightId].fighter2]].score += (f2HP - f1PP + 25);}
        }
        else if(fight[fightId].fighter1Moves[i] == 2 && fight[fightId].fighter2Moves[i] == 3) {
            if(f1KP >= f2HP) {member[addressToTokenId[fight[fightId].fighter1]].score += (f1KP - f2HP + 20);} 
                else {member[addressToTokenId[fight[fightId].fighter2]].score += (f2HP - f1KP + 5);}
        }
        else if(fight[fightId].fighter1Moves[i] == 2 && fight[fightId].fighter2Moves[i] == 1) {
            if(f1KP >= f2PP) {member[addressToTokenId[fight[fightId].fighter1]].score += (f1KP - f2PP + 15);} 
                else {member[addressToTokenId[fight[fightId].fighter2]].score += (f2PP - f1KP + 5);}
        }
        else if(fight[fightId].fighter1Moves[i] == 3 && fight[fightId].fighter2Moves[i] == 1) {
            if(f1HP >= f2PP) {member[addressToTokenId[fight[fightId].fighter1]].score += (f1HP - f2PP + 25);} 
                else {member[addressToTokenId[fight[fightId].fighter2]].score += (f2PP - f1HP + 10);}
        }
        else if(fight[fightId].fighter1Moves[i] == 3 && fight[fightId].fighter2Moves[i] == 2) {
            if(f1HP >= f2KP) {member[addressToTokenId[fight[fightId].fighter1]].score += (f1HP - f2KP + 5);} 
                else {member[addressToTokenId[fight[fightId].fighter2]].score += (f2KP - f1HP + 20);}
        }}
    }

    function trainFighter(address _fighterOwner) payable external {
        require(msg.value >= 1 ether, "Payment required");
        require(ownerOf(addressToTokenId[_fighterOwner]) == msg.sender, "NO");
        trainCounter[msg.sender] += 1;
        member[addressToTokenId[_fighterOwner]].punchPower += 1 * trainCounter[msg.sender];
        member[addressToTokenId[_fighterOwner]].kickPower += 1 * trainCounter[msg.sender];
        member[addressToTokenId[_fighterOwner]].headOffPower += 1 * trainCounter[msg.sender];
    }

    function withdraw() onlyOwner public returns (bool) {
        payable(msg.sender).transfer(address(this).balance);
        return true;
    }

}