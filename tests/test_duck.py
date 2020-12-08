def test_migrate(col, duck, whale):
    before = col.balanceOf(whale) // 100
    col.approve(duck, 2 ** 256 - 1)
    duck.migrate()
    assert col.balanceOf(whale) == 0
    assert duck.balanceOf(whale) == before
    assert duck.totalSupply() == before


def test_burn(col, duck, whale):
    before = col.balanceOf(whale) // 100
    col.approve(duck, 2 ** 256 - 1)
    duck.migrate()
    assert duck.totalSupply() == before
    amount = duck.balanceOf(whale) // 10
    duck.burn(amount)
    assert duck.totalSupply() == before - amount
    assert duck.balanceOf(whale) == before - amount
