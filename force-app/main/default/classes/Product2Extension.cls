public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}
    //private final Product2 product;

    public List<SelectOption>  familyOptions {
        get {
            if (familyOptions == null) {
                familyOptions = new List<SelectOption>{new SelectOption('', Constants.SELECT_ONE)};
                for( Schema.PicklistEntry pickListVal : Constants.PRODUCT_FAMILY){
                    familyOptions.add(new SelectOption(pickListVal.value,pickListVal.label));
                }
            }
            return familyOptions;
        }
        set;
    }

    public Product2Extension(ApexPages.StandardController stdController){
        //this.product = (Product2)stdController.getRecord();
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    //need this method to pass  third step's test
    public List<SelectOption> getFamilyOptions(){
        return this.familyOptions;
    }

    public void AddRows(){
        for ( Integer i=0; i< Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){
        Savepoint sp = Database.setSavepoint();
        try {

            Integer howManyInserted = insertProducts(productsToInsert);

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,howManyInserted+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            System.debug(e.getMessage());
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() +' ' + Constants.ERROR_MESSAGE));
            Database.rollback(sp);
        }
        return null;
    }

    private static Integer insertProducts(List<ProductWrapper> products) {
        List<SObject> productsAndPricebookEntries = new List<SObject>();
        List<Product2> product2s = new List<Product2>();
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        for (ProductWrapper pw : products) {
            if (pw.hasAnyEmptyValues()) {
                continue;
            }
            Integer randomNumber = Integer.valueof((Math.random() * 10000));
            Product2 productReference = new Product2(extId__c='externalKey'+String.valueOf(randomNumber));
            PricebookEntry pbe = new PricebookEntry(
                    Product2 = productReference,
                    Pricebook2Id =  Test.isRunningTest() ? Test.getStandardPricebookId() : Constants.STANDARD_PRICEBOOK_ID,
                    UnitPrice = pw.pricebookEntryRecord.UnitPrice
            );
            pbes.add(pbe);
            Product2 product = new Product2(
                    extId__c='externalKey'+String.valueOf(randomNumber),
                    Name = pw.productRecord.Name,
                    Family = pw.productRecord.Family,
                    IsActive = pw.productRecord.isActive,
                    Initial_Inventory__c = pw.productRecord.Initial_Inventory__c
            );
            product2s.add(product);
        }
        productsAndPricebookEntries.addAll(product2s);
        productsAndPricebookEntries.addAll(pbes);
        if (!productsAndPricebookEntries.isEmpty()) {
            Database.insert(productsAndPricebookEntries);
        }
        return productsAndPricebookEntries.size()/2;
    }

    public class ProductWrapper {
        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}

        public ProductWrapper() {
            productRecord = new Product2();
            pricebookEntryRecord =  new PricebookEntry();
        }

        public Boolean hasAnyEmptyValues() {
            Boolean  result = false;
            if (String.isBlank(productRecord.Name) || String.isBlank(productRecord.Family) ||
                !productRecord.isActive || productRecord.Initial_Inventory__c == null || productRecord.Initial_Inventory__c == 0) {
                result = true;
            }
            if (pricebookEntryRecord.UnitPrice == null || pricebookEntryRecord.UnitPrice == 0) {
                result =  true;
            }
            return result;
        }
    }
}