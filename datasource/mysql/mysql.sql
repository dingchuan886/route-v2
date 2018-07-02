CREATE TABLE route_rule_group
(
  group_id    INT PRIMARY KEY AUTO_INCREMENT,
  app_name    VARCHAR(64) NOT NULL,
  priority    INT             DEFAULT 1,
  status      VARCHAR(16)     DEFAULT 'OFF',
  protocol    VARCHAR(16) NOT NULL,
  group_desc  VARCHAR(256),
  create_time DATETIME,
  update_time DATETIME
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE route_rule
(
  rule_id     INT PRIMARY KEY AUTO_INCREMENT,
  group_id    INT          NOT NULL,
  rule_type   VARCHAR(64)  NOT NULL,
  rule_str    VARCHAR(128) NOT NULL,
  cluster     VARCHAR(64)  NOT NULL,
  priority    INT             DEFAULT 1,
  status      VARCHAR(16)     DEFAULT 'OFF',
  create_time DATETIME,
  update_time DATETIME
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE route_cluster
(
  cluster_id   INT PRIMARY KEY AUTO_INCREMENT,
  cluster      VARCHAR(64)  NOT NULL,
  addresses    VARCHAR(512) NOT NULL,
  status       VARCHAR(16)     DEFAULT 'OFF',
  cluster_desc VARCHAR(256),
  create_time  DATETIME,
  update_time  DATETIME
)ENGINE=MyISAM DEFAULT CHARSET=utf8;