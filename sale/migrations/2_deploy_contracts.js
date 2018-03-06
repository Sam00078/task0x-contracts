var Contract = artifacts.require("./Sale.sol");
var Token = artifacts.require("./Token.sol");

module.exports = function(deployer) {
  deployer.deploy(Contract);
  deployer.deploy(Token);
};