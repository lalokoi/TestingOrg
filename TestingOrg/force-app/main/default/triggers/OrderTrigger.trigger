trigger OrderTrigger on Order__c (after insert, after update) {

    Set<Id> orderIds = new Set<Id>();
    for (Order__c o : Trigger.new) {
        if (o.Customer__c != null && String.isBlank(o.Weather_Info__c)) {
            orderIds.add(o.Id);
        }
    }
    if(!orderIds.isEmpty()){
        System.enqueueJob(new weatherService(new List<Id>(orderIds)));
    }else{
        System.debug('No orders to update');
    }

}