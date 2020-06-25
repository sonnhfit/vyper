interface Exchange:
    def token() -> address: constant
    def receive(_from: address, _amt: uint256): modifying
    def transfer(_to: address, _amt: uint256): modifying


exchange_codehash: public(bytes32)
# Maps token addresses to exchange addresses
exchanges: public(HashMap[address, address])


@public
def __init__(_exchange_codehash: bytes32):
    # Register the exchange code hash during deployment of the factory
    self.exchange_codehash = _exchange_codehash


# NOTE: Could implement fancier upgrade logic around self.exchange_codehash
#       For example, allowing the deployer of this contract to change this
#       value allows them to use a new contract if the old one has an issue.
#       This would trigger a cascade effect across all exchanges that would
#       need to be handled appropiately.


@public
def register():
    # Verify code hash is the exchange's code hash
    assert msg.sender.codehash == self.exchange_codehash
    # Save a lookup for the exchange
    # NOTE: Use exchange's token address because it should be globally unique
    # NOTE: Should do checks that it hasn't already been set,
    #       which has to be rectified with any upgrade strategy.
    self.exchanges[Exchange(msg.sender).token()] = msg.sender


@public
def trade(_token1: address, _token2: address, _amt: uint256):
    # Perform a straight exchange of token1 to token 2 (1:1 price)
    # NOTE: Any practical implementation would need to solve the price oracle problem
    Exchange(self.exchanges[_token1]).receive(msg.sender, _amt)
    Exchange(self.exchanges[_token2]).transfer(msg.sender, _amt)
