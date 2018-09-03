TSQuery query = new TSQuery();
Order order = query.use(Order.class);
LineItem item = query.use(order.getLineItems());
Product product = query.use(item.product);
Catalog catalog = query.use(Catalog.class);
Price price = query.use(catalog.getPrices());


TSQuery subQuery = new TSQuery();
Catalog cat = subQuery.use(Catalog.class);

query
    .select()
        .distinct(order.getId())
        .and().sum(price.getAmount())
        .and().count(item)
    .from()
        ._(order).join(item).join(product)
        .and(catalog).join(price)
    .where()
        ._()
            .prop(order.isPaid()).equalTo(false)
            .or(order.getCustomer()).equalTo("sad")
        .$().and()._()
            .prop(price.getProduct()).equalTo(product)
            .or()._()
                .prop(catalog.getEffectiveDate()).lessThan().sysdate()
                .and(catalog.getEffectiveDate()).greaterAndEqualThan().all(
                    subQuery
                        .select()
                            ._(cat.getEffectiveDate()/*, ...*/)
                            //.and(cat.getXx(), ...)
                        .from()
                            ._(cat/*, ...*/)
                            //.and(prod, ...)
                        .where()
                            .prop(cat.getEffectiveDate()).lessThan().sysdate()
                )
            .$()
        .$()
    .group()
        .by(order)
        .by(catalog.getName())
    .having()
        .sum(price.getAmount()).greaterThan(123)
    .order()
        .by().sum(price.getAmount()).desc()
        .by(cat.getEffectiveDate()).asc()
;



select 
    distinct order.id
    , sum(price.amount)
    , count(item) 
from 
    Order as order 
    join order.lineItems as item 
    join item.product as product, 
    Catalog as catalog 
    join catalog.prices as price 
where 
    order.paid = false 
    and order.customer = :customer 
    and price.product = product 
    and catalog.effectiveDate < sysdate 
    and catalog.effectiveDate >= all ( 
        select 
            cat.effectiveDate 
        from 
            Catalog as cat 
        where 
            cat.effectiveDate < sysdate 
    ) 
group by 
    order
having
    sum(price.amount) > :minAmount 
order by 
    sum(price.amount) desc
