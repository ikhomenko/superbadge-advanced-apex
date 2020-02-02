/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {
        get {
            orderItemList =  new List<OrderItem>();
            for (SObject so : standardSetController.getRecords()) {
                orderItemList.add(orderItemMap.get((Id)so.get('Id')));
            }
            return orderItemList;
        }
        set;
    }
    public String selectedFamily {get;set;}
    public List<ChartHelper.ChartData> pieData {get;set;}
    public Decimal total {get;set;}
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

    public Map<Id,OrderItem> orderItemMap {
        get {
            if (orderItemMap == null) {
                orderItemMap = new Map<Id, OrderItem>();
                for (PricebookEntry pbe : pricebookEntries) {
                    orderItemMap.put(pbe.Id, new OrderItem(
                            PricebookEntryId = pbe.Id,
                            Quantity = 0,
                            Product2 = pbe.Product2,
                            Product2Id = pbe.Product2Id,
                            UnitPrice = pbe.UnitPrice
                    ));
                }
            }
            return orderItemMap;
        }
        set;
    }
    ApexPages.StandardSetController standardSetController {
        get {
            if (standardSetController == null) {
                standardSetController = new ApexPages.StandardSetController(pricebookEntries);
                standardSetController.setPageSize(Constants.DEFAULT_ROWS);
            }
            return standardSetController;
        }
        set;
    }

    private List<PricebookEntry> pricebookEntries {
        get {
            if (pricebookEntries == null) {
                pricebookEntries = new List<PricebookEntry>([
                    SELECT Id, Product2Id, Name, Product2.Family, UnitPrice, Product2.Quantity_Remaining__c
                    FROM PricebookEntry
                    WHERE Pricebook2Id = :Constants.STANDARD_PRICEBOOK_ID
                ]);
                String query =
                        ' SELECT Id, Product2Id, Name, Product2.Name, Product2.Family, UnitPrice, Product2.Quantity_Remaining__c' +
                        ' FROM PricebookEntry ' +
                        ' WHERE Pricebook2Id = ' + '\'' + Constants.STANDARD_PRICEBOOK_ID + '\'';
                if (String.isNotEmpty(selectedFamily)) {
                    query += ' AND Product2.Family = ' + '\'' + selectedFamily + '\'';
                }
                pricebookEntries = (List<PricebookEntry>)Database.query(query);
            }
            return pricebookEntries;
        }
        set;
    }

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
    }

    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection


    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        total = 0;
        pieData = new List<ChartHelper.ChartData>();
        for(OrderItem oi : orderItemMap.values()) {
            pieData.add(new ChartHelper.ChartData(oi.Product2.Name, (oi.UnitPrice * oi.Quantity)));
            total += (oi.UnitPrice*oi.Quantity);
        }
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        pricebookEntries = null;
        standardSetController = null;
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        Savepoint sp = Database.setSavepoint();
        try {
            insert orderRecord;
            List<OrderItem> itemsToInsert = new List<OrderItem>();
            for (OrderItem oi : orderItemMap.values()) {
                if (oi.Quantity > 0) {
                    oi.OrderId = orderRecord.Id;
                    itemsToInsert.add(oi);
                }
            }
            insert itemsToInsert;
        } catch (Exception e) {
            System.debug(e.getMessage());
            Database.rollback(sp);
        }

    }


    /**
     * @name First
     * @description
    **/
    public void First(){
        standardSetController.first();
        //populateOrderItems();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
        standardSetController.next();
        //populateOrderItems();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        standardSetController.previous();
        //populateOrderItems();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
        standardSetController.last();
        //populateOrderItems();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return (Integer)math.ceil(standardSetController.getResultSize()/(Decimal)Constants.DEFAULT_ROWS);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        return this.familyOptions;
    }

    /*public void populateOrderItems() {
        System.debug('you need this to cover one of TODOs');
        orderItemList = new List<OrderItem>();
        for(SObject record : standardSetController.getRecords()){
            System.debug('for=====');
            PricebookEntry pbeRecord = (PricebookEntry)record;
            if(orderItemMap.containsKey(pbeRecord.Product2Id)) {
                System.debug('if=====');
                orderItemList.add(orderItemMap.get(pbeRecord.Product2Id));
            } else{
                System.debug('else======');
                OrderItem orderItem = new OrderItem(
                        PricebookEntryId = pbeRecord.Id,
                        Product2Id = pbeRecord.Product2Id,
                        UnitPrice = pbeRecord.UnitPrice,
                        Quantity = 0,
                        Product2 = pbeRecord.Product2
                );
                orderItemList.add(orderItem);
                orderItemMap.put(pbeRecord.Product2Id,orderItem);
            }
        }
    }*/

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}