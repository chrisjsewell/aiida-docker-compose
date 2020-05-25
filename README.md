[![DockerHub1](https://img.shields.io/badge/DockerHub-aiida--core-blue)](https://hub.docker.com/r/chrisjsewell/aiida-core/tags)
[![DockerHub2](https://img.shields.io/badge/DockerHub-quantum--espresso-blue)](https://hub.docker.com/r/chrisjsewell/quantum-espresso/tags)

# aiida-compose-docker

This package provides container images and [Docker compose](https://docs.docker.com/compose/) files,
for running AiiDA as a multi-container application.

<img src="https://raw.githubusercontent.com/chrisjsewell/aiida-docker-compose/master/uml-diagram.png" width="500" alt="uml diagram"></img>

## Introduction

This approach is an alternative to the current [aiidateam/aiida-core](https://hub.docker.com/r/aiidateam/aiida-core) image,
which packages all services into one container.
Although this works and has some benefits, it does diverge from a central design principle of docker containers:

> "One service per container"

The reasons for this are outlined [here](https://docs.docker.com/config/containers/multi-service_container/) and [here](https://devops.stackexchange.com/a/451). Some specific benefits are that:

1. The responsibility for constructing/maintaining working RabbitMQ and PostgreSQL services are transferred to the official builds.
2. You can swap-in any RabbitMQ/PostgreSQL versions, without requiring a new core image.
3. The size of the core image is greatly reduced:

```console
$ docker image list
REPOSITORY                      TAG                  IMAGE ID            CREATED             SIZE
aiidateam/aiida-core            latest               547a467941da        4 days ago          1.72GB
chrisjsewell/aiida-core         1.2.1                d21f8a58855e        12 hours ago        482MB
rabbitmq                        3.8.3-management     867da7fcdf92        4 days ago          181MB
postgres                        12.3                 adf2b126dda8        9 days ago          313MB
```

## Using the system: basic

First spin-up the docker system:

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

Tip: [VSCode-Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) provides a nice UI for visualising Docker systems.

You will now have three containers running and connected over a private networks:

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
$ docker network ls
NETWORK ID          NAME                         DRIVER              SCOPE
63b22ad9aa35        aiidadockercompose_default   bridge              local
```

The containers are also connected to three volumes, which store data that will persist during container destruction/creation.

```console
$ docker volume list
DRIVER              VOLUME NAME
local               aiida-object-store
local               aiida-postgres-db
local               aiida-rmq-data
```

The postgres database is exposed to the localhost and can be accessed by:

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

To create an AiiDA profile (populating the `aiida-postgres-db` and `aiida-object-store`),
login to the `core` container then:

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
  ...
Success: database migration completed.
aiida@951715c4ed5b:~$ verdi status
 ✓ config dir:  /home/aiida/.aiida
 ✓ profile:     On profile default
 ✓ repository:  /home/aiida/.aiida/repository/default
 ✓ postgres:    Connected as aiida@database:5432
 ✓ rabbitmq:    Connected to amqp://messaging?heartbeat=600
 ✗ daemon:      The daemon is not running
```

The database will now show:

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

To spin-down the system:

```console
$ docker-compose down
Stopping aiida-core     ... done
Stopping aiida-rmq      ... done
Stopping aiida-database ... done
Removing aiida-core     ... done
Removing aiida-rmq      ... done
Removing aiida-database ... done
Removing network qedirect_default
```

## Add a computer: Quantum Espresso (Direct)

To add a computer to the above system:

```console
$ cd compose/qe-direct
$ docker-compose up -d
```

You can carry out MPI runs directly:

```console
$ docker exec -it --user qeuser computer mpiexec -np 2 pw.x -i examples/example_pw.in

     Program PWSCF v.6.5 starts on 24May2020 at 17:23:55

     This program is part of the open-source Quantum ESPRESSO suite
     for quantum simulation of materials; please cite
         "P. Giannozzi et al., J. Phys.:Condens. Matter 21 395502 (2009);
         "P. Giannozzi et al., J. Phys.:Condens. Matter 29 465901 (2017);
          URL http://www.quantum-espresso.org",
     in publications or presentations arising from this work. More details at
     http://www.quantum-espresso.org/quote

     Parallel version (MPI), running on     2 processors
     ...
=------------------------------------------------------------------------------=
   JOB DONE.
=------------------------------------------------------------------------------=
```

To add the computer and code to the AiiDA profile,
an additional folder is mounted to both the `computer` and `core` containers,
containing SSH keys and configuration to set up the nodes:

```console
$ docker exec -it --user aiida aiida-core /bin/bash
$ verdi computer setup --config ssh_key/aiida-computer-setup.yml
$ verdi computer configure ssh qe_computer --config ssh_key/aiida-computer-config.yml
$ verdi computer test qe_computer
Info: Testing computer<qe_computer> for user<my@email.com>...
* Opening connection... [OK]
* Checking for spurious output... [OK]
* Getting number of jobs from scheduler... [OK]: 5 jobs found in the queue
* Determining remote user name... [OK]: qeuser
* Creating and deleting temporary file... [OK]
Success: all 5 tests succeeded
$ verdi code setup --config ssh_key/aiida-code-setup.yml
Success: Code<1> qe-direct@qe_computer created
```

To add a pseudo-potential family to the profile:

```console
$ aiida-sssp install -v 1.1 -f PBE -p efficiency
Info: downloading selected pseudo potentials archive...  [OK]
Info: downloading selected pseudo potentials metadata...  [OK]
Info: unpacking archive and parsing pseudos...  [OK]
Success: installed `SSSP/1.1/PBE/efficiency` containing 85 pseudo potentials
$ verdi group list -T sssp.family
  PK  Label                    Type string    User
----  -----------------------  -------------  ------------
   3  SSSP/1.1/PBE/efficiency  sssp.family    my@email.com
```

To run an example calculation:

```console
$ verdi export inspect ssh_key/qe-pw-test.aiida
$ verdi node show 5eb94d2d-2f58-4769-9f74-80c223791077 a63f51e4-4a86-4271-bb30-ad69c1e1a7e2 ea01fb5e-9098-481c-b46e-57cfa60a77cc
Property     Value
-----------  ------------------------------------
type         StructureData
pk           2
uuid         5eb94d2d-2f58-4769-9f74-80c223791077
label
description
ctime        2020-04-29 01:33:56.285489+00:00
mtime        2020-04-29 01:36:59.366312+00:00
Property     Value
-----------  ------------------------------------
type         KpointsData
pk           3
uuid         a63f51e4-4a86-4271-bb30-ad69c1e1a7e2
label
description
ctime        2020-04-29 01:38:20.385837+00:00
mtime        2020-04-29 01:39:44.531806+00:00
Property     Value
-----------  ------------------------------------
type         Dict
pk           4
uuid         ea01fb5e-9098-481c-b46e-57cfa60a77cc
label
description
ctime        2020-04-29 01:40:54.281852+00:00
mtime        2020-04-29 01:41:02.971497+00:00
```

```console
$ verdi daemon start
Starting the daemon... RUNNING
$ verdi run ssh_key/run_example.py
pk= 102
$ verdi process watch 102
Info: watching for broadcasted messages, press CTRL+C to stop...
Process<102> [state_changed.waiting.waiting|--]: No message specified
Process<102> [state_changed.waiting.waiting|--]: No message specified
Process<102> [state_changed.waiting.waiting|--]: No message specified
Process<102> [state_changed.waiting.running|--]: No message specified
Process<102> [state_changed.running.finished|--]: No message specified
^C
Info: received interrupt, exiting...

Aborted!
$ verdi process show 102
Property     Value
-----------  ------------------------------------
type         PwCalculation
state        Finished [0]
pk           102
uuid         1768a99c-c964-4ead-9b27-ed49c0a5a94c
label
description
ctime        2020-05-25 09:59:38.544190+00:00
mtime        2020-05-25 10:01:47.948854+00:00
computer     [1] qe_computer

Inputs      PK    Type
----------  ----  -------------
pseudos
    Si      45    UpfData
code        101   Code
kpoints     3     KpointsData
parameters  4     Dict
structure   2     StructureData

Outputs              PK  Type
-----------------  ----  --------------
output_band         105  BandsData
output_parameters   107  Dict
output_trajectory   106  TrajectoryData
remote_folder       103  RemoteData
retrieved           104  FolderData
```

```console
$ docker-compose down
Stopping aiida-core     ... done
Stopping computer       ... done
Stopping aiida-rmq      ... done
Stopping aiida-database ... done
Removing aiida-core     ... done
Removing computer       ... done
Removing aiida-rmq      ... done
Removing aiida-database ... done
Removing network qedirect_default
```

## Development Notes

- Multi-stage build caching:
  - https://github.com/docker/hub-feedback/issues/1918
  - https://github.com/moby/moby/issues/34715
  - https://github.com/elgohr/Publish-Docker-Github-Action/issues/87#issuecomment-633250342
  - https://runkiss.blogspot.com/2019/12/use-cache-in-docker-multi-stage-build.html

- could potentially wait until database, rabbitmq ready, either
  - netstat -an | grep 5672 > /dev/null; if [ 0 != $? ]; then echo 1; fi;
  - nc -vz database 5432 | grep open && nc -vz messaging 5672 | grep open

- use secrets for injecting ssh keys? https://medium.com/@francesco.camillini/inject-ssh-private-key-securely-into-a-docker-container-8403b72ab9e3

- timezones in aiida-core could maybe be improved (need to be set for tzlocal to work)
  - https://medium.com/developer-space/be-careful-while-playing-docker-about-timezone-configuration-e7a2217e9b76

Image sizes (un-compressed):

```console
$ docker image list
REPOSITORY                      TAG                  IMAGE ID            CREATED             SIZE
aiidateam/aiida-core            latest               547a467941da        4 days ago          1.72GB
chrisjsewell/aiida-core         1.2.1                d21f8a58855e        12 hours ago        482MB
chrisjsewell/aiida-core         qe-3.0.0             2f1f86f77fbc        15 hours ago        832MB
rabbitmq                        3.8.3-management     867da7fcdf92        4 days ago          181MB
postgres                        12.3                 adf2b126dda8        9 days ago          313MB
chrisjsewell/quantum-espresso   qe-6.5-pw            7553db6a0972        12 hours ago        277MB
```
