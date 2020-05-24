[![DockerHub1](https://img.shields.io/badge/DockerHub-aiida--core-blue)](https://hub.docker.com/r/chrisjsewell/aiida-core/tags)
[![DockerHub2](https://img.shields.io/badge/DockerHub-quantum--espresso-blue)](https://hub.docker.com/r/chrisjsewell/quantum-espresso/tags)

# aiida-compose-docker

Docker service infrastructure for running AiiDA

```console
$ cd compose/basic
$ docker-compose up -d
Creating aiida-rmq ...
Creating aiida-database ...
Creating aiida-rmq
Creating aiida-database ... done
Creating aiida-core ...
Creating aiida-core ... done
```

```console
$ docker-compose ps
     Name                   Command               State                           Ports
----------------------------------------------------------------------------------------------------------------
aiida-core       /sbin/my_init                    Up
aiida-database   docker-entrypoint.sh postgres    Up      0.0.0.0:5432->5432/tcp
aiida-rmq        docker-entrypoint.sh rabbi ...   Up      15671/tcp, 0.0.0.0:15672->15672/tcp, 25672/tcp,
                                                          4369/tcp, 5671/tcp, 5672/tcp
```

```console
$ docker volume list
DRIVER              VOLUME NAME
local               aiida-object-store
local               aiida-postgres-db
local               aiida-rmq-data
```

```console
$ docker network ls
NETWORK ID          NAME                         DRIVER              SCOPE
63b22ad9aa35        aiidadockercompose_default   bridge              local
```

```console
$ psql postgres -h localhost -p 5432 -U pguser -c "\l"
Password for user pguser:
                              List of databases
   Name    | Owner  | Encoding |  Collate   |   Ctype    | Access privileges
-----------+--------+----------+------------+------------+-------------------
 pguser    | pguser | UTF8     | en_US.utf8 | en_US.utf8 |
 postgres  | pguser | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | pguser | UTF8     | en_US.utf8 | en_US.utf8 | =c/pguser        +
           |        |          |            |            | pguser=CTc/pguser
 template1 | pguser | UTF8     | en_US.utf8 | en_US.utf8 | =c/pguser        +
           |        |          |            |            | pguser=CTc/pguser
(4 rows)
```

```console
$ docker exec -it --user aiida aiida-core /bin/bash
aiida@951715c4ed5b:~$ verdi status
 ✓ config dir:  /home/aiida/.aiida
aiida@951715c4ed5b:~$ verdi quicksetup --config aiida-configs/aiida-qsetup-conf.yml -n
Success: created new profile `default`.
Info: migrating the database.
Operations to perform:
  Apply all migrations: auth, contenttypes, db
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying contenttypes.0002_remove_content_type_name... OK
  Applying auth.0001_initial... OK
  Applying auth.0002_alter_permission_name_max_length... OK
  Applying auth.0003_alter_user_email_max_length... OK
  Applying auth.0004_alter_user_username_opts... OK
  Applying auth.0005_alter_user_last_login_null... OK
  Applying auth.0006_require_contenttypes_0002... OK
  Applying auth.0007_alter_validators_add_error_messages... OK
  Applying auth.0008_alter_user_username_max_length... OK
  Applying auth.0009_alter_user_last_name_max_length... OK
  Applying auth.0010_alter_group_name_max_length... OK
  Applying auth.0011_update_proxy_permissions... OK
  Applying db.0001_initial... OK
  Applying db.0002_db_state_change... OK
  Applying db.0003_add_link_type... OK
  Applying db.0004_add_daemon_and_uuid_indices... OK
  Applying db.0005_add_cmtime_indices... OK
  Applying db.0006_delete_dbpath... OK
  Applying db.0007_update_linktypes... OK
  Applying db.0008_code_hidden_to_extra... OK
  Applying db.0009_base_data_plugin_type_string... OK
  Applying db.0010_process_type... OK
  Applying db.0011_delete_kombu_tables... OK
  Applying db.0012_drop_dblock... OK
  Applying db.0013_django_1_8... OK
  Applying db.0014_add_node_uuid_unique_constraint... OK
  Applying db.0015_invalidating_node_hash... OK
  Applying db.0016_code_sub_class_of_data... OK
  Applying db.0017_drop_dbcalcstate... OK
  Applying db.0018_django_1_11... OK
  Applying db.0019_migrate_builtin_calculations... OK
  Applying db.0020_provenance_redesign... OK
  Applying db.0021_dbgroup_name_to_label_type_to_type_string... OK
  Applying db.0022_dbgroup_type_string_change_content... OK
  Applying db.0023_calc_job_option_attribute_keys... OK
  Applying db.0024_dblog_update... OK
  Applying db.0025_move_data_within_node_module... OK
  Applying db.0026_trajectory_symbols_to_attribute... OK
  Applying db.0027_delete_trajectory_symbols_array... OK
  Applying db.0028_remove_node_prefix... OK
  Applying db.0029_rename_parameter_data_to_dict... OK
  Applying db.0030_dbnode_type_to_dbnode_node_type... OK
  Applying db.0031_remove_dbcomputer_enabled... OK
  Applying db.0032_remove_legacy_workflows... OK
  Applying db.0033_replace_text_field_with_json_field... OK
  Applying db.0034_drop_node_columns_nodeversion_public... OK
  Applying db.0035_simplify_user_model... OK
  Applying db.0036_drop_computer_transport_params... OK
  Applying db.0037_attributes_extras_settings_json... OK
  Applying db.0038_data_migration_legacy_job_calculations... OK
  Applying db.0039_reset_hash... OK
  Applying db.0040_data_migration_legacy_process_attributes... OK
  Applying db.0041_seal_unsealed_processes... OK
  Applying db.0042_prepare_schema_reset... OK
  Applying db.0043_default_link_label... OK
  Applying db.0044_dbgroup_type_string... OK
Success: database migration completed.
aiida@951715c4ed5b:~$ verdi status
 ✓ config dir:  /home/aiida/.aiida
 ✓ profile:     On profile default
 ✓ repository:  /home/aiida/.aiida/repository/default
 ✓ postgres:    Connected as aiida@database:5432
 ✓ rabbitmq:    Connected to amqp://messaging?heartbeat=600
 ✗ daemon:      The daemon is not running
```

```console
$ psql aiida_db -h localhost -p 5432 -U pguser -c "\l"
Password for user pguser:
                               List of databases
   Name    | Owner  | Encoding |   Collate   |    Ctype    | Access privileges
-----------+--------+----------+-------------+-------------+-------------------
 aiida_db  | aiida  | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/aiida        +
           |        |          |             |             | aiida=CTc/aiida
 pguser    | pguser | UTF8     | en_US.utf8  | en_US.utf8  |
 postgres  | pguser | UTF8     | en_US.utf8  | en_US.utf8  |
 template0 | pguser | UTF8     | en_US.utf8  | en_US.utf8  | =c/pguser        +
           |        |          |             |             | pguser=CTc/pguser
 template1 | pguser | UTF8     | en_US.utf8  | en_US.utf8  | =c/pguser        +
           |        |          |             |             | pguser=CTc/pguser
(5 rows)
```

## Development Notes

- Multi-stage build caching:
  - https://github.com/docker/hub-feedback/issues/1918
  - https://github.com/moby/moby/issues/34715
  - https://github.com/elgohr/Publish-Docker-Github-Action/issues/87#issuecomment-633250342
  - https://runkiss.blogspot.com/2019/12/use-cache-in-docker-multi-stage-build.html
