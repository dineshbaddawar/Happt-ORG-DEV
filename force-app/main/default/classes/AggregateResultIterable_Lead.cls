global class AggregateResultIterable_Lead implements Iterable<AggregateResult> {
  private String query;

  global AggregateResultIterable_Lead(String soql){
    query = soql;
  }

  global Iterator<AggregateResult> Iterator(){
    return new AggregateResultIterator(query);
  }

}