var KYCLibrary = artifacts.require("./KYCLibrary.sol");
var KYCCryptocom= artifacts.require("./KYCCryptocom.sol");
module.exports = async function(deployer) {
  await deployer.deploy(KYCLibrary,{
    fee_limit: 1.1e8,
    userFeePercentage: 31,
    originEnergyLimit: 1000000
  });

 await deployer.link(KYCLibrary, KYCCryptocom);

  await deployer.deploy(KYCCryptocom,{
    fee_limit: 1.1e8,
    userFeePercentage: 31,
    originEnergyLimit: 1000000
  });




