const Sale = artifacts.require('Sale')
const Token = artifacts.require('Token')

var expectThrow = async function(promise) {
  try {
    await promise;
  } catch (error) {
    const invalidOpcode = error.message.search('invalid opcode') >= 0;
    const invalidJump = error.message.search('invalid JUMP') >= 0;
    const outOfGas = error.message.search('out of gas') >= 0;
    const revert = error.message.search('revert') >= 0;
    assert(
      invalidOpcode || invalidJump || outOfGas || revert,
      "Expected throw, got '" + error + "' instead",
    );
    return;
  }
  assert.fail('Expected throw not received');
};
const rate = 1;
contract('Sale', accounts => {
    var instance;
    beforeEach(async () => {
      toko = await Token.deployed();
      instance = await Sale.deployed();

	});
    it('Send toko & initiate sale', async () => {
    	await toko.transfer.sendTransaction(instance.address, 100000e18);
    	await instance.changeAddr.sendTransaction(toko.address);
      await instance.changeRate.sendTransaction(rate);
    	await instance.setActive.sendTransaction();
    });
    it('Buy Tokens', async () => {    	
    	assert(await toko.balanceOf.call(accounts[1]) == 0 );
      await web3.eth.sendTransaction({ from: accounts[1], to: instance.address, value:  web3.toWei(10, "ether") });
    });
    it('Drain Wei', async () => {
      const bal = await web3.eth.getBalance(accounts[0]);
      await expectThrow(instance.drainWei.sendTransaction({from: accounts[1]}));
      await instance.drainWei.sendTransaction();
      const bal_After = await web3.eth.getBalance(accounts[0]);
    });
    it('Change Rules Fail not Owner', async () => {
      await expectThrow(instance.changeRate.sendTransaction(10, {from: accounts[1]}));
      await expectThrow(instance.changemincap.sendTransaction(10, {from: accounts[1]}));
      await expectThrow(instance.changeAddr.sendTransaction(accounts[1], {from: accounts[1]}));
    });
    it('Drain All Tokens', async () => {
      await instance.drainToken.sendTransaction();
    });
    it('Give Tokens', async () => {
      await instance.giveTokens.sendTransaction(1000);
      await instance.giveTokens.sendTransaction(100);
      await instance.giveTokens.sendTransaction(100);
      assert(await toko.balanceOf.call(accounts[1]) == 10e18 * rate);
    });

});