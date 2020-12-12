import brownie


def test_migrate(col, duck, whale):
    before = col.balanceOf(whale) // 100
    col.approve(duck, 2 ** 256 - 1)
    duck.quack()
    assert col.balanceOf(whale) == 0
    assert duck.balanceOf(whale) == before
    assert duck.totalSupply() == before


def test_migrate_fail(col, duck, whale):
    with brownie.reverts("dev: not approved"):
        duck.quack()


def test_burn(col, duck, whale):
    before = col.balanceOf(whale) // 100
    col.approve(duck, 2 ** 256 - 1)
    duck.quack()
    assert duck.totalSupply() == before
    amount = duck.balanceOf(whale) // 10
    duck.burn(amount)
    assert duck.totalSupply() == before - amount
    assert duck.balanceOf(whale) == before - amount
