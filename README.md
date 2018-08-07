Type-Safety Query - TSQuery
==============================

A **t**ype-**s**afety query for SQL, HQL, GraphQL and JSON path mutation.

## Goal

- Normal query

```java
TSQuery query = new TSQuery();
A a = query.use(A.class);
B b = query.use(B.class);

query
    .select()
        ._(a.getId(), b.getId())
    .from()
        ._(a, b)
    .where()
        ._() // -> `(`
            .prop(a.getName()).equalTo("a")
            .and(a.getCode()).isNotNull()
        .$().or()._()
            .prop(a.getTime()).greaterThan(new Date())
        .$() // -> `)`
    .group()
        .by(a.getName())
        .by(a.getCode())
    .order()
        .by(a.getName()).desc()
        .by(a.getCode()).asc()
;
```

- Conditional query

```java
TSQuery query = new TSQuery();
A a = query.use(A.class);

query
    .select()
        ._(a.getId())
    .from()
        ._(a)
    .where()
        .when(x > 10)
            .prop(a.getCode()).equalTo("abc")
        .otherwise()
            .prop(a.getCode()).equalTo("def")
        .end()
;
```

- Complex query

```java
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
        .by(order).having().sum(price.getAmount()).greaterThan(123)
        .by(catalog.getName())
    .order()
        .by().sum(price.getAmount()).desc()
        .by(cat.getEffectiveDate()).asc()
;
```

- Get results

```java
TSQuery query = new TSQuery();

// The total of matched results
query.count();

// Return all matched results
query.list();
// Return 'limit' results from 'start'
query.page(start, limit);
// Return the single result, if there are more than one results,
// the exception will be thrown
query.single();

// Return the first matched result
query.first();
// Return the last matched result
query.last();
// Pick one matched result which is at 'offset'
query.pick(offset);
```
