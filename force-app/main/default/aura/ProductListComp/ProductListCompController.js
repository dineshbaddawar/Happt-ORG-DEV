({
    init: function (cmp, event, helper) {
        debugger;
        var mapOfProdIdbyListOfPLDTobeReturn = cmp.get('v.mapOfProdIdbyListOfPLDTobeReturn');
        var mapOfNestedProdIdByListOfPLDTobeReturn = cmp.get('v.mapOfNestedProdIdByListOfPLDTobeReturn');
        var keyList = cmp.get('v.keyList');
        
        cmp.set('v.gridColumns', [
            {label: 'Product Name', fieldName: 'name', type: 'text'},
            {label: 'OTI Price', fieldName: 'OTI_Price__c', type: 'text'},
            {label: 'Quantity', fieldName: 'Quantity', type: 'text'},
            {label: 'SAAS Price', fieldName: 'SAAS_Price__c', type: 'number'},
            {label: 'Selected', fieldName: 'Selected__c', type: 'boolean'},
            {label: 'Travel Offering Price', fieldName: 'Travel_Offering_Type__c', type: 'text'},
            {label: 'Type', fieldName: 'Type__c', type: 'text'},
            {label: 'Sub Type',fieldName:'Sub_Type__c',type:'Picklist'}
        ]);
        
        //cmp.set('v.gridColumns', columns);
        var data = [];
        
        var nestedDataByProdId = new Map();
        var childData = [];
        for(let i = 0; i < keyList.length; i++){
            for (let j = 0; j < mapOfProdIdbyListOfPLDTobeReturn[keyList[i]].length; j++) {
                if(mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id] != undefined){
                    if(mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id].length > 0){
                        for (let k = 0; k < mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id].length; k++){
                            childData.push({
                                "name": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Product_Name__c,
                                "OTI_Price__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].OTI_Price__c,
                                "Quantity": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Quantity,
                                "SAAS_Price__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].SAAS_Price__c,
                                "Selected__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Selected__c,
                                "Travel_Offering_Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Travel_Offering_Type__c,
                                "Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Type__c,
                                "Sub_Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Quantity
                            })
                        }
                    }else{
                        childData.push({
                            "name": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Product_Name__c,
                            "OTI_Price__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].OTI_Price__c,
                            "Quantity": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Quantity,
                            "SAAS_Price__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].SAAS_Price__c,
                            "Selected__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Selected__c,
                            "Travel_Offering_Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Travel_Offering_Type__c,
                            "Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Type__c,
                            "Sub_Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Quantity
                        });
                    }
                  nestedDataByProdId.set(mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id,childData); 
                }
            }
        }
        
        
        for(let i = 0; i < keyList.length; i++){
            for (let j = 0; j < mapOfProdIdbyListOfPLDTobeReturn[keyList[i]].length; j++) {
                if(mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id] != undefined){
                    data.push({
                        "name": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product_Name__c,
                        "OTI_Price__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].OTI_Price__c,
                        "Quantity": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Quantity,
                        "SAAS_Price__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].SAAS_Price__c,
                        "Selected__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Selected__c,
                        "Travel_Offering_Type__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Travel_Offering_Type__c,
                        "Type__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Type__c,
                        "Sub_Type__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Quantity,
                        "_children": nestedDataByProdId.get(mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id)
                    })    
                }else{
                    data.push({
                        "name": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product_Name__c,
                        "OTI_Price__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].OTI_Price__c,
                        "Quantity": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Quantity,
                        "SAAS_Price__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].SAAS_Price__c,
                        "Selected__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Selected__c,
                        "Travel_Offering_Type__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Travel_Offering_Type__c,
                        "Type__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Type__c,
                        "Sub_Type__c": mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Quantity,
                        
                    })
                }
                
                

                
            }
        }
       
        cmp.set('v.gridData', data);
        
        var nestedData = [
            {
                "name": "123555",
                "accountName": "Rewis Inc",
                "employees": 3100,
                "phone": "837-555-1212",
                "accountOwner": "http://example.com/jane-doe",
                "accountOwnerName": "Jane Doe",
                "billingCity": "Phoeniz, AZ"
            },
            
            {
                "name": "123556",
                "accountName": "Acme Corporation",
                "employees": 10000,
                "phone": "837-555-1212",
                "accountOwner": "http://example.com/john-doe",
                "accountOwnerName": "John Doe",
                "billingCity": "San Francisco, CA",
                "_children": [
                    {
                        "name": "123556-A",
                        "accountName": "Acme Corporation (Bay Area)",
                        "employees": 3000,
                        "phone": "837-555-1212",
                        "accountOwner": "http://example.com/john-doe",
                        "accountOwnerName": "John Doe",
                        "billingCity": "New York, NY",
                        "_children": [
                            {
                                "name": "123556-A-A",
                                "accountName": "Acme Corporation (Oakland)",
                                "employees": 745,
                                "phone": "837-555-1212",
                                "accountOwner": "http://example.com/john-doe",
                                "accountOwnerName": "John Doe",
                                "billingCity": "New York, NY"
                            },
                            {
                                "name": "123556-A-B",
                                "accountName": "Acme Corporation (San Francisco)",
                                "employees": 578,
                                "phone": "837-555-1212",
                                "accountOwner": "http://example.com/jane-doe",
                                "accountOwnerName": "Jane Doe",
                                "billingCity": "Los Angeles, CA"
                            }
                        ]
                    },
                    
                    {
                        "name": "123556-B",
                        "accountName": "Acme Corporation (East)",
                        "employees": 430,
                        "phone": "837-555-1212",
                        "accountOwner": "http://example.com/john-doe",
                        "accountOwnerName": "John Doe",
                        "billingCity": "San Francisco, CA",
                        "_children": [
                            {
                                "name": "123556-B-A",
                                "accountName": "Acme Corporation (NY)",
                                "employees": 1210,
                                "phone": "837-555-1212",
                                "accountOwner": "http://example.com/jane-doe",
                                "accountOwnerName": "Jane Doe",
                                "billingCity": "New York, NY"
                            },
                            {
                                "name": "123556-B-B",
                                "accountName": "Acme Corporation (VA)",
                                "employees": 410,
                                "phone": "837-555-1212",
                                "accountOwner": "http://example.com/john-doe",
                                "accountOwnerName": "John Doe",
                                "billingCity": "New York, NY",
                                "_children": [
                                    {
                                        "name": "123556-B-B-A",
                                        "accountName": "Allied Technologies",
                                        "employees": 390,
                                        "phone": "837-555-1212",
                                        "accountOwner": "http://example.com/jane-doe",
                                        "accountOwnerName": "Jane Doe",
                                        "billingCity": "Los Angeles, CA",
                                        "_children": [
                                            {
                                                "name": "123556-B-B-A-A",
                                                "accountName": "Allied Technologies (UV)",
                                                "employees": 270,
                                                "phone": "837-555-1212",
                                                "accountOwner": "http://example.com/john-doe",
                                                "accountOwnerName": "John Doe",
                                                "billingCity": "San Francisco, CA"
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    }
                ]
            },
            
            {
                "name": "123557",
                "accountName": "Rhode Enterprises",
                "employees": 6000,
                "phone": "837-555-1212",
                "accountOwner": "http://example.com/john-doe",
                "accountOwnerName": "John Doe",
                "billingCity": "New York, NY",
                "_children": [
                    {
                        "name": "123557-A",
                        "accountName": "Rhode Enterprises (UCA)",
                        "employees": 2540,
                        "phone": "837-555-1212",
                        "accountOwner": "http://example.com/john-doe",
                        "accountOwnerName": "John Doe",
                        "billingCity": "New York, NY"
                    }
                ]
            },
            
            {
                "name": "123558",
                "accountName": "Tech Labs",
                "employees": 1856,
                "phone": "837-555-1212",
                "accountOwner": "http://example.com/john-doe",
                "accountOwnerName": "John Doe",
                "billingCity": "New York, NY",
                "_children": [
                    {
                        "name": "123558-A",
                        "accountName": "Opportunity Resources Inc",
                        "employees": 1934,
                        "phone": "837-555-1212",
                        "accountOwner": "http://example.com/john-doe",
                        "accountOwnerName": "John Doe",
                        "billingCity": "Los Angeles, CA"
                    }
                ]
            }
        ];
        
        
        
        
    },
    
});