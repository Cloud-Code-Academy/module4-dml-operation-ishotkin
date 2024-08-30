/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Ilana Shotkin
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        Account newAcct = new Account (Name = 'Apex Test Account: ' + String.valueOf(Math.floor(Math.random() * 100)), Type = 'Prospect'); // Create a new Account instance

        insert newAcct; // Insert the Account into the database

        return newAcct.Id; // Return the Id of the newly created Account
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        Account newAcct = new Account (Name = name, Industry = industry); // Create a new Account and set the fields inline

        insert newAcct; // Insert the Account
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        Contact newContact = new Contact (FirstName = 'New Test', LastName = 'Apex', AccountId = accountId); // Create a new Contact instance

        insert newContact; // Insert the Contact into the database

        return newContact.Id; // Return the Id of the newly created Contact
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        Contact foundContact = [SELECT Id FROM Contact WHERE Id = :contactId]; // Retrieve the Contact from the database

        foundContact.LastName = newLastName; // Update the Contact's last name

        update foundContact; // Update the Contact in the database
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        Opportunity newOpp = [SELECT Id FROM Opportunity WHERE Id = :oppId]; // Retrieve the Opportunity from the database

        newOpp.StageName = newStage; // Update the Opportunity's stage

        update newOpp; // Update the Opportunity in the database
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        Account updateAcct = new Account (Id = accountId); // Save the account

        updateAcct.Name = newName; // Update the Account with the given Id with the new name
        updateAcct.Industry = newIndustry; // Update the Account with the given Id with the new industry

        update updateAcct;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) { // Loop through each Opportunity in the list
            opp.StageName = 'Qualification'; // Set the Opportunity's Stage to Qualification
            opp.CloseDate = Date.today().addMonths(3); // Set the Opportunity's Close Date to 3 months from today
            opp.Amount = 50000; // Set the Opportunity's Amount to 50000
        }   

        upsert opportunities; // Upsert the opportunities List so that records are either updated or created
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        List<Opportunity> opportunityList = [SELECT Id,Name FROM Opportunity WHERE Name In :oppNames]; // Create a list to hold the existing Opportunities    
        List<Opportunity> oppsToProcess = new List<Opportunity> (); // Create a list for the Opps to upsert
        List<Account> accountsByName = [SELECT Id FROM Account WHERE Name = :accountName]; // Query to see if the Account exists
        Account oppAccount = new Account (); // Create the Account variable

        if (accountsByName.isEmpty() == false) {
            oppAccount = accountsByName.get(0); // If at least 1 Account was found, assign it to the Account variable
        } 
        else {
            oppAccount.Name = accountName; // Assign the Account Name
            insert oppAccount; // Make sure that the Account is in the database
        }

        for (String s : oppNames) { // Loop through each Opportunity name
            Opportunity newOpp = new Opportunity (Name = s, AccountId = oppAccount.Id, StageName = 'Prospecting', CloseDate = Date.today()); // Create an Opportunity instance with the given name
            
            for(Opportunity opp : opportunityList) { // Loop through existing Opportunities
                if (opp.Name == s) {
                    newOpp.Id = opp.Id; // If one is found with the correct name already, save the Id in the variable
                }
            }

            oppsToProcess.add(newOpp); // Add the value to the list of opportunities to process
        }

        upsert oppsToProcess; // Upsert the Opportunities
        
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		Account upsertAccount = new Account (); // Create placeholder account instance
		List<Account> accountList = [SELECT Id FROM Account WHERE Name = :accountName]; // Query for the Account

		if (accountList.isEmpty() == false){
            upsertAccount.Description='Updated Account'; // if the Account exists, update the description
            upsertAccount.Id = accountList.get(0).Id; // set the variable Account Id using the existing Id
        }
		else {
            upsertAccount.Description='New Account'; // otherwise, set the description
            upsertAccount.Name=accountName; // set the name for the new Account
        }
		
        upsert upsertAccount; // Upsert the Account

		return upsertAccount; // Return the upserted Account
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		Account contactAccount; // Create null instance of Account
        for( Contact c : contactsToUpsert) { // Loop through each Contact
            contactAccount = upsertAccount(c.LastName); // Extract the Account Name from Contact's LastName and call previous question to upsert Account
            c.accountId = contactAccount.Id; // Link the Contact to its Account using the Account Id
        }

		upsert contactsToUpsert; // Upsert the Contacts
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        List<Lead> leadsToProcess = new List<Lead> (); // Create list of leads

        for(String s : leadNames) { // Loop through each Lead name
            Lead currentLead = new Lead (LastName = s, Company = 'UpsertTest'); // Create the lead
            leadsToProcess.add(currentLead); // Add the lead to the list
        }

        insert leadsToProcess; // Insert the Leads

        delete leadsToProcess; // Delete the Leads
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> casesToProcess = new List<Case> (); // Create list of cases
        List<Account> accountList = [SELECT Id FROM Account WHERE Id = :accountId]; // Query for the account

        for(Integer i=0; i<numOfCases; i++) {
            Case newCase = new Case (AccountId = accountId);
            casesToProcess.add(newCase);
        }
        
        insert casesToProcess; // Insert the cases

        delete casesToProcess; // Delete the cases
    }
}