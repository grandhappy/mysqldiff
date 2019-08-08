# WARNING: Using a password on the command line interface can be insecure.
# server1 on 127.0.0.1: ... connected.
# server2 on 127.0.0.1: ... connected.
# Comparing adott_sandbox.test1 to adott_sandbox.test2             [FAIL]
# Transformation for --changes-for=server1:
#

ALTER TABLE `adott_sandbox`.`test1` 
  DROP PRIMARY KEY, 
  DROP COLUMN d, 
  CHANGE COLUMN b b varchar(5) NULL, 
  ADD COLUMN D int(11) NULL AFTER c, 
  CHANGE COLUMN a a varchar(10) NULL, 
  CHANGE COLUMN c c varchar(10) NULL, 
RENAME TO adott_sandbox.test2 
, COMMENT='test2';

# Compare failed. One or more differences found.
