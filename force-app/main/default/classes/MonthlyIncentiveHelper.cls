public class MonthlyIncentiveHelper {
    
    public static String getCurrentMonth(){
        DateTime dt = Datetime.now();
        return dt.format('MMMM');
    }

}