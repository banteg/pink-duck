import brownie


def test_transfer(accounts, fat_duck):
    a, b = accounts[0:2]
    a_balance = fat_duck.balanceOf(a)
    b_balance = fat_duck.balanceOf(b)
    # cannot send to zero address or token contract
    with brownie.reverts():
        fat_duck.transfer(fat_duck, fat_duck.balanceOf(a), {"from": a})
    with brownie.reverts():
        fat_duck.transfer("0x" + "0" * 40, fat_duck.balanceOf(a), {"from": a})
    # normal transfers work
    fat_duck.transfer(b, fat_duck.balanceOf(a), {"from": a})
    assert fat_duck.balanceOf(a) == 0
    assert fat_duck.balanceOf(b) == a_balance + b_balance


def test_transferFrom(accounts, fat_duck):
    a, b, c = accounts[0:3]
    a_balance = fat_duck.balanceOf(a)
    b_balance = fat_duck.balanceOf(b)
    # cannot send without approval
    with brownie.reverts():
        fat_duck.transferFrom(a, c, a_balance, {"from": c})
    # send with approval
    fat_duck.approve(c, fat_duck.balanceOf(a) // 2, {"from": a})
    assert fat_duck.allowance(a, c) == fat_duck.balanceOf(a) // 2
    # cannot send more than approved
    with brownie.reverts():
        fat_duck.transferFrom(a, b, fat_duck.balanceOf(a), {"from": c})
    # transfer with approval
    assert fat_duck.balanceOf(a) == a_balance
    assert fat_duck.balanceOf(b) == b_balance
    normal = fat_duck.transferFrom(a, b, fat_duck.balanceOf(a) // 2, {"from": c})
    assert fat_duck.balanceOf(a) == a_balance // 2
    assert fat_duck.balanceOf(b) == b_balance + a_balance // 2
    # unlimited approval saves gas
    fat_duck.approve(c, 2 ** 256 - 1, {"from": a})
    unlimited = fat_duck.transferFrom(a, b, fat_duck.balanceOf(a), {"from": c})
    assert unlimited.gas_used < normal.gas_used
    assert fat_duck.balanceOf(a) == 0
    assert fat_duck.balanceOf(b) == a_balance + b_balance
