@isTest (seeAllData=false)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @isTest
    static void Product2Extension_UnitTest(){
        Test.setCurrentPage(Page.Product2New);
        Test.startTest();
            Product2Extension ext = new Product2Extension(new ApexPages.StandardController(new Product2()));
            System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
            ext.addRows();
            System.assertEquals(2*Constants.DEFAULT_ROWS, ext.productsToInsert.size());
            for (Product2Extension.ProductWrapper pw : ext.productsToInsert) {
                pw.productRecord.Name = 'another product' + String.valueOf((Math.random() * 1000));
                pw.productRecord.Family = Constants.PRODUCT_FAMILY.get(Math.round(Math.random()*3)).getValue();
                pw.productRecord.IsActive =  true;
                pw.productRecord.Initial_Inventory__c = 100;
                pw.pricebookEntryRecord.UnitPrice = 100;
            }
            ext.save();
            System.assertEquals(2*Constants.DEFAULT_ROWS, [SELECT Id FROM Product2].size());
            ext.GetFamilyOptions();
            ext.GetInventory();
        Test.stopTest();
    }

    @isTest
    static void Product2Trigger_UnitTest() {}

}