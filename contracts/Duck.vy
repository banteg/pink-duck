# @version 0.2.7
from vyper.interfaces import ERC20

implements: ERC20


event Transfer:
    sender: indexed(address)
    dst: indexed(address)
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
col: public(ERC20)
DEAD: constant(address) = 0x000000000000000000000000000000000000dEaD
RATIO: constant(uint256) = 100  # 1 DUCK equals 100 COL


@external
def __init__():
    self.name = 'Unit Protocol'
    self.symbol = 'DUCK'
    self.decimals = 18
    self.col = ERC20(0xC76FB75950536d98FA62ea968E1D6B45ffea2A55)


@external
def migrate():
    """
    Migrate COL to DUCK. Quack quack.
    """
    col_amount: uint256 = self.col.balanceOf(msg.sender)
    duck_amount: uint256 = col_amount / RATIO
    assert duck_amount > 0  # dev: nothing to migrate
    self.col.transferFrom(msg.sender, DEAD, col_amount)
    self.totalSupply += duck_amount
    self.balanceOf[msg.sender] += duck_amount
    log Transfer(ZERO_ADDRESS, msg.sender, duck_amount)


@view
@external
def allowance(owner: address, spender: address) -> uint256:
    return self.allowances[owner][spender]


@external
def transfer(dst: address, amount: uint256) -> bool:
    assert not dst in [self, ZERO_ADDRESS]
    self.balanceOf[msg.sender] -= amount
    self.balanceOf[dst] += amount
    log Transfer(msg.sender, dst, amount)
    return True


@external
def transferFrom(src: address, dst: address, amount: uint256) -> bool:
    assert not dst in [self, ZERO_ADDRESS]
    self.balanceOf[src] -= amount
    self.balanceOf[dst] += amount
    if src != msg.sender and self.allowances[src][msg.sender] != MAX_UINT256:
        self.allowances[src][msg.sender] -= amount
        log Approval(src, msg.sender, self.allowances[src][msg.sender])
    log Transfer(src, dst, amount)
    return True


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
