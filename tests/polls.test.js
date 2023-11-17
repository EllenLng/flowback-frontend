const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Polls Contract", function () {
    let pollsContract;

    it("should not allow voting after the end date", async function () {
        const Polls = await ethers.getContractFactory("Polls");

        const pollTitle = "Sample Poll";
        const pollTag = "Sample Tag";
        const pollGroup = 1;
        const pollStartDate = Math.floor(Date.now() / 1000);
        const proposalEndDate = pollStartDate + 3600;
        const votingStartDate = proposalEndDate + 3600;
        const delegateEndDate = votingStartDate + 3600;
        const endDate = delegateEndDate + 3600;

        pollsContract = await Polls.deploy();
        await pollsContract.deployed();

        await pollsContract.createPoll(
            pollTitle,
            pollTag,
            pollGroup,
            pollStartDate,
            proposalEndDate,
            votingStartDate,
            delegateEndDate,
            endDate
        );

        await ethers.provider.send("evm_setNextBlockTimestamp", [endDate + 1]);

        const pollId = 1;
        const proposalId = 1;
        const hashedVote = "0x1234567890abcdef";

        await expect(pollsContract.vote(pollId, proposalId, hashedVote)).to.be.revertedWith("Voting is not allowed at this time");
    });
});