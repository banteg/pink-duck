import click
from brownie import Duck, accounts


def main():
    user = accounts.load(click.prompt("account", type=click.Choice(accounts.load())))
    Duck.deploy({"from": user})
