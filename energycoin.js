Energycontract('EnergyCoin', function(accounts) {
  it("should put 10000 EnergyCoin in the first account", function() {
    var energy = EnergyCoin.deployed();

    return energy.getBalance.call(accounts[0]).then(function(balance) {
      assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
    });
  });
  it("should call a function that depends on a linked library  ", function(){
    var energy = EnergyCoin.deployed();
    var energyCoinBalance;
    var energyCoinEthBalance;

    return energy.getBalance.call(accounts[0]).then(function(outCoinBalance){
      energyCoinBalance = outCoinBalance.toNumber();
      return energy.getBalanceInEth.call(accounts[0]);
    }).then(function(outCoinBalanceEth){
      energyCoinEthBalance = outCoinBalanceEth.toNumber();

    }).then(function(){
      assert.equal(energyCoinEthBalance,2*energyCoinBalance,"Library function returned unexpeced function, linkage may be broken");

    });
  });
  it("should send coin correctly", function() {
    var energy = MetaCoin.deployed();

    // Get initial balances of first and second account.
    var account_one = accounts[0];
    var account_two = accounts[1];

    var account_one_starting_balance;
    var account_two_starting_balance;
    var account_one_ending_balance;
    var account_two_ending_balance;

    var amount = 10;

    return energy.getBalance.call(account_one).then(function(balance) {
      account_one_starting_balance = balance.toNumber();
      return energy.getBalance.call(account_two);
    }).then(function(balance) {
      account_two_starting_balance = balance.toNumber();
      return energy.sendCoin(account_two, amount, {from: account_one});
    }).then(function() {
      return energy.getBalance.call(account_one);
    }).then(function(balance) {
      account_one_ending_balance = balance.toNumber();
      return energy.getBalance.call(account_two);
    }).then(function(balance) {
      account_two_ending_balance = balance.toNumber();

      assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
      assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
    });
  });
});
