"use strict";

const { openBrowser, goto, write, into, textBox, click, checkBox, dropDown, closeBrowser, waitFor, scrollDown } = require('taiko');
/**
 * Publishes a message to a Cloud Pub/Sub Topic. *
 * @param {object} req Cloud Function request context.
 * @param {object} req.body The request body.
 * @param {object} res Cloud Function response context.
 */

exports.investecPay = async (req, res) => {  

  console.log(`Making payment`);

   const data = req.body;

   try {
        await openBrowser();
        await goto("https://login.secure.investec.com/usrroot/login/form");
        await write(data.username);
        await write(data.password,into(textBox("Password")));
        await click("Log In");
        await waitFor("Make a payment", 60000);
        await goto("https://login.secure.investec.com/io/payments-sa/payment-method/make-payment/onceoff", {waitForNavigation: false});	

        await waitFor("Alert: Cellphone snatching", 60000);
		await scrollDown(1000);
        await click("Continue with payment");
       
        await checkBox({id:"onceOffFraudMsg"}, {selectHiddenElements : true}).check();
        await write(data.benificiaryName, into(textBox("Name")));
        await dropDown("Bank").select(data.bank);
        await dropDown("Account type").select(data.accountType);
        await write(data.accountNumber,into(textBox("Account number")));
        await write(data.description,into(textBox("My description")));
        await write(data.reference,into(textBox("Their reference")));
        await write(data.amount,into(textBox("Amount")));

        await scrollDown(1000);
        await click("Continue");
        await click("Submit");

		res.status(200).send("Payment made");

    } catch (error) {
        console.error(error);
		res.status(500).send(error);
        return Promise.reject(error);
    } finally {
        await closeBrowser();
    }  
};
