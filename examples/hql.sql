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


select
    order.id
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
    and catalog = :currentCatalog
group by
    order
having
    sum(price.amount) > :minAmount
order by
    sum(price.amount) desc



select
    count(payment)
    , status.name
from
    Payment as payment
    join payment.currentStatus as status
    join payment.statusChanges as statusChange
where
    payment.status.name <> PaymentStatus.AWAITING_APPROVAL
    or (
        statusChange.timeStamp = (
            select
                max(change.timeStamp)
            from
                PaymentStatusChange change
            where
                change.payment = payment
        )
        and statusChange.user <> :currentUser
    )
group by
    status.name
    , status.sortOrder
order by
    status.sortOrder


select
    count(payment)
    , status.name
from
    Payment as payment
    join payment.currentStatus as status
where
    payment.status.name <> PaymentStatus.AWAITING_APPROVAL
    or payment.statusChanges[ maxIndex(payment.statusChanges) ].user <> :currentUser
group by
    status.name
    , status.sortOrder
order by
    status.sortOrder


/*
The next query uses the MS SQL Server isNull() function to
return all the accounts and unpaid payments for the organization to
which the current user belongs. It translates to an SQL query with three inner joins,
an outer join and a subselect against the ACCOUNT, PAYMENT, PAYMENT_STATUS, ACCOUNT_TYPE, ORGANIZATION and ORG_USER tables.
*/
select
    account
    , payment
from
    Account as account
    left outer join account.payments as payment
where
    :currentUser in elements(account.holder.users)
    and PaymentStatus.UNPAID = isNull(payment.currentStatus.name, PaymentStatus.UNPAID)
order by
    account.type.sortOrder
    , account.accountNumber
    , payment.dueDate


select
    account
    , payment
from
    Account as account
    join account.holder.users as user
    left outer join account.payments as payment
where
    :currentUser = user
    and PaymentStatus.UNPAID = isNull(payment.currentStatus.name, PaymentStatus.UNPAID)
order by
    account.type.sortOrder
    , account.accountNumber
    , payment.dueDate

