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
            //insert productsToInsert;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            //apexPages.addMessage(new ApexPages.message('Something went wrong'));
            Database.rollback(sp);
        }
        return null;
    }

    public class ProductWrapper {
        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}
    }
}