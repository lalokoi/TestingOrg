public with sharing class weatherService implements Queueable, Database.AllowsCallouts {

    private List<Id> orderIds;

    public weatherService(List<Id> orderIds) {
        this.orderIds = orderIds;
    }

    public void execute(QueueableContext context) {
        List<Order__c> orders = [SELECT Id, Customer__c, Customer__r.Address__City__s, 
                                Customer__r.Address__CountryCode__s FROM Order__c WHERE Id IN: orderIds];
        
        List<Order__c> toUpdate = new List<Order__c>();

        WeatherbitConfig__mdt config = WeatherbitConfig__mdt.getInstance('Default');
        String apiKey = config != null ? config.API_Key__c : null;

        for (Order__c o : orders) {
            try {
                    String country = o.Customer__r.Address__CountryCode__s;
                    String city = o.Customer__r.Address__City__s;
                
                    if (String.isBlank(country) || String.isBlank(city)) {
                        o.Weather_Info__c = '<p><i>Missing country/city</i></p>';
                        toUpdate.add(o);
                        continue;
                    }

                    String url = 'callout:Weatherbit/v2.0/current'
                    + '?key=' + EncodingUtil.urlEncode(apiKey, 'UTF-8')
                    + '&country=' + EncodingUtil.urlEncode(country, 'UTF-8')
                    + '&city='    + EncodingUtil.urlEncode(city, 'UTF-8');

                    HttpRequest req = new HttpRequest();
                    req.setMethod('GET');
                    req.setEndpoint(url);
                    Http http = new Http();
                    HttpResponse res = http.send(req);

                    System.debug('Request URL => ' + req.getEndpoint()); 
                    System.debug('StatusCode   => ' + res.getStatusCode());
                    System.debug('Status       => ' + res.getStatus());
                    System.debug('Body         => ' + res.getBody());


                    if(res.getStatusCode() == 200){

                        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        List<Object> data = (List<Object>) root.get('data');

                        if (!data.isEmpty()) {
                        Map<String, Object> first = (Map<String, Object>) data[0];
                        Decimal temp = (Decimal) first.get('temp');
                        Map<String, Object> weather = (Map<String, Object>) first.get('weather');
                        String description = (String) weather.get('description');

                        o.Weather_Info__c =
                            '<p><b>Temp:</b> ' + temp + ' °C<br/>' +
                            '<b>Description:</b> ' + description + '</p>';
                        toUpdate.add(o);
                    }
                }
                    else{
                        o.Weather_Info__c = '<p><b>Error:</b> ' + res.getStatus() + '</p>';
                        toUpdate.add(o);
                    }

                }catch (Exception ex){
                    o.Weather_Info__c = '<p><b>Exception:</b> ' + ex.getMessage() + '</p>';
                    toUpdate.add(o);
                }

            }

            if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

}