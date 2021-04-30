# recolic's fork

Removed devfee. 

## Usage

1. read <https://azurecloudminingscript.github.io/Turn_your_Azure_Free_Credits_into_Cryptocurrency.html>. If this page is unavailable, refer to the archive: <https://git.recolic.net/many-archive/azurecloudminingscript.github.io>

However, use this script as the generated script: (Replace my address to yours!)

```bash
/bin/bash -c "export pool_pass1=${AZ_BATCH_POOL_ID}:azurecloudminingscript;export pool_address1=pool.supportxmr.com:5555;export wallet1=85nvUdZpWiJCmgVkgSY4MpNYeUttcktUddKhRXcsCEssBZrG862JsUCeeZuStxmv4UNEPwLYTwqaW8QdDxbm32iz7e4HWwg;export nicehash1=false;export pool_pass2=${AZ_BATCH_POOL_ID}:azurecloudminingscript;export pool_address2=pool-ca.supportxmr.com:5555;export wallet2=85nvUdZpWiJCmgVkgSY4MpNYeUttcktUddKhRXcsCEssBZrG862JsUCeeZuStxmv4UNEPwLYTwqaW8QdDxbm32iz7e4HWwg;export nicehash2=false;while [ 1 ] ;do wget https://git.recolic.net/root/azure-cloud-mining-script/-/raw/master/azure_script/setup_vm3.sh ; chmod u+x setup_vm3.sh ; ./setup_vm3.sh ; cd azure-cloud-mining-script; cd azure_script; ./run_xmr_stak.pl 30; cd ..; cd ..; rm -rf azure-cloud-mining-script ; rm -rf setup_vm3.sh; done;"
```

2. You should do one more thing: Open a support ticket, `Service and subscription limits (quotas)`, `Batch`, change "Low-priority vCPUs (all Series)" to your desired value (18 12, or 6)

3. Enjoy. 

## Note

`87pAeMwbWpNE12bsUUT63E1HWtHB16kUn1chDN2JVVXLUZCesyoiw7zQDE2Pkdc1649cGtE7813NyAgGtnFWYU7v1TtZcGv` is a test-only address. If this address has any hashrate on supportxmr.com, 
it means that there's still devfee. Please open an issue!

----

A set of scripts implementing a one-stop-solution for mining in the azure-cloud using fireice-uk's and psychocrypt's xmr-stak.

Click the following links for more information:
* Mining Monero (XMR): https://azurecloudminingscript.github.io/Turn_your_Azure_Free_Credits_into_Cryptocurrency.html
* Mining other Cryptonight-coins: https://azurecloudminingscript.github.io/Turn_your_Azure_Free_Credits_into_Cryptocurrency_detailed.html
* Mining Nimiq (NIM): https://azurecloudminingscript.github.io/Turn_your_Azure_Free_Credits_into_NIMIQ.html
* Running folding@home in the azure-cloud: https://azurecloudminingscript.github.io/Run_Folding_At_Home_in_the_Azure_Cloud.html


