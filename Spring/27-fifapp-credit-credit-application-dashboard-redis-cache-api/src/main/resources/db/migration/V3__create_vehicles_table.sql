create table vehicles
(
    id                 bigserial primary key,
    plate_number       varchar(20) not null,
    brand              varchar(50) not null,
    model              varchar(50) not null,
    manufacturing_year integer     not null,
    created_at         timestamp   not null default current_timestamp
);

create unique index uk_vehicles_plate_number on vehicles (plate_number);
