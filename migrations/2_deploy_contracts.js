const Hedpay = artifacts.require('Hedpay');
const ReserveFund = artifacts.require('ReserveFund');

module.exports = function(deployer) {
  deployer.deploy(Hedpay).then(function() {
    return deployer.deploy(ReserveFund, Hedpay.address);
  });
};
