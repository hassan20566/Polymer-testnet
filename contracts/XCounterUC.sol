  function sendUniversalPacket(address destPortAddr, bytes32 channelId, uint64 timeoutSeconds) external {
       string memory query = "crossChainQueryMint";
       bytes memory payload = abi.encode(msg.sender, query);
       uint64 timeoutTimestamp = uint64((block.timestamp + timeoutSeconds) * 1000000000);


       IbcUniversalPacketSender(mw).sendUniversalPacket(
           channelId, IbcUtils.toBytes32(destPortAddr), payload, timeoutTimestamp
       );
   }


# Other Functions


   function onUniversalAcknowledgement(bytes32 channelId, UniversalPacket memory packet, AckPacket calldata ack)
       external
       override
       onlyIbcMw
   {
       ackPackets.push(UcAckWithChannel(channelId, packet, ack));


       // decode the counter from the ack packet
       (address caller, string memory _functionCall) = abi.decode(ack.data, (address, string));
       require(balanceOf(caller) == 0, "Caller already has an NFT");


       if (currentTokenId < 500) {
           require(keccak256(bytes(_functionCall)) == keccak256(bytes("mint")), "Invalid function call");
           mint(caller);
           emit MintAckReceived(caller, currentTokenId, "NFT minted successfully");
       } else {
           emit MintAckReceived(caller, 0, "NFT minting limit reached");
       }
   }
