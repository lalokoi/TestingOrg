import { LightningElement, wire, track } from 'lwc';
import getOrders from '@salesforce/apex/searchOrderController.getOrders';

const COLUMNS = [
    { label: 'Customer', fieldName: 'customerName', type: 'text' },
    { label: 'Total Amount', fieldName: 'totalAmount', type: 'currency' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Start Date', fieldName: 'startDate', type: 'date' },
    { label: 'End Date', fieldName: 'endDate', type: 'date' },
    { label: 'Weather Info', fieldName: 'weatherInfo', type: 'richText'},
    { label: 'Quantity', fieldName: 'quantity', type: 'number' },
    { label: 'Unit Price', fieldName: 'unitPrice', type: 'currency' },
    { label: 'Item Total', fieldName: 'itemTotal', type: 'currency' }
];

export default class SearchOrders extends LightningElement {
    @track gridData = [];
    columns = COLUMNS;
    gridExpandedRows = [];

    @wire(getOrders)
    wiredOrders({ error, data }) {
        if (data) {
            this.gridData = data.map(order => ({
                ...order,
                customerName: order.Customer__r ? order.Customer__r.Name : '',
                totalAmount: order.Total_Amount__c,
                status: order.Status__c,
                startDate: order.Order_Start_Date__c,
                endDate: order.Order_End_Date__c,
                weatherInfo: this.stripHtml(order.Weather_Info__c),
                _children: order.Order_Items__r ? order.Order_Items__r.map(item => ({
                    ...item,
                    quantity: item.Quantity__c,
                    unitPrice: item.Unit_Price__c,
                    itemTotal: item.Total__c
                })) : []
            }));
            this.gridExpandedRows = this.gridData.map(order => order.Id);
        } else if (error) {
            console.error('Error loading orders:', error);
        }
    }

    stripHtml(html) {
        if (!html) return '';
        const tmp = document.createElement('DIV');
        tmp.innerHTML = html;
        return tmp.textContent || tmp.innerText || '';
    }
}