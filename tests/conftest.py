import pytest


@pytest.fixture(scope="function", autouse=True)
def shared_setup(fn_isolation):
    pass


@pytest.fixture
def whale(accounts):
    return accounts.at("0x02FECAD9225a881d2Cb868E7860C2D5B9b56B0bf", force=True)


@pytest.fixture
def col(interface, whale):
    return interface.ERC20("0xC76FB75950536d98FA62ea968E1D6B45ffea2A55", owner=whale)


@pytest.fixture
def duck(Duck, whale):
    return Duck.deploy({"from": whale})
