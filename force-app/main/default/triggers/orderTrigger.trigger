/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (after insert, after update) {
    try {
        if ( Trigger.New != null ){
            OrderHelper.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }catch ( Exception e ){
    
    }
}