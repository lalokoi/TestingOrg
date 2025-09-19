# TestingOrg
Technical Test

# Salesforce Metadata Setup Instructions

## Summary

This project has metadata components for a custom app. The app manages customers, orders, and order items. It also gets weather information from an external API.

## Requirements

- Access to a Salesforce org (sandbox or production).
- Permissions to create objects, fields, flows, etc.
- The project files are available for reference.

## Setup Instructions

Follow the steps in order to set up each metadata component.

### 1. Custom Objects

Set up the custom objects first.

**Customer (Customer__c):**
1. Go to Setup > Object Manager > Create > Custom Object.
2. Label: Customer
3. API Name: Customer__c
4. Name Field: Text
5. Enable reports, search, etc. (see Customer__c.object-meta.xml for full details).

**Order (Order__c):**
1. Create custom object.
2. Label: Order
3. API Name: Order__c
4. Name Field: Auto Number (ORD-{0000})
5. Set permissions and features as in Order__c.object-meta.xml.

**Order Item (Order_Item__c):**
1. Create custom object.
2. Label: Order Item
3. API Name: Order_Item__c
4. Name Field: Auto Number (OI-{0000})
5. Use Order_Item__c.object-meta.xml as guide.

### 2. Custom Fields

Add fields to the objects.

**For Customer__c:**
- Address (Address__c): Address type

**For Order__c:**
- Customer (Customer__c): Lookup to Customer__c
- Items (Items__c): Lookup to Order_Item__c
- Start Date (Order_Start_Date__c): Date
- End Date (Order_End_Date__c): Date
- Status (Status__c): Picklist (New, In Progress, Completed)
- Total Amount (Total_Amount__c): Currency
- Weather Info (Weather_Info__c): Long Text (Rich Text)

**For Order_Item__c:**
- Order (Order__c): Lookup to Order__c
- Quantity (Quantity__c): Number
- Unit Price (Unit_Price__c): Currency
- Total (Total__c): Currency

Use the .field-meta.xml files as guide for detailed settings.

### 3. Custom Tabs

Create tabs for navigation.

1. Go to Setup > Create > Tabs.
2. For Customer: Object Customer__c, Style: People.
3. For Order: Object Order__c.
4. For Order and Items: Custom page or app.

### 4. Flows

Set up flows for automation.

**Calculate Total Price:**
1. Go to Setup > Flows > New Flow.
2. Type: Autolaunched Flow.
3. Trigger: On create/update Order_Item__c.
4. Formula: Quantity__c * Unit_Price__c for Total__c.
5. Use Calculate_total_price.flow-meta.xml as guide.

**Check Overdue Orders:**
1. Create scheduled or record-triggered flow.
2. Check order dates.
3. Use Check_Overdue_Orders.flow-meta.xml.

**Update Order Fields:**
1. Flow to update related fields.
2. Use Update_Order_Fields.flow-meta.xml.

### 5. Named Credentials

Set up credentials for external API.

1. Go to Setup > Security > Named Credentials > New.
2. Label: Weatherbit
3. URL: https://api.weatherbit.io
4. Authentication: Use External Credential WeatherbitExt.
5. See Weatherbit.namedCredential-meta.xml.

### 6. External Credentials

Set up external authentication.

1. Go to Setup > Security > External Credentials > New.
2. Label: WeatherbitExt
3. Protocol: Custom
4. Parameters: Key (Named Principal).
5. See WeatherbitExt.externalCredential-meta.xml.

### 7. Custom Metadata Types

Create and fill metadata.

1. Go to Setup > Custom Metadata Types > New Custom Metadata Type.
2. Label: Weatherbit Config
3. Fields: API_Key__c (Text)
4. Create record: Default, with API key.
5. See WeatherbitConfig.Default.md-meta.xml.

### 8. Apex Classes

Create classes for backend logic.

**searchOrderController:**
1. Go to Setup > Developer > Apex Classes > New.
2. Copy code from searchOrderController.cls.
3. Method: getOrders() to get orders with items.

**weatherService:**
1. Create Apex class.
2. Implements Queueable and Database.AllowsCallouts.
3. Calls Weatherbit API using named credentials.
4. Updates Weather_Info__c on orders.
5. Copy from weatherService.cls.
6. Postman collection to test : https://.postman.co/workspace/My-Workspace~80dda069-298e-44aa-8568-ab0a6c07b1da/collection/10083619-80ae8d01-3df0-4601-83fc-b2ace59edee2?action=share&creator=10083619

### 9. Apex Triggers

Create triggers for automation.

**OrderTrigger:**
1. Go to Setup > Developer > Apex Triggers > New.
2. Object: Order__c
3. Events: after insert, after update.
4. Queues weatherService if Weather_Info__c is missing.
5. Copy from OrderTrigger.trigger.

### 10. Lightning Web Components

Set up LWC component.

1. Go to Setup > Developer > Lightning Web Components > New.
2. Name: searchOrders
3. Copy HTML, JS, and meta from provided files.
4. Shows orders in tree grid with items.

### 11. Page Layouts

Set up layouts.

1. Go to Setup > Object Manager > [Object] > Page Layouts.
2. Add fields and sections as in .layout-meta.xml files.

### 12. List Views

Create custom views.

1. Go to Setup > Object Manager > [Object] > List Views > New.
2. Set filters and columns.
3. Use .listView-meta.xml files.

## Additional Notes

- Use the XML files as exact guide for settings.
- Test each component after setup.
- Give correct permissions to users.
- Update API key in metadata if needed.
