public class OrderHelper {

    /**
     * @name AfterUpdate
     * @description
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(Map<Id, Order> newMap, Map<Id, Order> oldMap){
        Set<Id> orderIds = new Set<Id>();
        for (Id orderId : newMap.keyset()){
            if ( newMap.get(orderId).Status == Constants.ACTIVATED_ORDER_STATUS && oldMap.get(orderId).Status != Constants.ACTIVATED_ORDER_STATUS ){
                orderIds.add(orderId);
            }
        }
        RollUpOrderItems(orderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        //ToDo: Declare a Map named "productMap" of Ids to Product2 records
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        //ToDo: Loop through a query of OrderItems related to the activatedOrderIds
        for (OrderItem oi : [
                SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity, Order.ActivatedDate
                FROM OrderItem
                WHERE OrderId IN :activatedOrderIds
        ]) {
            //ToDo: Populate the map with the Id of the related Product2 as the key and Product2 record as the value
            productMap.put(oi.Product2Id, new Product2(Id = oi.Product2Id, Quantity_Ordered__c = oi.Product2.Quantity_Ordered__c));
        }
        //ToDo: Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset
        for (AggregateResult oiRes :  [
                SELECT Product2Id, SUM(Quantity) quant
                FROM  OrderItem
                WHERE OrderId IN :activatedOrderIds
                GROUP BY Product2Id
        ]) {
            Product2 product = productMap.get((Id)oiRes.get('Product2Id'));
            product.Quantity_Ordered__c += (Decimal)oiRes.get('quant');//do not  try Integer
            productMap.put(product.Id, product);
        }
        //ToDo: Perform an update on the records in the productMap
        update productMap.values();
    }

}