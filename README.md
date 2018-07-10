Type-Safety Query - TSQuery
==============================

A **t**ype-**s**afety query for SQL, HQL, GraphQL and JSON path mutation.

## Goal

- Normal query

```java
TSQuery query = new TSQuery();
Object m = query.use(Model.class);

query
    .select(m.getId())
    .from(m, A.class)
    .where()
        ._ // -> `(`
            .prop(m.getName()).is("a")
            .and
            .prop(m.getCode()).isNotNull()
        .$.or._
            .prop(m.getTime()).greaterThan(new Date())
        .$ // -> `)`
    .group()
        .by(m.getName())
        .by(m.getCode())
    .order()
        .by(m.getName()).desc()
        .by(m.getCode()).asc()
;
```

- Conditional query

```java
TSQuery query = new TSQuery();
Object m = query.use(Model.class);

query
    .select(m.getId())
    .from(m)
    .where()
        .when(a > 10)
            .prop(m.getCode()).is("abc")
        .otherwise()
            .prop(m.getCode()).is("def")
        .end()
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
