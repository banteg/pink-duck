# @version 0.2.8
from vyper.interfaces import ERC20

implements: ERC20


event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256


event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256


name: public(String[64])
symbol: public(String[32])
decimals: public(uint256)
balanceOf: public(HashMap[address, uint256])
allowances: HashMap[address, HashMap[address, uint256]]
totalSupply: public(uint256)
COL: constant(address) = 0xC76FB75950536d98FA62ea968E1D6B45ffea2A55
DEAD: constant(address) = 0x000000000000000000000000000000000000dEaD
RATIO: constant(uint256) = 100  # 1 DUCK equals 100 COL


@external
def __init__():
    self.name = 'Unit Protocol'
    self.symbol = 'DUCK'
    self.decimals = 18


@external
def quack():
    """
    Migrate and burn COL for DUCK. Quack quack.
    """
    cols: uint256 = ERC20(COL).balanceOf(msg.sender)
    ducks: uint256 = cols / RATIO
    assert ERC20(COL).transferFrom(msg.sender, DEAD, cols)  # dev: not approved
    self.totalSupply += ducks
    self.balanceOf[msg.sender] += ducks
    log Transfer(ZERO_ADDRESS, msg.sender, ducks)


@view
@external
def allowance(owner: address, spender: address) -> uint256:
    return self.allowances[owner][spender]


@internal
def _transfer(sender: address, owner: address, receiver: address, amount: uint256) -> bool:
    assert receiver not in [self, ZERO_ADDRESS]
    self.balanceOf[owner] -= amount
    self.balanceOf[receiver] += amount
    if owner != sender and self.allowances[owner][sender] != MAX_UINT256:
        self.allowances[owner][sender] -= amount
        log Approval(owner, sender, self.allowances[owner][sender])
    log Transfer(owner, receiver, amount)
    return True


@external
def transfer(receiver: address, amount: uint256) -> bool:
    return self._transfer(msg.sender, msg.sender, receiver, amount)


@external
def transferFrom(owner: address, receiver: address, amount: uint256) -> bool:
    return self._transfer(msg.sender, owner, receiver, amount)


@external
def approve(spender: address, amount: uint256) -> bool:
    self.allowances[msg.sender][spender] = amount
    log Approval(msg.sender, spender, amount)
    return True


@external
def burn(amount: uint256):
    self.totalSupply -= amount
    self.balanceOf[msg.sender] -= amount
    log Transfer(msg.sender, ZERO_ADDRESS, amount)
