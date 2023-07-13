#!/usr/bin/env bash
set -e

## Expected directory structure for the backup directory
## {ROOT_BACKUP_DIRECTORY}
## \-> sql
##    \-> schemata.sql
##    \-> users.sql
## \-> BACKUP
##    \-> BACKUP-{BACKUP_ID}
##       \-> (BACKUP-{BACKUP_ID}-PART-[1-9]-OF-[1-9]) Optionally if there are multiple LDM threads
##          \-> *.Data
##          \-> *.ctl
##          \-> *.log

DEFAULT_NDB_ROOT_DIR=/srv/hops/mysql-cluster
DEFAULT_MYSQL_ROOT_DIR=/srv/hops/mysql

NDB_ROOT_DIR=$DEFAULT_NDB_ROOT_DIR
MYSQL_ROOT_DIR=$DEFAULT_MYSQL_ROOT_DIR

n=$(date +'%g%m%d')
log_file=${NDB_ROOT_DIR}/log/ndb_restore_${n}.log

_log(){
    now=$(date)
    set +e
    echo "$now - $1 - $2" |& tee -a $log_file
    set -e
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

if [ "$NDB_ROOT_DIR" == "$DEFAULT_NDB_ROOT_DIR" ]; then
    _log_warn "NDB_ROOT_DIR is not set, using default value $DEFAULT_NDB_ROOT_DIR"
fi

if [ "$MYSQL_ROOT_DIR" == "$DEFAULT_MYSQL_ROOT_DIR" ]; then
    _log_warn "MYSQL_ROOT_DIR is not set, using default value $DEFAULT_MYSQL_ROOT_DIR"
fi

MYSQL_CLIENT=${NDB_ROOT_DIR}/ndb/scripts/mysql-client.sh
NDB_RESTORE=${MYSQL_ROOT_DIR}/bin/ndb_restore

unset -v backup_path
unset -v node_id
unset -v backup_id
unset -v mgm_connection
unset -v ndb_restore_exclude_tables
unset -v ndb_restore_op
unset -v ndb_restore_serial

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
    schema_file=${backup_path}/sql/schemata.sql
    _log_info "Restoring SQL schemata and views from $schema_file"
    $MYSQL_CLIENT < $schema_file >> $log_file 2>&1
    _log_info "Finished restoring SQL schemata and views"
    users_file=${backup_path}/sql/users.sql
    _log_info "Restoring MySQL users from $users_file"
    _log_warn "Some users such as kthfs might already be present so it is expected to see them failing"
    set +e
    $MYSQL_CLIENT -e "SOURCE $backup_path/sql/users.sql" >> $log_file 2>&1
    set -e
    _log_info "Finished restoring MySQL users"
}

########################
## Restore RonDB data ##
########################

_ndb_restore(){
    while getopts 'p:n:b:c:e:m:sh' opt; do
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
            s)
                ndb_restore_serial=1
                ;;
            ?|h)
                echo -e "Usage $(basename $0) restore_schema -p ARG -n ARG -b ARG -c ARG -m ARG [-e ARG]\n\t-p: Path to backup directory\n\t-n: Node id to restore\n\t-b: Backup id to restore\n\t-c: Connection to Management server ip_address:port\n\t-m: Restore mode\n\t\tMETA for restoring only metadata\n\t\tDATA for restoring data\n\t-s: Force restore multiple parts serially\n\t-e: OPTIONALLY exclude some comma-sperated tables"
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
        if [ $ndb_restore_serial ]; then
            _log_info "Restoring multiparts serially"

            # If there was a single LDM thread to take the backup
            # then the backup files whould be directly under BACKUP-{ID}
            # and we should NOT iterate over any subdirectory
            if [ -n "$(find $ndb_backup_path -mindepth 1 -type d)" ]; then
                for d in ${ndb_backup_path}/*/
                do
                    backup_dirs+=($d)
                    # when restoring metadata we only need to restore one part
                    break
                done
            else
                backup_dirs=($ndb_backup_path)
            fi
        else
            _log_info "Restoring multiparts in parallel"
            backup_dirs=($ndb_backup_path)
        fi

        for d in "${backup_dirs[@]}"
        do
            _log_info "Restoring METADATA backup id $backup_id from node $node_id from path $d excluding tables $exclude_tables"
            $NDB_RESTORE --ndb-connectstring=$mgm_connection --nodeid=$node_id --backupid=$backup_id --backup_path=$d $exclude_tables --restore-meta --disable-indexes >> $log_file 2>&1
        done
        _log_info "Finished restoring METADATA"
    elif [ "$ndb_restore_op" == "DATA" ]; then
        if [ $ndb_restore_serial ]; then
            _log_info "Restoring multiparts serially"
            # If there was a single LDM thread to take the backup
            # then the backup files whould be directly under BACKUP-{ID}
            # and we should NOT iterate over any subdirectory
            if [ -n "$(find $ndb_backup_path -mindepth 1 -type d)" ]; then
                for d in ${ndb_backup_path}/*/
                do
                    backup_dirs+=($d)
                done
            else
                backup_dirs=($ndb_backup_path)
            fi
        else
            _log_info "Restoring multiparts in parallel"
            backup_dirs=($ndb_backup_path)
        fi

        for d in "${backup_dirs[@]}"
        do
            _log_info "Restoring DATA backup id $backup_id from node $node_id from path $d excluding tables $exclude_tables"
            $NDB_RESTORE --ndb-connectstring=$mgm_connection --nodeid=$node_id --backupid=$backup_id --backup_path=$d $exclude_tables --restore-data >> $log_file 2>&1
        done
        _log_info "Finished restoring DATA"
    elif [ "$ndb_restore_op" == "REBUILD-INDEXES" ]; then
        _log_info "Rebuilding INDEXES"
        $NDB_RESTORE --ndb-connectstring=$mgm_connection --nodeid=$node_id --backupid=$backup_id --backup_path=$ndb_backup_path --rebuild-indexes >> $log_file 2>&1
        _log_info "Finished rebuilding indexes"
    fi
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

echo "ndb_restore $NDB_RESTORE"
echo "mysql-client $MYSQL_CLIENT"

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