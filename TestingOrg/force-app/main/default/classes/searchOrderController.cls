public with sharing class searchOrderController {
    @auraEnabled(cacheable=true)
    public static list <Order__c> getOrders() {
        return[SELECT Id, Customer__r.Name,Total_Amount__c, Status__c, Order_Start_Date__c ,
                Order_End_Date__c, Weather_Info__c, (SELECT Id, Quantity__c, Unit_Price__c, 
                Total__c From Order_Items__r) FROM Order__c ORDER BY Name];
    }
}