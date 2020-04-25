/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        return new CollaborationGroup(
                Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS,
                CollaborationType = 'public'
        );
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < cnt; i++) {
            products.add(new Product2(
                Name = 'prod ' + String.valueOf(i),
                IsActive =  true,
                Initial_Inventory__c = 10,
                Quantity_Ordered__c = 0,
                Family = Constants.PRODUCT_FAMILY.size() <= i ? 'Side' : Constants.PRODUCT_FAMILY.get(i).getValue()
            ));
        }
        return products;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 product : prods) {
            pricebookEntries.add(new PricebookEntry(
                Product2Id = product.Id,
                Pricebook2Id  = Test.isRunningTest() ? Test.getStandardPricebookId() : Constants.STANDARD_PRICEBOOK_ID,
                IsActive = true,
                UnitPrice = 100
            ));
        }
        return pricebookEntries;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public  static List<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> accounts =  new List<Account>();
        for (Integer i = 0; i < cnt; i++) {
            accounts.add(new Account(
                Name = 'Just account ' + String.valueOf(i)
            ));
        }
        return accounts;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < cnt; i++) {
            contacts.add(new Contact(
                LastName = 'another contact ' +  String.valueOf(i),
                AccountId = accts.size() <= i ? accts.get(0).Id : accts.get(i).Id
            ));
        }
        return contacts;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < cnt; i++) {
            orders.add(new Order(
                AccountId = accts.size() <= i ? accts.get(0).Id : accts.get(i).Id,
                Pricebook2Id = Test.isRunningTest() ? Test.getStandardPricebookId() : Constants.STANDARD_PRICEBOOK_ID,
                Status = 'Draft',
                EffectiveDate = Date.today()
            ));
        }
        return orders;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(Integer cnt, List<PricebookEntry> pbes, List<Order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Integer i = 0; i < cnt; i++) {
            orderItems.add(new OrderItem(
                PricebookEntryId =  pbes.size() <= i ? pbes.get(0).Id : pbes.get(i).Id,
                OrderId = ords.size() <= i ? ords.get(0).Id : ords.get(i).Id,
                Quantity = Constants.DEFAULT_ROWS,
                UnitPrice =  100
            ));
        }
        return orderItems;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        CollaborationGroup groups = TestDataFactory.ConstructCollaborationGroup();
        insert groups;

        List<Product2>  products= TestDataFactory.ConstructProducts(cnt);
        insert products;

        List<PriceBookEntry> pricebookEntries = TestDataFactory.ConstructPricebookEntries(products);
        insert pricebookEntries;

        List<Account> accounts = TestDataFactory.ConstructAccounts(cnt);
        insert accounts;

        List<Contact> contacts = TestDataFactory.ConstructContacts(cnt,accounts);
        insert contacts;

        List<Order> orders = TestDataFactory.ConstructOrders(cnt, accounts);
        insert orders;

        List<OrderItem> items = TestDataFactory.ConstructOrderItems(cnt, pricebookEntries, orders);
        insert items;

    }

    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
        System.assertEquals( updatedProduct.Quantity_Ordered__c, originalProduct.Quantity_Ordered__c + qtyOrdered, 'Quantity ordered caltucalation fail');
    }

}