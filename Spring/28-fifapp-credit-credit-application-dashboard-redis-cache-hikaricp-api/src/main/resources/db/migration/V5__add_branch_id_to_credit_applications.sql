alter table credit_applications
    add column branch_id bigint not null default 10;

create index idx_credit_applications_branch_id on credit_applications (branch_id);
create index idx_credit_applications_branch_status on credit_applications (branch_id, status);