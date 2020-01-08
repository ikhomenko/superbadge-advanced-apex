@isTest (seeAllData=false)
private class OrderTests {

    @testSetup
    static void SetupTestData(){
        TestDataFactory.InsertTestData(Constants.DEFAULT_ROWS);
    }

    @isTest
    static void OrderUpdate_UnitTest() {
        Map<Id, Product2> productsBeforeOrdersActivation = new Map<Id, Product2>([SELECT Id, Quantity_Ordered__c FROM Product2]);
        List<Order> orders = [SELECT Id FROM Order];
        for (Order order : orders) {
            order.Status = Constants.ACTIVATED_ORDER_STATUS;
            order.ActivatedDate = Date.today();
        }
        update orders;
        Map<Id, Product2> productsAfterOrdersActivation = new Map<Id, Product2>([SELECT Id, Quantity_Ordered__c FROM Product2]);
        for (Id key : productsBeforeOrdersActivation.keySet()) {
            TestDataFactory.VerifyQuantityOrdered(productsBeforeOrdersActivation.get(key), productsAfterOrdersActivation.get(key), Constants.DEFAULT_ROWS);
        }
    }

    @isTest
    static void OrderExtension_UnitTest() {}

}