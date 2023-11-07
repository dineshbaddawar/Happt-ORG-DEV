public class customLookupCompController {
    @AuraEnabled
    public static List<product2> getProducts(String searchTerm, List <product2> selectedOptions) {
        List<String> Ids = new List<String>();
        
        for(product2 prod : selectedOptions){
            Ids.add(prod.Id);
        }
        system.debug('selectedOptions:::'+selectedOptions);
        system.debug('Ids:::'+Ids);
        
        if(selectedOptions != NULL){
            List<product2> prodList = [Select Id, Name,Is_Travel_Product__c from product2 Where Name Like  : ('%'+searchTerm+'%') AND (Id != : Ids) LIMIT  5];
            system.debug('prodList:::'+prodList);
            return prodList;
        }else{
            List<product2> prodList = [Select Id, Name,Is_Travel_Product__c from product2 Where Name Like  : ('%'+searchTerm+'%') LIMIT  5];
            system.debug('prodList:::'+prodList);
            return prodList;    
        }
    }
    
}