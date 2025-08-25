// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract P2PDuel {

    mapping(uint256 => Duel) public duels;

    struct Duel {
        address challenging;
        address challenged;
        uint96 betValue;
        uint40 deadline;
        DuelStatus status;
        string description;
    }

    enum DuelStatus {
        Pending,
        Active,
        Fineshed,
        Canceled
    }

    uint256 private _nextDuelId;
    uint256 public constant ACCEPTANCE_PERIOD = 3 days;
    uint256 public constant DEFAULT_DUEL_DURATION = 7 days;

    event DuelCreated(uint256 indexed id, address indexed challenging, address indexed challenged, uint256 value, string description);
    event DuelAccepted(uint256 indexed id);
    event DuelFineshed(uint256 indexed id, address winner, address loser);
    event DuelCanceled(uint256 indexed id);

    error InvalidBetValue();
    error InvalidChallenged();
    error DuelNotFound();
    error OnlyParticipantsCanAct();
    error ActionNotAllowedOnThisState();
    error AcceptancePeriodExpired();
    error IncorrectBetValueToAccept();
    error ExpiredDuelPeriod();
    error FailToSendEther();
    error AcceptancePeriodNotExpired();

    modifier onlyParticipants(uint256 _id) {
        Duel storage duel = duels[_id];
        if (msg.sender != duel.challenging && msg.sender != duel.challenged) {
            revert OnlyParticipantsCanAct();
        }
        _;
    }

    function create(address _challenged, string calldata _description) external payable {
        if (msg.value == 0) revert InvalidBetValue();
        if (_challenged == address(0) || _challenged == msg.sender) revert InvalidChallenged();

        uint256 id = _nextDuelId;

        duels[id] = Duel({
            challenging: msg.sender,
            challenged: _challenged,
            betValue: uint96(msg.value),
            deadline: uint40(block.timestamp + ACCEPTANCE_PERIOD),
            status: DuelStatus.Pending,
            description: _description
        });

        _nextDuelId++;
        emit DuelCreated(id, msg.sender, _challenged, msg.value, _description);
    }

    function accept(uint256 _id) external payable onlyParticipants(_id) {
        Duel storage duel = duels[_id];

        if (duel.challenging == address(0)) revert DuelNotFound();
        if (duel.status != DuelStatus.Pending) revert ActionNotAllowedOnThisState();
        if (block.timestamp > duel.deadline) revert AcceptancePeriodExpired();
        if (msg.value != duel.betValue) revert IncorrectBetValueToAccept();

        duel.status = DuelStatus.Active;
        duel.deadline = uint40(block.timestamp + DEFAULT_DUEL_DURATION);

        emit DuelAccepted(_id);
    }

    function acceptDefeat(uint256 _id) external onlyParticipants(_id) {
        Duel storage duel = duels[_id];

        if (duel.status != DuelStatus.Active) revert ActionNotAllowedOnThisState();
        if (block.timestamp > duel.deadline) revert ExpiredDuelPeriod();

        duel.status = DuelStatus.Fineshed;

        address winner = (msg.sender == duel.challenging) ? duel.challenged : duel.challenging;
        uint256 jackpot = uint256(duel.betValue) * 2;

        emit DuelFineshed(_id, winner, msg.sender);

        (bool success, ) = winner.call{value: jackpot}("");
        if (!success) revert FailToSendEther();
    }

    function cancel(uint256 _id) external onlyParticipants(_id) {
        Duel storage duel = duels[_id];

        if (duel.challenging == address(0)) revert DuelNotFound();
        if (duel.status == DuelStatus.Active || duel.status == DuelStatus.Fineshed || duel.status == DuelStatus.Canceled) revert ActionNotAllowedOnThisState();
        if (block.timestamp <= duel.deadline) revert AcceptancePeriodNotExpired();

        duel.status = DuelStatus.Canceled;

        emit DuelCanceled(_id);

        (bool success, ) = duel.challenging.call{value: duel.betValue}("");
        if (!success) revert FailToSendEther();
    }

}
