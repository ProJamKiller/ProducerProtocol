async function main() {
  const WPJK = await ethers.getContractFactory("WPJK");
  const wpjk = await WPJK.deploy();
  await wpjk.deployed();
  console.log("WPJK deployed to:", wpjk.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });