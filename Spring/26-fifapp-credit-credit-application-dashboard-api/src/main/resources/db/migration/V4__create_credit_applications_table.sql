create table credit_applications
(
    id          bigserial primary key,
    customer_id bigint         not null,
    vehicle_id  bigint         not null,
    loan_amount numeric(19, 2) not null,
    tenor_month integer        not null,
    status      varchar(30)    not null,
    created_at  timestamp      not null default current_timestamp,

    constraint fk_credit_applications_customer foreign key (customer_id) references customers (id),
    constraint fk_credit_applications_vehicle foreign key (vehicle_id) references vehicles (id)
);

