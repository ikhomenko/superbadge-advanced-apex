public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> newList, List<Product2> oldList){
        //ToDo: Declare a List of Product2 records named needsAnnouncement
        List<Product2> needsAnnouncement = new List<Product2>();
        //ToDo: Declare a Map of Strings to Inventory_Setting__mdt records
        Map<String, Inventory_Setting__mdt> invSettings =  new Map<String, Inventory_Setting__mdt>();
        //ToDo: Loop through a query of Inventory_Setting__mdt records and populate the Map with Name as the key
        for (Inventory_Setting__mdt invSetting :  [
                SELECT DeveloperName, MasterLabel, Low_Quantity_Alert__c
                FROM Inventory_Setting__mdt
        ]) {
            invSettings.put(invSetting.DeveloperName, invSetting);
        }
        //ToDo: Loop through the Products in newList
        // Use the corresponding Inventory Setting record to determine the correct Low Quantity Alert
        // If the Product's Quantity Remaining has been changed to less than the Low Quantity Alert
        //      add it to the needsAnnouncement list
        List<Product2> lowInStockProducts = new List<Product2>();
        for (Product2 product : newList) {
            if (product.Quantity_Remaining__c < invSettings.get(product.Family).Low_Quantity_Alert__c) {
                lowInStockProducts.add(product);
            }
        }
        //ToDo: Pass records to the postAlerts method
        PostAlerts(lowInStockProducts);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 product : productList ){
            // ToDo: Construct a new AnnouncementInput for the Chatter Group so that it:
            // expires in a day
            // does not notify users via email.
            // and has a text body that includes the name of the product followed by the INVENTORY_LEVEL_LOW constant
            ConnectApi.AnnouncementInput alert = new ConnectApi.AnnouncementInput();
            alert.expirationDate = Date.today().addDays(1);
            alert.sendEmails = false;
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput message = new ConnectApi.TextSegmentInput();
            message.text =  product.Name + ' has ' +  Constants.INVENTORY_LEVEL_LOW;
            body.messageSegments = new List<ConnectApi.TextSegmentInput>{message};
            alert.body =  body;
            alert.parentId =  COLLABORATION_GROUP.get(0).Id;
            toPost.add(alert);
        }
        // ToDo: Create and enqueue an instance of the announcementQueuable class with the list of Products
        AnnouncementQueueable queue = new AnnouncementQueueable();
        queue.toPost = toPost;
        System.enqueueJob(queue);
    }
}