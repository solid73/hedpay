const Hedpay = artifacts.require('Hedpay');
const ReserveFund = artifacts.require('ReserveFund');

module.exports = function(deployer) {
  deployer.deploy(Hedpay);
  deployer.deploy(ReserveFund, Hedpay.address);
};
