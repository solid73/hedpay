const Hedpay = artifacts.require('Hedpay');

module.exports = function(deployer) {
  deployer.deploy(Hedpay, 223);
};
