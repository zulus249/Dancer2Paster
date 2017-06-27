--drop table entries;
create table if not exists entries (
  id string primary key,
  ip string not null,
  text string not null,
  date integer default CURRENT_TIMESTAMP
);
