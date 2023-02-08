#!/usr/bin/env bash
set -e

MYSQL_CLIENT=/srv/hops/mysql-cluster/ndb/scripts/mysql-client.sh
NDB_RESTORE=/srv/hops/mysql/bin/ndb_restore

unset -v backup_path
unset -v node_id
unset -v backup_id
unset -v mgm_connection
unset -v ndb_restore_exclude_tables
unset -v ndb_restore_op

n=$(date +'%g%m%d')
log_file=/srv/hops/mysql-cluster/log/ndb_restore_${n}.log

_log(){
    now=$(date)
    echo "$now - $1 - $2" |& tee $log_file
}

_log_info(){
    _log "INFO" "$1"
}

_log_warn(){
    _log "WARN" "$1"
}

_log_error(){
    _log "ERROR" "$1"
}

##########################
## Restore MySQL schema ##
##########################

_restore_schema(){
    _log_info "Restoring schema"
    while getopts 'p:h' opt; do
        case "$opt" in
            p)
                backup_path="$OPTARG"
                ;;
            ?|h)
                echo -e "Usage $(basename $0) restore_schema -p ARG\n\t-p: Path to backup directory"
                exit 1
                ;;
        esac
    done
    _restore_schema_int
}

_restore_schema_int(){
    if [ -z "$backup_path" ]; then
        _log_error "Backup path is not specified [-p]"
        exit 1
    fi
    _log_info "Restoring schema from $backup_path"
    $MYSQL_CLIENT < $backup_path/sql/schemata.sql
    $MYSQL_CLIENT -e "SOURCE $backup_path/sql/users.sql"
}

########################
## Restore RonDB data ##
########################

_ndb_restore(){
    while getopts 'p:n:b:c:e:m:h' opt; do
        case "$opt" in
            p)
                backup_path="$OPTARG"
                ;;
            n)
                node_id="$OPTARG"
                ;;
            b)
                backup_id="$OPTARG"
                ;;
            c)
                mgm_connection="$OPTARG"
                ;;
            e)
                ndb_restore_exclude_tables="$OPTARG"
                ;;
            m)
                ndb_restore_op="$OPTARG"
                ;;
            ?|h)
                echo -e "Usage $(basename $0) restore_schema -p ARG\n\t-p: Path to backup directory\n\t-n: Node id to restore\n\t-b: Backup id to restore\n\t-c: Connection to Management server ip_address:port\n\t-m: Restore mode\n\t\tMETA for restoring only metadata\n\t\tDATA for restoring data\n\t-e: OPTIONALLY exclude some comma-sperated tables"
                exit 1
                ;;
        esac
    done
    _ndb_restore_int
}

_ndb_restore_int(){
    if [ -z "$backup_path" ]; then
        _log_error "RonDB backup path is not specified [-p]"
        exit 1
    fi
    if [ -z "$node_id" ]; then
        _log_error "RonDB node id is not specified [-n]"
        exit 1
    fi
    if [ -z "$backup_id" ]; then
        _log_error "RonDB backup id is not specified [-b]"
        exit 1
    fi
    if [ -z "$mgm_connection" ]; then
        _log_error "RonDB Management server connection is not specifed [-m ip_address:port]"
        exit 1
    fi
    if [ -z "$ndb_restore_op" ]; then
        _log_error "NDB restore operation was not specified. One of -d or -m MUST be set"
        exit 1
    fi
    if [ -n "$ndb_restore_exclude_tables" ]; then
        exclude_tables="--exclude-tables=$ndb_restore_exclude_tables"
    fi

    ndb_backup_path=$backup_path/BACKUP/BACKUP-$backup_id
    if [ "$ndb_restore_op" == "META" ]; then
        _log_info "Restoring METADATA backup id $backup_id from node $node_id from path $ndb_backup_path excluding tables $exclude_tables"
        $NDB_RESTORE --ndb-connectstring=$mgm_connection --nodeid=$node_id --backupid=$backup_id --backup_path=$ndb_backup_path $exclude_tables --restore_meta >> $log_file 2>&1
    elif [ "$ndb_restore_op" == "DATA" ]; then
        _log_info "Restoring DATA backup id $backup_id from node $node_id from path $backup_path excluding tables $exclude_tables"
        $NDB_RESTORE --ndb-connectstring=$mgm_connection --nodeid=$node_id --backupid=$backup_id --backup_path=$ndb_backup_path $exclude_tables --restore_data >> $log_file 2>&1
    fi
    _log_info "Finished restoring data"
}

########################
## Create tablespaces ##
########################

_create_tablespaces(){
    while getopts 'h' opt; do
        case "$opt" in
            ?|h)
                echo -e "Usage $(basename $0) create-tablespaces"
                exit 1
                ;;
        esac
    done
    _create_tablespaces_int
}

_create_tablespaces_int(){
    _log_info "Creating log file lg_1"
    $MYSQL_CLIENT -e "CREATE LOGFILE GROUP lg_1 ADD UNDOFILE 'undo_log_0.log' INITIAL_SIZE = 128M ENGINE ndbcluster" >> $log_file 2>&1
    _log_info "Creating data file ts_1"
    $MYSQL_CLIENT -e "CREATE TABLESPACE ts_1 ADD datafile 'ts_1_data_file_0.dat' use LOGFILE GROUP lg_1 INITIAL_SIZE = 128M  ENGINE ndbcluster" >> $log_file 2>&1
    _log_info "Finished creating tablespaces"
}

_help(){
    echo -e "Usage: $(basename $0) create-tablespaces | restore-schema | ndb-restore\nUse -h for further help"
    exit 1
}

subcommand=$1
case $subcommand in
    "create-tablespaces")
        shift
        _create_tablespaces $@
        ;;
    "restore-schema")
        shift
        _restore_schema $@
        ;;
    "ndb-restore")
        shift
        _ndb_restore $@
        ;;
    *)
        _help
        ;;
esac