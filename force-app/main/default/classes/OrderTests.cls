@isTest (seeAllData=false)
private class OrderTests {

    @testSetup
    static void SetupTestData(){
        TestDataFactory factory = new TestDataFactory();
        factory.InsertTestData(0);
    }

    @isTest
    static void OrderUpdate_UnitTest() {}

}