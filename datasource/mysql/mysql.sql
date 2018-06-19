create table route_rule_group
(
  group_id int primary key auto_increment,
  app_name varchar(64) not null,
  priority int default 1,
  status varchar(16) default 'OFF',
  protocol varchar(16) not null,
  group_desc varchar(256),
  create_time datetime,
  update_time datetime
)

create table route_rule
(
  rule_id int primary key auto_increment,
  group_id int not null,
  rule_type varchar(64) not null,
  rule_str varchar(128) not null,
  cluster varchar(64) not null,
  priority int default 1,
  status varchar(16) default 'OFF',
  group_desc varchar(256),
  create_time datetime,
  update_time datetime
)